public class CESUtilities{
    
    /* *** REMOVED - NEVER BECAME PRODUCTION PROCESS
    public static void CheckPriceTargets(list<CESContract__c> records){
        list <CESContract__c> stuffToUpdate = new list <CESContract__c> ();
        for (CESContract__c cesc:records){
            if (cesc.strike_control__c && (cesc.Fixed_Price_Maximum_Target__c!=null || cesc.Price_Target__c!=null) && cesc.Fixed_Price_Target_Notifications_On__c){
                ApexPages.StandardController sc = new ApexPages.standardController(cesc);
                FixedPriceQuoteController fpqc = new FixedPriceQuoteController(sc);
                
                fpqc.LiveMarket=true;
    			fpqc.DoVolumes();
                fpqc.lock.Price_at_Last_Check__c=fpqc.WACOGPosition.Customer_Price__c.setscale(4);
                fpqc.lock.Last_Fixed_Price_Target_Check__c=system.now();
                fpqc.lock.strike_control__c=false;
                stuffToUpdate.add(fpqc.lock);
            }
        }
        update stuffToUpdate;
    }
	*/

    public static list<Position__c> FillPositionsWithoutSave(CESContract__c cesc, boolean setSyncProperties){
        return CESContractUtils.FillPositionsWithoutSave(cesc, setSyncProperties);
    }

    /*private static Position__c CreatePosition(CESContract__c cesc, boolean setSyncProperties, date period, string zero){
        return CESContractUtils.CreatePosition(cesc, setSyncProperties, period, zero);
    }*/

    public static list<Position__c> FillPositionsWithoutSave1(CESContract__c cesc, boolean setSyncProperties){
        return CESContractUtils.FillPositionsWithoutSave1(cesc, setSyncProperties);
    }
	/*
	private static void FillPositions(CESContract__c cesc, boolean setSyncProperties){
        CESContractUtils.FillPositions(cesc, setSyncProperties);
    }

    private static void ConvertMonthlyPositionsToDaily(list<Position__c> pos){
        CESContractUtils.ConvertMonthlyPositionsToDaily(pos);
    }*/
    	
    private static void SplitMultiFacilityListFixedPriceContracts(CESContract__c cesc){
        
        list<CESContract__c> kids = new list<CESContract__c>();
        
        for(string s:cesc.List_of_Facility_Lists__c.split(',')){
            CESContract__c kid = cesc.clone();
            kid.List_of_Facility_Lists__c = null;
            kid.Facility_List__c = [select id from Facility_List__c where name =: s].id;
            kids.add(kid);
        }  
        insert kids;
        
        //create the map of usage maps
        map<id, list<CESUtilities.UsageTable>> UsageMap = new map<id, list<CESUtilities.UsageTable>>();
        
        //build the usage table (weather and historical average by calendar month
        for (CESContract__c kid:kids){
            UsageMap.put(kid.Facility_List__c, makeUsageSummary( new set<facility_list__c>([select id from Facility_List__c where id =: kid.Facility_List__c]) ));
        }
      
        list<position__c> AllocatedPositions = new list<position__c>();
        for (position__c p:[select id, volume__c from position__c where ces_contract__c =: cesc.id]){
            for (CESContract__c kid:kids){
                position__c pchild = p.clone();
                pchild.ces_contract__c = kid.id;
                if (kid.Volume_Calculation_Method__c == 'Weather Normalized'){
                    for(CESUtilities.UsageTable UT:usagemap.get(kid.Facility_List__c)){
                        if (UT.startmonth.month()==pchild.Contract_Month__c.month()){
                        	pchild.Volume__c = (p.volume__c*(ut.weatherized/p.Weatherized_Volume__c)).setscale(0);
                        }
                    }
                } else if (kid.Volume_Calculation_Method__c == 'Historical Average'){
                    for(CESUtilities.UsageTable UT:usagemap.get(kid.Facility_List__c)){
                        if (UT.startmonth.month()==pchild.Contract_Month__c.month()){
                            pchild.Volume__c = (p.volume__c*(ut.hist/p.historical_volume__c)).setscale(0);
                        }
                    }
                }
                AllocatedPositions.add(pchild);
            }
        }
        //if the contract is motnhly, go through the kids and do the WACOG for each one
        insert AllocatedPositions;
        
        for (CESContract__c kid:kids){ //submit them all
            // Create an approval request
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setObjectId(kid.id);
            
            // Submit the approval request for the account
            Approval.ProcessResult result = Approval.process(req1);
        }
        
		cesc.Contract_Status__c = 'dead';
        update cesc;
    }
    
    
    
