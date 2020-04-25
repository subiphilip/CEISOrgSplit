public class AccountUtils {
//*****************************************************************************
//*** TRIGGER METHODS *********************************************************
//*****************************************************************************
    
    public static void CheckAccountDuplicateStatus(list<Account> accts, map<id, Account> oldmap){
        Set<String> acctNameSet = new Set<String>();
        Set<Id> acctIdSet = new Set<Id>();
        list<Account> baList = new list<Account>();
        list<Account> finalList = new list<Account>();
        // *** REMOVED FOR PHASE 3
        //list<Record_Processing__c> procsToInsert = new list<Record_Processing__c>();

        for (Account a:accts){//Business Accounts only list
            if (a.Record_Type_Name__c == 'Business_Account'){
                baList.add(a);
                acctNameSet.add(a.name);
                acctIdSet.add(a.Id);
            }
        }

        if (baList.size()>0){//only process if there are business accounts
            if (oldmap != null){//this is an update, only get name updates to process
                acctNameSet.clear();
                acctIdSet.clear();
                for (Account a:baList){
                    Account oldA = oldmap.get(a.Id);
                    if (oldA != null && oldA.name != a.name){//name was changed so add to final list
                        finalList.add(a);
                        acctNameSet.add(a.name);
                        acctIdSet.add(a.Id);
                    }
					
                    /* *** REMOVED FOR PHASE 3 ***
                    // add update to record processing for each safari database connected to this account
                    if (oldA.HOU_ID__c != null && !oldA.HOU_ID__c.startsWith('Pending')){
                        Record_Processing__c proc = new Record_Processing__c(Account__c=a.id, External_ID__c='HOU-'+oldA.HOU_ID__c, Object_Type__c='Account', Operation_Type__c='Update');
                        procsToInsert.add(proc);
                    } 
                    if (oldA.Live_ID__c != null && !oldA.Live_ID__c.startsWith('Pending')){
                        Record_Processing__c proc = new Record_Processing__c(Account__c=a.id, External_ID__c='LIVE-'+oldA.Live_ID__c, Object_Type__c='Account', Operation_Type__c='Update');
                        procsToInsert.add(proc);
                    }
                    if (oldA.MPLS_ID__c != null  && !oldA.MPLS_ID__c.startsWith('Pending')){
                        Record_Processing__c proc = new Record_Processing__c(Account__c=a.id, External_ID__c='MPLS-'+oldA.MPLS_ID__c, Object_Type__c='Account', Operation_Type__c='Update');
                        procsToInsert.add(proc);
                    }
                    if (oldA.STL_ID__c != null  && !oldA.STL_ID__c.startsWith('Pending')){
                        Record_Processing__c proc = new Record_Processing__c(Account__c=a.id, External_ID__c='STL-'+oldA.STL_ID__c, Object_Type__c='Account', Operation_Type__c='Update');
                        procsToInsert.add(proc);
                    }
					*/
                }
                // *** REMOVED FOR PHASE 3
                //if (procsToInsert.size()>0){insert procsToInsert;} //insert updates to record processing
                if (finalList.size()==0){//do nothing since no name changes were made
                    return;
                }
            } else {finalList = baList;}

            //get any business accounts matching the name exactly
            list<Account> existAccts = [select id, name from Account where name in : acctNameSet and Record_Type_Name__c =: 'Business_Account' 
                                            and Like_named_Unique_Account__c =: false and id not in: acctIdSet];
            Map<String,Account> existAcctMap = new Map<String, Account>();

            for (Account a:existAccts){
                existAcctMap.put(a.name, a);//make map of name and existing account
            }

            for (Account a:finalList){//check each business account to see if it is a duplicate and not marked as like-named unique
                if (a.Record_Type_Name__c == 'Business_Account' && a.Like_named_Unique_Account__c == false){
                    try{
                        Account dupAcct = existAcctMap.get(a.name);
                        if (dupAcct != null){
                            system.debug('dupAccount is not null.  account name is: ' + dupAcct.name);
                            a.name.addError('A Business Account with this name already exists: ' + dupAcct.name);
                        }else {system.debug('dupAccount is null');}
                    } catch (exception e){}
                }
            }
        }
    }

    public static void AccountAfterUpsertProcess(list<Account> accts, map<id, Account> oldmap, boolean isDelete){
        
        list<Account> hous = new list<Account>();
        list<Account> lives = new list<Account>();
        list<Account> mplss = new list<Account>();
        list<Account> stls = new list<Account>();
        list<Id> oIds = new list<Id>();
        Set<Id> acctIds = New Set<Id>();
        
        //killswitch for tc revision monitoring 
        Trigger_Killswitch__mdt acctChange = [SELECT Kill__c FROM Trigger_Killswitch__mdt where DeveloperName = 'AccountChange'];
        
        if (!isDelete){
            for (Account a:accts){//get acct list by office of sync complete records for record locking
                boolean added = false;
                if (a.Record_Type_Name__c == 'Business_Account'){
                    if (a.Safari_HOU_Sync_Status__c == 'Sync Complete'){
                        if (added == false){
                            hous.add(a);
                            oIds.add(a.id);
                            added = true;
                        }
                    } 
                    if (a.Safari_LIVE_Sync_Status__c == 'Sync Complete'){
                        if (added == false){
                            lives.add(a);
                            oIds.add(a.id);
                            added = true;
                        }
                    } 
                    if (a.Safari_MPLS_Sync_Status__c == 'Sync Complete'){
                        if (added == false){
                            mplss.add(a);
                            oIds.add(a.id);
                            added = true;
                        }
                    } 
                    if (a.Safari_HOU_Sync_Status__c == 'Sync Complete'){
                        if (added == false){
                            stls.add(a);
                            oIds.add(a.id);
                            added = true;
                        }
                    }
                }
            }
        }   
       
         //confirm that killswitch is FALSE and that this is an update (aka oldMap has values)
        if (!acctChange.Kill__c && oldMap != null){
            
           //TC Revision Process Changes KNS 20200306  
            for (Account a:accts){
                system.debug('Inside populate acctIds');
                Account oldAcct = oldmap.get(a.Id);
                system.debug(oldAcct);
                system.debug(a.Name);system.debug(oldAcct.Name);
                if(a.Name != oldAcct.Name){
                    system.debug('Inside populate acctIds');
                    acctIds.add(a.Id);                    
                }
            }
                 
                 
                //List of contracts to update
                List <CESContract__c> contractsToUpdate = New List <CESContract__c>();
                //Query
                List <Account> changedAccts = [Select Id, Name,
                                               (Select Id, name, Confirmation_Status__c, Contract_Status__c, Pending_TC_Revision__c, 
                                                Account_Name_Change__c, TC_Revision_Requires_Review__c 
                                                from CES_Contracts__r
                                               where Confirmation_Status__c = 'Issued'
                                               and Contract_Status__c = 'Activated'
                                               and Pending_TC_Revision__c = False ) 
                                               from Account where id in:acctIds];
                System.debug(changedAccts);
                
                for(Account acct : changedAccts){
                    for(CESContract__c con: acct.CES_Contracts__r){
                        con.Account_Name_Change__c = True;
                        con.Pending_TC_Revision__c = True;
                        con.TC_Revision_Requires_Review__c = True;
                        contractsToUpdate.add(con);
                    }
                }
                System.debug(contractsToUpdate);
                Update contractsToUpdate;    
            
        }
		
        //ONLY FOR INSERTS
        if(oldMap == null)
        {
            if (oIds.size()>0){
                CESDataSyncUtilities.ScheduleRecordLock(oIds);
            }
        } 
        else
        {
            list<Id> uIds = new list<Id>();
            if (hous.size()>0){
                for (Account a:hous){
                    Account oa = oldMap.get(a.id);
                    if (a.Safari_HOU_Sync_Status__c == 'Sync Complete' && oa.Safari_HOU_Sync_Status__c != 'Sync Complete'){
                        uIds.add(a.id);
                    }
                }
            }
            if (lives.size()>0){
                for (Account a:lives){
                    Account oa = oldMap.get(a.id);
                    if (a.Safari_LIVE_Sync_Status__c == 'Sync Complete' && oa.Safari_LIVE_Sync_Status__c != 'Sync Complete'){
                        uIds.add(a.id);
                    }
                }
            }
            if (mplss.size()>0){
                for (Account a:mplss){
                    Account oa = oldMap.get(a.id);
                    if (a.Safari_MPLS_Sync_Status__c == 'Sync Complete' && oa.Safari_MPLS_Sync_Status__c != 'Sync Complete'){
                        uIds.add(a.id);
                    }
                }
            }
            if (stls.size()>0){
                for (Account a:stls){
                    Account oa = oldMap.get(a.id);
                    if (a.Safari_STL_Sync_Status__c == 'Sync Complete' && oa.Safari_STL_Sync_Status__c != 'Sync Complete'){
                        uIds.add(a.id);
                    }
                }
            }

            if (uIds.size()>0){
                CESDataSyncUtilities.ScheduleRecordLock(uIds);
            }
        }
    }

    public static void RefreshAccountActiveStateField(id acctId){
        String stateList = '';
        list<AggregateResult> prems = new list<AggregateResult>();

        prems = [select Account__c, Electric_Service_Address_State2__c state, Count(id) RecCount from Premises__c where Account__c=:acctId and Premise_Status_Formula__c = 'Active' 
                group by Account__c, Electric_Service_Address_State2__c order by Electric_Service_Address_State2__c];

        if (prems.size()>0){
            for (AggregateResult agr:prems){
                if (stateList != '')
                    stateList = stateList + ', ';

                stateList = stateList + (String)agr.get('state') + ':' + String.valueOf((Integer)agr.get('RecCount'));
            }

            Account a = [select id, name, States_with_Active_Premises__c from Account where id=:acctId];
            a.States_with_Active_Premises__c = stateList;
            update a;
        }
    }

    public static void RefreshAccountActiveStateFieldBulk(set<Id> acctIdSet){
        //String stateList = '';
        list<Account> accts = new list<Account>();
        list<AggregateResult> prems = new list<AggregateResult>();
        map<Id, String> acctStateMap = new map<Id, String>();
        
        // get accounts
        accts = [select id, name, States_with_Active_Premises__c, Partner_States_with_Active_Premises__c from Account where id in:acctIdSet order by id];

        prems = [select Account__c, Electric_Service_Address_State2__c state, Count(id) RecCount from Premises__c 
                    where Account__c in:acctIdSet and Premise_Status_Formula__c = 'Active' 
                    group by Account__c, Electric_Service_Address_State2__c order by Account__c, Electric_Service_Address_State2__c];

        if (prems.size()>0){ //at least one account has active premises
            Id currentAcctId = null;
            String stateList = null;
            for (AggregateResult agr:prems){
                if (currentAcctId == null){ // this is the first record
                    currentAcctId = (Id)agr.get('Account__c');
                    stateList = (String)agr.get('state') + ':' + String.valueOf((Integer)agr.get('RecCount'));
                } else if (currentAcctId == (Id)agr.get('Account__c')){ // this record account matches previous account, add to state list
                    if (stateList != '')
                        stateList = stateList + ', ';

                    stateList = stateList + (String)agr.get('state') + ':' + String.valueOf((Integer)agr.get('RecCount'));
                } else if (currentAcctId != (Id)agr.get('Account__c')){ // this is a different account. add list to old account and start new list for new account
                    acctStateMap.put(currentAcctId, stateList);
                    currentAcctId = (Id)agr.get('Account__c');
                    stateList = (String)agr.get('state') + ':' + String.valueOf((Integer)agr.get('RecCount'));
                }
            }

            // add last iteration of for loop to map
            acctStateMap.put(currentAcctId, stateList);

            for (Account a:accts){
                stateList = null;

                try {
                    stateList = acctStateMap.get(a.Id);
                } catch (exception e){stateList = null;}

                a.States_with_Active_Premises__c = stateList;
            }
        } else { // no accounts have active premises, set active states to null for all records
            for (Account a:accts){
                a.States_with_Active_Premises__c = null;
            }
        }

        update accts;
    }
    
    public static void RefreshPartnerAccountActiveStateField(id acctId){
        String stateList = '';
        list<AggregateResult> prems = new list<AggregateResult>();

        prems = [select Consultant__c, Electric_Service_Address_State2__c state, Count(id) RecCount from Premises__c where Consultant__c=:acctId and Premise_Status_Formula__c = 'Active' 
                group by Consultant__c, Electric_Service_Address_State2__c order by Electric_Service_Address_State2__c];

        if (prems.size()>0){
            for (AggregateResult agr:prems){
                if (stateList != '')
                    stateList = stateList + ', ';

                stateList = stateList + (String)agr.get('state') + ':' + String.valueOf((Integer)agr.get('RecCount'));
            }

            Account a = [select id, name, Partner_States_with_Active_Premises__c from Account where id=:acctId];
            a.Partner_States_with_Active_Premises__c = stateList;
            update a;
        }
    }

    public static void RefreshPartnerAccountActiveStateFieldBulk(set<Id> acctIdSet){
        //String stateList = '';
        list<Account> accts = new list<Account>();
        list<AggregateResult> prems = new list<AggregateResult>();
        map<Id, String> acctStateMap = new map<Id, String>();

        // get accounts
        accts = [select id, name, States_with_Active_Premises__c, Partner_States_with_Active_Premises__c from Account where id in:acctIdSet order by id];

        prems = [select Consultant__c, Electric_Service_Address_State2__c state, Count(id) RecCount from Premises__c 
                    where Consultant__c in:acctIdSet and Premise_Status_Formula__c = 'Active' 
                    group by Consultant__c, Electric_Service_Address_State2__c order by Consultant__c, Electric_Service_Address_State2__c];

        if (prems.size()>0){ //at least one account has active premises
            Id currentAcctId = null;
            String stateList = null;
            for (AggregateResult agr:prems){
                if (currentAcctId == null){ // this is the first record
                    currentAcctId = (Id)agr.get('Consultant__c');
                    stateList = (String)agr.get('state') + ':' + String.valueOf((Integer)agr.get('RecCount'));
                } else if (currentAcctId == (Id)agr.get('Consultant__c')){ // this record account matches previous account, add to state list
                    if (stateList != '')
                        stateList = stateList + ', ';

                    stateList = stateList + (String)agr.get('state') + ':' + String.valueOf((Integer)agr.get('RecCount'));
                } else if (currentAcctId != (Id)agr.get('Consultant__c')){ // this is a different account. add list to old account and start new list for new account
                    acctStateMap.put(currentAcctId, stateList);
                    currentAcctId = (Id)agr.get('Consultant__c');
                    stateList = (String)agr.get('state') + ':' + String.valueOf((Integer)agr.get('RecCount'));
                }
            }

            // add last iteration of for loop to map
            acctStateMap.put(currentAcctId, stateList);

            for (Account a:accts){
                stateList = null;

                try {
                    stateList = acctStateMap.get(a.Id);
                } catch (exception e){stateList = null;}

                a.Partner_States_with_Active_Premises__c = stateList;
            }
        } else { // no accounts have active premises, set active states to null for all records
            for (Account a:accts){
                a.Partner_States_with_Active_Premises__c = null;
            }
        }

        update accts;
    }
//*****************************************************************************
//*** Account Credit Approval (ACR) TRIGGER METHODS ***************************
//*****************************************************************************
/* no longer using account credit approval
    public static void ACRBeforeDeleteProcess(list<Account_Credit_Approval__c> ACRs){
        Set<Id> acrSet = new Set<Id>();
        list<Sync_User_Field_Value__c> vals = new list<Sync_User_Field_Value__c>();

        for (Account_Credit_Approval__c acr: ACRs){
            acrSet.add(acr.Id);//get set of acr ids to get all sync values related to deleted ACRs
        }
        if (acrSet.size()>0){
            vals = [select id, name, Account_Credit_Approval__c from Sync_User_Field_Value__c where Account_Credit_Approval__c in: acrSet and Account_Credit_Approval__c != null];
            if (vals.size()>0){delete vals;}//get sync values and delete
        }
    }

    public static void ACRAfterUpdateProcess(list<Account_Credit_Approval__c> ACRs, map<id, Account_Credit_Approval__c> oldmap){
        list<Sync_User_Field_Value__c> valsToUpdate = new list<Sync_User_Field_Value__c>();

        // get user field object with existing field values
        CESDataSyncUtilities.SyncSObjectUserFieldObject syncObject = CESDataSyncUtilities.BuildSObjectSyncUserFieldObject(null, ACRs, null);

        for (Account_Credit_Approval__c acr:ACRs){
            Account_Credit_Approval__c oldAcr = oldmap.get(acr.id); //get old version of fields
            //only process user field updates if the old values have already been synced and user fields were created
            if (oldAcr.Safari_Sync_Status__c == 'Sync Complete' && oldAcr.Sync_Field_Values_Created__c){
                
                //field values have been created so now look for changes
                for (String str : syncObject.targetFields.keyset()) { 
                    Sync_User_Field__c suf;
                    try { 
                        System.debug('Field name: '+str +'. New value: ' + acr.get(str) +'. Old value: '+oldAcr.get(str)); 
                        if(acr.get(str) != oldAcr.get(str)){ 
                            system.debug('******The value has changed!!!! ');
                            system.debug('******* target field name: ' + str);
                            suf = syncObject.UserFieldMapBySourceFieldName.get(str);
                        } 
                    } catch (Exception e) { System.debug('Error: ' + e); suf=null; }

                    //changed value is for a sync field so update it
                    if (suf != null){
                        Sync_User_Field_Value__c valFromMap;
                        try {
                            valFromMap = syncObject.SOBjectUserFieldValueMap.get(acr.id).get(str);
                        } catch (exception e) {valFromMap = null;}
                        if (valFromMap != null){
                            try {
                                Sync_User_Field_Value__c sval = CESDataSyncUtilities.UpdateSyncUserFieldValueDynamic(acr, suf, valFromMap, syncObject.targetFields, acr.Office_Code__c);
                                if (sval != null){
                                    valsToUpdate.add(sval);
                                }
                            } catch (exception e) {system.debug('Update Error: ' + e);}
                        }
                    } 
                }
            }
        }
        if (valsToUpdate.size()>0){update valsToUpdate;}
    }
    */

    public static void AccountUFAfterProcess(list<Account> accts, map<id, Account> oldmap){
        list<Sync_User_Field_Value__c> valsToUpdate = new list<Sync_User_Field_Value__c>();
        list<Sync_User_Field_Value__c> valsToInsert = new list<Sync_User_Field_Value__c>();

        // get user field object with existing field values
        CESDataSyncUtilities.SyncSObjectUserFieldObject syncObject = CESDataSyncUtilities.BuildSObjectSyncUserFieldObject(null, accts, null);

        map<String, String> userFieldOfficeCodeMap = BuildAccountUserFieldOfficeCode();

        for (Account acct:accts){
            Account oldAcct = oldmap.get(acct.id); //get old version of fields
            //only process user field updates if sync has a status
            if (acct.Safari_HOU_Sync_Status__c != null ||
                acct.Safari_LIVE_Sync_Status__c != null ||
                acct.Safari_MPLS_Sync_Status__c != null ||
                acct.Safari_STL_Sync_Status__c != null){ //&& oldAcct.Sync_Field_Values_Created__c){
                
                //field values have been created so now look for changes
                for (String str : syncObject.targetFields.keyset()) { 
                    Sync_User_Field__c suf;
                    try { 
                        System.debug('Field name: '+str +'. New value: ' + acct.get(str) +'. Old value: '+oldAcct.get(str)); 
                        if(acct.get(str) != oldAcct.get(str)){ 
                            system.debug('******The value has changed!!!! ');
                            system.debug('******* target field name: ' + str);
                            suf = syncObject.UserFieldMapBySourceFieldName.get(str);
                        } 
                    } catch (Exception e) { System.debug('Error: ' + e); suf=null; }

                    //changed value is for a sync field so update it
                    if (suf != null){
                        // initialize office code
                        String offCode = null;

                        // try and get office code from user field
                        try {
                            offCode = userFieldOfficeCodeMap.get(str);
                        } catch (exception e){offCode = null;}

                        Sync_User_Field_Value__c valFromMap;
                        try {
                            valFromMap = syncObject.SOBjectUserFieldValueMap.get(acct.id).get(str);
                        } catch (exception e) {valFromMap = null;}
                        if (valFromMap != null){
                            try {
                                Sync_User_Field_Value__c sval = CESDataSyncUtilities.UpdateSyncUserFieldValueDynamic(acct, suf, valFromMap, syncObject.targetFields, offCode);
                                if (sval != null){
                                    valsToUpdate.add(sval);
                                }
                            } catch (exception e) {system.debug('Update Error: ' + e);}
                        } else if (acct.get(str) != null && acct.get(str) != false) {
                            // only run this logic to create if the value is not null and not false, ie - a deletion that didnt have a user field to update to delete me or a false boolean on create
                            // *** logic to create new sync field value from source object ***
                            valsToInsert.add(CESDataSyncUtilities.CreateSyncUserFieldvalueDynamic(acct, suf, syncObject.targetFields, null, offCode));
                        }
                    } 
                }
            }
        }
        if (valsToUpdate.size()>0){update valsToUpdate;}
        if (valsToInsert.size()>0){insert valsToInsert;}
    }

    public static map<String, String> BuildAccountUserFieldOfficeCode(){
        map<String, String> accountUfOfficeCodeMap = new map<String, String>();

        // HOU
        accountUfOfficeCodeMap.put('hou_primary_credit_limit__c','HOU');
        accountUfOfficeCodeMap.put('hou_secondary_credit_limit__c','HOU');
        accountUfOfficeCodeMap.put('hou_insurance_amount__c','HOU');
        accountUfOfficeCodeMap.put('hou_special_care_credit__c','HOU');
        accountUfOfficeCodeMap.put('hou_duns_number__c','HOU');
        accountUfOfficeCodeMap.put('hou_insurance_number__c','HOU');
        accountUfOfficeCodeMap.put('hou_primary_credit_type__c','HOU');
        accountUfOfficeCodeMap.put('hou_secondary_credit_type__c','HOU');
        accountUfOfficeCodeMap.put('hou_sic_code__c','HOU');
        // LIVE
        accountUfOfficeCodeMap.put('live_primary_credit_limit__c','LIVE');
        accountUfOfficeCodeMap.put('live_secondary_credit_limit__c','LIVE');
        accountUfOfficeCodeMap.put('live_insurance_amount__c','LIVE');
        accountUfOfficeCodeMap.put('live_special_care_credit__c','LIVE');
        accountUfOfficeCodeMap.put('live_duns_number__c','LIVE');
        accountUfOfficeCodeMap.put('live_insurance_number__c','LIVE');
        accountUfOfficeCodeMap.put('live_primary_credit_type__c','LIVE');
        accountUfOfficeCodeMap.put('live_secondary_credit_type__c','LIVE');
        accountUfOfficeCodeMap.put('live_sic_code__c','LIVE');
        // MPLS
        accountUfOfficeCodeMap.put('mpls_primary_credit_limit__c','MPLS');
        accountUfOfficeCodeMap.put('mpls_secondary_credit_limit__c','MPLS');
        accountUfOfficeCodeMap.put('mpls_insurance_amount__c','MPLS');
        accountUfOfficeCodeMap.put('mpls_special_care_credit__c','MPLS');
        accountUfOfficeCodeMap.put('mpls_duns_number__c','MPLS');
        accountUfOfficeCodeMap.put('mpls_insurance_number__c','MPLS');
        accountUfOfficeCodeMap.put('mpls_primary_credit_type__c','MPLS');
        accountUfOfficeCodeMap.put('mpls_secondary_credit_type__c','MPLS');
        accountUfOfficeCodeMap.put('mpls_sic_code__c','MPLS');
        // STL
        accountUfOfficeCodeMap.put('stl_primary_credit_limit__c','STL');
        accountUfOfficeCodeMap.put('stl_secondary_credit_limit__c','STL');
        accountUfOfficeCodeMap.put('stl_insurance_amount__c','STL');
        accountUfOfficeCodeMap.put('stl_special_care_credit__c','STL');
        accountUfOfficeCodeMap.put('stl_duns_number__c','STL');
        accountUfOfficeCodeMap.put('stl_insurance_number__c','STL');
        accountUfOfficeCodeMap.put('stl_primary_credit_type__c','STL');
        accountUfOfficeCodeMap.put('stl_secondary_credit_type__c','STL');
        accountUfOfficeCodeMap.put('stl_sic_code__c','STL');

        return accountUfOfficeCodeMap;
    }

}