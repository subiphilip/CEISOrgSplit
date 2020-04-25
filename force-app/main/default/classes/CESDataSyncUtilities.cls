public without sharing class CESDataSyncUtilities {
	
    public static void CheckSyncBatchStatusForOffice(string office){
        list<Sync_Batch__c> batches = new list<Sync_Batch__c>();
        AggregateResult[] sbas; //accounts
        AggregateResult[] bgs; //bill groups
        AggregateResult[] prems; //premises
        AggregateResult[] mus; //usages
        AggregateResult[] pos; //positions
        AggregateResult[] cps; //contract premises
        AggregateResult[] pStats; //premise statuses
        AggregateResult[] props; //date eff property values
        AggregateResult[] ufvs; //user field values
        AggregateResult[] pTerms; // premise terminations

        map<id, integer> sbasMap = new map<id, integer>();
        map<id, integer> bgsMap = new map<id, integer>();
        map<id, integer> premsMap = new map<id, integer>();
        map<id, integer> musMap = new map<id, integer>();
        map<id, integer> posMap = new map<id, integer>();
        map<id, integer> cpsMap = new map<id, integer>();
        map<id, integer> pStatsMap = new map<id, integer>();
        map<id, integer> propsMap = new map<id, integer>();
        map<id, integer> ufvsMap = new map<id, integer>();
        map<id, integer> pTermsMap = new map<id, integer>();

        batches = [select id, name, CES_Office__c, CES_Office__r.Customer_Number__c, Status__c, Email_Sent__c from Sync_Batch__c where CES_Office__r.Customer_Number__c=:office and Status__c !='Complete'];

        if (batches.size()>0){
            set<Id> batchSet = new set<Id>();
            list<Sync_Batch__c> batchesToUpdate = new list<Sync_Batch__c>();
            for (Sync_Batch__c batch:batches){
                batchSet.add(batch.id);
            }
            sbas = database.query('select Sync_Batch__c, count(id) recCount from Sync_Batch_Account__c where Sync_Batch__c in:batchSet and Account__r.Safari_'+office+'_Sync_Status__c !=\'Sync Complete\' group by Sync_Batch__c');
            bgs = [select Sync_Batch__c, count(id) recCount from Bill_Group__c where Sync_Batch__c in:batchSet and Safari_Sync_Status__c != 'Sync Complete' group by Sync_Batch__c];
            prems = [select Sync_Batch__c, count(id) recCount from Premises__c where Sync_Batch__c in:batchSet and Safari_Sync_Status__c != 'Sync Complete' group by Sync_Batch__c];
            mus = [select Sync_Batch__c, count(id) recCount from Monthly_Usage__c where Sync_Batch__c in:batchSet and Safari_Sync_Status__c != 'Sync Complete' group by Sync_Batch__c];
            pos = [select Sync_Batch__c, count(id) recCount from Position__c where Sync_Batch__c in:batchSet and Safari_Sync_Status__c != 'Sync Complete' group by Sync_Batch__c];
            cps = [select Sync_Batch__c, count(id) recCount from Contract_Premise__c where Sync_Batch__c in:batchSet and Safari_Sync_Status__c != 'Sync Complete' group by Sync_Batch__c];
            pStats = [select Sync_Batch__c, count(id) recCount from Premise_Status__c where Sync_Batch__c in:batchSet and Status__c = 'Active' and Safari_Sync_Status__c != 'Sync Complete' group by Sync_Batch__c];
            props = [select Sync_Batch__c, count(id) recCount from Property_Value__c where Sync_Batch__c in:batchSet and Safari_Sync_Status__c != 'Sync Complete' group by Sync_Batch__c];
            ufvs = [select Sync_Batch__c, count(id) recCount from Sync_User_Field_Value__c where Sync_Batch__c in:batchSet and Safari_Sync_Status__c != 'Sync Complete' group by Sync_Batch__c];
            pTerms = [select Sync_Batch__c, count(id) recCount from Premise_Status__c where Sync_Batch__c in:batchSet and Status__c = 'Terminated' and Safari_Sync_Status__c != 'Sync Complete' group by Sync_Batch__c];

            if (sbas.size()>0){
                for (AggregateResult agr:sbas){
                    sbasMap.put((id)agr.get('Sync_Batch__c'),(integer)agr.get('recCount'));
                }
            }
            if (bgs.size()>0){
                for (AggregateResult agr:bgs){
                    bgsMap.put((id)agr.get('Sync_Batch__c'),(integer)agr.get('recCount'));
                }
            }
            if (prems.size()>0){
                for (AggregateResult agr:prems){
                    premsMap.put((id)agr.get('Sync_Batch__c'),(integer)agr.get('recCount'));
                }
            }
            if (mus.size()>0){
                for (AggregateResult agr:mus){
                    musMap.put((id)agr.get('Sync_Batch__c'),(integer)agr.get('recCount'));
                }
            }
            if (pos.size()>0){
                for (AggregateResult agr:pos){
                    posMap.put((id)agr.get('Sync_Batch__c'),(integer)agr.get('recCount'));
                }
            }
            if (cps.size()>0){
                for (AggregateResult agr:cps){
                    cpsMap.put((id)agr.get('Sync_Batch__c'),(integer)agr.get('recCount'));
                }
            }
            if (pStats.size()>0){
                for (AggregateResult agr:pStats){
                    pStatsMap.put((id)agr.get('Sync_Batch__c'),(integer)agr.get('recCount'));
                }
            }
            if (props.size()>0){
                for (AggregateResult agr:props){
                    propsMap.put((id)agr.get('Sync_Batch__c'),(integer)agr.get('recCount'));
                }
            }
            if (ufvs.size()>0){
                for (AggregateResult agr:ufvs){
                    ufvsMap.put((id)agr.get('Sync_Batch__c'),(integer)agr.get('recCount'));
                }
            }
            if (pTerms.size()>0){
                for (AggregateResult agr:pTerms){
                    pTermsMap.put((id)agr.get('Sync_Batch__c'),(integer)agr.get('recCount'));
                }
            }

            for (Sync_Batch__c b:batches){//go through each batch and mark which ones are complete
                boolean isComplete = true;
                integer batchid=null;
                if (sbas.size()>0){
                    try {
                        batchid = sbasMap.get(b.id);
                        if (batchid != null){
                            isComplete = false;
                            continue;
                        }
                    } catch (exception e){}
                }
                if (bgs.size()>0){
                    try {
                        batchid = bgsMap.get(b.id);
                        if (batchid != null){
                            isComplete = false;
                            continue;
                        }
                    } catch (exception e){}
                }
                if (prems.size()>0){
                    try {
                        batchid = premsMap.get(b.id);
                        if (batchid != null){
                            isComplete = false;
                            continue;
                        }
                    } catch (exception e){}
                }
                if (mus.size()>0){
                    try {
                        batchid = musMap.get(b.id);
                        if (batchid != null){
                            isComplete = false;
                            continue;
                        }
                    } catch (exception e){}
                }
                if (pos.size()>0){
                    try {
                        batchid = posMap.get(b.id);
                        if (batchid != null){
                            isComplete = false;
                            continue;
                        }
                    } catch (exception e){}
                }
                if (cps.size()>0){
                    try {
                        batchid = cpsMap.get(b.id);
                        if (batchid != null){
                            isComplete = false;
                            continue;
                        }
                    } catch (exception e){}
                }
                if (pStats.size()>0){
                    try {
                        batchid = pStatsMap.get(b.id);
                        if (batchid != null){
                            isComplete = false;
                            continue;
                        }
                    } catch (exception e){}
                }
                if (props.size()>0){
                    try {
                        batchid = propsMap.get(b.id);
                        if (batchid != null){
                            isComplete = false;
                            continue;
                        }
                    } catch (exception e){}
                }
                if (ufvs.size()>0){
                    try {
                        batchid = ufvsMap.get(b.id);
                        if (batchid != null){
                            isComplete = false;
                            continue;
                        }
                    } catch (exception e){}
                }
                if (pTerms.size()>0){
                    try {
                        batchid = pTermsMap.get(b.id);
                        if (batchid != null){
                            isComplete = false;
                            continue;
                        }
                    } catch (exception e){}
                }

                if (isComplete){
                    b.Status__c = 'Complete';
                    batchesToUpdate.add(b);
                }
            }

            if (batchesToUpdate.size()>0){
                update batchesToUpdate;
                CreateSyncBatchCompleteStatusChatters(batchesToUpdate);
            }
        }
    }

    public static void CreateSyncBatchCompleteStatusChatters(list<Sync_Batch__c> batches){
        list<Account> offices = new list<Account>();
        map<id, list<Id>> offUsers = new map<id, list<Id>>();
        list<Sync_Batch__c> batchesToUpdate = new list<Sync_Batch__c>();
        
        offices = [select id, name from Account where Record_Type_Name__c = 'CES_Location' order by id];
        for (Account o:offices){
            list<User_Office__c> uos = new list<User_Office__c>();
            list<Id> uIds = new list<Id>();

            uos = [select id, name, User__c from User_Office__c where CES_Office__c =:o.id order by User__c];
            for (User_Office__c uo:uos){
                uIds.add(uo.User__c);
            }
            offUsers.put(o.id,uIds);
        }
        
        if (batches.size()>0){
            for (Sync_Batch__c b: batches){
                list<Id> uIds = new list<Id>();
                try {
                    uIds = offUsers.get(b.CES_Office__c);
                } catch (exception e){}
                if (uIds.size()>0){
                    ChatterUtils.multiMentionOnRecord(b.id, uIds, ' this Sync Batch has completed successfully');
                    batchesToUpdate.add(b);
                }
            }

            if (batchesToUpdate.size()>0){
                for (Sync_Batch__c b:batchesToUpdate){
                    b.Email_Sent__c = true;
                }
                update batchesToUpdate;
            }
        }
    }

    public static void CheckRecordsToSyncExist(string office){
        //*** run through all tasks in order until one is found
        string officeLike = '%' + office + '-%';
        string pendingOffice = 'Pending-' + office;
        string taskID;
        //check for account 
        // get business account record type
        RecordType rType;
        rType = [select id, name from RecordType where SobjectType = 'Account' and name = 'Business Account' limit 1];

        list<Account> acts = new list<Account>();
        acts = [select id, name, Safari_HOU_Needs_Sync__c, Safari_LIVE_Needs_Sync__c, Safari_MPLS_Needs_Sync__c, Safari_STL_Needs_Sync__c from Account
                where RecordTypeId =:rType.Id and
                    (Safari_HOU_Needs_Sync__c = true or Safari_LIVE_Needs_Sync__c = true or Safari_MPLS_Needs_Sync__c = true or Safari_STL_Needs_Sync__c = true)];

        if (acts.size() >0){
            boolean needsSync = false;
            for (Account a:acts){
                if (office == 'HOU' && a.Safari_HOU_Needs_Sync__c){
                    needsSync = true;
                } else if (office == 'LIVE' && a.Safari_LIVE_Needs_Sync__c){
                    needsSync = true;
                } else if (office == 'MPLS' && a.Safari_MPLS_Needs_Sync__c){
                    needsSync = true;
                } else if (office == 'STL' && a.Safari_STL_Needs_Sync__c){
                    needsSync = true;
                }
            }
            if (needsSync){
                taskID = getInformaticaTaskID(office, 'Account');

                if (taskID != ''){
                    InformaticaRunner.runInformaticaTaskV2('WORKFLOW', taskID);
                }
            }
        }

        //check for bill group
        list<Bill_Group__c> bs = new list<Bill_Group__c>();
        bs = [select id, name, Account__r.Safari_HOU_Sync_Status__c, Account__r.Safari_LIVE_Sync_Status__c, Account__r.Safari_MPLS_Sync_Status__c, Account__r.Safari_STL_Sync_Status__c,
                 Safari_Sync_Status__c, CES_Office__r.Customer_Number__c 
                from Bill_Group__c where CES_Office__r.Customer_Number__c =:office and (Safari_Sync_Status__c = 'Pending Sync' or Safari_Sync_Status__c = 'Sending SalesForce ID')];

        if (bs.size() >0){
            boolean needsSync = false;
            for (Bill_Group__c b:bs){
                if (office == 'HOU' && b.Account__r.Safari_HOU_Sync_Status__c == 'Sync Complete'){
                    needsSync = true;
                } else if (office == 'LIVE' && b.Account__r.Safari_LIVE_Sync_Status__c == 'Sync Complete'){
                    needsSync = true;
                } else if (office == 'MPLS' && b.Account__r.Safari_MPLS_Sync_Status__c == 'Sync Complete'){
                    needsSync = true;
                } else if (office == 'STL' && b.Account__r.Safari_STL_Sync_Status__c == 'Sync Complete'){
                    needsSync = true;
                }
            }

            if (needsSync){
                taskID = getInformaticaTaskID(office, 'Bill Group');

                if (taskID != ''){
                    InformaticaRunner.runInformaticaTaskV2('WORKFLOW', taskID);
                }
            }
        }
        //check for premise
        list<Premises__c> prems = new list<Premises__c>();
        prems = [select id, name, Bill_Group__r.Safari_Sync_Status__c from Premises__c where Bill_Group__r.Safari_Sync_Status__c = 'Sync Complete' 
                and Bill_Group__r.Safari_ID__c LIKE: officeLike and (Safari_Sync_Status__c LIKE '%Pending%' OR Safari_Sync_Status__c LIKE '%Sales Rep%' 
                    OR Safari_Sync_Status__c LIKE '%UDFs%' OR Safari_Sync_Status__c LIKE '%Services%')];
        if (prems.size() > 0){
            taskID = getInformaticaTaskID(office, 'Premise');

            if (taskID != ''){
                InformaticaRunner.runInformaticaTaskV2('WORKFLOW', taskID);
            }
        }
        //check for premise status
        list<Premise_Status__c> pss = new list<Premise_Status__c>();
        pss = [select id, name, Premise__r.Safari_Sync_Status__c, Premise__r.Safari_Premise_Key__c, Safari_Sync_Status__c from Premise_Status__c where Premise__r.Safari_Sync_Status__c = 'Sync Complete'
                and Premise__r.Safari_Premise_Key__c LIKE: officeLike and Safari_Sync_Status__c LIKE '%Pending%'];
        if (pss.size() >0){
            taskID = getInformaticaTaskID(office, 'Premise Status');

            if (taskID != ''){
                InformaticaRunner.runInformaticaTaskV2('WORKFLOW', taskID);
            }
        }
        //check for usage
        list<Monthly_Usage__c> us = new list<Monthly_Usage__c>();
        us = [select id, name, Premise__r.Safari_Sync_Status__c, Premise__r.Safari_Premise_Key__c, Safari_Sync_Status__c from Monthly_Usage__c where Premise__r.Safari_Sync_Status__c = 'Sync Complete'
                and Premise__r.Safari_Premise_Key__c LIKE: officeLike and Safari_Sync_Status__c LIKE '%Pending%'];
        if (us.size() >0){
            taskID = getInformaticaTaskID(office, 'Usage');

            if (taskID != ''){
                InformaticaRunner.runInformaticaTaskV2('WORKFLOW', taskID);
            }
        }
        //check for contract
        list<CESContract__c> cons = new list<CESContract__c>();
        cons = [Select id, name, Account__r.Safari_HOU_Sync_Status__c, Account__r.Safari_LIVE_Sync_Status__c, Account__r.Safari_MPLS_Sync_Status__c, Account__r.Safari_STL_Sync_Status__c,
                Safari_Sync_Status__c, CES_Office__r.Customer_Number__c from CESContract__c 
                where Active__c = true and CES_Office__r.Customer_Number__c =:office and (Safari_Sync_Status__c LIKE '%Pending%' OR Safari_Sync_Status__c LIKE '%UDFs%' OR Safari_Sync_Status__c LIKE '%Contract Charges%')];
        if (cons.size() >0 ){
            boolean needsSync = false;
            for (CESContract__c c:cons){
                if (office == 'HOU' && c.Account__r.Safari_HOU_Sync_Status__c == 'Sync Complete'){
                    needsSync = true;
                } else if (office == 'LIVE' && c.Account__r.Safari_LIVE_Sync_Status__c == 'Sync Complete'){
                    needsSync = true;
                } else if (office == 'MPLS' && c.Account__r.Safari_MPLS_Sync_Status__c == 'Sync Complete'){
                    needsSync = true;
                } else if (office == 'STL' && c.Account__r.Safari_STL_Sync_Status__c == 'Sync Complete'){
                    needsSync = true;
                }
            }

            if (needsSync){
                taskID = getInformaticaTaskID(office, 'Contract');

                if (taskID != ''){
                    InformaticaRunner.runInformaticaTaskV2('WORKFLOW', taskID);
                }
            }
        }
        //check for position
        list<Position__c> pos = new list<Position__c>();
        pos = [select id, name, CES_Contract__r.Safari_Sync_Status__c, CES_Contract__r.Safari_Key__c from Position__c where CES_Contract__r.Safari_Sync_Status__c = 'Sync Complete'
                and CES_Contract__r.Safari_Key__c LIKE: officeLike and Safari_Sync_Status__c LIKE '%Pending%'];
        if (pos.size() >0){
            taskID = getInformaticaTaskID(office, 'Position');

            if (taskID != ''){
                InformaticaRunner.runInformaticaTaskV2('WORKFLOW', taskID);
            }
        }
        //check for contract premise 
        list<Contract_Premise__c> cps = new list<Contract_Premise__c>();
        cps = [select id, name, CESContract__r.Safari_Sync_Status__c, CESContract__r.Safari_Key__c, Premise__r.Safari_Premise_Key__c, Premise__r.Safari_Sync_Status__c 
                from Contract_Premise__c where CESContract__r.Safari_Sync_Status__c = 'Sync Complete' and CESContract__r.Safari_Key__c LIKE: officeLike 
                and Premise__r.Safari_Sync_Status__c = 'Sync Complete' and Premise__r.Safari_Premise_Key__c LIKE: officeLike
                and Safari_Sync_Status__c LIKE '%Pending%'];
        if (cps.size() >0){
            taskID = getInformaticaTaskID(office, 'Contract Premise');

            if (taskID != ''){
                InformaticaRunner.runInformaticaTaskV2('WORKFLOW', taskID);
            }
        }
        //check for premise utility property values
        list<Property_Value__c> pvs = new list<Property_Value__c>();
        pvs = [select id, name, Premise__r.Safari_Sync_Status__c, Premise__r.Safari_Premise_Key__c, Safari_Sync_Status__c from Property_Value__c where Premise__r.Safari_Sync_Status__c = 'Sync Complete'
                and Premise__r.Safari_Premise_Key__c LIKE: officeLike and Safari_Sync_Status__c LIKE '%Pending%' and Property__r.Safari_Type__c = 'Utility Property'];
        if (pvs.size() >0){
            taskID = getInformaticaTaskID(office, 'Premise Property Value');

            if (taskID != ''){
                InformaticaRunner.runInformaticaTaskV2('WORKFLOW', taskID);
            }
        }
        //check for premise account property values
        list<Property_Value__c> pavs = new list<Property_Value__c>();
        pavs = [select id, name, Premise__r.Safari_Sync_Status__c, Premise__r.Safari_Premise_Key__c, Safari_Sync_Status__c from Property_Value__c where Premise__r.Safari_Sync_Status__c = 'Sync Complete'
                and Premise__r.Safari_Premise_Key__c LIKE: officeLike and Safari_Sync_Status__c LIKE '%Pending%' and Property__r.Safari_Type__c = 'Account Property'];
        if (pavs.size() >0){
            taskID = getInformaticaTaskID(office, 'Premise AP Value');

            if (taskID != ''){
                InformaticaRunner.runInformaticaTaskV2('WORKFLOW', taskID);
            }
        }
        //check for contract udfs 
        //boolean ufvsFound = false;
        list<Sync_User_Field_Value__c> ufvs = new list<Sync_User_Field_Value__c>();
        ufvs = [select id, name, CESContract__r.Safari_Sync_Status__c, CESContract__r.Safari_Key__c, Safari_Sync_Status__c 
                from Sync_User_Field_Value__c where CESContract__r.Safari_Sync_Status__c = 'Sync Complete' and CESContract__r.Safari_Key__c LIKE: officeLike 
                and Safari_Sync_Status__c LIKE '%Pending%'];
        if (ufvs.size() >0){
            taskID = getInformaticaTaskID(office, 'Contract UFV');

            if (taskID != ''){
                InformaticaRunner.runInformaticaTaskV2('WORKFLOW', taskID);
                //ufvsFound = true;
            } 
        }

        //check for credit udfs if contract ufvs were not found.  runs same task so only needs to run if contract ufvs were not found 
        // no longer managing credit udfs.  managed on the account.
        /*
        if (!ufvsFound){
            ufvs.clear();
            ufvs = [select id, name, Account_Credit_Approval__r.Safari_Sync_Status__c, Account_Credit_Approval__r.Account_Safari_Key__c, Safari_Sync_Status__c, Account_Credit_Approval__r.CES_Office__r.Customer_Number__c  
                    from Sync_User_Field_Value__c where Account_Credit_Approval__r.Safari_Sync_Status__c = 'Sync Complete' and Account_Credit_Approval__r.Account_Safari_Key__c != null
                    and Account_Credit_Approval__r.CES_Office__r.Customer_Number__c =: office 
                    and Safari_Sync_Status__c LIKE '%Pending%'];
            if (ufvs.size() >0){
                taskID = getInformaticaTaskID(office, 'Contract UFV');

                if (taskID != ''){
                    InformaticaRunner.runInformaticaTaskV2('WORKFLOW', taskID);
                    ufvsFound = true;
                }
            }
        }
        */

         //check for account udfs. do not run same tasks any longer 
        list<Sync_User_Field_Value__c> aufvs = new list<Sync_User_Field_Value__c>();
        aufvs = [select id, name, Account__c, Safari_Key__c, Safari_Sync_Status__c 
                from Sync_User_Field_Value__c where Account__c != null and Safari_Key__c =: pendingOffice 
                and Safari_Sync_Status__c LIKE '%Pending%'];
        if (aufvs.size() >0){
            taskID = getInformaticaTaskID(office, 'Account UFV');

            if (taskID != ''){
                InformaticaRunner.runInformaticaTaskV2('WORKFLOW', taskID);
            } 
        }
        //check for premise udfs if contract ufvs were not found.  runs same task so only needs to run if it was not previously run
        /*if (!ufvsFound){
            ufvs.clear();
            ufvs = [select id, name, Premise__r.Safari_Sync_Status__c, Premise__r.Safari_Premise_Key__c, Safari_Sync_Status__c, Premise__r.CES_Office__r.Customer_Number__c  
                    from Sync_User_Field_Value__c where Premise__r.Safari_Sync_Status__c = 'Sync Complete' and Premise__r.Safari_Premise_Key__c LIKE: officeLike
                    and Premise__r.CES_Office__r.Customer_Number__c =: office 
                    and Safari_Sync_Status__c LIKE '%Pending%'];
            if (ufvs.size() >0){
                taskID = getInformaticaTaskID(office, 'Contract UFV');

                if (taskID != ''){
                    InformaticaRunner.runInformaticaTaskV2('WORKFLOW', taskID);
                    ufvsFound = true;
                }
            }
        }
        //check for billing udfs if contract and premise ufvs were not found.  runs same task so only needs to run if it was not previously run
        if (!ufvsFound){
            ufvs.clear();
            ufvs = [select id, name, Bill_Group__r.Safari_Sync_Status__c, Bill_Group__r.Safari_ID__c, Safari_Sync_Status__c, Bill_Group__r.CES_Office__r.Customer_Number__c  
                    from Sync_User_Field_Value__c where Bill_Group__r.Safari_Sync_Status__c = 'Sync Complete' and Bill_Group__r.Safari_ID__c LIKE: officeLike
                    and Bill_Group__r.CES_Office__r.Customer_Number__c =: office 
                    and Safari_Sync_Status__c LIKE '%Pending%'];
            if (ufvs.size() >0){
                taskID = getInformaticaTaskID(office, 'Contract UFV');

                if (taskID != ''){
                    InformaticaRunner.runInformaticaTaskV2('WORKFLOW', taskID);
                    ufvsFound = true;
                }
            }
        }*/
        // check for premise and billing udfs.  no longer use the same task flow as contracts.  commented out original above
        // check for Billing udfs
        list<Sync_User_Field_Value__c> bufvs = new list<Sync_User_Field_Value__c>();
        bufvs = [select id, name, Bill_Group__r.Safari_Sync_Status__c, Bill_Group__r.Safari_ID__c, Safari_Sync_Status__c, Bill_Group__r.CES_Office__r.Customer_Number__c  
                from Sync_User_Field_Value__c where Bill_Group__r.Safari_Sync_Status__c = 'Sync Complete' and Bill_Group__r.Safari_ID__c LIKE: officeLike
                and Bill_Group__r.CES_Office__r.Customer_Number__c =: office 
                and Safari_Sync_Status__c LIKE '%Pending%'];
        if (bufvs.size() >0){
            taskID = getInformaticaTaskID(office, 'Billing UFV');

            if (taskID != ''){
                InformaticaRunner.runInformaticaTaskV2('WORKFLOW', taskID);
            }
        }

        // check for Premise udfs
        list<Sync_User_Field_Value__c> pufvs = new list<Sync_User_Field_Value__c>();
        pufvs = [select id, name, Premise__r.Safari_Sync_Status__c, Premise__r.Safari_Premise_Key__c, Safari_Sync_Status__c, Premise__r.CES_Office__r.Customer_Number__c  
                from Sync_User_Field_Value__c where Premise__r.Safari_Sync_Status__c = 'Sync Complete' and Premise__r.Safari_Premise_Key__c LIKE: officeLike
                and Premise__r.CES_Office__r.Customer_Number__c =: office 
                and Safari_Sync_Status__c LIKE '%Pending%'];
        if (pufvs.size() >0){
            taskID = getInformaticaTaskID(office, 'Premise UFV');

            if (taskID != ''){
                InformaticaRunner.runInformaticaTaskV2('WORKFLOW', taskID);
            }
        }

        //check for premise terminations
        /* No longer needed - sending all status inserts via premise status
        list<Premise_Status__c> pts = new list<Premise_Status__c>();
        pts = [select id, name, Premise__r.Safari_Sync_Status__c, Premise__r.Safari_Premise_Key__c, Safari_Sync_Status__c from Premise_Status__c where Premise__r.Safari_Sync_Status__c = 'Sync Complete'
                and Premise__r.Safari_Premise_Key__c LIKE: officeLike and Status__c = 'Terminated' and Safari_Sync_Status__c LIKE '%Pending%'];
        if (pts.size() >0){
            taskID = getInformaticaTaskID(office, 'Premise Termination');

            if (taskID != ''){
                InformaticaRunner.runInformaticaTaskV2('WORKFLOW', taskID);
            }
        }
        */

        //check for contract charges
        list<Customer_Charge__c> cCharges = new list<Customer_Charge__c>();
        cCharges = [select id, name, Contract__r.Safari_Sync_Status__c, Contract__r.Safari_Key__c from Customer_Charge__c where Contract__r.Safari_Sync_Status__c = 'Sync Complete'
                    and Contract__r.Safari_Key__c LIKE: officeLike and Safari_Sync_Status__c LIKE '%Pending%'];
        if (cCharges.size() >0){
            taskID = getInformaticaTaskID(office, 'Contract Charge');

            if (taskID != ''){
                InformaticaRunner.runInformaticaTaskV2('WORKFLOW', taskID);
            }
        }
    }

    public static id CreateSyncBatch(id office){
        Sync_Batch__c batch = new Sync_Batch__c(CES_Office__c=office, Status__c='Pending');
        insert batch;
        return batch.id;
    }

    public static void CreateSyncBatchAccount(id acct, id batch){
        Sync_Batch_Account__c sba = new Sync_Batch_Account__c(Account__c=acct, Sync_Batch__c=batch);
        insert sba;
    }

    public static void ScheduleRecordLock(list<Id> oIds){
        list<AsyncRequest__c> reqs = new list<AsyncRequest__c>();

        for (Id o:oIds){
            AsyncRequest__c ar = new AsyncRequest__c(Type__c='ProcessRecordLock',Params__c=o,Queueable__c=true);
            reqs.add(ar);
        }
        insert reqs;
    }

    public static void ProcessRecordLock(id oId){
        try{
            //Create the approval request
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Record Lock after Sync.');
            req1.setObjectId(oId);
            
            //Submit the approval request for the contract
            Approval.ProcessResult result = Approval.process(req1);
        } catch (exception e){}
    }

    public static string getInformaticaTaskID(string office, string tType){
        InformaticaTaskIDs__c taskIDs = InformaticaTaskIDs__c.getOrgDefaults();
        string tId;

        if (tType=='Account'){
            if (office == 'HOU'){
                tid = taskIDs.HOU_Account__c;
            } else if (office == 'LIVE'){
                tid = taskIDs.LIVE_Account__c;
            } else if (office == 'MPLS'){
                tId = taskIDs.MPLS_Account__c;
            } else if (office == 'STL'){
                tId = taskIDs.STL_Account__c;
            }
        } else if (tType=='Bill Group'){
            if (office == 'HOU'){
                tId = taskIDs.HOU_Bill_Group__c;
            } else if (office == 'LIVE'){
                tId = taskIDs.LIVE_Bill_Group__c;
            } else if (office == 'MPLS'){
                tId = taskIDs.MPLS_Bill_Group__c;
            } else if (office == 'STL'){
                tId = taskIDs.STL_Bill_Group__c;
            }
        } else if (tType=='Contract'){
            if (office == 'HOU'){
                tId = taskIDs.HOU_Contract__c;
            } else if (office == 'LIVE'){
                tId = taskIDs.LIVE_Contract__c;
            } else if (office == 'MPLS'){
                tId = taskIDs.MPLS_Contract__c;
            } else if (office == 'STL'){
                tId = taskIDs.STL_Contract__c;
            }
        } else if (tType=='Customer Care'){
            if (office == 'HOU'){
            
            } else if (office == 'LIVE'){
                
            } else if (office == 'MPLS'){
                
            } else if (office == 'STL'){
                
            }
        } else if (tType=='Entire Process'){
            if (office == 'HOU'){
            
            } else if (office == 'LIVE'){
                
            } else if (office == 'MPLS'){
                tId = taskIDs.MPLS_Entire_Process__c;
            } else if (office == 'STL'){
                
            }
        } else if (tType=='Premise') {
            if (office == 'HOU'){
                tId = taskIDs.HOU_Premise__c;
            } else if (office == 'LIVE'){
                tId = taskIDs.LIVE_Premise__c;
            } else if (office == 'MPLS'){
                tId = taskIDs.MPLS_Premise__c;
            } else if (office == 'STL'){
                tId = taskIDs.STL_Premise__c;
            }
        } else if (tType=='Usage') {
            if (office == 'HOU'){
                tId = taskIDs.HOU_Usage__c;
            } else if (office == 'LIVE'){
                tId = taskIDs.LIVE_Usage__c;
            } else if (office == 'MPLS'){
                tId = taskIDs.MPLS_Usage__c;
            } else if (office == 'STL'){
                tId = taskIDs.STL_Usage__c;
            }
        } else if (tType=='Position'){
            if (office == 'HOU'){
                tId = taskIDs.HOU_Position__c;
            } else if (office == 'LIVE'){
                tId = taskIDs.LIVE_Position__c;
            } else if (office == 'MPLS'){
                tId = taskIDs.MPLS_Position__c;
            } else if (office == 'STL'){
                tId = taskIDs.STL_Position__c;
            }
        } else if (tType=='Premise Status'){
            if (office == 'HOU'){
                tId = taskIDs.HOU_Premise_Status__c;
            } else if (office == 'LIVE'){
                tId = taskIDs.LIVE_Premise_Status__c;
            } else if (office == 'MPLS'){
                tId = taskIDs.MPLS_Premise_Status__c;
            } else if (office == 'STL'){
                tId = taskIDs.STL_Premise_Status__c;
            }
        } else if (tType=='Contract Premise'){
            if (office == 'HOU'){
                tId = taskIDs.HOU_Contract_Premise__c;
            } else if (office == 'LIVE'){
                tId = taskIDs.LIVE_Contract_Premise__c;
            } else if (office == 'MPLS'){
                tId = taskIDs.MPLS_Contract_Premise__c;
            } else if (office == 'STL'){
                tId = taskIDs.STL_Contract_Premise__c;
            }
        } else if (tType=='Premise Property Value'){
            if (office == 'HOU'){
                tId = taskIDs.HOU_Premise_Property_Value__c;
            } else if (office == 'LIVE'){
                tId = taskIDs.LIVE_Premise_Property_Value__c;
            } else if (office == 'MPLS'){
                tId = taskIDs.MPLS_Premise_Property_Value__c;
            } else if (office == 'STL'){
                tId = taskIDs.STL_Premise_Property_Value__c;
            }
        } else if (tType=='Premise AP Value'){
            if (office == 'HOU'){
                tId = taskIDs.HOU_Premise_AP_Value__c;
            } else if (office == 'LIVE'){
                tId = taskIDs.LIVE_Premise_AP_Value__c;
            } else if (office == 'MPLS'){
                tId = taskIDs.MPLS_Premise_AP_Value__c;
            } else if (office == 'STL'){
                tId = taskIDs.STL_Premise_AP_Value__c;
            }
        } else if (tType=='Contract UFV'){
            if (office == 'HOU'){
                tId = taskIDs.HOU_Contract_UFV__c;
            } else if (office == 'LIVE'){
                tId = taskIDs.LIVE_Contract_UFV__c;
            } else if (office == 'MPLS'){
                tId = taskIDs.MPLS_Contract_UFV__c;
            } else if (office == 'STL'){
                tId = taskIDs.STL_Contract_UFV__c;
            }
        } else if (tType=='Premise Termination'){
            if (office == 'HOU'){
                tId = taskIDs.HOU_Premise_Termination__c;
            } else if (office == 'LIVE'){
                tId = taskIDs.LIVE_Premise_Termination__c;
            } else if (office == 'MPLS'){
                tId = taskIDs.MPLS_Premise_Termination__c;
            } else if (office == 'STL'){
                tId = taskIDs.STL_Premise_Termination__c;
            }
        } else if (tType=='Account UFV'){
            if (office == 'HOU'){
                tId = taskIDs.HOU_Account_UFV__c;
            } else if (office == 'LIVE'){
                tId = taskIDs.LIVE_Account_UFV__c;
            } else if (office == 'MPLS'){
                tId = taskIDs.MPLS_Account_UFV__c;
            } else if (office == 'STL'){
                tId = taskIDs.STL_Account_UFV__c;
            }
        } else if (tType=='Billing UFV'){
            if (office == 'HOU'){
                tId = taskIDs.HOU_Billing_UFV__c;
            } else if (office == 'LIVE'){
                tId = taskIDs.LIVE_Billing_UFV__c;
            } else if (office == 'MPLS'){
                tId = taskIDs.MPLS_Billing_UFV__c;
            } else if (office == 'STL'){
                tId = taskIDs.STL_Billing_UFV__c;
            }
        } else if (tType=='Premise UFV'){
            if (office == 'HOU'){
                tId = taskIDs.HOU_Premise_UFV__c;
            } else if (office == 'LIVE'){
                tId = taskIDs.LIVE_Premise_UFV__c;
            } else if (office == 'MPLS'){
                tId = taskIDs.MPLS_Premise_UFV__c;
            } else if (office == 'STL'){
                tId = taskIDs.STL_Premise_UFV__c;
            }
        }
        else if (tType=='Contract Charge'){
            if (office == 'HOU'){
                tId = taskIDs.HOU_Contract_Charge__c;
            } else if (office == 'LIVE'){
                tId = taskIDs.LIVE_Contract_Charge__c;
            } else if (office == 'MPLS'){
                tId = taskIDs.MPLS_Contract_Charge__c;
            } else if (office == 'STL'){
                tId = taskIDs.STL_Contract_Charge__c;
            }
        }
        return tId;
    }

    //*****************************************************************************************************************************
    //****Sync User Field *********************************************************************************************************
    //*****************************************************************************************************************************

    //building sync field object for use
    public class SyncContractUserFieldObject{
        public map<String, Sync_User_Field__c> UserFieldMapBySourceFieldName {get;set;}
        public map<Id, map<String, Sync_User_Field_Value__c>> ContractUserFieldValueMap {get;set;}
        public Set<Id> ContractIdSet {get;set;}
        public map<String, Schema.sObjectField> targetFields {get;set;}

        public SyncContractUserFieldObject(map<String, Sync_User_Field__c> sufMap, map<Id, map<String, Sync_User_Field_Value__c>> ufvMap, Set<Id> conIdSet, map<String, Schema.sObjectField> flds){
            UserFieldMapBySourceFieldName = sufMap;
            ContractUserFieldValueMap = ufvMap;
            ContractIdSet = conIdSet;
            targetFields = flds;
        }
    }

    public static SyncContractUserFieldObject BuildContractSyncUserFieldObject(CESContract__c cesc, list<CESContract__c> CESCs, map<Id, String> offMap){
        map<Id, String> offCodeMap;
        if (offMap == null){
            offCodeMap = CESUtilities.getOfficeCodeMap();
        } else {
            offCodeMap = offMap;
        }

        //get object type and fields for change comparison
        Map<String, Schema.sObjectField> targetFields = CESUtilities.getObjectFieldMap('CESContract__c');

        //get sync field map
        Map<String, Sync_User_Field__c> sufMap = new Map<String, Sync_User_Field__c>();
        list<Sync_User_Field__c> sufs = [select id, name, Source_Object_Sync_Field_Name__c, Divide_by_Therm_Factor__c, Multiply_by_Therm_Factor__c, Sync_HOU__c, Sync_LIVE__c, Sync_MPLS__c, Sync_STL__c  
                                                from Sync_User_Field__c where Field_Type__c = 'Contract' order by name];

        //system.debug('*********** building sufMap *******');
        for (Sync_User_Field__c suf:sufs){
            sufMap.put(suf.Source_Object_Sync_Field_Name__c, suf);
            //system.debug('suf sync field: ' + suf.Source_Object_Sync_Field_Name__c + ', suf name: ' + suf.name);
        }

        //get existing sync field values for these contracts
        Set<Id> conIdSet = new Set<Id>();
        map<Id, map<String, Sync_User_Field_Value__c>> ufvMap = new map<Id, map<String, Sync_User_Field_Value__c>>();
        
        if (CESCs != null){
            //list of contracts was passed so build contract set and value map
            for (CESContract__c con:CESCs){
                conIdSet.add(con.id);
                ufvMap.put(con.id, new map<String, Sync_User_Field_Value__c>{});
            }

            list<Sync_User_Field_Value__c> ufVals = new list<Sync_User_Field_Value__c>();
            ufVals = [select id, name, CESContract__c, Value__c, Sync_User_Field__c, Sync_User_Field__r.name, Sync_User_Field__r.Source_Object_Sync_Field_Name__c, 
                    Sync_User_Field__r.Divide_by_Therm_Factor__c, Sync_User_Field__r.Multiply_by_Therm_Factor__c, Sync_User_Field__r.Sync_HOU__c, Sync_User_Field__r.Sync_LIVE__c, Sync_User_Field__r.Sync_MPLS__c, 
                    Sync_User_Field__r.Sync_STL__c  
                    from Sync_User_Field_Value__c where CESContract__c in: conIdSet
                    order by CESContract__c, Sync_User_Field__r.name];

            if (ufVals.size()>0){
                for (Sync_User_Field_Value__c ufv:ufVals){
                    ufvMap.get(ufv.CESContract__c).put(ufv.Sync_User_Field__r.Source_Object_Sync_Field_Name__c,ufv);
                }
            }
        }
        else {
            //only one contract was passed, which is for contract creation, so do not build value map
            conIdSet = null;
            ufvMap = null;
        }

        SyncContractUserFieldObject sufObject = new SyncContractUserFieldObject(sufMap, ufvMap, conIdSet, targetFields);

        return sufObject;
    }
    //end of sync field object creation

    //run through all fields of a contract after activation to see what sync user fields need to be created
    //and then create them
    public static boolean BuildContractSyncUserFieldValues(CESContract__c cesc, id batch){
        boolean created = false;
        list<Sync_User_Field_Value__c> valsToInsert = new list<Sync_User_Field_Value__c>();
        
        //get object type and fields for comparison
        SyncContractUserFieldObject syncObject = BuildContractSyncUserFieldObject(cesc, null, null);
/*
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get('CESContract__c');
        Map<String, Schema.sObjectField> targetFields = targetType.getDescribe().fields.getMap();

        //get sync field map
        
        Map<String, Sync_User_Field__c> sufMap = new Map<String, Sync_User_Field__c>();
        list<Sync_User_Field__c> sufs = [select id, name, Source_Object_Sync_Field_Name__c, Divide_by_Therm_Factor__c, Multiply_by_Therm_Factor__c 
                                                from Sync_User_Field__c where Field_Type__c = 'Contract' order by name];
        
        for (Sync_User_Field__c suf:sufs){
            sufMap.put(suf.Source_Object_Sync_Field_Name__c, suf);
            system.debug('suf sync field: ' + suf.Source_Object_Sync_Field_Name__c + ', suf name: ' + suf.name);
        }
*/
        for (String str : syncObject.targetFields.keyset()) { 
            Sync_User_Field__c suf;
            try { 
                if(cesc.get(str) != null){ 
                    //system.debug('******The value is not null!!!! ');
                    //system.debug('******* target field name: ' + str);
                    suf = syncObject.UserFieldMapBySourceFieldName.get(str);
                } 
            } catch (Exception e) { System.debug('Error: ' + e); suf=null; }

            //current field is a sync field so insert its value
            if (suf != null){
                Sync_User_Field_Value__c newVal;
                try{
                    newVal = CreateSyncUserFieldvalue(cesc, null, suf, syncObject.targetFields, batch);
                    if (newVal != null){
                        valsToInsert.add(newVal);
                    }
                } catch (exception e){system.debug('Insert Error: ' + e);}
            } 
        }
        if (valsToInsert.size()>0){insert valsToInsert; created = true;}

        return created;
    }

    //creation of sync user field
    public static Sync_User_Field_Value__c CreateSyncUserFieldvalue(CESContract__c cesc, Premises__c prem, Sync_User_Field__c suf, Map<String, Schema.sObjectField> targetFields, id batch){
        Sync_User_Field_Value__c val;
        if (cesc != null){
            string uval;
            integer factor = 1;
            string offCode;
            
            offCode = cesc.CES_Office__r.Customer_Number__c;

            if (offCode == 'MPLS' || offCode == 'LIVE'){
                factor = 10;
            }

            uval = getUserFieldSyncValue(cesc, suf, null, factor, targetFields);

            //create the user field value
            if (uval != null){
                val = new Sync_User_Field_Value__c(Sync_User_Field__c=suf.id, Value__c=uval, CESContract__c=cesc.id);
                if (offCode == 'HOU'){
                    if (suf.Sync_HOU__c){
                        val.Safari_Key__c='Pending-'+offCode;
                        val.Safari_Sync_Status__c='Pending Sync';
                        val.Sync_Batch__c=batch;
                        val.Incremental_Sync_OK__c=true;
                    }
                } else if (offCode == 'LIVE'){
                    if (suf.Sync_LIVE__c){
                        val.Safari_Key__c='Pending-'+offCode;
                        val.Safari_Sync_Status__c='Pending Sync';
                        val.Sync_Batch__c=batch;
                        val.Incremental_Sync_OK__c=true;
                    }
                } else if (offCode == 'MPLS'){
                    if (suf.Sync_MPLS__c){
                        val.Safari_Key__c='Pending-'+offCode;
                        val.Safari_Sync_Status__c='Pending Sync';
                        val.Sync_Batch__c=batch;
                        val.Incremental_Sync_OK__c=true;
                    }
                } else if (offCode == 'STL'){
                    if (suf.Sync_STL__c){
                        val.Safari_Key__c='Pending-'+offCode;
                        val.Safari_Sync_Status__c='Pending Sync';
                        val.Sync_Batch__c=batch;
                        val.Incremental_Sync_OK__c=true;
                    }
                }
                return val;
            }
        }

        return null;
    }

    //update sync user field
    public static Sync_User_Field_Value__c UpdateSyncUserFieldValue(CESContract__c cesc, Premises__c prem, Sync_User_Field__c suf, Sync_User_Field_Value__c sufv, Map<String, Schema.sObjectField> targetFields, string offCode){
        if (cesc != null){
            //this is a contract user field
            string uval;
            integer factor = 1;

            if (offCode == 'MPLS' || offCode == 'LIVE'){
                factor = 10;
            }

            uval = getUserFieldSyncValue(cesc, suf, sufv, factor, targetFields);

            //update the user field value
            if (uval != null){
                sufv.Value__c = uval;
                return sufv;
            }
        }

        return null;
    }

    //get the string representation of the field to be created / updated
    public static String getUserFieldSyncValue(CESContract__c cesc, Sync_User_Field__c suf, Sync_User_Field_Value__c sufv, integer factor, Map<String, Schema.sObjectField> targetFields){
        string uval;
        boolean doDivide = false;
        boolean doMultiply = false;

        //get booleans for update and insert
        if (sufv != null){
            //this is an update
            doDivide = sufv.Sync_User_Field__r.Divide_by_Therm_Factor__c;
            doMultiply = sufv.Sync_User_Field__r.Multiply_by_Therm_Factor__c;
        } else {
            doDivide = suf.Divide_by_Therm_Factor__c;
            doMultiply = suf.Multiply_by_Therm_Factor__c;
        }

        //get source field type and convert as needed
        //convert to string if it is numeric, while accounting for office factor
        Schema.DisplayType valueType = targetFields.get(suf.Source_Object_Sync_Field_Name__c).getDescribe().getType();

        Object value = cesc.get(suf.Source_Object_Sync_Field_Name__c);
        
        if (valueType == Schema.DisplayType.Date) {
            Date dvalue = (Date)value;
            uval = dvalue.format();
        } else if (valueType == Schema.DisplayType.Percent ||
                valueType == Schema.DisplayType.Currency) {
            Decimal decValue = (Decimal)value;
            if (doDivide){uval = String.valueOf(decValue / factor);} 
            else if (doMultiply){uval = String.valueOf(decValue * factor);}
        } else if (valueType == Schema.DisplayType.Double) {
            Decimal decValue = Decimal.valueOf((Double)value);
            if (doDivide){uval = String.valueOf(decValue / factor);}
            else if (doMultiply){uval = String.valueOf(decValue * factor);}
        } else if (valueType == Schema.DisplayType.Integer) {
            Integer intValue = (Integer)value;
            if (doDivide){uval = String.valueOf(intValue / factor);}
            else if (doMultiply){uval = String.valueOf(intValue / factor);}
        } else if (valueType == Schema.DisplayType.String) {
            uval = (String)value;
        } else {
            uval = (String)value;
        }

        return uval;
    }

    //***  SYNC DYNAMIC METHODS TO BE USED FOR ANY sObject
    //building sync field object for use
    public class SyncSObjectUserFieldObject{
        public map<String, Sync_User_Field__c> UserFieldMapBySourceFieldName {get;set;}
        public map<Id, map<String, Sync_User_Field_Value__c>> SOBjectUserFieldValueMap {get;set;}
        public Set<Id> SObjectIdSet {get;set;}
        public map<String, Schema.sObjectField> targetFields {get;set;}

        public SyncSObjectUserFieldObject(map<String, Sync_User_Field__c> sufMap, map<Id, map<String, Sync_User_Field_Value__c>> ufvMap, Set<Id> objIdSet, map<String, Schema.sObjectField> flds){
            UserFieldMapBySourceFieldName = sufMap;
            SObjectUserFieldValueMap = ufvMap;
            SObjectIdSet = objIdSet;
            targetFields = flds;
        }
    }

    public static SyncSObjectUserFieldObject BuildSObjectSyncUserFieldObject(sObject obj, list<sObject> objs, map<Id, String> offMap){
        String objName;
        map<Id, String> offCodeMap;
        if (offMap == null){
            offCodeMap = CESUtilities.getOfficeCodeMap();
        } else {
            offCodeMap = offMap;
        }

        //get the object type name
        if (objs != null){objName = objs[0].getSObjectType().getDescribe().getName();}
        else {objName = obj.getSObjectType().getDescribe().getName();}

        //get object type and fields for change comparison
        Map<String, Schema.sObjectField> targetFields = CESUtilities.getObjectFieldMap(objName);

        //get sync field map
        Map<String, Sync_User_Field__c> sufMap = new Map<String, Sync_User_Field__c>();
        list<Sync_User_Field__c> sufs = [select id, name, Source_Object_Sync_Field_Name__c, Divide_by_Therm_Factor__c, Multiply_by_Therm_Factor__c, Sync_HOU__c, 
                                        Sync_LIVE__c, Sync_MPLS__c, Sync_STL__c, Source_Object_API_Name__c
                                                from Sync_User_Field__c where Source_Object_API_Name__c =: objName order by name];

        //system.debug('*********** building sufMap *******');
        for (Sync_User_Field__c suf:sufs){
            sufMap.put(suf.Source_Object_Sync_Field_Name__c, suf);
            //system.debug('suf sync field: ' + suf.Source_Object_Sync_Field_Name__c + ', suf name: ' + suf.name);
        }

        //get existing sync field values for these objects
        Set<Id> objIdSet = new Set<Id>();
        map<Id, map<String, Sync_User_Field_Value__c>> ufvMap = new map<Id, map<String, Sync_User_Field_Value__c>>();
        
        if (objs != null){
            String sourceName;
            String q;
            //list of contracts was passed so build contract set and value map
            for (sObject o:objs){
                objIdSet.add((Id)o.get('Id'));
                ufvMap.put((Id)o.get('Id'), new map<String, Sync_User_Field_Value__c>{});
            }

            // get ufv source object name for query
            if (objName == 'Account')
                sourceName = 'Account__c';
            else if (objName == 'Premises__c')
                sourceName = 'Premise__c';
            else if (objName == 'Credit')
                sourceName = 'Account_Credit_Approval__c';
            else 
                sourceName = objName;

            // build query string
            q = 'select id, name, Account__c, CESContract__c, Account_Credit_Approval__c, Premise__c, Bill_Group__c, Value__c, Sync_User_Field__c, Sync_User_Field__r.name, Sync_User_Field__r.Source_Object_Sync_Field_Name__c, ' +
                    'Sync_User_Field__r.Divide_by_Therm_Factor__c, Sync_User_Field__r.Multiply_by_Therm_Factor__c, Sync_User_Field__r.Sync_HOU__c, Sync_User_Field__r.Sync_LIVE__c, Sync_User_Field__r.Sync_MPLS__c, ' +
                    'Sync_User_Field__r.Sync_STL__c, Delete_Me__c from Sync_User_Field_Value__c where ' + sourceName + ' in: objIdSet order by ' + sourceName + ', Sync_User_Field__r.name';

            list<Sync_User_Field_Value__c> ufVals = new list<Sync_User_Field_Value__c>();
            //query the database
            ufVals = database.query(q);
            if (ufVals.size()>0){
                for (Sync_User_Field_Value__c ufv:ufVals){
                    //system.debug(ufv);
                    ufvMap.get((Id)ufv.get(sourceName)).put(ufv.Sync_User_Field__r.Source_Object_Sync_Field_Name__c,ufv);
                }
            }
        }
        else {
            //only one contract was passed, which is for contract creation, so do not build value map
            objIdSet = null;
            ufvMap = null;
        }

        SyncSObjectUserFieldObject sufObject = new SyncSObjectUserFieldObject(sufMap, ufvMap, objIdSet, targetFields);

        return sufObject;
    }
    //end of sync field object creation

    //run through all fields of an object after activation to see what sync user fields need to be created
    //and then create them
    // this is old method
    public static boolean BuildSObjectSyncUserFieldValues1(sObject obj, id batch, string offCode){
        boolean created = false;
        list<Sync_User_Field_Value__c> valsToInsert = new list<Sync_User_Field_Value__c>();
        
        //get object type and fields for comparison
        SyncSObjectUserFieldObject syncObject = BuildSObjectSyncUserFieldObject(obj, null, null);

        for (String str : syncObject.targetFields.keyset()) { 
            Sync_User_Field__c suf;
            try { 
                if(obj.get(str) != null){ 
                    //system.debug('******The value is not null!!!! ');
                    //system.debug('******* target field name: ' + str);
                    suf = syncObject.UserFieldMapBySourceFieldName.get(str);
                } 
            } catch (Exception e) { System.debug('Error: ' + e); suf=null; }

            //current field is a sync field so insert its value
            if (suf != null){
                Sync_User_Field_Value__c newVal;
                try{
                    newVal = CreateSyncUserFieldvalueDynamic(obj, suf, syncObject.targetFields, batch, offCode);
                    if (newVal != null){
                        valsToInsert.add(newVal);
                    }
                } catch (exception e){system.debug('Insert Error: ' + e);}
            } 
        }
        if (valsToInsert.size()>0){system.debug(valsToInsert.size()); insert valsToInsert; created = true;}

        return created;
    }

    // method will take list or single object and build user field values
    public static boolean BuildSObjectSyncUserFieldValues(sObject obj, list<sObject> objs, id batch, string offCode){
        boolean created = false;
        SyncSObjectUserFieldObject syncObject;
        list<Sync_User_Field_Value__c> valsToInsert = new list<Sync_User_Field_Value__c>();
        list<sObject> objsToUpdate = new list<sObject>();
        Integer valCount = 0;
        
        // get object type and fields for comparison
        // then get the list of user field value records to create
        if (objs != null){
            syncObject = BuildSObjectSyncUserFieldObject(objs[0], null, null);

            for (sObject o:objs){
                // get the field value records
                valsToInsert.addAll(BuildSObjectSyncUserFieldValueList(o, syncObject, batch, offCode));

                // if records were created, mark object accordingly
                if (valsToInsert.size() > valCount){
                    system.debug('values to insert size: ');
                    system.debug(valsToInsert.size());

                    o.put('Sync_Field_Values_Created__c',true);
                    objsToUpdate.add(o);

                    // add to valCount
                    valCount += valsToInsert.size();
                }
            }
        } else {
            syncObject = BuildSObjectSyncUserFieldObject(obj, null, null);

            valsToInsert = BuildSObjectSyncUserFieldValueList(obj, syncObject, batch, offCode);
            if (valsToInsert.size()>0){
                obj.put('Sync_Field_Values_Created__c',true);
                objsToUpdate.add(obj);
            }
        }

        // insert the list of user field value records
        if (valsToInsert.size()>0){system.debug(valsToInsert.size()); insert valsToInsert;}

        // update objects marked as field values created
        if (objsToUpdate.size()>0){update objsToUpdate; created=true;}

        // return if records were created or not
        return created;
    }

    public static list<Sync_User_Field_Value__c> BuildSObjectSyncUserFieldValueList(sObject obj, SyncSObjectUserFieldObject syncObject, id batch, string offCode){
        list<Sync_User_Field_Value__c> valsToInsert = new list<Sync_User_Field_Value__c>();
        
        for (String str : syncObject.targetFields.keyset()) { 
            Sync_User_Field__c suf;
            try { 
                if(obj.get(str) != null){ 
                    //system.debug('******The value is not null!!!! ');
                    //system.debug('******* target field name: ' + str);
                    suf = syncObject.UserFieldMapBySourceFieldName.get(str);
                } 
            } catch (Exception e) { System.debug('Error: ' + e); suf=null; }

            //current field is a sync field so insert its value
            if (suf != null){
                Sync_User_Field_Value__c newVal;
                try{
                    newVal = CreateSyncUserFieldvalueDynamic(obj, suf, syncObject.targetFields, batch, offCode);
                    if (newVal != null){
                        valsToInsert.add(newVal);
                    }
                } catch (exception e){system.debug('Insert Error: ' + e);}
            } 
        }
        
        return valsToInsert;
    }

    //creation of sync user field
    public static Sync_User_Field_Value__c CreateSyncUserFieldvalueDynamic(sObject obj, Sync_User_Field__c suf, Map<String, Schema.sObjectField> targetFields, id batch, string offCode){
        Sync_User_Field_Value__c val;

        string uval;
        integer factor = 1;

        if (offCode == 'MPLS' || offCode == 'LIVE'){
            factor = 10;
        }

        uval = getUserFieldSyncValueDynamic(obj, suf, null, factor, targetFields);

        //create the user field value
        if (uval != null && uval != 'DeleteMe'){ // only process creations if value exists and isnt a deletion
            val = new Sync_User_Field_Value__c(Sync_User_Field__c=suf.id, Value__c=uval);

            // set source id
            string objName = obj.getSObjectType().getDescribe().getName();
            if (objName == 'Account')
                val.Account__c = (Id)obj.get('Id');
            else if (objName == 'Bill_Group__c')
                val.Bill_Group__c = (Id)obj.get('Id');
            else if (objName == 'Premises__c')
                val.Premise__c = (Id)obj.get('Id');
            else if (objName == 'CESContract__c')
                val.CESContract__c = (Id)obj.get('Id');
            else if (objName == 'Account_Credit_Approval__c')
                val.Account_Credit_Approval__c = (Id)obj.get('Id');

            system.debug(objName);
            // set office sync specifics if batch was passed
            if (batch != null){
                if (offCode == 'HOU'){
                    if (suf.Sync_HOU__c){
                        val.Safari_Key__c='Pending-'+offCode;
                        val.Safari_Sync_Status__c='Pending Sync';
                        val.Sync_Batch__c=batch;
                        val.Incremental_Sync_OK__c=true;
                    }
                } else if (offCode == 'LIVE'){
                    if (suf.Sync_LIVE__c){
                        val.Safari_Key__c='Pending-'+offCode;
                        val.Safari_Sync_Status__c='Pending Sync';
                        val.Sync_Batch__c=batch;
                        val.Incremental_Sync_OK__c=true;
                    }
                } else if (offCode == 'MPLS'){
                    if (suf.Sync_MPLS__c){
                        val.Safari_Key__c='Pending-'+offCode;
                        val.Safari_Sync_Status__c='Pending Sync';
                        val.Sync_Batch__c=batch;
                        val.Incremental_Sync_OK__c=true;
                    }
                } else if (offCode == 'STL'){
                    if (suf.Sync_STL__c){
                        val.Safari_Key__c='Pending-'+offCode;
                        val.Safari_Sync_Status__c='Pending Sync';
                        val.Sync_Batch__c=batch;
                        val.Incremental_Sync_OK__c=true;
                    }
                }
            }
            return val;
        }

        return null;
    }

    //update sync user field
    public static Sync_User_Field_Value__c UpdateSyncUserFieldValueDynamic(sObject obj, Sync_User_Field__c suf, Sync_User_Field_Value__c sufv, Map<String, Schema.sObjectField> targetFields, string offCode){

        string uval;
        integer factor = 1;

        if (offCode == 'MPLS' || offCode == 'LIVE'){
            factor = 10;
        }

        uval = getUserFieldSyncValueDynamic(obj, suf, sufv, factor, targetFields);

        //update the user field value
        if (uval != null){
            if (uval == 'DeleteMe'){
                sufv.Delete_Me__c = true;
            } else {
                sufv.Delete_Me__c = false;
                sufv.Value__c = uval;
            }
            return sufv;
        }

        return null;
    }

    //get the string representation of the field to be created / updated
    public static String getUserFieldSyncValueDynamic(sObject obj, Sync_User_Field__c suf, Sync_User_Field_Value__c sufv, integer factor, Map<String, Schema.sObjectField> targetFields){
        string uval;
        boolean doDivide = false;
        boolean doMultiply = false;

        //get booleans for update and insert
        if (sufv != null){
            //this is an update
            doDivide = sufv.Sync_User_Field__r.Divide_by_Therm_Factor__c;
            doMultiply = sufv.Sync_User_Field__r.Multiply_by_Therm_Factor__c;
        } else {
            doDivide = suf.Divide_by_Therm_Factor__c;
            doMultiply = suf.Multiply_by_Therm_Factor__c;
        }
        system.debug(doDivide); system.debug(doMultiply);

        //get source field type and convert as needed
        //convert to string if it is numeric, while accounting for office factor
        Schema.DisplayType valueType = targetFields.get(suf.Source_Object_Sync_Field_Name__c).getDescribe().getType();

        Object value = obj.get(suf.Source_Object_Sync_Field_Name__c);
        
        if (value == null){return 'DeleteMe';}
        if (value == false){return 'DeleteMe';}
        if (valueType == Schema.DisplayType.Date) {
            Date dvalue = (Date)value;
            uval = dvalue.format();
        } else if (valueType == Schema.DisplayType.Percent ||
                valueType == Schema.DisplayType.Currency) {
            Decimal decValue = (Decimal)value;
            if (doDivide){uval = String.valueOf(decValue / factor);} 
            else if (doMultiply){uval = String.valueOf(decValue * factor);}
            else {uval = String.valueOf(decValue);}
        } else if (valueType == Schema.DisplayType.Double) {
            Decimal decValue = Decimal.valueOf((Double)value);
            if (doDivide){uval = String.valueOf(decValue / factor);}
            else if (doMultiply){uval = String.valueOf(decValue * factor);}
            else {uval = String.valueOf(decValue);}
        } else if (valueType == Schema.DisplayType.Integer) {
            Integer intValue = (Integer)value;
            if (doDivide){uval = String.valueOf(intValue / factor);}
            else if (doMultiply){uval = String.valueOf(intValue / factor);}
            else {uval = String.valueOf(intValue);}
        } else if (valueType == Schema.DisplayType.String) {
            uval = (String)value;
        } else if (valueType == Schema.DisplayType.Boolean) {
            if (value == true){uval = 'Yes';} else {uval = 'No';}
        } else {
            uval = (String)value;
        }

        return uval;
    }

    public static void upsertObjectSUFvalues(list<sObject> objs, map<id, sObject> oldmap, boolean createRecordProc){
        map<Id, String> offCodeMap = new map<Id, String>();
        String safariKeyFieldName;

        //get office list and make a map
        offCodeMap = CESUtilities.getOfficeCodeMap();

        //**** get object type and fields for user field change comparison ****
        list<Sync_User_Field_Value__c> valsToUpdate = new list<Sync_User_Field_Value__c>();
        list<Sync_User_Field_Value__c> valsToInsert = new list<Sync_User_Field_Value__c>();

        //**** list of record processings to create ****
        list<Record_Processing__c> procsToInsert = new list<Record_Processing__c>();

        CESDataSyncUtilities.SyncsObjectUserFieldObject syncObject = CESDataSyncUtilities.BuildsObjectSyncUserFieldObject(null, objs, offCodeMap);

        // determine object type and set field names
        string objName = objs[0].getSObjectType().getDescribe().getName();
        if (objName == 'Account')
            safariKeyFieldName = '_ID__c'; // need to append office code to this field name
        else if (objName == 'Bill_Group__c')
            safariKeyFieldName = 'Safari_ID__c';
        else if (objName == 'Premises__c')
            safariKeyFieldName = 'Safari_Premise_Key__c';
        else if (objName == 'CESContract__c')
            safariKeyFieldName = 'Safari_Key__c';

        // cycle through objects and update user fields as needed
        for (sObject cip:objs){
            sObject oldcip = oldmap.get((Id)cip.get('id'));

            string offCode = null;
            try {
                offCode = offCodeMap.get((Id)cip.get('CES_Office__c'));
                if (objName == 'Account'){safariKeyFieldName = offCode + safariKeyFieldName;}
            } catch (exception e) {offCode = null;}

            //**** process user field changes ****
            //look to see if user fields have been previously created (on the old version, not updated to avoid activation updates firing this twice) and if they have changed with this update
            // *** TRY LOOKING FOR SAFARI PREMISE KEY ONLY HERE.  THEN DO THE FIELD REVIEW, UPDATE AND INSERT ***
            if (cip.get(safariKeyFieldName) != null){
                boolean checkAllUserFields = false;

                if (oldcip.get(safariKeyFieldName) == null){// if this update is to set pending-sync, then check all fields regardless of value change
                    checkAllUserFields = true;
                }
            //if (oldcip.Sync_Field_Values_Created__c){
                //field values have been created so now look for changes
                for (String str : syncObject.targetFields.keyset()) { 
                    Sync_User_Field__c suf;
                    try { 
                        // value changed, get the field value record.  new process will treat nulls as deletions
                        //if(cip.get(str) != oldcip.get(str) && cip.get(str) != null){ 
                        // *** check all non null fields if this is first sync, otherwise only check fields that have changed
                        if((checkAllUserFields && (cip.get(str) != null || oldcip.get(str) != null)) || (cip.get(str) != oldcip.get(str))){ 
                            suf = syncObject.UserFieldMapBySourceFieldName.get(str);
                        } 
                    } catch (Exception e) { System.debug('Error: ' + e); suf=null; }

                    //changed value is for a sync field so update it
                    if (suf != null){
                        Sync_User_Field_Value__c valFromMap;
                        try {
                            valFromMap = syncObject.SObjectUserFieldValueMap.get((Id)cip.get('id')).get(str);
                            system.debug(valFromMap);
                        } catch (exception e) {valFromMap = null;}
                        if (valFromMap != null){
                            try {
                                Sync_User_Field_Value__c sval = CESDataSyncUtilities.UpdateSyncUserFieldValueDynamic(cip, suf, valFromMap, syncObject.targetFields, offCode);
                                if (sval != null){
                                    valsToUpdate.add(sval);
                                }
                            } catch (exception e) {system.debug('Update Error: ' + e);}
                        } else {
                            // *** logic to create new sync field value from source object ***
                            valsToInsert.add(CESDataSyncUtilities.CreateSyncUserFieldvalueDynamic(cip, suf, syncObject.targetFields, null, offCode));
                        }
                    } 
                }
            }

            // create record processing to verify sync to safari.  only do it for updates after original sync
            if (createRecordProc){
                String safKey = (String)oldcip.get(safariKeyFieldName);
                if (oldcip.get(safariKeyFieldName) != null && !safKey.startsWith('Pending')){
                    Record_Processing__c proc = new Record_Processing__c(Bill_Group__c=(Id)cip.get('id'), External_ID__c=(String)oldcip.get(safariKeyFieldName), Object_Type__c=objName, Operation_Type__c='Update');
                    procsToInsert.add(proc);
                }
            }
        }

        // MOD: check for null in addition to list containing 0 items
        if (valsToUpdate != null && valsToUpdate.size()>0){update valsToUpdate;} 
        if (valsToInsert != null && valsToInsert.size()>0){insert valsToInsert;}

        if (procsToInsert != null && procsToInsert.size()>0){insert procsToInsert;}
    }


    //*****************************************************************************************************************************
    //****Old Sync User Field Stuff************************************************************************************************
    //*****************************************************************************************************************************
    /*
    public static boolean BuildContractSyncUserFieldValues(CESContract__c cesc, id batch){
        list<Sync_User_Field__c> fields = new list<Sync_User_Field__c>();
        map<String, Sync_User_Field__c> fieldMap = new map<String,Sync_User_Field__c>();
        list<Sync_User_Field_Value__c> vals = new list<Sync_User_Field_Value__c>();
        Sync_User_Field_Value__c val;
        string office;
        integer factor;
        boolean created = false;

        office = cesc.CES_Office__r.Customer_Number__c;
        if (office == 'MPLS' || office == 'LIVE'){
            factor = 10;
        } else {
            factor = 1;
        }

        fields = [select id, name, Field_Type__c from Sync_User_Field__c where Field_Type__c = 'Contract' OR Field_Type__c = null];

        if (fields.size() > 0){
            for (Sync_User_Field__c f:fields){
                fieldMap.put(f.name,f);
            }

            //create a value for each populated user field
            if (cesc.UDF_Agency__c != null){
                val = CreateSyncUserFieldValue(cesc, null, office, fieldMap, 'Agency', cesc.UDF_Agency__c, batch);
                if (val != null){ vals.add(val); }
            }

            if (cesc.UDF_All_Product_Type__c != null){
                val = CreateSyncUserFieldValue(cesc, null, office, fieldMap, 'AllProductType', cesc.UDF_All_Product_Type__c, batch);
                if (val != null){ vals.add(val); }
            }

            if (cesc.UDF_Base_Contract__c != null){
                val = CreateSyncUserFieldValue(cesc, null, office, fieldMap, 'Base Contract', cesc.UDF_Base_Contract__c, batch);
                if (val != null){ vals.add(val); }
            }

            if (cesc.UDF_CESUM__c != null){
                val = CreateSyncUserFieldValue(cesc, null, office, fieldMap, 'CESUM', string.valueOf(cesc.UDF_CESUM__c / factor), batch);
                if (val != null){ vals.add(val); }
            }

            if (cesc.Consultant_Unit_Margin__c != null){
                val = CreateSyncUserFieldValue(cesc, null, office, fieldMap, 'CUM', string.valueOf(cesc.Consultant_Unit_margin__c / factor), batch);
                if (val != null){ vals.add(val); }
            }

            if (cesc.UDF_Contract_Version__c != null){
                val = CreateSyncUserFieldValue(cesc, null, office, fieldMap, 'Contract Version', cesc.UDF_Contract_Version__c, batch);
                if (val != null){ vals.add(val); }
            }

            if (cesc.UDF_DealTranType__c != null){
                val = CreateSyncUserFieldValue(cesc, null, office, fieldMap, 'DealTranType', cesc.UDF_DealTranType__c, batch);
                if (val != null){ vals.add(val); }
            }

            if (cesc.Delivery_Point__c != null){
                val = CreateSyncUserFieldValue(cesc, null, office, fieldMap, 'Delivery Point', cesc.Delivery_Point__c, batch);
                if (val != null){ vals.add(val); }
            }

            if (cesc.UDF_GUM__c != null){
                val = CreateSyncUserFieldValue(cesc, null, office, fieldMap, 'GUM', string.valueOf(cesc.UDF_GUM__c / factor), batch);
                if (val != null){ vals.add(val); }
            }

            if (cesc.UDF_Product_Type__c != null){
                val = CreateSyncUserFieldValue(cesc, null, office, fieldMap, 'Product Type', cesc.UDF_Product_Type__c, batch);
                if (val != null){ vals.add(val); }
            }

            if (cesc.UDF_Storage_Val__c != null && cesc.UDF_Storage_Val__c == 'Yes'){
                val = CreateSyncUserFieldValue(cesc, null, office, fieldMap, 'Storage Val', cesc.UDF_Storage_Val__c, batch);
                if (val != null){ vals.add(val); }
            }

            if (cesc.UDF_Telemetry__c != null && cesc.UDF_Telemetry__c == 'Yes'){
                val = CreateSyncUserFieldValue(cesc, null, office, fieldMap, 'Telemetry', cesc.UDF_Telemetry__c, batch);
                if (val != null){ vals.add(val); }
            }

            if (cesc.UDF_GUM__c != null){
                val = CreateSyncUserFieldValue(cesc, null, office, fieldMap, 'TGUM', string.valueOf(cesc.UDF_GUM__c / factor), batch);
                if (val != null){ vals.add(val); }
            }

            if (cesc.UDF_Transport_Fuel__c != null && cesc.UDF_Transport_Fuel__c == 'Yes'){
                val = CreateSyncUserFieldValue(cesc, null, office, fieldMap, 'Transport Fuel', cesc.UDF_Transport_Fuel__c, batch);
                if (val != null){ vals.add(val); }
            }

            if (cesc.UDF_Upstream_Transport__c != null){
                val = CreateSyncUserFieldValue(cesc, null, office, fieldMap, 'Upstream Transport', cesc.UDF_Upstream_Transport__c, batch);
                if (val != null){ vals.add(val); }
            }

            if (cesc.Utility_Balancing__c != null){
                val = CreateSyncUserFieldValue(cesc, null, office, fieldMap, 'Utility Balancing', cesc.Utility_Balancing__c, batch);
                if (val != null){ vals.add(val); }
            }

            if (cesc.Utility_Cashout__c != null){
                val = CreateSyncUserFieldValue(cesc, null, office, fieldMap, 'Utility Cashout', cesc.Utility_Cashout__c, batch);
                if (val != null){ vals.add(val); }
            }

            if (cesc.UDF_Utility_Meter_Read__c != null){
                val = CreateSyncUserFieldValue(cesc, null, office, fieldMap, 'Utility Meter Read', cesc.UDF_Utility_Meter_Read__c, batch);
                if (val != null){ vals.add(val); }
            }

            if (cesc.UDF_Utility_Transport__c != null){
                val = CreateSyncUserFieldValue(cesc, null, office, fieldMap, 'Utility Transport', cesc.UDF_Utility_Transport__c, batch);
                if (val != null){ vals.add(val); }
            }
            
            if (vals.size() > 0){insert vals; created=true;}
        }
        return created;
    }
    
    public static Sync_User_Field_Value__c CreateSyncUserFieldValue2(CESContract__c cesc, Premises__c prem, string office, map<String, Sync_User_Field__c> fieldMap, string fieldName, string fieldValue, id batch){
        Sync_User_Field__c fld;
        Sync_User_Field_Value__c val;

        try{
            fld = fieldMap.get(fieldName);
            if (fld != null){
                val = new Sync_User_Field_Value__c(Sync_User_Field__c=fld.id, Safari_Key__c='Pending-' + office,
                                                    Safari_Sync_Status__c='Pending Sync', Value__c=fieldValue, Sync_Batch__c=batch);
                if (cesc != null){val.CESContract__c=cesc.id;}
                if (prem != null){val.Premise__c=prem.id;}
            }
        } catch (exception e){}

        return val;
    }

    public static Sync_User_Field_Value__c UpdateSyncUserFieldValue2(CESContract__c cesc, Premises__c prem, Sync_User_Field__c suf, Sync_User_Field_Value__c sufv, string offCode){
        if (cesc != null){
            //this is a contract user field
            string uval;
            integer factor = 1;

            if (offCode == 'MPLS' || offCode == 'LIVE'){
                factor = 10;
            }

            //get source field type and convert as needed
            //convert to string if it is numeric, while accounting for office factor
            Schema.SObjectType targetType = Schema.getGlobalDescribe().get('CESContract__c');
            Map<String, Schema.sObjectField> targetFields = targetType.getDescribe().fields.getMap();
            Schema.DisplayType valueType = targetFields.get(suf.Source_Object_Sync_Field_Name__c).getDescribe().getType();

            Object value = cesc.get(suf.Source_Object_Sync_Field_Name__c);
            
            if (valueType == Schema.DisplayType.Date) {
                Date dvalue = (Date)value;
                uval = dvalue.format();
            } else if (valueType == Schema.DisplayType.Percent ||
                    valueType == Schema.DisplayType.Currency) {
                Decimal decValue = (Decimal)value;
                if (sufv.Sync_User_Field__r.Divide_by_Therm_Factor__c){uval = String.valueOf(decValue / factor);} 
                else if (sufv.Sync_User_Field__r.Multiply_by_Therm_Factor__c){uval = String.valueOf(decValue * factor);}
            } else if (valueType == Schema.DisplayType.Double) {
                Decimal decValue = Decimal.valueOf((Double)value);
                if (sufv.Sync_User_Field__r.Divide_by_Therm_Factor__c){uval = String.valueOf(decValue / factor);}
                else if (sufv.Sync_User_Field__r.Multiply_by_Therm_Factor__c){uval = String.valueOf(decValue * factor);}
            } else if (valueType == Schema.DisplayType.Integer) {
                Integer intValue = (Integer)value;
                if (sufv.Sync_User_Field__r.Divide_by_Therm_Factor__c){uval = String.valueOf(intValue / factor);}
                else if (sufv.Sync_User_Field__r.Multiply_by_Therm_Factor__c){uval = String.valueOf(intValue / factor);}
            } else if (valueType == Schema.DisplayType.String) {
                uval = (String)value;
            } else {
                uval = (String)value;
            }

            //update the user field value
            if (uval != null){
                sufv.Value__c = uval;
                return sufv;
            }
        }

        return null;
    }*/


    //*** OLD STUFF ***

    /*
    public static void CreateSyncBatchScheduledChatter(id bId){
        Sync_Batch__c batch;
        list<User_Office__c> userOffs = new list<User_Office__c>();
        list<Id> uIds = new list<Id>();

        batch = [select id, name, CES_Office__c from Sync_Batch__c where id=:bId];
        userOffs = [select id, name, User__c from User_Office__c where CES_Office__c =: batch.CES_Office__c order by User__c];
        if (userOffs.size()>0){
            for (User_Office__c uo:userOffs){
                uIds.add(uo.User__c);
            }

            ChatterUtils.multiMentionOnRecord(batch.id, uIds, ' this Sync Batch has been successfully scheduled to run in the next Safari syncronization process');
        }
    }
    
    public static void CreateSyncBatchStatusChatters(string format){
        list<Sync_Batch__c> batches = new list<Sync_Batch__c>();
        list<Account> offices = new list<Account>();
        map<id, list<Id>> offUsers = new map<id, list<Id>>();
        list<Sync_Batch__c> batchesToUpdate = new list<Sync_Batch__c>();
        string text;        

        if (format == 'Complete'){
            batches = [select id, name, CES_Office__c, CES_Office__r.Customer_Number__c, Status__c, Email_Sent__c from Sync_Batch__c where Status__c = 'Complete' and Email_Sent__c = false
                        order by CES_Office__c, name];
            text = ' this Sync Batch has completed successfully';
        } else if (format == 'Error'){
            batches = [select id, name, CES_Office__c, CES_Office__r.Customer_Number__c, Status__c, Email_Sent__c from Sync_Batch__c where Status__c = 'Started' and CreatedDate <=: datetime.now().addMinutes(-30) 
                        order by CES_Office__c, name];
            text = ' this Sync Batch has errors and requires data review';
        } else if (format == 'Started'){
            batches = [select id, name, CES_Office__c, CES_Office__r.Customer_Number__c, Status__c, Email_Sent__c from Sync_Batch__c where Status__c = 'Started' and Started_Email_Sent__c = false 
                        order by CES_Office__c, name];
            text = ' this Sync Batch processing has begun';
        }
        
        offices = [select id, name from Account where Record_Type_Name__c = 'CES_Location' order by id];
        for (Account o:offices){
            list<User_Office__c> uos = new list<User_Office__c>();
            list<Id> uIds = new list<Id>();

            uos = [select id, name, User__c from User_Office__c where CES_Office__c =:o.id order by User__c];
            for (User_Office__c uo:uos){
                uIds.add(uo.User__c);
            }
            offUsers.put(o.id,uIds);
        }
        
        if (batches.size()>0){
            for (Sync_Batch__c b: batches){
                list<Id> uIds = new list<Id>();
                try {
                    uIds = offUsers.get(b.CES_Office__c);
                } catch (exception e){}
                if (uIds.size()>0){
                    ChatterUtils.multiMentionOnRecord(b.id, uIds, text);
                    batchesToUpdate.add(b);
                }
            }

            if (batchesToUpdate.size()>0){
                if (format == 'Complete'){//update status only if this is a complete email
                    for (Sync_Batch__c b:batchesToUpdate){
                        b.Email_Sent__c = true;
                    }
                    update batchesToUpdate;
                }
                if (format == 'Started'){//update status only if this is a started email
                    for (Sync_Batch__c b:batchesToUpdate){
                        b.Started_Email_Sent__c = true;
                    }
                    update batchesToUpdate;
                }
            }
        }
    }

    public static void CheckSyncBatchStatus(id bId){
        Sync_Batch__c batch;
        list<Sync_Batch_Account__c> sbas = new list<Sync_Batch_Account__c>();
        set<Id> acctIdSet = new set<Id>();
        list<Account> ass = new list<Account>();
        list<Bill_Group__c> bgs = new list<Bill_Group__c>();
        list<Premises__c> prems = new list<Premises__c>();
        list<Monthly_Usage__c> mus = new list<Monthly_Usage__c>();
        list<Position__c> pos = new list<Position__c>();
        list<Contract_Premise__c> cps = new list<Contract_Premise__c>();
        list<Premise_Status__c> pStats = new list<Premise_Status__c>();
        boolean isComplete = true;

        batch = [select id, name, CES_Office__c, CES_Office__r.Customer_Number__c, Status__c, Email_Sent__c from Sync_Batch__c where id=:bId];

        sbas = [select id, Account__c from Sync_Batch_Account__c where Sync_Batch__c =:bId];//check accounts
        if (sbas.size()>0){
            for (Sync_Batch_Account__c sba:sbas){
                acctIdSet.add(sba.Account__c);
            }
            ass = database.query('select id from Account where id in:acctIdSet and Safari_'+batch.CES_Office__r.Customer_Number__c+'_Sync_Status__c !=\'Sync Complete\' ');
            if (ass.size()>0){
                isComplete = false;
            }
        }

        bgs = [select id from Bill_Group__c where Sync_Batch__c =:bId and Safari_Sync_Status__c != 'Sync Complete'];
        if (bgs.size()>0){ isComplete = false;}

        prems = [select id from Premises__c where Sync_Batch__c =:bId and Safari_Sync_Status__c != 'Sync Complete'];
        if (prems.size()>0){ isComplete = false;}

        mus = [select id from Monthly_Usage__c where Sync_Batch__c =:bId and Safari_Sync_Status__c != 'Sync Complete'];
        if (mus.size()>0){ isComplete = false;}

        pos = [select id from Position__c where Sync_Batch__c =:bId and Safari_Sync_Status__c != 'Sync Complete'];
        if (pos.size()>0){ isComplete = false;}

        cps = [select id from Contract_Premise__c where Sync_Batch__c =:bId and Safari_Sync_Status__c != 'Sync Complete'];
        if (cps.size()>0){ isComplete = false;}

        pStats = [select id from Premise_Status__c where Sync_Batch__c =:bId and Safari_Sync_Status__c != 'Sync Complete'];
        if (pStats.size()>0){ isComplete = false;}

        if (isComplete){
            batch.Status__c = 'Complete';
            update batch;
        }
    }
    */

    /*
    public static void SendSyncBatchScheduledEmail(id bId){
        Contact offCon;
        Sync_Batch__c batch;
        list<Messaging.SingleEmailMessage> theEmails = new list<Messaging.SingleEmailMessage>();

        batch = [select id, name, CES_Office__c from Sync_Batch__c where id=:bId];
        offCon = [select id, name, Email, AccountId, Account.Name from Contact where AccountId =: batch.CES_Office__c and LastName =: 'Admin' limit 1];

        if (offCon!=null){
            try{
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String body = 'Sync Batch # ' + batch.name + ' has been successfully scheduled by ' + offCon.name + ' to run in the next safari syncronization process.  ';
                String hBody = '';
                
                hBody += '<b><a href=https://na1.salesforce.com/' + batch.Id + '>' + 'Click here to view Sync Batch # ' + batch.name + '</b> <p>';

                mail.setTargetObjectId(offCon.id);
                mail.setOrgWideEmailAddressId('0D230000000L03v');
                mail.setSubject('Sync Batch #' + batch.name + ' scheduled successfully!');
                mail.setPlainTextBody(body);
                mail.setHtmlBody(body + '<p>' + hBody);
                theEmails.add(mail);
            } catch (exception e){}
            
            if (theEmails.size()>0){
                list<Messaging.Email> allMails = new list<Messaging.Email>();
                for (Messaging.SingleEmailMessage mess: theEmails){
                    allMails.add(mess);
                }

                Messaging.SendEmailResult[] results = Messaging.sendEmail(allMails);
            }
        }
    }

    public static void SendSyncBatchCompletedEmail(){
        list<Sync_Batch__c> batches = new list<Sync_Batch__c>();
        map<id, list<String>> offEmail = new map<id, list<String>>();
        map<id, id> offContactID = new map<id, id>();
        list<CESContract__c> cons = new list<CESContract__c>();
        list<Contact> offCons = new list<Contact>();
        map<id, list<Sync_Batch__c>> offBatches = new map<id, list<Sync_Batch__c>>();
        list<Messaging.SingleEmailMessage> theEmails = new list<Messaging.SingleEmailMessage>();
        list<Sync_Batch__c> batchesToUpdate = new list<Sync_Batch__c>();


        batches = [select id, name, CES_Office__c, CES_Office__r.Customer_Number__c, Status__c, Email_Sent__c from Sync_Batch__c where Status__c = 'Complete' and Email_Sent__c = false
                    order by CES_Office__c, name];
        offCons = [select id, name, Email, AccountId, Account.Name from Contact where Account.Record_Type_Name__c =: 'CES_Location' and LastName =: 'Admin' order by Account.Name];

        if (batches.size()>0){
            list<Sync_Batch__c> bs = new list<Sync_Batch__c>();
            String currOff = null;

            for (Sync_Batch__c b: batches){
                if (currOff == null){ //first record of the loop
                    currOff = b.CES_Office__c;
                    bs.add(b);
                }
                else if(currOff == b.CES_Office__c){ //this record is the same office as last so add to existing list
                    bs.add(b);
                }
                else{//this record has a different office so add existing list with old office and start new list for this office
                    offBatches.put((id)currOff,bs);
                    bs = new list<Sync_Batch__c>();
                    currOff = b.CES_Office__c;
                    bs.add(b);
                }
            }
            //add the last iteration to the map
            offBatches.put((id)currOff,bs);


            for (Contact oc: offCons){
                list<Sync_Batch__c> eBatches = new list<Sync_Batch__c>();
                try{
                    eBatches = offBatches.get(oc.AccountId);
                    if (eBatches.size()>0){
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        String body = 'The following ' + oc.Account.Name + ' Sync Batches have completed successfully:  ';
                        String pBody = '';
                        String hBody = '';
                        
                        for (Sync_Batch__c eb: eBatches){
                            hBody += '<b><a href=https://na1.salesforce.com/' + eb.Id + '>Sync Batch #' + eb.Name + '</b> <p>';
                            pBody += 'Sync Batch #' + eb.Name + '\r\n';
                            batchesToUpdate.add(eb);
                        }

                        mail.setTargetObjectId(oc.Id);
                        mail.setOrgWideEmailAddressId('0D230000000L03v');
                        mail.setSubject(oc.Account.Name + ': ' + eBatches.size() + ' Sync Batches completed successfully!');
                        mail.setPlainTextBody(body + '\r\n' + pBody);
                        mail.setHtmlBody(body + '<p>' + hBody);
                        theEmails.add(mail);
                    }
                } catch (exception e){}
            }

            list<Messaging.Email> allMails = new list<Messaging.Email>();
            for (Messaging.SingleEmailMessage mess: theEmails){
                allMails.add(mess);
            }

            Messaging.SendEmailResult[] results = Messaging.sendEmail(allMails);

            if (batchesToUpdate.size()>0){
                for (Sync_Batch__c b:batchesToUpdate){
                    b.Email_Sent__c = true;
                }
                update batchesToUpdate;
            }
        }
    }

    public static void SendSyncBatchEmail(string format){
        list<Sync_Batch__c> batches = new list<Sync_Batch__c>();
        map<id, list<String>> offEmail = new map<id, list<String>>();
        map<id, id> offContactID = new map<id, id>();
        list<CESContract__c> cons = new list<CESContract__c>();
        list<Contact> offCons = new list<Contact>();
        map<id, list<Sync_Batch__c>> offBatches = new map<id, list<Sync_Batch__c>>();
        list<Messaging.SingleEmailMessage> theEmails = new list<Messaging.SingleEmailMessage>();
        list<Sync_Batch__c> batchesToUpdate = new list<Sync_Batch__c>();
        string text;

        if (format == 'Complete'){
            batches = [select id, name, CES_Office__c, CES_Office__r.Customer_Number__c, Status__c, Email_Sent__c from Sync_Batch__c where Status__c = 'Complete' and Email_Sent__c = false
                        order by CES_Office__c, name];
            text = 'Sync Batches have completed successfully';
        } else if (format == 'Error'){
            batches = [select id, name, CES_Office__c, CES_Office__r.Customer_Number__c, Status__c, Email_Sent__c from Sync_Batch__c where Status__c = 'Started' and CreatedDate <=: datetime.now().addMinutes(-30) 
                        order by CES_Office__c, name];
            text = 'Sync Batches have errors and require data review';
        }
        offCons = [select id, name, Email, AccountId, Account.Name from Contact where Account.Record_Type_Name__c =: 'CES_Location' and LastName =: 'Admin' order by Account.Name];

        if (batches.size()>0){
            list<Sync_Batch__c> bs = new list<Sync_Batch__c>();
            String currOff = null;

            for (Sync_Batch__c b: batches){
                if (currOff == null){ //first record of the loop
                    currOff = b.CES_Office__c;
                    bs.add(b);
                }
                else if(currOff == b.CES_Office__c){ //this record is the same office as last so add to existing list
                    bs.add(b);
                }
                else{//this record has a different office so add existing list with old office and start new list for this office
                    offBatches.put((id)currOff,bs);
                    bs = new list<Sync_Batch__c>();
                    currOff = b.CES_Office__c;
                    bs.add(b);
                }
            }
            //add the last iteration to the map
            offBatches.put((id)currOff,bs);


            for (Contact oc: offCons){
                list<Sync_Batch__c> eBatches = new list<Sync_Batch__c>();
                try{
                    eBatches = offBatches.get(oc.AccountId);
                    if (eBatches.size()>0){
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

                        String body = 'The following ' + oc.Account.Name + ' ' + text + ':  ';
                        String pBody = '';
                        String hBody = '';
                        
                        for (Sync_Batch__c eb: eBatches){
                            hBody += '<b><a href=https://na1.salesforce.com/' + eb.Id + '>Sync Batch #' + eb.Name + '</b> <p>';
                            pBody += 'Sync Batch #' + eb.Name + '\r\n';
                            batchesToUpdate.add(eb);
                        }

                        mail.setTargetObjectId(oc.Id);
                        mail.setOrgWideEmailAddressId('0D230000000L03v');
                        mail.setSubject(oc.Account.Name + ': ' + eBatches.size() + ' ' + text + '!');
                        mail.setPlainTextBody(body + '\r\n' + pBody);
                        mail.setHtmlBody(body + '<p>' + hBody);
                        theEmails.add(mail);
                    }
                } catch (exception e){}
            }

            list<Messaging.Email> allMails = new list<Messaging.Email>();
            for (Messaging.SingleEmailMessage mess: theEmails){
                allMails.add(mess);
            }

            Messaging.SendEmailResult[] results = Messaging.sendEmail(allMails);

            if (format == 'Complete'){//update status only if this is a complete email
                if (batchesToUpdate.size()>0){
                    for (Sync_Batch__c b:batchesToUpdate){
                        b.Email_Sent__c = true;
                    }
                    update batchesToUpdate;
                }
            }
        }
    }
    */
/*
    public static void CreateSyncBatchScheduledChatter(id bId){
        CESDataSyncUtilities.CreateSyncBatchScheduledChatter(bId);
    }

    public static void CreateSyncBatchStatusChatters(string format){
        CESDataSyncUtilities.CreateSyncBatchStatusChatters(format);
    }

    public static void CheckSyncBatchStatus(id bId){
        CESDataSyncUtilities.CheckSyncBatchStatus(bId);
    }
*/
}