    public static list<CESUtilities.UsageTable> makeUsageSummary(set<Facility_List__c> AllSelectedFL){
        
        list<CESUtilities.UsageTable> UsageSummary = new list<CESUtilities.UsageTable>();
        list<CESUtilities.UsageTable> UsageOutput = new list<CESUtilities.UsageTable>();
        
        map<date, decimal> histUsage = CESUtilities.getVolFromFL(AllSelectedFL);
        premises__c WP = new premises__c();
        try{
            WP = [select id, Location__Latitude__s, Location__Longitude__s from premises__c where facility_list__c in: AllSelectedFL limit 1][0];
        }catch (exception e){
            WP = new premises__c();
        }
        WeatherizedUsage WU = new WeatherizedUsage('gas', histusage, WP);
        map<integer, decimal> WeatherUsage=WU.NormalizedUsage;

        list<date> keyset = new list<date>();
        keyset.addall(histUsage.keyset());
        keyset.sort();        
        for (date d:keyset){
            UsageOutput.add(new CESUtilities.UsageTable(d, histusage.get(d), 0));            
        }
        for (integer k=1; k<13; k++){
            decimal monthTotal=0;
            integer monthCount=0;
            for (date d:histUsage.keyset()){
                if (d.month()==k) {
                    monthTotal=monthTotal+histusage.get(d);
                    monthCount=monthCount+1;
                }
            }
            if (monthCount!=0)          
                UsageSummary.add(new CESUtilities.UsageTable(date.newinstance(system.today().year(), k, 1), monthtotal/monthcount, WeatherUsage.get(k)));
        }  
        return usageSummary;
        
    }
    
    public static map<date, decimal> getVolFromFL(set<facility_list__c> FLs){
        system.debug('in getVolfromFL with FL ' + fLs);
        map<date, decimal> output = new map<date, decimal>();
        list<AggregateResult> Totals = [select Start_Date__c, sum(Usage__c) vol 
                                        from Monthly_Usage__c 
                                        where premise__r.facility_list__c in:FLs
                                        group by Start_Date__c order by Start_Date__c DESC limit 36];
        for (AggregateResult aR:Totals){
            output.put(date.valueof(ar.get('Start_Date__c')), integer.valueof(ar.get('vol')));  
        }
        //find premises that have zeroes in the calculations
        return output;
        
    }

    public static map<date, decimal> getVolFromPremises(set<Id> premIdSet){
        map<date, decimal> output = new map<date, decimal>();
        list<AggregateResult> Totals = [select Start_Date__c, sum(Usage__c) vol 
                                        from Monthly_Usage__c 
                                        where premise__c in:premIdSet
                                        group by Start_Date__c order by Start_Date__c DESC limit 36];
        for (AggregateResult aR:Totals){
            output.put(date.valueof(ar.get('Start_Date__c')), integer.valueof(ar.get('vol')));  
        }
        //find premises that have zeroes in the calculations
        return output;
        
    }
    
    public class UsageTable {
        public date startmonth{Get;set;}
        public decimal hist{Get;set;}
        public decimal weatherized{Get;set;}
        public UsageTable(date d, decimal h, decimal w){
            startmonth=d;
            hist=h;
            weatherized=w;
        	system.debug('on Date ' + startmonth + 'Weatherized was ' + weatherized + ' and historical was '+hist);
        }
    }
    
    public static map<date, decimal> getCurrentNymex(){
        map<date, decimal> output = new map<date, decimal>();
        list<index_future__c> IndexFutures = [select id, name, delivery_date__c, index__r.name, price__c
                                                from index_future__c
                                                where index__r.name = 'NYMEX'
                                                and delivery_date__c>:system.today() 
                                                and delivery_date__c<:system.today().addmonths(36)
                                                order by index__r.name ASC, delivery_date__c ASC];
        for (index_future__c IndexFuture:IndexFutures){            
            output.put(IndexFuture.delivery_date__c,indexFuture.price__c);
        }
        system.debug(logginglevel.Error, 'Output is ' + output);
        return output;
    }

    public static map<date, decimal> getCurrentNymexWithAdder(){
        map<date, decimal> output = new map<date, decimal>();
        list<index_future__c> IndexFutures = [select id, name, delivery_date__c, index__r.name, price__c, index__r.Index_cost__c
                                                from index_future__c
                                                where index__r.name = 'NYMEX'
                                                and delivery_date__c>:system.today() 
                                                and delivery_date__c<:system.today().addmonths(36)
                                                order by index__r.name ASC, delivery_date__c ASC];
        for (index_future__c IndexFuture:IndexFutures){            
            output.put(IndexFuture.delivery_date__c,indexFuture.price__c + IndexFuture.index__r.Index_cost__c);
        }
        system.debug(logginglevel.Error, 'Output is ' + output);
        return output;
    }

    public static map<date, decimal> getPastNYMEX(date d){
        map<date, decimal> output = new map<date, decimal>();
        list<Index_Future_Tracking__c> IndexFutures = [select id, name, delivery_date__c, index_parent__r.name, value__c
                                                from Index_Future_Tracking__c
                                                where index_parent__r.name = 'NYMEX'
                                                and delivery_date__c>:system.today() 
                                                and delivery_date__c<:system.today().addmonths(36)
                                                and As_of_date__c =: d       
                                                order by delivery_date__c ASC];
        for (Index_Future_Tracking__c IndexFuture:IndexFutures){            
            output.put(IndexFuture.delivery_date__c,indexFuture.value__c);
        }
        system.debug(logginglevel.Error, 'Output is ' + output);
        return output;
    }

