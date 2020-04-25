public class PremiseUtils {
//*****************************************************************************
//*** TRIGGERS ****************************************************************
//*****************************************************************************

    //*****************************************************************************
    //*** PREMISE *****************************************************************
    //*****************************************************************************
    /* REMOVED FOR PHASE 3 -- no longer adding pending status to new premises
    public static void CIPremiseAfterInsertProcess(list<Premises__c> prems){
        list<Premise_Status__c> pslist = new list<Premise_Status__c>();
        list<Premise_List__c> pllist = new list<Premise_List__c>();
        list<Premises__c> ciPrems = new list<Premises__c>();
        list<AsyncRequest__c> asrs = new list<AsyncRequest__c>();
        
        for (Premises__c prem: prems){
            if (prem.Record_Type_Name__c.contains('C&I Premise')){ 
                if (prem.Assignment_From_Premise__c == null){
                    //add premise status and list if this is a C&I premise and was not created from a contract assignment
                    Premise_Status__C ps = new Premise_Status__c(Premise__c=prem.id,Status__c='Pending',Status_Date__c=date.today(),
                                                                 Notes__c='New Record Status Trigger');
                    pslist.add(ps);
                }

                //look for gas only and work on weather region
                if (prem.Record_Type_Name__c.contains('C&I Premise Gas')){
                    if (prem.Weather_Station__c == null && prem.CES_Office__c != null){
                        //create async if the weather station is not populated and the office is populated
                        asrs.add(new AsyncRequest__c(Type__c='ApplyClosestWeatherStation', Params__c=prem.Id, Queueable__c=true));
                    }
                }

                //add this premise to the c&i list for later use
                ciPrems.add(prem);
            }
        }
        if (pslist.size()>0){insert pslist;}
        //if (pllist.size()>0){insert pllist;}

        //process date effective properties for premises
        if (ciPrems.size()>0){
            //there are c&i premises so build any applicable property values
            BuildPremisePropertyValues(ciPrems, null);
        }

        if (asrs.size()>0){insert asrs;}
    }
	*/

    public static map<string, id> BuildPropertyMap(string oType){
        list<Date_Effective_Property__c> props = new list<Date_Effective_Property__c>();
        map<string, id> propIdMap = new map<string, id>();

        //get date effective property list
        props = [select id, name from Date_Effective_Property__c where Property_Type__c =: oType or Property_Type__c = null];
        //properties exist so make a property map and then build the property values for each premise
        if (props.size()>0){
            //make map
            for (Date_Effective_Property__c prop:props){
                propIdMap.put(prop.name, prop.id);
            }
        }
        return propIdMap;
    }

    public static void BuildPremisePropertyValues(list<Premises__c> ciPrems, map<id, Premises__c> oldmap){
        map<string, id> propIdMap = new map<string, id>();
        list<Property_Value__c> vals = new list<Property_Value__c>();

        propIdMap = BuildPropertyMap('Premise');

        //properties exist so make a property map and then build the property values for each premise
        if (propIdMap.size()>0){
            //cycle through the ci premises and build the property values
            for (Premises__c prem:ciPrems){
                Premises__c oldp=null;
                if (oldmap!=null){
                    oldp = oldmap.get(prem.id);
                }
                CreatePropertyValuesForPremise(prem,propIdMap, vals, oldp);
            }

            if (vals.size()>0){insert vals;}
        }
    }

    public static void CreatePropertyValuesForPremise(Premises__c prem, map<string, id> propIdMap, list<Property_Value__c> vals, Premises__c oldp){
        date effDate;
        id propId;
        
        if (prem.Property_Effective_Date__c != null){
            effDate = prem.Property_Effective_Date__c;
        } else {
            effDate = date.today().toStartOfMonth();
        }
        /* *** FOR NEW PREMISE PROPERTIES: 
                    ADD NEW PROPERTIES TO THIS CREATION LIST
                    ADD TO PREMISEPROPETYSCRIPT AND PREMISEPROPERTYPAGE
        *** */

        if (prem.Consultant__c != null){
            if (oldp == null || prem.Consultant__c != oldp.Consultant__c){
                try{
                    propId = (id)propIdMap.get('Consultant');
                } catch (exception e) {propId = null;}

                if (propId != null){
                    Property_Value__c val = new Property_Value__c(Premise__c=prem.id, Property__c=propId, Effective_Date__c=effDate, Consultant__c=prem.Consultant__c);
                    vals.add(val);
                }
            }
        }

        if (prem.Default_Delivery_Obligation__c != null){
            if (oldp == null || prem.Default_Delivery_Obligation__c != oldp.Default_Delivery_Obligation__c){
                try{
                    propId = (id)propIdMap.get('Delivery Type');
                } catch (exception e) {propId = null;}

                if (propId != null){
                    Property_Value__c val = new Property_Value__c(Premise__c=prem.id, Property__c=propId, Effective_Date__c=effDate, Text_Value__c=prem.Default_Delivery_Obligation__c);
                    vals.add(val);
                }
            }
        }

        if (prem.MDQ__c != null && prem.MDQ__c != 0 && prem.CES_Office_Code__c != 'LIVE'){ // property is managed by external system for LIVE
            if (oldp == null || prem.MDQ__c != oldp.MDQ__c){
                try{
                    propId = (id)propIdMap.get('MDQ');
                } catch (exception e) {propId = null;}

                if (propId != null){
                    Property_Value__c val = new Property_Value__c(Premise__c=prem.id, Property__c=propId, Effective_Date__c=effDate, Numeric_Value__c=prem.MDQ__c);
                    vals.add(val);
                }
            }
        }

        if (prem.LDC_Rate_Class__c != null && prem.CES_Office_Code__c != 'LIVE'){ // property is managed by external system for LIVE
            if (oldp == null || prem.LDC_Rate_Class__c != oldp.LDC_Rate_Class__c){
                try{
                    propId = (id)propIdMap.get('Rate Class');
                } catch (exception e) {propId = null;}

                if (propId != null){
                    Property_Value__c val = new Property_Value__c(Premise__c=prem.id, Property__c=propId, Effective_Date__c=effDate, Rate_Class__c=prem.LDC_Rate_Class__c);
                    vals.add(val);
                }
            }
        }

        if (prem.Pipeline_Lookup__c != null){
            if (oldp == null || prem.Pipeline_Lookup__c != oldp.Pipeline_Lookup__c){
                try{
                    propId = (id)propIdMap.get('Pipeline');
                } catch (exception e) {propId = null;}

                if (propId != null){
                    Property_Value__c val = new Property_Value__c(Premise__c=prem.id, Property__c=propId, Effective_Date__c=effDate, Pipeline__c=prem.Pipeline_Lookup__c);
                    vals.add(val);
                }
            }
        }

        if (prem.Zone__c != null){
            if (oldp == null || prem.Zone__c != oldp.Zone__c){
                try{
                    propId = (id)propIdMap.get('Area');
                } catch (exception e) {propId = null;}

                if (propId != null){
                    Property_Value__c val = new Property_Value__c(Premise__c=prem.id, Property__c=propId, Effective_Date__c=effDate, Text_Value__c=prem.Zone__c);
                    vals.add(val);
                }
            }
        }

        if (prem.Fuel_Rate__c != null){
            if (oldp == null || prem.Fuel_Rate__c != oldp.Fuel_Rate__c){
                try{
                    propId = (id)propIdMap.get('Fuel Rate');
                } catch (exception e) {propId = null;}

                if (propId != null){
                    Property_Value__c val = new Property_Value__c(Premise__c=prem.id, Property__c=propId, Effective_Date__c=effDate, Text_Value__c=prem.Fuel_Rate__c);
                    vals.add(val);
                }
            }
        }

        if (prem.Utility_Zone__c != null){
            if (oldp == null || prem.Utility_Zone__c != oldp.Utility_Zone__c){
                try{
                    propId = (id)propIdMap.get('Zone');
                } catch (exception e) {propId = null;}

                if (propId != null){
                    Property_Value__c val = new Property_Value__c(Premise__c=prem.id, Property__c=propId, Effective_Date__c=effDate, Text_Value__c=prem.Utility_Zone__c);
                    vals.add(val);
                }
            }
        }

        if (prem.Telemetry_Option__c != null){
            if (oldp == null || prem.Telemetry_Option__c != oldp.Telemetry_Option__c){
                try{
                    propId = (id)propIdMap.get('Telemetry Option');
                } catch (exception e) {propId = null;}

                if (propId != null){
                    Property_Value__c val = new Property_Value__c(Premise__c=prem.id, Property__c=propId, Effective_Date__c=effDate, Text_Value__c=prem.Telemetry_Option__c);
                    vals.add(val);
                }
            }
        }
    }
	
    /* REMOVED FOR PHASE 3 -- also deleted commented code
    public static void CIPremiseBeforeUpdateProcess(list<Premises__c> prems, map<id, Premises__c> oldmap){
        list<Id> acctIdList = new list<Id>();
        list<Id> partnerAcctIdList = new list<Id>();
        list<Premises__c> ciPrems = new list<Premises__c>();
        map<id, Premises__c> ciOldMap = new map<id, Premises__c>();

        //**** list of record processings to create ****
        list<Record_Processing__c> procsToInsert = new list<Record_Processing__c>();

        // c&i premise gas only
        for (Premises__c p:prems){
            if (p.Record_Type_Name__c == 'C&I Premise Gas'){
                Premises__c oldp = oldmap.get(p.id);
                boolean consultantAdded = false;

                // *** check to see if sales rep has changed.  if yes, update flag to true.  informatica process will flip back to false
                if (p.Sales_Rep__c != oldp.Sales_Rep__c){
                    p.Sales_Rep_Changed__c = true;
                }

                // *** check to see if consultant has changed.  if yes, update flag to true.  informatica process will flip back to false
                if (p.Consultant__c != oldp.Consultant__c){
                    p.Consultant_Changed__c = true;
                    consultantAdded = true;
                    if (p.Consultant__c == null){
                        partnerAcctIdList.add(oldp.Consultant__c);
                    }
                    else {
                        if (oldp.Consultant__c != null){
                            partnerAcctIdList.add(oldp.Consultant__c);
                        }
                        partnerAcctIdList.add(p.Consultant__c);
                    }
                }

                // *** check for status change to update Account state list ***
                if (p.Premise_Status_Formula__c != oldp.Premise_Status_Formula__c){
                    acctIdList.add(p.Account__c);
                    if (p.Consultant__c != null && !consultantAdded) {
                        partnerAcctIdList.add(p.Consultant__c);
                    }
                }

                // *** check if this was an external update
                if (p.External_Update__c){
                    p.Do_Not_Sync_Last_Update__c = true;
                    p.External_Update__c = false;
                } else {
                    p.Do_Not_Sync_Last_Update__c = false;
                }

                // create record processing to verify sync to safari.  only do it for updates after original sync
                if (oldp.Safari_Premise_Key__c != null && !oldp.Safari_Premise_Key__c.startsWith('Pending')){
                    boolean found = false;
                    
                    // logic to only add a premise operation once due to multiple saves that can occur from workflow, triggers, etc.
                    for (Record_Processing__c pti:procsToInsert){
                        if (pti.Premise__c == p.id && pti.Operation_Type__c == 'Update'){found = true;}
                    }
                    if (!found){
                        Record_Processing__c proc = new Record_Processing__c(Premise__c=p.id, External_ID__c=p.Safari_Premise_Key__c, Object_Type__c='Premises__c', Operation_Type__c='Update');
                        procsToInsert.add(proc);
                    }
                }

                // add premise to ci list and add old version to map
                ciPrems.add(p);
                ciOldMap.put(p.id,oldp);
            }
        }

        // *** process any user field updates ***
        if (ciPrems.size()>0){
            
            CESDataSyncUtilities.upsertObjectSUFvalues(ciPrems, ciOldMap, false);
            
        }

        if (procsToInsert.size()>0){insert procsToInsert;}
    }
	*/
	/* REMOVED FOR PHASE 3
    public static void CIPremiseBeforeInsertProcess(list<Premises__c> prems){
        //check to see if this is a record type for new CI gas premises and change record type to standard
        RecordType rt;
        rt = [select id, name from recordtype where name='C&I Premise Gas' and SobjectType = 'Premises__c'];
        if (rt != null){
            for (Premises__c p:prems){
                if (p.Record_Type_Name__c == 'C&I Premise Gas New'){
                    p.RecordTypeId = rt.Id;
                }
            }
        }
    }
	*/
	
    /* REMOVED FOR PHASE 3
    public static void CIPremiseBeforeDeleteProcess(list<Premises__c> prems){
        list<Sync_User_Field_Value__c> vals = new list<Sync_User_Field_Value__c>();
        list<Property_Value__c> props = new list<Property_Value__c>();
        Set<Id> premSet = new Set<Id>();
        for (Premises__c p:prems){
            premSet.add(p.id);
        }
        // delete property values
        props = [select id, name from Property_Value__c where Premise__c in:premSet and Premise__c != null];
        if (props.size()>0){delete props;}
        // delete user field values
        vals = [select id, name, Premise__c from Sync_User_Field_Value__c where Premise__c in: premSet and Premise__c != null];
        if (vals.size()>0){delete vals;}//get sync values and delete
    }
	*/

    public static void ApplyClosestWeatherStation(id premId){
        Premises__c prem;

        prem = [select id, name, TDSP_Lookup__c, TDSP_Lookup__r.Location__Latitude__s, TDSP_Lookup__r.Location__Longitude__s, CES_Office__c, Weather_Station__c
                from Premises__c where id=:premId];

        if (prem != null){
            Premises__c ws;
            ws = WeatherizedUsage.WSLookupForOffice(prem.TDSP_Lookup__r.Location__Latitude__s, prem.TDSP_Lookup__r.Location__Longitude__s, prem.CES_Office__c);

            if (ws != null){
                prem.Weather_Station__c = ws.id;
                update prem;
            }
        }
    }

    public static void ApplyNowEffectiveStatus(date effDate){
        list<Premise_Status__c> stats = new list<Premise_Status__c>();
        
        stats = [select id, name, Premise__c, Status__c, Status_Date__c from Premise_Status__c where Status_Date__c=:effDate];

        if (stats.size()>0){
            PremiseStatusAssignment(stats);
            ChatterUtils.mentionTextPost('00530000008PQie', '00530000008PQie', ' the ApplyNowEffectiveStatus process completed successfully');
        } else {
            ChatterUtils.mentionTextPost('00530000008PQie', '00530000008PQie', ' there are no statuses to process today');
        }
    }
    
    //*****************************************************************************
    //*** PPREMISE STATUS *********************************************************
    //*****************************************************************************
    public static void PremiseStatusAssignment(list<Premise_Status__c> stats){
        list<Premises__c> matchingPrems = new list<Premises__c>();
        set<Id> premIdSet = new set<Id>();

        // print out size of passed list
        system.debug('Passed list size:');
        system.debug(stats.size());
        for (Premise_Status__c ps:stats){// get unique premise list
            premIdSet.add(ps.Premise__c);
        }
        
        // get premises matching the set of ids
        try {
            matchingPrems = [select id, name, Current_Premise_Status__c, Dynamic_Status__c from Premises__c where id in:premIdSet];
            system.debug('premise list size:');
            system.debug(matchingPrems.size());
        } catch (exception e){}
        
        if (matchingPrems.size() > 0){
            list<Premise_Status__c> ordPremStats = new list<Premise_Status__c>();
            list<Premise_Status__c> maxPremStats = new list<Premise_Status__c>();
            map<Id, Premise_Status__c> premCurStatMap = new map<Id, Premise_Status__c>();
            list<Premise_Status__c> minFutureStats = new list<Premise_Status__c>();
            map<Id, Premise_Status__c> minFutureMap = new map<Id, Premise_Status__c>();

            // *** Current Status ***
            // get list of premise statuses for premises, ordered by status date desc.  this will be used to assign the most current status to the premise
            ordPremStats = [select id, name, Premise__c, Status__c, Status_Date__c from Premise_Status__c where Premise__c in:premIdSet and Status_Date__c <=: date.today() order by Premise__c, Status_Date__c desc];

            // now, get the first status (latest dated current status) for each premise.  this will result in a list of premises and the current status
            Id prevPremId = null;
            for (Premise_Status__c ps:ordPremStats){
                if (prevPremId == null){// this is the first iteration, add to list
                    maxPremStats.add(ps);
                    prevPremId = ps.Premise__c;
                } else if (prevPremId != ps.Premise__c){// this is the next premise in the list, add to list
                    maxPremStats.add(ps);
                    prevPremId = ps.Premise__c;
                } // otherwise do nothing
            }

            // now make a map of max current status for each premise
            for (Premise_Status__c ps:maxPremStats){
                premCurStatMap.put(ps.Premise__c, ps);
            }

            // *** Future Status ***
            // get first future status for each premise.  this is used to set the dynamic status field on premise.
            ordPremStats.clear();
            ordPremStats = [select id, name, Premise__c, Status__c, Status_Date__c, Future_Status_Formula__c from Premise_Status__c where Premise__c in:premIdSet and Status_Date__c >: date.today() order by Premise__c, Status_Date__c];
            
            // now, get the first status (earliest dated future status) for each premise.  this will result in a list of premises and the nearest future status
            prevPremId = null;
            for (Premise_Status__c ps:ordPremStats){
                if (prevPremId == null){// this is the first iteration, add to list
                    minFutureStats.add(ps);
                    prevPremId = ps.Premise__c;
                } else if (prevPremId != ps.Premise__c){// this is the next premise in the list, add to list
                    minFutureStats.add(ps);
                    prevPremId = ps.Premise__c;
                } // otherwise do nothing
            }
            
            // now make a map of min future status for premise
            for (Premise_Status__c ps:minFutureStats){
                minFutureMap.put(ps.Premise__c, ps);
            }

            // *** Process status maps ***
            for (Premises__c prem:matchingPrems){ // cycle through premise list and process status maps
                Premise_Status__c currPS = null;
                Premise_Status__c futPS = null;
                try {
                    // try getting current premise and update the status assignment
                    currPS = premCurStatMap.get(prem.Id);
                    prem.Current_Premise_Status__c = currPS.Id;
                } catch (exception e){currPS = null;}
                try {
                    // try getting future premise and update the upcoming status
                    futPS = minFutureMap.get(prem.Id);
                    Date futDate = futPS.Status_Date__c;

                    prem.Dynamic_Status__c = futPS.Future_Status_Formula__c; 
                } catch (exception e){futPS = null;}

                if (futPS == null){ // if there is no future status, just use the current status to update the dynamic status. if neither exist, set to blank
                    if (currPS == null){
                        prem.Dynamic_Status__c = null;
                    } else {
                        prem.Dynamic_Status__c = currPS.Status__c;
                    }
                }
            }

            update matchingPrems;
        }
    }

    public static void PremiseStatusDeletionRecords(list<Premise_Status__c> stats){
        list<Record_Processing__c> procs = new list<Record_Processing__c>();

        for (Premise_Status__c pstat:stats){
            system.debug(pstat);
            if (pstat.Safari_Key__c != null && !pstat.Safari_Key__c.startsWith('Pending')){
                // only process deletion for sync'd statuses (active and termination)
                Record_Processing__c proc = new Record_Processing__c(Record_ID__c=pstat.Id, External_ID__c=pstat.Safari_Key__c, Object_Type__c='Premise_Status__c', Operation_Type__c='Delete', Date__c=pstat.Status_Date__c);
                procs.add(proc);
            }
        }
        if (procs.size()>0){
            insert procs;
        }
    }

    public static void CIPremiseStatusDeleteProcess(list<Premise_Status__c> stats){
        /*
        Set<Id> statIds = new Set<Id>();
        Set<Id> premIds = new Set<Id>();
        list<Premises__c> prems = new list<Premises__c>();
        list<Premises__c> premsToUpdate = new list<Premises__c>();
        list<AsyncRequest__c> statsReqs = new list<AsyncRequest__c>();
        map<id, AsyncRequest__c> ReqStatMap = new map<id, AsyncRequest__c>();
        list<AsyncRequest__c> reqsToDelete = new list<AsyncRequest__c>();
        list<AsyncRequest__c> reqsToInsert = new list<AsyncRequest__c>();
        
        for (Premise_Status__c ps: stats){
            statIds.add(ps.id);//get stat keys
            premIds.add(ps.Premise__c);//get premise keys
        }
        
        prems = [select id, name, Current_Premise_Status__c, Premise_Status_Formula__c, Premise_Status_Date_Formula__c, Dynamic_Status__c 
                    from Premises__c where id in: premIds]; //get premise list from premise keys
        
        map<id, Premises__c> premsMap = new map<id, Premises__c>(prems); //make map of premises
        
        statsReqs = [select id, name, type__c, params__c, process_date__c from AsyncRequest__c 
                        where type__c = 'ProcessFuturePremiseStatusNowCurrent'
                        and params__c in: statIds and process_date__c >: date.today()]; //get future asyncrequests for deleted statuses
        
        for (AsyncRequest__c asrr: StatsReqs){ //make map of status id and request
            reqStatMap.put(asrr.Params__c, asrr);
        }
        
        for (Premise_Status__c ps: stats){ //cycle through statuses
            Premises__c prem = premsMap.get(ps.Premise__c); //get premise for this status
            
            prem.Dynamic_Status__c = 'Processing...';
            AsyncRequest__c req = new AsyncRequest__c(Type__c='ProcessUpcomingPremiseStatusDelete',Params__c=prem.Id, Queueable__c=true);
            premsToUpdate.add(prem);
            reqsToInsert.add(req);//add asyncrequest to process dynamic status on premise after status deletion
            if (ps.Status_Date__c > date.today()){//deleted status is for the future so try to delete existing future asyncrequests
                try{
                    AsyncRequest__c asr = reqStatMap.get(ps.Id); //get request, if exists
                    if (asr != null){
                        if (asr.Process_Date__c == ps.Status_Date__c){ //delete request if it matches deleted status date
                            reqsToDelete.add(asr);
                        }
                    }
                }catch (exception e) {}
            } 
        }
        if (premsToUpdate.size() > 0){update premsToUpdate;}
        if (reqsToDelete.size() > 0){delete reqsToDelete;}
        if (reqsToInsert.size() > 0){insert reqsToInsert;}
        */

                /* this was the original code for this process.  need to look back at this after testing new code process.
                    map<string, object> fMap = new map<string, object>();
                    fMap.put('PremiseID',prem.Id);
                    Flow.Interview.update_premise_from_max_premise_status mf = new Flow.Interview.update_premise_from_max_premise_status(fMap);
                    mf.start();
                */
    }

    public static void CIPremiseStatusAfterProcess(list<Premise_Status__c> stats){
        /*
        Set<Id> premIds = new Set<Id>();
        list<Premises__c> prems = new list<Premises__c>();
        list<Premises__c> premsToUpdate = new list<Premises__c>();
        list<AsyncRequest__c> reqsToInsert = new list<AsyncRequest__c>();
        boolean processPremise;
        
        for (Premise_Status__c ps: stats){
            premIds.add(ps.Premise__c); //get premise keys
        }
        
        prems = [select id, name, Current_Premise_Status__c, Premise_Status_Formula__c, Premise_Status_Date_Formula__c, Dynamic_Status__c 
                    from Premises__c where id in: premIds]; //get premise list from premise keys
        
        map<id, Premises__c> premsMap = new map<id, Premises__c>(prems); //make map of premises
        
        for (Premise_Status__c ps: stats){ //cycle through statuses
            processPremise = false;
            Premises__c prem = premsMap.get(ps.Premise__c); //get premise for this status
            
            if (prem.Current_Premise_Status__c == null){ //current premise status is not assigned so assign this one
                prem.Current_Premise_Status__c = ps.Id;
                processPremise = true;
            }
            else if (ps.Id == prem.Current_Premise_Status__c){//status matches premise current status assignment.  only happens for update trigger.
                processPremise = true;
            }
            else if (ps.Status_Date__c > date.today()){ //updated status is dated in the future
                processPremise = true;
            }
            else if (ps.Status_Date__c > prem.Premise_Status_Date_Formula__c){//status date is greater than current status date and in the past so update status
                prem.Current_Premise_Status__c = ps.Id;
                processPremise = true;
            }
            if (processPremise){//if premise was updated, then process it
                prem.Dynamic_Status__c = 'Processing...';
                premsToUpdate.add(prem);
                reqsToInsert.add(CESUtilities.CreateUpcomingStatusAsyncRequest(ps));//add asyncrequest to process dynamic status on premise and insert applicable future asyncrequests
            }
        }
        if (premsToUpdate.size() > 0){update premsToUpdate;}
        if (reqsToInsert.size() > 0){insert reqsToInsert;}
        */
    }
    //*****************************************************************************
    //*** PREMISE LIST ************************************************************
    //*****************************************************************************
    /* 
    public static void CIPremiseListDeleteProcess(list<Premise_List__c> lsts){
        Set<Id> lstIds = new Set<Id>();
        Set<Id> premIds = new Set<Id>();
        list<Premises__c> prems = new list<Premises__c>();
        //list<Premises__c> premsToUpdate = new list<Premises__c>();
        list<AsyncRequest__c> lstsReqs = new list<AsyncRequest__c>();
        map<id, AsyncRequest__c> ReqLstMap = new map<id, AsyncRequest__c>();
        list<AsyncRequest__c> reqsToDelete = new list<AsyncRequest__c>();
        //list<AsyncRequest__c> reqsToInsert = new list<AsyncRequest__c>();
        
        for (Premise_List__c plst: lsts){
            lstIds.add(plst.id);//get list keys
            premIds.add(plst.Premise__c);//get premise keys
        }
        
        prems = [select id, name, Facility_List__c, Facility_List_Formula__c 
                    from Premises__c where id in: premIds]; //get premise list from premise keys
        
        map<id, Premises__c> premsMap = new map<id, Premises__c>(prems); //make map of premises
        
        lstsReqs = [select id, name, type__c, params__c, process_date__c from AsyncRequest__c 
                        where type__c = 'ProcessFuturePremiseFacilityListNowCurrent'
                        and params__c in: lstIds and process_date__c >: date.today()]; //get future asyncrequests for deleted statuses
        
        for (AsyncRequest__c asrr: lstsReqs){ //make map of list id and request
            reqLstMap.put(asrr.Params__c, asrr);
        }
        
        for (Premise_List__c plst: lsts){ //cycle through lists
            Premises__c prem = premsMap.get(plst.Premise__c); //get premise for this list
            
            //prem.Dynamic_Status__c = 'Processing...';
            //AsyncRequest__c req = new AsyncRequest__c(Type__c='ProcessUpcomingPremiseListDelete',Params__c=prem.Id);
            //premsToUpdate.add(prem);
            //reqsToInsert.add(req);//add asyncrequest to process dynamic list on premise after list deletion
            if (plst.Effective_Date__c > date.today()){//deleted list is for the future so try to delete existing future asyncrequests
                try{
                    AsyncRequest__c asr = reqLstMap.get(plst.Id); //get request, if exists
                    if (asr != null){
                        if (asr.Process_Date__c == plst.Effective_Date__c){ //delete request if it matches deleted status date
                            reqsToDelete.add(asr);
                        }
                    }
                }catch (exception e) {}
            }
        }
        //if (premsToUpdate.size() > 0){update premsToUpdate;}
        if (reqsToDelete.size() > 0){delete reqsToDelete;}
        //if (reqsToInsert.size() > 0){insert reqsToInsert;}
    }
	*/
    /*
    public static void CIPremiseListAfterUpdateProcess(list<Premise_List__c> lsts, map<id, Premise_List__c> oldmap){
        Set<Id> premIds = new Set<Id>();
        list<Premises__c> prems = new list<Premises__c>();
        list<Premises__c> premsToUpdate = new list<Premises__c>();
        list<AsyncRequest__c> reqsToInsert = new list<AsyncRequest__c>();
        
        for (Premise_List__c plst: lsts){
            premIds.add(plst.Premise__c); //get premise keys
        }
        
        prems = [select id, name, Facility_List__c from Premises__c where id in: premIds]; //get premises from premise keys
        
        map<id, Premises__c> premsMap = new map<id, Premises__c>(prems); //make map of premises
        
        for (Premise_List__c plst: lsts){ //cycle through lists
            Premise_List__c oldPL = null;
            if (oldmap != null){ oldPL = oldmap.get(plst.Id);}//get old values if this is an update
            Premises__c prem = premsMap.get(plst.Premise__c); //get premise for this list
            
            if (plst.Active__c){ //premise list must be active to process
                if (prem.Facility_List__c == null){ //facility list is not assigned so assign this one
                    prem.Facility_List__c = plst.Facility_List__c;
                    premsToUpdate.add(prem);
                }
                else if (plst.Effective_Date__c > date.today()){ //effective date is in the future
                    if (oldPL != null && plst.Effective_Date__c != oldPL.Effective_Date__c && oldPL.Effective_Date__c > date.today()){ //effective date changed
                        //old and new dates are in the future so make async to update future async that is waiting to be processed
                        AsyncRequest__c req = new AsyncRequest__c(Type__c='UpdateFuturePremListProcessDate',Params__c=plst.Id);
                        reqsToInsert.add(req);
                    }
                    else{
                        //add future asyncrequest to process facility list assignment
                        AsyncRequest__c req = new AsyncRequest__c(Type__c='ProcessFuturePremiseFacilityListNowCurrent',Params__c=plst.Id,Process_Date__c=plst.Effective_Date__c);
                        reqsToInsert.add(req);
                    }
                }
                else{ //date is today or in the past
                    if (oldPl != null && plst.Effective_Date__c != oldPL.Effective_Date__c && oldPL.Effective_Date__c > date.today()){
                        //old date is in future but new date is current.  
                        //make async to delete future async and possibly update premise with this facility list
                        AsyncRequest__c req = new AsyncRequest__c(Type__c='DeleteFuturePremListProcess',Params__c=plst.Id);
                        reqsToInsert.add(req);
                    }
                    else{//effective date is in the past. make async to see if it is most current list to assign to premise
                        AsyncRequest__c req = new AsyncRequest__c(Type__c='CheckCurrentPremiseListAssignment',Params__c=plst.Id);
                        reqsToInsert.add(req);                        
                    }
                }
            }
        }
        if (premsToUpdate.size() > 0){update premsToUpdate;}
        if (reqsToInsert.size() > 0){insert reqsToInsert;}
    }
	*/

//*****************************************************************************
//*** ASYNC PROCESSES ************************************************************
//*****************************************************************************
    //*** PREMISE STATUS ***
    public static void ProcessFuturePremiseStatusNowCurrentAsync(id premstatid){
        /*
        Premise_Status__c futureStat;
        Premise_Status__c ps = [select id, name, premise__c, Status__c, Status_Date__c from Premise_Status__c where id=:premstatid];
        Premises__c prem = [select id, name, Current_Premise_Status__c, Premise_Status_Formula__c, Premise_Status_Date_Formula__c, Dynamic_Status__c 
                            from Premises__c where id=:ps.Premise__c];
        try{
            futureStat = [select id, name, premise__c, Status__c, Status_Date__c from Premise_Status__c 
                              where premise__c =: prem.Id and Id !=: ps.Id and Status_Date__c >: date.today() 
                              order by Status_Date__c asc limit 1];
        }catch (exception e){}
        
        if (ps.Status_Date__c <= date.today()){ //status date should have already occurred so process status on the premise
            prem.Current_Premise_Status__c = ps.Id;
            if (futureStat != null){//future status exists to build dynamic status
                prem.Dynamic_Status__c = CESUtilities.BuildDynamicStatus(futureStat);
            }else{prem.Dynamic_Status__c = ps.Status__c;}
            update prem;
        }
        */
    }
    
    public static void ProcessUpcomingPremiseStatusAsync(id premstatid){
        /*
        Premise_Status__c ps = [select id, name, premise__c, Status__c, Status_Date__c from Premise_Status__c where id=:premstatid];
        Premises__c prem = [select id, name, Current_Premise_Status__c, Premise_Status_Formula__c, Premise_Status_Date_Formula__c, Dynamic_Status__c 
                            from Premises__c where id=:ps.Premise__c];
        Premise_Status__c psCurrent;
        Premise_Status__c futureStat;
        AsyncRequest__c statReq;
        //get the most recent status for this premise to compare to current status assignment to premise
        try{
            psCurrent = [select id, name, premise__c, Status__c, Status_Date__c from Premise_Status__c 
                         where premise__c=:prem.Id and Status_Date__c <=: date.today() order by Status_Date__c desc limit 1];
        }catch (exception e) {}
        
        try{
            if (ps.Status_Date__c > date.today()){//get most recent future status that may be before this status
                futureStat = [select id, name, premise__c, Status__c, Status_Date__c from Premise_Status__c 
                              where premise__c =: prem.Id and Id !=: ps.Id 
                                and Status_Date__c >: date.today() and Status_Date__c <: ps.Status_Date__c 
                              order by Status_Date__c asc limit 1];
            }
            else{//get most recent future status since this status is not in the future
                futureStat = [select id, name, premise__c, Status__c, Status_Date__c from Premise_Status__c 
                              where premise__c =: prem.Id and Id !=: ps.Id and Status_Date__c >: ps.Status_Date__c 
                              order by Status_Date__c asc limit 1];
            }
        }catch (exception e){}
        
        try{
            statReq = [select id, name, type__c, params__c, process_date__c from AsyncRequest__c 
                        where type__c = 'ProcessFuturePremiseStatusNowCurrent'
                        and params__c =: ps.Id and process_date__c >: date.today()];
        }catch (exception e){}
        
        if (ps.Status_Date__c > date.today()){
            if (futureStat != null){//there is a more recent future status than this status so use this for the dynamic status
                prem.Dynamic_Status__c = CESUtilities.BuildDynamicStatus(futureStat);
            }
            else{prem.Dynamic_Status__c = CESUtilities.BuildDynamicStatus(ps);}
            if (statReq != null){ //this status has a future request so update the process date if it changed
                if (statReq.Process_Date__c != ps.Status_Date__c){
                    statReq.Process_Date__c = ps.Status_Date__c;
                    update statReq;
                }
            }
            else{ insert CESUtilities.CreateAsyncRequest(ps); }//status does not have a future request so build one
        }
        else if (futureStat != null){prem.Dynamic_Status__c = CESUtilities.BuildDynamicStatus(futureStat);}//status is in the past but future request exists so update dynamic status with future status
        else{ prem.Dynamic_Status__c = ps.Status__c;}//otherwise, set dynamic status to this status
        
        if (prem.Premise_Status_Date_Formula__c > date.today()){//status assigned to premise is for the future.  change it to most recent status, if exists
            if (psCurrent != null){//current status exists so update premise
                prem.Current_Premise_Status__c = psCurrent.Id;
            }
            else{//there is no current status so delete status assignment on premise
                prem.Current_Premise_Status__c = null;
            }
        }
        
        update prem;
        */
    }
    
    public static void ProcessUpcomingPremiseStatusDeleteAsync(id premid){
        /*
        Premise_Status__c futStat;
        Premise_Status__c currStat;
        Premises__c prem = [select id, name, Current_Premise_Status__c, Premise_Status_Formula__c, Premise_Status_Date_Formula__c, Dynamic_Status__c 
                            from Premises__c where id=:premid];
        boolean updatePremise = false;
        
        try{
            //get most recent future status for premise, if exists
            futStat = [select id, name, premise__c, Status__c, Status_Date__c from Premise_Status__c 
                        where Premise__c =:premid and Status_Date__c >: date.today() order by Status_Date__c asc limit 1];
        }catch (exception e) {}
        
        try{//get most recent current status for premise, if exists
            currStat = [select id, name, premise__c, Status__c, Status_Date__c from Premise_Status__c 
                        where Premise__c =:premid and Status_Date__c <=: date.today() order by Status_Date__c desc limit 1];
        }catch (exception e) {}
        
        if (prem.Current_Premise_Status__c == null){//premise has no status assigned
            if (currStat != null){//assign current status to premise if exists
                prem.Current_Premise_Status__c = currStat.Id;
                prem.Dynamic_Status__c = currStat.Status__c;
                updatePremise = true;
            }
            else if (futStat == null){//no current or future status so delete dynamic status
                prem.Dynamic_Status__c = null;
                updatePremise = true;
            }
        }
        else if (currStat != null){//premise status exists so just update dynamic status from current status
            prem.Dynamic_Status__c = currStat.Status__c;
            updatePremise = true;
        }            
        
        if (futStat != null){//get future status if exists and update premise dynamic status      
            prem.Dynamic_Status__c = CESUtilities.BuildDynamicStatus(futStat);
            updatePremise = true;
        }
        
        if (updatePremise){
            update prem;
        }
        */
    }

    //*** PREMISE LIST ***
    public static void ProcessPremiseListActivationAsync(id cId){
        /*
        Set<Id> premIds = new Set<Id>();
        list<Premises__c> prems = new list<Premises__c>();
        CESContract__c cesc = [select id, name, Account__c, Facility_List__c, Start_Date_New__c, CES_Office__r.Customer_Number__c from CESContract__c where id =: cid];
        list<Premise_List__c> plistsToUpdate = new list<Premise_List__c>();
        list<AsyncRequest__c> reqs = new list<AsyncRequest__c>();
        Map<Id, Premise_List__c> plistMap = new Map<Id, Premise_List__c>();
        list<Premise_List__c> existPListsToTerminate = new list<Premise_List__c>();
        list<Premise_List__c> plsToUpdate = new list<Premise_List__c>();

        boolean setSyncProperties = CESUtilities.getSafariSyncSetting(cesc.CES_Office__r.Customer_Number__c); 

        if (cesc.Facility_List__c != null){
            //get facility list assigned to contract and update sync field
            Facility_List__c fl = [select id, name, Database_to_Sync__c from Facility_List__c where id =: cesc.Facility_List__c];
            if (fl.Database_to_Sync__c == null && setSyncProperties){
                fl.Database_to_Sync__c = cesc.CES_Office__r.Customer_Number__c;
                update fl;
            }
            //get premise list records for this facility list
            plistsToUpdate = [select id, name, premise__c, facility_list__c, Effective_Date__c, active__c from Premise_List__c where Facility_List__c =: cesc.Facility_List__c];

            if (plistsToUpdate.size() >0 ){
                for (Premise_List__c plist: plistsToUpdate){//activate the premise list records
                    plist.Active__c = true;//activate the premise list records
                    premIds.add(plist.Premise__c); //get premise keys
                    plistMap.put(plist.Premise__c, plist); //get map of list for premise
                }
                update plistsToUpdate;//update premise lists
                
                //get premises from premise list that do not have a matching facility list assigned.
                prems = [select id, name, facility_list__c from Premises__c where id in: premIds and facility_list__c !=: cesc.Facility_List__c];
                existPListsToTerminate = [select id, name, Premise__c, Facility_List__c, Effective_Date__c, End_Date__c, Active__c from Premise_List__c where Premise__c in: premIds and Facility_List__c !=: cesc.Facility_List__c];
                if (prems.size()>0){
                    for (Premises__c prem: prems){
                        if (cesc.Start_Date_New__c <= Date.today()){//update premise facility list if effective date is current
                            prem.Facility_List__c = cesc.Facility_List__c;
                        }
                        else {
                            Premise_List__c plp = plistMap.get(prem.Id);
                            reqs.add(new AsyncRequest__c(Type__c='ProcessFuturePremiseFacilityListNowCurrent',Params__c=plp.id,Process_Date__c=cesc.Start_Date_New__c));
                        }
                        //add async to terminate existing premise list
                        for (Premise_List__c pl:existPListsToTerminate){
                            if (pl.Premise__c == prem.id && pl.Facility_List__c == prem.Facility_List__c){// this is the matching premise list
                                if (cesc.Start_Date_New__c <= Date.today()){//in the future so make async to terminate premise list
                                    reqs.add(new AsyncRequest__c(Type__c='ProcessPremiseListTermination',Params__c=pl.id,Process_Date__c=cesc.Start_Date_New__c.addDays(-1)));
                                }
                                else{
                                    pl.End_Date__c = cesc.Start_Date_New__c.addDays(-1);
                                    plsToUpdate.add(pl);
                                }
                            }
                        }
                    }
                    update prems;
                    if (plsToUpdate.size() > 0){update plsToUpdate;}
                    if (reqs.size() > 0){insert reqs;}
                }
                
            }
        }
        */
        
    }

    public static void ProcessFuturePremiseFacilityListNowCurrentAsync(id plistId){
        /*
        Premise_List__c pl = [select id, name, premise__c, Facility_List__c, Effective_Date__c, Active__c from Premise_List__c where id=:plistId];
        Premises__c prem = [select id, name, Facility_List__c from Premises__c where id=:pl.Premise__c];
        
        
        if (pl.Effective_Date__c <= date.today()){ //effective date should have already occurred so process fac list on the premise
            prem.Facility_List__c = pl.Facility_List__c;
            update prem;
        }
        */
    }

    public static void UpdateFuturePremListProcessDateAsync(id plistId){
        /*
        Premise_List__c pl = [select id, name, premise__c, Facility_List__c, Effective_Date__c, Active__c from Premise_List__c where id=:plistId];
        AsyncRequest__c plr; 

        try { //try to get an existing future async for this premise list
            plr = [select id, name, Type__c, Params__c, Process_Date__c from AsyncRequest__c 
                    where Type__c = 'ProcessFuturePremiseFacilityListNowCurrent' and Params__c =: pl.Id limit 1];
        } catch (exception e) {}
        
        if (plr != null){//if future async is found, update the process date
            plr.Process_Date__c = pl.Effective_Date__c;
            update plr;
        }
        */
    }    

    public static void DeleteFuturePremListProcessAsync(id plistId){
        //Premise_List__c pl = [select id, name, premise__c, Facility_List__c, Effective_Date__c, Active__c from Premise_List__c where id=:plistId];
        //Premises__c prem = [select id, name, facility_list__c from Premises__c where id =: pl.premise__c];
        /*
        AsyncRequest__c plr; 

        try { //try to get an existing future async for this premise list
            plr = [select id, name, Type__c, Params__c, Process_Date__c from AsyncRequest__c 
                    where Type__c = 'ProcessFuturePremiseFacilityListNowCurrent' and Params__c =: plistId limit 1];
        } catch (exception e) {}

        if (plr != null){ delete plr;}//delete future async since date was changed to be current

        //check to see if premise list fac list should be assigned to premise
        CheckCurrentPremiseListAssignmentAsync(plistId);
        */
    }

    public static void ProcessPremiseListTermination(id pListId, date termDate){
        /*
        Premise_List__c pl = [select id, name, Premise__c, Facility_List__c, Effective_Date__c, End_Date__c, Active__c from Premise_List__c where id =: pListId];

        pl.End_Date__c = termDate;
        update pl;
        */
    }

    public static void CheckCurrentPremiseListAssignmentAsync(id plistId){
        /*
        Premise_List__c pl = [select id, name, premise__c, Facility_List__c, Effective_Date__c, Active__c from Premise_List__c where id=:plistId];
        Premises__c prem = [select id, name, facility_list__c from Premises__c where id =: pl.premise__c];

        //check to see if premise list fac list should be assigned to premise
        if (prem.facility_list__c != pl.Facility_List__c){//premise facility list is not the same as this premise list fac list
            Premise_List__c curList = [select id, name, facility_list__c, premise__c, Effective_Date__c, End_Date__c, Active__c from Premise_List__c 
                                        where premise__c =: prem.id and facility_list__c =: prem.Facility_List__c]; //get the premise list for this premise and assigned facility list
            if (curList != null){
                if (curList.Effective_Date__c < pl.Effective_Date__c){//new fac list is more current than premise list for premise assigned fac list so update it
                    prem.Facility_List__c = pl.Facility_List__c;
                    update prem;
                    curList.End_Date__c = pl.Effective_Date__c.addDays(-1);
                    update curList;
                }
            }
        }
        */
    }
}