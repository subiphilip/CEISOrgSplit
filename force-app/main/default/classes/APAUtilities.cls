global class APAUtilities {
    
    public class APAWrapper{        
        public string PremiseAddress{get;set;}
        public id APAid{get;set;}
        public boolean selected{Get;set;}
        public boolean DataPermission{Get;set;}
        public datetime createddate{Get;set;}
        public string PremiseType{get;set;}
        public boolean PublicData{get;set;}
        
        public APAWrapper(AccountPremiseAssociation__c APA){
            PublicData = APA.public_data__c;
            PremiseAddress = APA.premise__r.Electric_Service_Address__c;
            APAid = APA.id;
            selected = APA.selected__c;
            DataPermission = APA.meter_data_permission__c;
            createddate = APA.createddate;
            PremiseType = APA.premise__r.premise_type__c;
        
        }
    }
    
    public static AccountPremiseAssociation__c getActiveAPA(id user){
																	
        list<AccountPremiseAssociation__c> theActivelist=[select id, selected__c, public_data__c, premise__r.Electric_Service_Address__c, Customer_Selected_Profile__c, meter_data_permission__c,Meter_Data_Request_Status__c, premise__r.Electric_Service_Address_Zip__c, meter_data_estimated__c, account__c, account__r.id, premise__c, premise__r.id, premise__r.tdsp_lookup__c, premise__r.tdsp_lookup__r.id from AccountPremiseAssociation__c where account__r.id =: user and selected__c =: true order by LastModifiedDate DESC];
    	//return the active one.  If there are more than one selected (shame on us) then return the most recently modified selected one.
        if (theActivelist.size()>0){
           return theActivelist[0];
        } else {
           //if no active ones, return the most recently modified one? 
           list<AccountPremiseAssociation__c> thelist=[select id, selected__c, public_data__c, premise__r.Electric_Service_Address__c, Customer_Selected_Profile__c, meter_data_permission__c,Meter_Data_Request_Status__c, account__c, account__r.id, premise__c, premise__r.id, premise__r.tdsp_lookup__c, premise__r.tdsp_lookup__r.id from AccountPremiseAssociation__c where account__r.id =: user order by LastModifiedDate DESC ];
            if(thelist.size()>0) {
                return thelist[0];
            }
        }
        AccountPremiseAssociation__c empty = new AccountPremiseAssociation__c();
        return empty; //just in case nothing was found
        
    }
    
    public static list<AccountPremiseAssociation__c> GetAllAPAs (id user){
       list<AccountPremiseAssociation__c> thelist=[select id, public_data__c, createddate, selected__c, premise__r.premise_type__c, premise__r.Electric_Service_Address__c, Customer_Selected_Profile__c, meter_data_permission__c, account__c, account__r.id, premise__c, premise__r.id, premise__r.tdsp_lookup__c, premise__r.tdsp_lookup__r.id from AccountPremiseAssociation__c where account__r.id =: user order by selected__c DESC, LastModifiedDate DESC ];
       return thelist;
    }
    
    public static void makeapa(id acct, id premid){
        accountpremiseassociation__c newapa = new accountpremiseassociation__c(); 
        newapa.account__c=acct;
        newapa.premise__c=premid;
        newapa.selected__c=true;
        insert newapa;
        //TrueCostUtilities.grantMeterDataPermission(premid);  
        ChangeSelectedAPA (newapa.id, acct);
    }
    
    public static void ChangeSelectedAPA (id SelectedAPA, id whichAccount){       
        list<accountPremiseAssociation__C> APAlist = [select id, selected__c from accountPremiseAssociation__C where account__r.id=:whichAccount];
        //deactivate all but the selected one
        for (accountPremiseAssociation__C apa:APAlist ){
            if (apa.id!=SelectedAPA) {
                system.debug(apa.id + '===================is not the selected APA');
                apa.selected__c = false;
            }else {
                apa.selected__c = true;
                system.debug(apa.id + '===================We found the selected APA');
            }
            
        }
        update APAlist;  system.debug(apaList);
    }
        public static decimal GetMaxFromStringList(string stuff){
        //takes a list of comma separated values
        decimal output=0;
        //chop the string into a list
        for (string s:stuff.split(',', 0)){
            if (decimal.valueOf(s)>output) output = decimal.valueOf(s);
        }
        
        return output;
        
    }
    
           
    /*Webservice static string RequestIntervalData(id APAid){
        try{
            string CallType = 'Interval Data';
            id APApremid = [select premise__r.id from AccountPremiseAssociation__c where id=:APAid].id;
            list<premises__c> Premlist = [select id, meter_number__C, meter_data_permission__c, 
                              
                              Electric_Service_Address__c, ESID__c, Electric_Service_Address_City__c,  Electric_Service_Address_State2__c,Electric_Service_Address_Zip__c from premises__c where id=:APApremid];
        
            list<daily_usage__c> UsageList = [select id from daily_usage__c where Account_Premise_Association__r.id =: APAid];                                          
            UsageRequestManager uhitReq = new UsageRequestManager();
            uhitReq.sendBatchRequest(Premlist, CallType); 
            return 'done';
        }catch(exception e){return string.valueof(e);}
    } */
}