    public class PremiseUsageDetail {
        public Premises__c prem{Get;set;}
        public decimal usage{get;set;}
        public boolean usageGap{Get;set;}
        public integer usageCount{get;set;}
        public decimal defaultPctg{get;set;}
        public decimal pctg{get;set;}

        public PremiseUsageDetail(Premises__c p, decimal u, boolean e, integer uc, decimal dp, decimal pc){
            prem=p;
            usage=u;
            usageGap=e;
            usageCount=uc;
            defaultPctg=dp;
            pctg=pc;
        }
    }

    public class PremiseWithFlag 
    {
        public Premises__c prem {get;set;}
        public boolean isSelected {get;set;}
        
        public PremiseWithFlag(Premises__c inPrem){
            prem = inPrem;
            isSelected=true;
        }
    }

    public class PremiseWithUsagePaste{
        public Premises__c prem {get;set;}
        public string paste {get;set;}
        public list<Monthly_Usage__c> usageList {get;set;}
        public Integer position {get;set;}
        public boolean usageCreated {get;set;}

        public PremiseWithUsagePaste(Premises__c inPrem){
            prem = inPrem;
            position = null;
            usageCreated = false;
            paste = null;
            usageList = new list<Monthly_Usage__c>();
        }
    }

//*****************************************************************************
//*** HELPER METHODS **********************************************************
//*****************************************************************************
    /*
    public static string BuildDynamicStatus(Premise_Status__c ps){
        return 'Going ' + ps.Status__c + ' on ' + ps.Status_Date__c.month() + '-' + 
            ps.Status_Date__c.day() + '-' + ps.Status_Date__c.year();
    }
    
    public static AsyncRequest__c CreateAsyncRequest(Premise_Status__c ps){
        AsyncRequest__c req = new AsyncRequest__c(Type__c='ProcessFuturePremiseStatusNowCurrent',Params__c=ps.Id,Process_Date__c=ps.Status_Date__c,Queueable__c=true);
        return req;
    }
    
    public static AsyncRequest__c CreateUpcomingStatusAsyncRequest(Premise_Status__c ps){
        AsyncRequest__c req = new AsyncRequest__c(Type__c='ProcessUpcomingPremiseStatus',Params__c=ps.Id,Queueable__c=true);
        return req;
    }
    */
    // Returns a dynamic SOQL statement for the whole object, includes only creatable fields since inserting a cloned result of this query
    public static string getObjectFieldsSOQL(String objectName, String whereClause, String orderByClause){
         
        String selects = '';
         
        if (whereClause == null || whereClause == ''){ return null; }
        if (orderByClause == null || orderByClause == ''){
            orderByClause = '';
        }else{
            orderByClause = ' ORDER BY ' + orderByClause;
        }
         
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();
         
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                if (fd.getName()!='Location__c'){
                    // do not add the field if it is location__c since it creates an exception for some reason
                    selectFields.add(fd.getName());
                }
            }
        }
         
        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                selects += s + ',';
            }
            if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}
             
        }
         
        return 'SELECT ' + selects + ' FROM ' + objectName + ' WHERE ' + whereClause + orderByClause;
         
    }

    public static boolean getSafariSyncSetting(string office){
        SafariSyncSettings__c syncSetting = SafariSyncSettings__c.getOrgDefaults();
        boolean setting = false;
        if (office == 'HOU'){
            setting = syncSetting.To_HOU__c;
        } else if (office == 'LIVE'){
            setting = syncSetting.To_LIVE__c;
        } else if (office == 'MPLS'){
            setting = syncSetting.To_MPLS__c;
        } else if (office == 'STL'){
            setting = syncSetting.To_STL__c;
        }

        return setting;
    }

    public static boolean getManageMarginSetting(){
        CIMarginCalcInputs__c marginSettings = CIMarginCalcInputs__c.getOrgDefaults();
        return marginSettings.Manage_Margin__c;
    }

    public static string ProcessUsageUploadFile(Blob rawFile, map<string, Id> premIdMap){
        string nameFile;
        string[] fileLines = new string[]{};
        list<Monthly_Usage__c> usageToInsert = new list<Monthly_Usage__c>();

        nameFile = rawFile.toString();
        fileLines = nameFile.split('\n');
        try {
            for (integer i=1; i < fileLines.size(); i++){
                id premId;
                string entryType;
                string sDate;
                date startDate;
                string[] lineValues = new string[]{};
                lineValues = fileLines[i].split(',');
                //system.debug('acctnbr: ' + lineValues[0] + ', date: ' + lineValues[5] + ', entryType: ' + lineValues[3]);
                sDate = lineValues[5];
                if (sDate != ''){
                    startDate = date.parse(sDate);
                    entryType = lineValues[2];
                    try {
                        premId = premIdMap.get(lineValues[0]);
                    } catch (exception e){ premId = null;}

                    if (premId != null){
                        Monthly_Usage__c u = new Monthly_Usage__c();
                        u.Premise__c = premId;
                        u.Start_Date__c = startDate;
                        u.Volume_Entry_Type__c = entryType;
                        if (entryType=='Daily'){
                            u.End_date__c = startDate;
                        } else {
                            u.End_date__c = startDate.addMonths(1).addDays(-1);
                        }
                        u.Month_Number__c = startDate.month();
                        u.Usage__c = decimal.valueOf(lineValues[3]);
                        usageToInsert.add(u);
                    }
                }
                premId = null; entryType = null; sDate = null; startDate = null;

            }
            if (usageToInsert.size()>0){ insert usageToInsert; }
        } catch (exception e){return e.getMessage();}

        return null;
    }

    public static list<Monthly_Usage__c> ConvertUsagePasteToRecords(PremiseWithUsagePaste pwu){
        string[] fileLines = new string[]{};
        list<Monthly_Usage__c> usageToInsert = new list<Monthly_Usage__c>();

        fileLines = pwu.paste.split('\n');
        system.debug(fileLines);
        
        try {
            for (integer i=0; i < fileLines.size(); i++){
                string sDate;
                date startDate;
                string[] lineValues = new string[]{};
                lineValues = fileLines[i].split('\t');
                system.debug(lineValues.size());
                system.debug(lineValues);
                system.debug('month: ' + lineValues[0] + ', volume: ' + lineValues[1]);
                
                sDate = CheckDateFormat(lineValues[0]);
                system.debug(sDate);
                if (sDate != ''){
                    startDate = date.parse(sDate);
                    system.debug(startDate);

                    if (pwu.prem.Id != null){
                        Monthly_Usage__c u = new Monthly_Usage__c();
                        u.Premise__c = pwu.prem.Id;
                        u.Start_Date__c = startDate;
                        u.Volume_Entry_Type__c = 'Monthyly';
                        u.End_date__c = startDate.addMonths(1).addDays(-1);
                        
                        u.Month_Number__c = startDate.month();
                        u.Usage__c = decimal.valueOf(lineValues[1]);
                        usageToInsert.add(u);
                    }
                }
                sDate = null; startDate = null;
            }
            //if (usageToInsert.size()>0){ insert usageToInsert; }
        } catch (exception e){}//return e.getMessage();}

        return usageToInsert;        
    }

    public static string CheckDateFormat(string inDateStr){
        map<String, String> monthMap = new map<String, String>();
        String mth = null;

        monthMap.put('Jan','1');
        monthMap.put('Feb','2');
        monthMap.put('Mar','3');
        monthMap.put('Apr','4');
        monthMap.put('May','5');
        monthMap.put('Jun','6');
        monthMap.put('Jul','7');
        monthMap.put('Aug','8');
        monthMap.put('Sep','9');
        monthMap.put('Oct','10');
        monthMap.put('Nov','11');
        monthMap.put('Dec','12');

        try {
            mth = (String)monthMap.get(inDateStr.left(3));
        } catch (exception e){mth = null;}

        if (mth == null){
            return inDateStr.replaceAll('-', '/');
        } else {
            mth = mth + '-1' + inDateStr.right(inDateStr.length() - 3);
            return mth.replaceAll('-', '/');
        }
    }
    
    public static void CloseOpportunityFromContract(id contractId){
        cesContract__c cesc = [select id, opportunity__c, contract_status__c from cesContract__c where id=:contractId];

        opportunity o=[select StageName, Opty_Peak_Daily_Volume__c, Opty_Credit_Price__c from opportunity where id=:cesc.opportunity__c]; 
        o.StageName = 'Closed Won';
        if (o.Opty_Peak_Daily_Volume__c == null) {o.Opty_Peak_Daily_Volume__c = 0;}
        if (o.Opty_Credit_Price__c == null) {o.Opty_Credit_Price__c = 0;}
        update o;
    
    } 

    public list<String> getPickListValues(string oType, string fType){
        list<String> pls = new list<String>();
        list<Schema.PickListEntry> lst = new list<Schema.PickListEntry>();
        lst = getPicklistEntryValues(oType, fType);

        for (Schema.PicklistEntry pl:lst){
            pls.add(pl.getLabel());
        }

        return pls;
    }

    public list<Schema.PickListEntry> getPicklistEntryValues(string oType, string fType){
        //use GlobalDecribe to get a list of all available Objects
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Set<String> objectKeys = gd.keySet();
        for(String objectKey: objectKeys)
        {
            //Iterate through all objects to locate object by variable
            if (objectKey == oType)
            {
                Schema.SObjectType systemObjectType = gd.get(objectKey);
                Schema.DescribeSObjectResult r = systemObjectType.getDescribe();
                Map<String, Schema.SObjectField> M = r.fields.getMap();
                Set<String> fieldNames = M.keySet();
                 //iterate through all fields of the object to locate the field
                for(String fieldName: fieldNames)
                {
                    if (fieldName == fType)//match field name
                    {
                        Schema.SObjectField field = M.get(fieldName);
                        Schema.DescribeFieldResult fieldDesc = field.getDescribe();
                        //extract the picklist values
                        //System.debug(fieldDesc.getPicklistValues() + ' ::::::::::::::::::::::::::::::::::: ') ;
                        return fieldDesc.getPickListValues();
                    }
                }
            }
          }
          
          return null;
    }

    public static map<Id, String> getOfficeCodeMap(){
        list<Account> offs = new list<Account>();
        map<Id, String> offCodeMap = new map<Id, String>();

        //get office list and make a map
        offs = [select id, name, Customer_Number__c from Account where Record_Type_Name__c =: 'CES_Location' and name like 'CES%' order by Customer_Number__c];
        for (Account o:offs){
            offCodeMap.put(o.id, o.Customer_Number__c);
        }

        return offCodeMap;
    }

    public static Map<String, Schema.sObjectField> getObjectFieldMap(string oName){
        //get object type and fields for change comparison
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(oName);
        Map<String, Schema.sObjectField> targetFields = targetType.getDescribe().fields.getMap();
        return targetFields;
    }

    public static list<Credit_Request__c> QueryQualifiedCreditRequests(id acct, string crit){
        list<Credit_Request__c> crs = new list<Credit_Request__c>();
        list<AccountPartner> aps = new list<AccountPartner>();
        set<Id> acctSet = new set<Id>();

        crit = '%'+crit+'%';

        Account a = [select id, name, ParentId from Account where id=:acct];
        acctSet.add(a.id);

        // look for parent
        if (a.ParentId != null){
            acctSet.add(a.ParentId);
        }

        // look for partner accounts
        aps = [select AccountFromId, AccountToId from AccountPartner where AccountFromId=:acct];
        if (aps.size()>0){
            for (AccountPartner ap:aps){
                acctSet.add(ap.AccountToId);
            }
        }

        crs = [select Id, Name, Long_Credit_Name__c from Credit_Request__c 
                where (Search_Code__c like: crit OR Long_Credit_Name__c like: crit) and Credit_Request_Status__c = 'Credit Decision - Limit Approved' and Account__c in:acctSet
                order by Long_Credit_Name__c, Estimated_Start_Date__c desc];

        return crs;
    }

    public static void ContactBeforeUpdateTrigger(list<Contact> cons, map<Id, Contact> oldmap){
        /* *** REMOVED FOR PHASE 3 ***  all this code did was create record processing records to push data syncs for records related to the contact
        set<Id> conIdSet = new set<Id>();
        list<Record_Processing__c> procsToInsert = new list<Record_Processing__c>();
        list<Premises__c> prems = new list<Premises__c>();
        list<Bill_Group__c> bills = new list<Bill_Group__c>();
        list<Account> accts = new list<Account>();

        for (Contact c:cons){
            Contact oldc = oldmap.get(c.id);
            if (c.LastName != oldc.LastName || c.FirstName != oldc.FirstName || c.Email != oldc.Email || c.Fax != oldc.Fax || c.Phone != oldc.Phone){
                conIdSet.add(c.id);
            }
        }

        if (conIdSet.size() >0){
            // look for premises with this contact assigned
            prems = [select id, name, Safari_Premise_Key__c, Premise_Primary_Contact__c from Premises__c where Premise_Primary_Contact__c in: conIdSet and Safari_Premise_Key__c != null];

            if (prems.size() > 0){
                // create update record processings
                for (Premises__c p:prems){
                    if (!p.Safari_Premise_Key__c.startsWith('Pending')){
                        Record_Processing__c proc = new Record_Processing__c(Premise__c=p.id, External_ID__c=p.Safari_Premise_Key__c, Object_Type__c='Premises__c', Operation_Type__c='Update');
                        procsToInsert.add(proc);
                    }
                }
            }

            // look for bill groups with this contact assigned
            bills = [select id, name, Safari_ID__c, Billing_Contact__c from Bill_Group__c where Billing_Contact__c in: conIdSet and Safari_ID__c != null];

            if (bills.size() >0){
                // create update record processings
                for (Bill_Group__c b:bills){
                    if (!b.Safari_ID__c.startsWith('Pending')){
                        Record_Processing__c proc = new Record_Processing__c(Bill_Group__c=b.id, External_ID__c=b.Safari_ID__c, Object_Type__c='Bill_Group__c', Operation_Type__c='Update');
                        procsToInsert.add(proc);
                    }
                }
            }

            // *** query each office's accounts individually to only get records assigned to the contacts that have changed ***
            // look for HOU accounts with this contact assigned
            accts = [select id, name, HOU_ID__c, Primary_Safari_Contact__c, Live_ID__c, Primary_Safari_LIVE_Contact__c, MPLS_ID__c, Primary_Safari_MPLS_Contact__c, STL_ID__c, Primary_Safari_STL_Contact__c 
                        from Account where (Primary_Safari_Contact__c in: conIdSet and HOU_ID__c != null and HOU_ID__c != 'Pending-HOU')];

            if (accts.size() >0){
                // create update record processings
                for (Account a:accts){
                    // add update to record processing for each safari database connected to this account
                    Record_Processing__c proc = new Record_Processing__c(Account__c=a.id, External_ID__c='HOU-'+a.HOU_ID__c, Object_Type__c='Account', Operation_Type__c='Update');
                    procsToInsert.add(proc);
                }
            }

            // look for LIVE accounts with this contact assigned
            accts = [select id, name, HOU_ID__c, Primary_Safari_Contact__c, Live_ID__c, Primary_Safari_LIVE_Contact__c, MPLS_ID__c, Primary_Safari_MPLS_Contact__c, STL_ID__c, Primary_Safari_STL_Contact__c 
                        from Account where (Primary_Safari_LIVE_Contact__c in: conIdSet and Live_ID__c != null and Live_ID__c != 'Pending-LIVE')];

            if (accts.size() >0){
                // create update record processings
                for (Account a:accts){
                    // add update to record processing for each safari database connected to this account
                    Record_Processing__c proc = new Record_Processing__c(Account__c=a.id, External_ID__c='LIVE-'+a.Live_ID__c, Object_Type__c='Account', Operation_Type__c='Update');
                    procsToInsert.add(proc);
                }
            }

            // look for MPLS accounts with this contact assigned
            accts = [select id, name, HOU_ID__c, Primary_Safari_Contact__c, Live_ID__c, Primary_Safari_LIVE_Contact__c, MPLS_ID__c, Primary_Safari_MPLS_Contact__c, STL_ID__c, Primary_Safari_STL_Contact__c 
                        from Account where (Primary_Safari_MPLS_Contact__c in: conIdSet and MPLS_ID__c != null and MPLS_ID__c != 'Pending-MPLS')];

            if (accts.size() >0){
                // create update record processings
                for (Account a:accts){
                    // add update to record processing for each safari database connected to this account
                    Record_Processing__c proc = new Record_Processing__c(Account__c=a.id, External_ID__c='MPLS-'+a.MPLS_ID__c, Object_Type__c='Account', Operation_Type__c='Update');
                    procsToInsert.add(proc);
                }
            }

            // look for STL accounts with this contact assigned
            accts = [select id, name, HOU_ID__c, Primary_Safari_Contact__c, Live_ID__c, Primary_Safari_LIVE_Contact__c, MPLS_ID__c, Primary_Safari_MPLS_Contact__c, STL_ID__c, Primary_Safari_STL_Contact__c 
                        from Account where (Primary_Safari_STL_Contact__c in: conIdSet and STL_ID__c != null and STL_ID__c != 'Pending-STL')];

            if (accts.size() >0){
                // create update record processings
                for (Account a:accts){
                    // add update to record processing for each safari database connected to this account
                    Record_Processing__c proc = new Record_Processing__c(Account__c=a.id, External_ID__c='STL-'+a.STL_ID__c, Object_Type__c='Account', Operation_Type__c='Update');
                    procsToInsert.add(proc);
                }
            }

            if (procsToInsert.size() > 0){insert procsToInsert;}
        }
		*/
    }


//*****************************************************************************
//*****************************************************************************
/*** THESE METHODS MOVED TO SEPARATE CLASSES ***/
//*****************************************************************************
//*****************************************************************************

//*****************************************************************************
//*** CONTRACT MARGIN AND RENEWAL BATCH METHODS *******************************
//*****************************************************************************

    //*****************************************************************************
    //*** CONTRACT RENEWAL BATCH METHODS ******************************************
    //*****************************************************************************
    public static void RolloverBatchDetailContract(id detailId){
        ContractMarginAndRenewal.RolloverBatchDetailContract(detailId);
    }

    public static integer RollContractPremises(id cescid, date currEndDate, date endDate){
        return ContractMarginAndRenewal.RollContractPremises(cescid, currEndDate, endDate);
    }

    public static integer RollContractPositions(id cescId, date startdate, integer term, boolean volumeRequired){
        return ContractMarginAndRenewal.RollContractPositions(cescId, startdate, term, volumeRequired);
    }

    public static void CheckContractRenewalBatchStatus(id batchId){
        ContractMarginAndRenewal.CheckContractRenewalBatchStatus(batchId);
    }

    //*****************************************************************************
    //*** CONTRACT MARGIN METHODS *************************************************
    //*****************************************************************************

    //*** Create margin terms for contract ***
    public static list<Contract_Margin__c> GenerateContractMarginTerms(CESContract__c cesc, Date startdate, Date enddate, list<Premises__c> prems, id batchDetailID){
        return ContractMarginAndRenewal.GenerateContractMarginTerms(cesc, startdate, enddate, prems, batchDetailID);
    }

    public static list<Premises__c> GetContractMarginPremises(id flId){
        return ContractMarginAndRenewal.GetContractMarginPremises(flId);
    }

    public static list<ContractMarginAndRenewal.PremiseMargins> GetExistingPremiseMarginRecords(id cescId, set<Id> premIdSet, list<Premises__c> premsToPass){
        return ContractMarginAndRenewal.GetExistingPremiseMarginRecords(cescId, premIdSet, premsToPass);
    }

    public static list<Contract_Margin__c> ConstructContractMarginTerms(CESContract__c cesc, date startdate, date enddate, list<ContractMarginAndRenewal.PremiseMargins> pMarginObjects, map<string, set<Id>> conMarginPremIgnoreMap, id batchDetailID, integer premCount){
        return ContractMarginAndRenewal.ConstructContractMarginTerms(cesc, startdate, enddate, pMarginObjects, conMarginPremIgnoreMap, batchDetailID, premCount);
    }

    public static list<Premise_Margin__c> ConstructPremiseMarginRecordsWithoutIgnores(list<Contract_Margin__c> conMargins, map<string, set<Id>> conMarginPremIgnoreMap, list<Premises__c> premsToPass){
        return ContractMarginAndRenewal.ConstructPremiseMarginRecordsWithoutIgnores(conMargins, conMarginPremIgnoreMap, premsToPass);
    }

    public static set<Id> FindMatchingPremiseMarginTerms(list<ContractMarginAndRenewal.PremiseMargins> pmOs, date startdate, date enddate){
        return ContractMarginAndRenewal.FindMatchingPremiseMarginTerms(pmOs, startdate, enddate);
    }

    public static Contract_Margin__c addContractMarginRecord(CESContract__c cesc, date StartDate, date EndDate, integer Term, id batchDetailID){
        return ContractMarginAndRenewal.addContractMarginRecord(cesc, StartDate, EndDate, Term, batchDetailID);
    }    

    public static list<Premise_Margin__c> addPremiseMarginRecords(Contract_Margin__c conMargin, list<Premises__c> prems, set<Id> ignoreSet){
        return ContractMarginAndRenewal.addPremiseMarginRecords(conMargin, prems, ignoreSet);
    }

    //*** process the margin terms and populate volume and margin totals ***
    public static integer ProcessPendingContractMargin(Contract_Margin__c conMargin){
        return ContractMarginAndRenewal.ProcessPendingContractMargin(conMargin);
    }

//*****************************************************************************
//*** SYNC BATCH **************************************************************
//*****************************************************************************

    public static void CheckRecordsToSyncExist(string office){
        CESDataSyncUtilities.CheckRecordsToSyncExist(office);
    }

    public static id CreateSyncBatch(id office){
        return CESDataSyncUtilities.CreateSyncBatch(office);
    }

    public static void CreateSyncBatchAccount(id acct, id batch){
        CESDataSyncUtilities.CreateSyncBatchAccount(acct, batch);
    }

    public static void ScheduleRecordLock(list<Id> oIds){
        CESDataSyncUtilities.ScheduleRecordLock(oIds);
    }

    public static void ProcessRecordLock(id oId){
        CESDataSyncUtilities.ProcessRecordLock(oId);
    }
    

//*****************************************************************************
//*** TRIGGER METHODS *********************************************************
//*****************************************************************************
    
    //*****************************************************************************
    //*** ACCOUNT *****************************************************************
    //*****************************************************************************
    public static void CheckAccountDuplicateStatus(list<Account> accts, map<id, Account> oldmap){
        AccountUtils.CheckAccountDuplicateStatus(accts, oldmap);
    }

    public static void AccountAfterUpsertProcess(list<Account> accts, map<id, Account> oldmap, boolean isDelete){
        AccountUtils.AccountAfterUpsertProcess(accts, oldmap, isDelete);
    }

    //*****************************************************************************
    //*** PREMISE *****************************************************************
    //*****************************************************************************
    /* *** REMOVED from PremiseUtils FOR PHASE 3
    public static void CIPremiseAfterInsertProcess(list<Premises__c> prems){
        PremiseUtils.CIPremiseAfterInsertProcess(prems);
    }
	*/
    /* *** REMOVED from PremiseUtils FOR PHASE 3
    public static void CIPremiseBeforeUpdateProcess(list<Premises__c> prems, map<id, Premises__c> oldmap){
        PremiseUtils.CIPremiseBeforeUpdateProcess(prems, oldmap);
    }
	*/
    
    //*****************************************************************************
    //*** PPREMISE STATUS *********************************************************
    //*****************************************************************************
    public static void CIPremiseStatusDeleteProcess(list<Premise_Status__c> stats){
        PremiseUtils.CIPremiseStatusDeleteProcess(stats);
    }

    public static void CIPremiseStatusAfterProcess(list<Premise_Status__c> stats){
    	PremiseUtils.CIPremiseStatusAfterProcess(stats);
    }

    //*****************************************************************************
    //*** PREMISE LIST ************************************************************
    //*****************************************************************************
    /* REMOVED from PremiseUtils FOR PHASE 3
    public static void CIPremiseListDeleteProcess(list<Premise_List__c> lsts){
        PremiseUtils.CIPremiseListDeleteProcess(lsts);
    }
	*/
    /* REMOVED from PremiseUtils FOR PHASE 3
    public static void CIPremiseListAfterUpdateProcess(list<Premise_List__c> lsts, map<id, Premise_List__c> oldmap){
        PremiseUtils.CIPremiseListAfterUpdateProcess(lsts, oldmap);
    }
	*/
    //*****************************************************************************
    //*** CES CONTRACT ************************************************************
    //*****************************************************************************
    public static void CESContractBeforeUpsertProcess(list<CESContract__c> CESCs, map<id, CESContract__c> oldmap){
        CESContractUtils.CESContractBeforeUpsertProcess(CESCs, oldmap);
    }

    public static void CESContractAfterUpdateProcess(list<CESContract__c> CESCs, map<id, CESContract__c> oldmap){
        CESContractUtils.CESContractAfterUpdateProcess(CESCs, oldmap);
    }

    public static void CESContractBeforeDeleteProcess(list<CESContract__c> CESCs){
        CESContractUtils.CESContractBeforeDeleteProcess(CESCs);
    }

    public static void CheckContractPendingSafariSyncStatus(list<CESContract__c> contracts)
    {
        
    }

    //*****************************************************************************
    //*** POSITION ****************************************************************
    //*****************************************************************************
    public static void PositionBeforeDeleteProcess(list<Position__c> pos){
        CESContractUtils.PositionBeforeDeleteProcess(pos);
    }

    public static void PositionAfterUpsertProcess(list<Position__c> pos, map<id, Position__c> oldmap){
        CESContractUtils.PositionAfterUpsertProcess(pos, oldmap);
    }

    public static void ReCalcPremiseMarginAfterChange(id pMarginId, id arId){
        ContractMarginAndRenewal.ReCalcPremiseMarginAfterChange(pMarginId, arId);
    }
	
    //*****************************************************************************
    //*** Quote *****************************************************************
    //*****************************************************************************
    /* BDM -- do not use this code, use the CESQuoteUtils class instead
    public static void QuoteBeforeInsertProcess(list<Quote> quotes){
        CESQuoteUtils.QuoteBeforeInsertProcess(quotes);
    }
	*/

//*****************************************************************************
//*** ASYNC PROCESSES ************************************************************
//*****************************************************************************
    //*** PREMISE STATUS ***
    public static void ProcessFuturePremiseStatusNowCurrentAsync(id premstatid){
        PremiseUtils.ProcessFuturePremiseStatusNowCurrentAsync(premstatid);
    }
    
    public static void ProcessUpcomingPremiseStatusAsync(id premstatid){
        PremiseUtils.ProcessUpcomingPremiseStatusAsync(premstatid);
    }
    
    public static void ProcessUpcomingPremiseStatusDeleteAsync(id premid){
        PremiseUtils.ProcessUpcomingPremiseStatusDeleteAsync(premid);
    }

    //*** CONTRACT ***    
    public static void ProcessTCActivationAsync(id tcId){
        CESContractUtils.ProcessTCActivation(tcId);
    }

    public static void RottingContractRequestBulkAsync(){
        CESContractUtils.RottingContractRequestBulkAsync();
    }
    
    //*** PREMISE LIST ***
    public static void ProcessPremiseListActivationAsync(id cId){
        PremiseUtils.ProcessPremiseListActivationAsync(cId);
    }

    public static void ProcessFuturePremiseFacilityListNowCurrentAsync(id plistId){
        PremiseUtils.ProcessFuturePremiseFacilityListNowCurrentAsync(plistId);
    }

    public static void UpdateFuturePremListProcessDateAsync(id plistId){
        PremiseUtils.UpdateFuturePremListProcessDateAsync(plistId);
    }    

    public static void DeleteFuturePremListProcessAsync(id plistId){
        PremiseUtils.DeleteFuturePremListProcessAsync(plistId);
    }

    public static void ProcessPremiseListTermination(id pListId, date termDate){
        PremiseUtils.ProcessPremiseListTermination(pListId, termDate);
    }

    public static void CheckCurrentPremiseListAssignmentAsync(id plistId){
        PremiseUtils.CheckCurrentPremiseListAssignmentAsync(plistId);        
    }
}