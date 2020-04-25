public class CESContractUtils {


//*****************************************************************************
//*** CONTRACT METHODS *********************************************************
//*****************************************************************************
    public static void ProcessTCActivation(id tcId){
        Set<Id> premIds = new Set<Id>();
        list<Premises__c> prems = new list<Premises__c>();
        map<Id, Date> agMap = new map<Id, Date>();
        list<Premise_Status__c> statsToInsert = new list<Premise_Status__c>();
        list<Premises__c> premsToUpdate = new list<Premises__c>();
        Set<Id> billIds = new Set<Id>();
        list<Contract_Premise__c> conPrems = new list<Contract_Premise__c>();
        list<Contract_Premise__c> conPremsToUpdate = new list<Contract_Premise__c>();
        boolean acctUpdated = false;
        id batch;
        
        CESContract__c cesc = [select id, name, Account__c, Facility_List__c, Start_Date_New__c, End_Date__c, CES_Office__r.Customer_Number__c, Safari_Key__c, Safari_Sync_Status__c, 
                                Contact_For_Confirmations__c, Contact_for_Invoices__c, Contact_for_Notices__c, Delivery_Obligation__c, Term_New__c, Record_Type_Name__c, Sales_Adder__c, Index_Adder__c,
                                Utility_Rate_Name__c, Market_Rate_Index_Name__c, Index_Rate_Name__c, Index_Rate_Name__r.Frequency__c, Product_Subtype_Lookup__r.Contract_Volume_Required__c, Over_Index_Name__c, Sync_Batch__c, 
                                Over_Adder__c, Margin_on_Over__c, Under_Index_Name__c, Under_Adder__c, Margin_on_Under__c, Consultant__c, Consultant_Unit_Margin__c, UDF_CESUM__c, UDF_GUM__c, Incremental_Sync_OK__c, UDF_TGUM__c, 
                                Date_Activated_by_Contract_Admin__c, UDF_Agency__c, UDF_All_Product_Type__c, UDF_Base_Contract__c, UDF_Contract_Version__c, UDF_DealTranType__c, UDF_Product_Type__c, UDF_Storage_Val__c,
                                UDF_Telemetry__c, UDF_Transport_Fuel__c, UDF_Upstream_Transport__c, UDF_Utility_Meter_Read__c, UDF_Utility_Transport__c, Delivery_Point__c, Utility_Balancing__c, Utility_Cashout__c,
                                Opportunity__r.OwnerId, Volume_Entry_Type__c, Daily_Volume_Type__c, Require_Daily_Positions__c, Transport_Bill_Consolidation__c, Sync_Field_Values_Created__c, Contract_ID__c
                                from CESContract__c where id =: tcid];
        Account a = [select id, name, active__c, ownerid, HOU_ID__c, Live_ID__c, MPLS_ID__c, STL_ID__c, Safari_HOU_Sync_Status__c, Safari_LIVE_Sync_Status__c, Safari_MPLS_Sync_Status__c, 
                        Safari_STL_Sync_Status__c, Primary_Safari_Contact__c, Primary_Safari_LIVE_Contact__c, Primary_Safari_MPLS_Contact__c, Primary_Safari_STL_Contact__c, Incremental_Sync_OK__c,
                        Incremental_LIVE_Sync_OK__c, Incremental_MPLS_Sync_OK__c, Incremental_STL_Sync_OK__c, Primary_Safari_HOU_Sales_Rep__c, Primary_Safari_LIVE_Sales_Rep__c, Primary_Safari_MPLS_Sales_Rep__c, 
                        Primary_Safari_STL_Sales_Rep__c
                        from Account where id =: cesc.Account__c];

        boolean setSyncProperties = CESUtilities.getSafariSyncSetting(cesc.CES_Office__r.Customer_Number__c);
        boolean manageMargin = CESUtilities.getManageMarginSetting();
        //boolean manageConPrems = getManageContractPremiseSetting();

        if (setSyncProperties){
            batch = CESDataSyncUtilities.CreateSyncBatch(cesc.CES_Office__c);
        }

        if (!a.Active__c){
        	a.Active__c = true;
            acctUpdated = true;
        }

        //set pending safari sync
        if (cesc.CES_Office__r.Customer_Number__c == 'HOU') {
            if (a.Primary_Safari_Contact__c == null){//set safari contact if not already set
                a.Primary_Safari_Contact__c = cesc.Contact_for_Notices__c;
                acctUpdated = true;
            }
            if (a.Primary_Safari_HOU_Sales_Rep__c == null){//set safari sales rep if not already set
                a.Primary_Safari_HOU_Sales_Rep__c = cesc.Opportunity__r.OwnerId;
                acctUpdated = true;
            }
            if (a.HOU_ID__c == null && setSyncProperties){
                a.HOU_ID__c = 'Pending-' + cesc.CES_Office__r.Customer_Number__c;
                a.Safari_HOU_Sync_Status__c = 'Pending Sync';
                a.Incremental_Sync_OK__c = true;
                CESDataSyncUtilities.CreateSyncBatchAccount(a.id, batch);
                acctUpdated = true;
            }
        } else if (cesc.CES_Office__r.Customer_Number__c == 'LIVE'){
            if (a.Primary_Safari_LIVE_Contact__c == null){//set safari contact if not already set
                a.Primary_Safari_LIVE_Contact__c = cesc.Contact_for_Notices__c;
                acctUpdated = true;
            }
            if (a.Primary_Safari_LIVE_Sales_Rep__c == null){//set safari sales rep if not already set
                a.Primary_Safari_LIVE_Sales_Rep__c = cesc.Opportunity__r.OwnerId;
                acctUpdated = true;
            }
            if (a.Live_ID__c == null && setSyncProperties){
                a.Live_ID__c = 'Pending-' + cesc.CES_Office__r.Customer_Number__c;
                a.Safari_LIVE_Sync_Status__c = 'Pending Sync';
                a.Incremental_LIVE_Sync_OK__c = true;
                CESDataSyncUtilities.CreateSyncBatchAccount(a.id, batch);
                acctUpdated = true;
            }
        } else if (cesc.CES_Office__r.Customer_Number__c == 'MPLS'){ 
            if (a.Primary_Safari_MPLS_Contact__c == null){//set safari contact if not already set
                a.Primary_Safari_MPLS_Contact__c = cesc.Contact_for_Notices__c;
                acctUpdated = true;
            }
            if (a.Primary_Safari_MPLS_Sales_Rep__c == null){//set safari sales rep if not already set
                a.Primary_Safari_MPLS_Sales_Rep__c = cesc.Opportunity__r.OwnerId;
                acctUpdated = true;
            }
            if (a.MPLS_ID__c == null && setSyncProperties){
                a.MPLS_ID__c = 'Pending-' + cesc.CES_Office__r.Customer_Number__c;
                a.Safari_MPLS_Sync_Status__c = 'Pending Sync';
                a.Incremental_MPLS_Sync_OK__c = true;
                CESDataSyncUtilities.CreateSyncBatchAccount(a.id, batch);
                acctUpdated = true;
            }
        } else if (cesc.CES_Office__r.Customer_Number__c == 'STL'){
            if (a.Primary_Safari_STL_Contact__c == null){//set safari contact if not already set
                a.Primary_Safari_STL_Contact__c = cesc.Contact_for_Notices__c;
                acctUpdated = true;
            }
            if (a.Primary_Safari_STL_Sales_Rep__c == null){//set safari sales rep if not already set
                a.Primary_Safari_STL_Sales_Rep__c = cesc.Opportunity__r.OwnerId;
                acctUpdated = true;
            }
            if (a.STL_ID__c == null && setSyncProperties){
                a.STL_ID__c = 'Pending-' + cesc.CES_Office__r.Customer_Number__c;
                a.Safari_STL_Sync_Status__c = 'Pending Sync';
                a.Incremental_STL_Sync_OK__c = true;
                CESDataSyncUtilities.CreateSyncBatchAccount(a.id, batch);
                acctUpdated = true;
            }
        }

        if (acctUpdated){ update a; }
        
        list<Contract_Premise__c> allContractPrems = new list<Contract_Premise__c>();
        list<Contract_Premise__c> cpsToUpdate = new list<Contract_Premise__c>();
        
        allContractPrems = [select id, name, CESContract__c, Premise__c, Start_Date__c, End_Date__c, Safari_Key__c, Safari_Sync_Status__c, Sync_Batch__c, Incremental_Sync_OK__c
                        from Contract_Premise__c where CESContract__c =: cesc.id];

        if (allContractPrems.size() >0){
            for (Contract_Premise__c acp:allContractPrems){//run through records to see if date updates need to occur
                boolean isUpdate = false;
                if (acp.Safari_Sync_Status__c != 'Sync Complete'){//check records that are not yet synced
                    if (acp.Start_Date__c != cesc.Start_Date_New__c){
                        acp.Start_Date__c = cesc.Start_Date_New__c;
                        isUpdate = true;
                    }
                    if (acp.End_Date__c != cesc.End_Date__c){
                        acp.End_date__c = cesc.End_date__c;
                        isUpdate = true;
                    }
                    if (isUpdate){
                        cpsToUpdate.add(acp);
                    }
                }
            }
            if (cpsToUpdate.size()>0){update cpsToUpdate;}
        }

        list<Contract_Premise__c> existConPrems = new list<Contract_Premise__c>();
        map<Id, Contract_Premise__c> cpMap = new map<Id, Contract_Premise__c>();
        
        existConPrems = [select id, name, CESContract__c, Premise__c, Start_Date__c, End_Date__c, Safari_Key__c, Safari_Sync_Status__c, Sync_Batch__c, Incremental_Sync_OK__c
                        from Contract_Premise__c where CESContract__c =: cesc.id and Start_Date__c =: cesc.Start_Date_New__c and End_Date__c =: cesc.End_Date__c];
        set<Id> conPremSet = new set<Id>();

        if (existConPrems.size() > 0){
            //get premises without a status or status that is not active
            
            //make set of premises from contract_premise to query premises on this contract
            for (Contract_Premise__c cp:existConPrems){
                conPremSet.add(cp.Premise__c);
                if (cp.Safari_Key__c == null){
                    cp.Safari_Key__c = 'Pending-' + cesc.CES_Office__r.Customer_Number__c;
                    cp.Safari_Sync_Status__c = 'Pending Sync';
                    cp.Sync_Batch__c = batch;
                    cp.Incremental_Sync_OK__c = true;
                    conPremsToUpdate.add(cp);
                }
            }
            if (conPremsToUpdate.size()>0){update conPremsToUpdate;}

            prems = [select id, name, Premise_Status_Formula__c, Safari_Premise_Key__c, Safari_Sync_Status__c, Premise_Primary_Contact__c, Safari_Sync_Start_Date__c, Default_Delivery_Obligation__c, Sync_Batch__c, 
                        Incremental_Sync_OK__c, Consultant__c, MDQ__c, LDC_Rate_Class__c, TDSP_Lookup__c, Consolidated_Billing__c 
                    from Premises__c where id in: conPremSet 
                                            and (Premise_Status_Formula__c = null or Premise_Status_Formula__c != 'Active')];
            
            if (prems.size()>0){
                
                //get map of contract premise to premise    
                /*for (Contract_Premise__c cp:existConPrems){
                    cpMap.put(cp.Premise__c, cp);
                }*/
                
                list<Date_Effective_Property__c> effProps = new list<Date_Effective_Property__c>();
                map<String, Date_Effective_Property__c> effPropMap = new map<String, Date_Effective_Property__c>();
                list<Property_Value__c> newProps = new list<Property_Value__c>();
                list<Property_Value__c> props = new list<Property_Value__c>();

                //get all properties
                effProps = [select id, name from Date_Effective_Property__c order by name];
                for (Date_Effective_Property__c ep:effProps){
                    effPropMap.put(ep.name, ep);
                }

                for (Premises__c prem: prems){//get premise keys
                    boolean updPrem = false;//flag to track if premise should be updated
                    premIds.add(prem.Id);
                    if (prem.Safari_Premise_Key__c == null && setSyncProperties){//set pending safari sync
                        prem.Safari_Premise_Key__c = 'Pending-' + cesc.CES_Office__r.Customer_Number__c;
                        prem.Safari_Sync_Status__c = 'Pending Sync';
                        prem.Safari_Sync_Start_Date__c = cesc.Start_Date_New__c;
                        prem.Sync_Batch__c = batch;
                        prem.Incremental_Sync_OK__c = true;
                        updPrem = true;

                        //try to get an existing contract premise
                        /*
                        Contract_Premise__c existCP;
                        try {
                            existCP = cpMap.get(prem.id);
                        } catch (exception e) {existCP = null;}

                        if (existCP != null){//contract premise found, update sync fields if needed
                            if (existCP.Safari_Key__c == null){
                                existCP.Safari_Key__c = 'Pending-' + cesc.CES_Office__r.Customer_Number__c;
                                existCP.Safari_Sync_Status__c = 'Pending Sync';
                                existCP.Sync_Batch__c = batch;
                                existCP.Incremental_Sync_OK__c = true;
                                conPremsToUpdate.add(existCP);
                            }
                        } else {//contract premise not found, create new one
                            conPrems.add(new Contract_Premise__c(CESContract__c = cesc.Id, Premise__c = prem.Id, Start_Date__c = cesc.Start_Date_New__c, 
                                                            End_Date__c = cesc.End_Date__c, Safari_Key__c = 'Pending-' + cesc.CES_Office__r.Customer_Number__c, Safari_Sync_Status__c = 'Pending Sync',
                                                            Sync_Batch__c = batch, Incremental_Sync_OK__c=true));
                        }*/
                    }
                        
                    if (prem.Premise_Primary_Contact__c == null){
                        prem.Premise_Primary_Contact__c = cesc.Contact_for_Confirmations__c;
                        updPrem = true;
                    }
                    if (prem.Default_Delivery_Obligation__c == null){
                        try {
                            //add property value
                            Property_Value__c pv = new Property_Value__c(Premise__c=prem.id, Effective_Date__c=cesc.Start_Date_New__c, Text_Value__c=cesc.Delivery_Obligation__c);
                            pv.Property__c = effPropMap.get('Delivery Type').id;
                            newProps.add(pv);
                        } catch (exception e){}
                        //update premise with initial value
                        prem.Default_Delivery_Obligation__c = cesc.Delivery_Obligation__c;
                        updPrem = true;
                    }
                    if (prem.Consultant__c == null && cesc.Consultant__c != null){
                        try {
                        	//add property value
                            Property_Value__c pv = new Property_Value__c(Premise__c=prem.id, Effective_Date__c=cesc.Start_Date_New__c, Consultant__c=cesc.Consultant__c);
                            pv.Property__c = effPropMap.get('Consultant').id;
                            newProps.add(pv);
                        } catch (exception e){}
                        //update premise with initial value
                        prem.Consultant__c = cesc.Consultant__c;
                        updPrem = true;
                    }
                    if (cesc.Transport_Bill_Consolidation__c){
                        prem.Consolidated_Billing__c = true;
                        updPrem = true;
                    }
                    if (updPrem){ premsToUpdate.add(prem); }
                }

                if (premsToUpdate.size()>0){update premsToUpdate;}
                if (conPrems.size()>0){insert conPrems;}
                if (newProps.size()>0){insert newProps;}

                //premise properties setup for sync if operational
                if (setSyncProperties){                    
                    props = database.query('select id, name, Premise__c, Safari_Key__c, Safari_Sync_Status__c from Property_Value__c where Premise__c in:premIds and Property__r.Sync_'+cesc.CES_Office__r.Customer_Number__c+'__c = true and Safari_Key__c = null');

                    if (props.size()>0){
                        for (Property_Value__c prop:props){
                            prop.Safari_Key__c = 'Pending-' + cesc.CES_Office__r.Customer_Number__c;
                            prop.Safari_Sync_Status__c = 'Pending Sync';
                            prop.Sync_Batch__c = batch;
                            prop.Incremental_Sync_OK__c = true;
                        }
                        update props;
                    }
                }

                //get bill groups
                AggregateResult[] agBills = [select bill_group__c, COUNT(id) premcnt from Premises__c where id in:premIds group by bill_group__c];
                if (agBills.size()>0){
                    for (AggregateResult agr:agBills){
                        billIds.add((id)agr.get('bill_group__c'));
                    }
                    list<Bill_Group__c> bills = new list<Bill_Group__c>();
                    bills = [select id, name, Safari_ID__c, Safari_Sync_Status__c, Billing_Contact__c, Sync_Batch__c, Incremental_Sync_OK__c from Bill_Group__c where id in:billIds and Safari_ID__c = null];
                    if (bills.size()>0){//go through bills that are not already waiting sync or synced
                        for (Bill_Group__c bill:bills){
                            if (setSyncProperties){
                                bill.Safari_ID__c = 'Pending-' + cesc.CES_Office__r.Customer_Number__c;
                                bill.Safari_Sync_Status__c = 'Pending Sync';
                                bill.Sync_Batch__c = batch;
                                bill.Incremental_Sync_OK__c = true;
                            }
                            if (bill.Billing_Contact__c == null){
                                bill.Billing_Contact__c = cesc.Contact_for_Invoices__c;
                            }
                        }
                        update bills;
                    }
                }

                //get active statuses for the premises between today and the start of the contract.  if found, do not add an active status since 
                //one is waiting to be processed
                AggregateResult[] stats = [select premise__c, MIN(Status_Date__c) minDate from Premise_Status__c where premise__c in:premIds
                        					and Status__c = 'Active' and Status_Date__c >=: date.today() and Status_Date__c <=: cesc.Start_Date_New__c
                                          group by premise__c];
                if (stats.size()>0){
                    for (AggregateResult agr: stats){//get map of agg results
                        agMap.put((id)agr.get('premise__c'), (date)agr.get('minDate'));
                    }
                }
                
                for (Premises__c prem: prems){//cycle through premises again and add status if premise does not have a pending activation already (no date map)
                    Date dt = null;
                    try {
                    	dt = agmap.get(prem.Id);
                    }catch (exception e){}
                    
                    if (dt == null){//add status since date was not found for a pending activation and set sync status
                        Premise_Status__c pstat = new Premise_Status__c(Premise__c=prem.Id, Status__c='Active', Status_Date__c=cesc.Start_Date_New__c,
                                                                       Notes__c='Activated from Contract # ' + cesc.Name, Sync_Batch__c=batch);
                        if (setSyncProperties){
                            pstat.Safari_Key__c='Pending-' + cesc.CES_Office__r.Customer_Number__c;
                            pstat.Safari_Sync_Status__c='Pending Sync';
                            pstat.Incremental_Sync_OK__c=true;
                        }
                        statsToInsert.add(pstat);
                    }
                }
                
                if (statsToInsert.size()>0){insert statsToInsert;}//insert the statuses.  status insert trigger will do the rest.

                //get monthly usage and set the sync batch.  monthly usage should already be set to pending sync from activation page
                if (setSyncProperties){
                    list<Monthly_Usage__c> mus = new list<Monthly_Usage__c>();
                    mus = [select id, name, Safari_Sync_Status__c, Sync_Batch__c, Incremental_Sync_OK__c from Monthly_Usage__c 
                            where Premise__c in: premIds and Safari_Sync_Status__c != null and Safari_Sync_Status__c != 'Sync Complete' and Sync_Batch__c = null];
                    if (mus.size()>0){
                        for (Monthly_Usage__c mu:mus){
                            mu.Sync_Batch__c = batch;
                            mu.Incremental_Sync_OK__c = true;
                        }
                        update mus;
                    }
                }
            }
        }


        //create positions if they do not exist and set sync status if needed
        
        list<Position__c> pos = new list<Position__c>();
                    
        pos = [select id, name, CES_Contract__c, Facility_List__c, Contract_Month__c, Safari_Key__c, Safari_Sync_Status__c, Sync_Batch__c, Incremental_Sync_OK__c, Active_Contract_Pricing__c, Customer_Price__c, Customer_PriceWACOG__c, 
                Adder__c, AdderWACOG__c, Other_Charges__c, Balancing__c, DT_Basis__c, DT_Basis_Physical__c, DT_NYMEX__c, Fuel_Cost__c, PL_Commodity__c, PL_Demand__c, Swing_Cost__c, Contract_CES_Unit_Margin__c, Contract_Gross_Unit_Margin__c, 
                Contract_Total_Gross_Unit_Margin__c, Contract_Consultant_Unit_Margin__c, Contract_Pricing_Index__c, Contract_Over_Index__c, Contract_Over_Adder__c, Contract_Over_Margin__c, Contract_Under_Index__c, 
                Contract_Under_Adder__c, Contract_Under_Margin__c, Volume__c, Weatherized_Volume__c
               from Position__c where CES_Contract__c =: cesc.Id];
        
        if (pos.size() == 0)  //populate position object if not already exists
        {
            //FillPositions(cesc, setSyncProperties);
        } else {//update position safari status to pending if sync is set to true
            for (Position__c p:pos){
                if (setSyncProperties){
                    if (p.Safari_Key__c == null){
                        p.Safari_Key__c = 'Pending-' + cesc.CES_Office__r.Customer_Number__c;
                        p.Safari_Sync_Status__c = 'Pending Sync';
                        p.Incremental_Sync_OK__c = true;
                    }
                    if (p.Sync_Batch__c == null){
                        p.Sync_Batch__c = batch;
                    }
                }
                p.Active_Contract_Pricing__c = true;
                //set margin fields from contract
                p.Contract_CES_Unit_Margin__c = cesc.UDF_CESUM__c;
                p.Contract_Gross_Unit_Margin__c = cesc.UDF_GUM__c;
                p.Contract_Total_Gross_Unit_Margin__c = cesc.UDF_GUM__c;
                p.Contract_Consultant_Unit_Margin__c = cesc.Consultant_Unit_Margin__c;

                if (!cesc.Record_Type_Name__c.contains('Lock')){//set the pricing fields if this is not a lock and already has values
                    p.Customer_Price__c=cesc.sales_adder__c;
                    p.Customer_PriceWACOG__c = cesc.Sales_Adder__c;
                    if(cesc.Index_Adder__c!=null) {
                        p.Adder__c = cesc.Index_Adder__c; 
                        p.AdderWACOG__c = cesc.Index_Adder__c; }
                    else{ 
                        p.Adder__c=0;
                        p.AdderWACOG__c=0;}
                    p.Other_Charges__c=0;
                    p.Balancing__c=0;
                    p.DT_Basis__c=0;
                    p.DT_Basis_Physical__c=0;
                    p.DT_NYMEX__c=0;
                    p.Fuel_Cost__c=0;
                    p.PL_Commodity__c=0;
                    p.PL_Demand__c=0;
                    p.Swing_Cost__c=0;
                }
            }
            update pos;

            //check for daily pricing needs
            if (cesc.Require_Daily_Positions__c){
                if (pos.size() == cesc.Term_New__c){//positions have not been converted to daily
                    ConvertMonthlyPositionsToDaily(pos);
                }
            }

        }

        //set contract sync status after everything else
        boolean createdContractUFVs = false;
        if (setSyncProperties){
            if (cesc.Safari_Key__c == null){
                cesc.Safari_Key__c = 'Pending-' + cesc.CES_Office__r.Customer_Number__c;
                cesc.Safari_Sync_Status__c = 'Pending Sync';
                cesc.Sync_Batch__c = batch;
                cesc.Incremental_Sync_OK__c = true;
                //create user field values for sync if they have not already been created
                if (!cesc.Sync_Field_Values_Created__c){
                    createdContractUFVs = CESDataSyncUtilities.BuildContractSyncUserFieldValues(cesc, batch);
                }
            }
        }
        //activate contract
        cesc.Active__c = true;
        cesc.Contract_Status__c = 'Processed/Activated';
        cesc.Date_Activated_by_Contract_Admin__c = datetime.now();
        if (createdContractUFVs){cesc.Sync_Field_Values_Created__c = true;}
        update cesc;

        if (setSyncProperties){//send chatter that batch is scheduled
            //CESDataSyncUtilities.CreateSyncBatchScheduledChatter(batch); //stop sending chatter for scheduled batches
            //check for any records to be synced
            AsyncRequest__c asr = new AsyncRequest__c(Type__c='CheckRecordsToSyncExist',Params__c=cesc.CES_Office__r.Customer_Number__c);
            insert asr;
        } 

        //kick off informatica if sync is operational
        /*if (setSyncProperties){
            string taskID='';
            
            taskID = getInformaticaTaskID(cesc.CES_Office__r.Customer_Number__c, 'Entire Process');
            system.debug('informatica task id: ' + taskID);

            if (taskID != ''){
                AsyncRequest__c asr = new AsyncRequest__c(Type__c='RunInformaticaJob',Params__c='WORKFLOW,'+taskID);
                insert asr;
            }
        }*/


        //add pending contract margin records in increments of 12 months
        if (manageMargin){
            list<Contract_Margin__c> conMargins = ContractMarginAndRenewal.GenerateContractMarginTerms(cesc, cesc.Start_Date_New__c, cesc.End_Date__c, null, null);
        }
    }

    public static list<String> ProcessTCActivation1(CESContract__c cesc){
        list<String> rslt = new list<String>();
        //create positions if they do not exist and set sync status if needed
        
        list<Position__c> pos = new list<Position__c>();
                    
        pos = [select id, name, CES_Contract__c, Facility_List__c, Contract_Month__c, Safari_Key__c, Safari_Sync_Status__c, Sync_Batch__c, Incremental_Sync_OK__c, Active_Contract_Pricing__c, Customer_Price__c, Customer_PriceWACOG__c, 
                Adder__c, AdderWACOG__c, Other_Charges__c, Balancing__c, DT_Basis__c, DT_Basis_Physical__c, DT_NYMEX__c, Fuel_Cost__c, PL_Commodity__c, PL_Demand__c, Swing_Cost__c, Contract_CES_Unit_Margin__c, Contract_Gross_Unit_Margin__c, 
                Contract_Total_Gross_Unit_Margin__c, Contract_Consultant_Unit_Margin__c, Contract_Pricing_Index__c, Contract_Over_Index__c, Contract_Over_Adder__c, Contract_Over_Margin__c, Contract_Under_Index__c, 
                Contract_Under_Adder__c, Contract_Under_Margin__c, 
                Cashout_Over_Index__c, Cashout_Over_Adder__c, Cashout_Over_Margin__c, Cashout_Under_Index__c, Cashout_Under_Adder__c, Cashout_Under_Margin__c, Volume__c, Weatherized_Volume__c,
                LDC_Fuel_Rate__c, Pipeline_Fuel_Rate__c, Over_LDC_Fuel_Rate__c, Over_Pipeline_Fuel_Rate__c, Under_LDC_Fuel_Rate__c, Under_Pipeline_Fuel_Rate__c 
               from Position__c where CES_Contract__c =: cesc.Id];
        
        integer posCnt = 0;
        if (pos.size() != 0)  //populate position object if not already exists
        {//update position safari status to pending if sync is set to true
            for (Position__c p:pos){
                
                if (p.Safari_Key__c == null){
                    p.Safari_Key__c = 'Pending-' + cesc.CES_Office__r.Customer_Number__c;
                    p.Safari_Sync_Status__c = 'Pending Sync';
                    p.Incremental_Sync_OK__c = true;
                    p.Sync_Batch__c = cesc.Sync_Batch__c;
                    posCnt++;
                } else if (p.Sync_Batch__c == null){
                    p.Sync_Batch__c = cesc.Sync_Batch__c;
                    posCnt++;
                }

                p.Active_Contract_Pricing__c = true;
                //set margin fields from contract
                p.Contract_CES_Unit_Margin__c = cesc.UDF_CESUM__c;
                p.Contract_Gross_Unit_Margin__c = cesc.UDF_GUM__c;
                p.Contract_Total_Gross_Unit_Margin__c = cesc.UDF_GUM__c;
                p.Contract_Consultant_Unit_Margin__c = cesc.Consultant_Unit_Margin__c;

                if (!cesc.Record_Type_Name__c.contains('Lock')){//set the pricing fields if this is not a lock and already has values
                    p.Customer_Price__c=cesc.sales_adder__c;
                    p.Customer_PriceWACOG__c = cesc.Sales_Adder__c;
                    if(cesc.Index_Adder__c!=null) {
                        p.Adder__c = cesc.Index_Adder__c; 
                        p.AdderWACOG__c = cesc.Index_Adder__c; }
                    else{ 
                        p.Adder__c=0;
                        p.AdderWACOG__c=0;}
                    p.Other_Charges__c=0;
                    p.Balancing__c=0;
                    p.DT_Basis__c=0;
                    p.DT_Basis_Physical__c=0;
                    p.DT_NYMEX__c=0;
                    p.Fuel_Cost__c=0;
                    p.PL_Commodity__c=0;
                    p.PL_Demand__c=0;
                    p.Swing_Cost__c=0;
                }

                //get contract pricing information for monthly records
                // mod: consolidate contract indexes
                /*
                if (cesc.Record_Type_Name__c.contains('Guaranteed') || cesc.Record_Type_Name__c.contains('Enhanced Supply')){
                    p.contract_pricing_index__c = cesc.Utility_Rate_Name__c;}
                else if (cesc.Record_Type_Name__c.contains('Market Price')){
                    p.contract_pricing_index__c = cesc.Market_Rate_Index_Name__c;}
                else {
                */
                    p.contract_pricing_index__c = cesc.Index_Rate_Name__c;
                    try {
                        p.LDC_Fuel_Rate__c = cesc.LDC_Fuel_Rate__c;
                    } catch (exception e){}
                    try {
                        p.Pipeline_Fuel_Rate__c = cesc.Pipeline_Fuel_Rate__c;
                    } catch (exception e){}
                    
                    if (cesc.Product_Subtype_Lookup__r.Contract_Volume_Required__c){
                        p.contract_over_index__c = cesc.Over_Index_Name__c;
                        p.contract_over_adder__c = cesc.Over_Adder__c;
                        p.contract_over_margin__c = cesc.Margin_on_Over__c;
                        p.contract_under_index__c = cesc.Under_Index_Name__c;
                        p.contract_under_adder__c = cesc.Under_Adder__c;
                        p.contract_under_margin__c = cesc.Margin_on_Under__c;
                        try {
                            p.Over_LDC_Fuel_Rate__c = cesc.Over_LDC_Fuel_Rate__c;
                        } catch (exception e){}
                        try {
                            p.Over_Pipeline_Fuel_Rate__c = cesc.Over_Pipeline_Fuel_Rate__c;
                        } catch (exception e){}
                        try {
                            p.Under_LDC_Fuel_Rate__c = cesc.Under_LDC_Fuel_Rate__c;
                        } catch (exception e){}
                        try {
                            p.Under_Pipeline_Fuel_Rate__c = cesc.Under_Pipeline_Fuel_Rate__c;
                        } catch (exception e){}
                    } 
                //}
                // end mod: consolidate contract indexes

                // get cashout information
                if (cesc.Product_Subtype_Lookup__r.Cashout_Obligation_Applies__c){
                    p.Cashout_Over_Index__c = cesc.Cashout_Over_Index_Name__c;
                    p.Cashout_Over_Adder__c = cesc.Cashout_Over_Adder__c;
                    p.Cashout_Over_Margin__c = cesc.Cashout_Over_Margin__c;
                    p.Cashout_Under_Index__c = cesc.Cashout_Under_Index_Name__c;
                    p.Cashout_Under_Adder__c = cesc.Cashout_Under_Adder__c;
                    p.Cashout_Under_Margin__c = cesc.Cashout_Under_Margin__c;
                }
            }
            update pos;

            //check for daily pricing needs
            if (cesc.Require_Daily_Positions__c){
                if (pos.size() == cesc.Term_New__c){//positions have not been converted to daily
                    posCnt = posCnt + ConvertMonthlyPositionsToDaily1(pos);
                }
            }
            

        }
        rslt.add('Positions: '+posCnt);

        /* moved SUFVs management to object trigger
        //set contract sync status after everything else
        boolean createdContractUFVs = false;
        */

        if (cesc.Safari_Key__c == null){
            cesc.Safari_Key__c = 'Pending-' + cesc.CES_Office__r.Customer_Number__c;
            cesc.Safari_Sync_Status__c = 'Pending Sync';
            cesc.Incremental_Sync_OK__c = true;

            /* moved SUFVs management to object trigger
            //create user field values for sync if they have not already been created
            if (!cesc.Sync_Field_Values_Created__c){
                createdContractUFVs = CESDataSyncUtilities.BuildContractSyncUserFieldValues(cesc, cesc.Sync_Batch__c);
            }
            */
        }

        /* moved SUFVs management to object trigger
        rslt.add('Contract User field Values Created: ' + createdContractUFVs);
        */
        
        //activate contract
        cesc.Active__c = true;
        cesc.Contract_Status__c = 'Processed/Activated';
        cesc.Date_Activated_by_Contract_Admin__c = datetime.now();
        /* moved SUFVs management to object trigger
        if(!cesc.Sync_Field_Values_Created__c){cesc.Sync_Field_Values_Created__c = createdContractUFVs;}
        */
        
        update cesc;

        rslt.add('Contracts: 1');

        return rslt;
    }

    public static void RottingContractRequestBulkAsync(){
        map<id, list<String>> offEmail = new map<id, list<String>>();
        map<id, id> offContactID = new map<id, id>();
        list<CESContract__c> cons = new list<CESContract__c>();
        list<Contact> offCons = new list<Contact>();
        map<id, list<CESContract__c>> offCESCs = new map<id, list<CESContract__c>>();
        list<Messaging.SingleEmailMessage> theEmails = new list<Messaging.SingleEmailMessage>();

        offCons = [select id, name, Email, AccountId, Account.Name from Contact where Account.Record_Type_Name__c =: 'CES_Location' and LastName =: 'Admin' order by Account.Name];
        cons = [select id, name, CES_Office__c, CES_Office__r.Name, Contract_Owner_Email__c, Date_Submitted_for_Approval__c, Contract_Status__c, 
                    Record_Type_Name__c, Last_Approval_Activity_Days__c, Account__c, Account__r.Name
                from CESContract__c where CES_Office__c != null and Contract_Status__c = 'Submitted for SCA Approval'
                    and Last_Approval_Activity_Days__c > 1 
                order by CES_Office__c, name];

        if (cons.size()>0){
            list<CESContract__c> CESCs = new list<CESContract__c>();
            String currOff = null;

            for (CESContract__c con: cons){
                if (currOff == null){ //first record of the loop
                    currOff = con.CES_Office__c;
                    CESCs.add(con);
                }
                else if(currOff == con.CES_Office__c){ //this record is the same office as last so add to existing list
                    CESCs.add(con);
                }
                else{//this record has a different office so add existing list with old office and start new list for this office
                    offCESCs.put((id)currOff,CESCs);
                    CESCs = new list<CESContract__c>();
                    currOff = con.CES_Office__c;
                    CESCs.add(con);
                }
            }
            //add the last iteration to the map
            offCESCs.put((id)currOff,CESCs);
            system.debug('number of office groups of contracts: ' + offCESCs.size());

            for (Contact oc: offCons){
                list<CESContract__c> eCons = new list<CESContract__c>();
                try{
                    eCons = offCESCs.get(oc.AccountId);
                    if (eCons.size()>0){
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        String body = 'The following contract requests are awaiting review / approval by ' + oc.Account.Name + ' contract administration: ';
                        String pBody = '';
                        String hBody = '';
                        
                        for (CESContract__c ec: eCons){
                            hBody += '<b><a href=https://na1.salesforce.com/' + ec.Id + '>' + ec.Name + '</b> (' + ec.Record_Type_Name__c + ')</a> for ' + ec.Account__r.Name + ' submitted on '+ ec.Date_Submitted_for_Approval__c.month() +
                                            '/' + ec.Date_Submitted_for_Approval__c.day() + '/' + ec.Date_Submitted_for_Approval__c.year() + ' (' + ec.Last_Approval_Activity_days__c +
                                            ' days ago)<p>';
                            pBody += ec.Name + ' (' + ec.Record_Type_Name__c + ') for ' + ec.Account__r.Name + ' submitted on '+ ec.Date_Submitted_for_Approval__c.month() +
                                            '/' + ec.Date_Submitted_for_Approval__c.day() + '/' + ec.Date_Submitted_for_Approval__c.year() + ' (' + ec.Last_Approval_Activity_days__c +
                                            ' days ago)' + '\r\n';
                        }

                        mail.setTargetObjectId(oc.Id);
                        mail.setOrgWideEmailAddressId('0D230000000L03v');
                        mail.setSubject('REMINDER: ' + eCons.size() + ' ' + oc.Account.Name + ' Contract Requests ' + ' still require attention');
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
        }
    }

    public static void CEIPFOMNominationAlert(){
        set<Id> conIdSet = new set<Id>();
        list<Contact> tacts = new list<Contact>();
        list<CampaignMember> members = new list<CampaignMember>();
        map<Id, String> targetAcctMap = new map<Id, String>();

        list<Messaging.SingleEmailMessage> theEmails = new list<Messaging.SingleEmailMessage>();

        members = [select id, Contact.Id, Contact.Account.Name, Target_Account__c, Target_Account__r.Name from CampaignMember where Campaign.Name = 'CEIP Nominations' and Campaign.IsActive = true];

        for (CampaignMember cm: members){
            conIdSet.add(cm.Contact.Id);
            // set the map target account name for each contact
            if (cm.Target_Account__c == null){targetAcctMap.put(cm.Contact.Id, cm.Contact.Account.Name);}
            else {targetAcctMap.put(cm.Contact.Id, cm.Target_Account__r.Name);}
        }

        tacts = [select id, name, FirstName, LastName, Email, Account.Name, 
                    (select id, Campaign.Name, FOM_Nomination__c, Sales_Rep__c, Sales_Rep__r.Name, Sales_Rep__r.Email, Campaign.StartDate from CampaignMembers),
                    (select id, name, Account_Number__c, FOM_Nomination__c from Premises1__r)
                from Contact
                Where id in:conIdSet
                order by name];
        
        if (tacts.size()>0){
            // nom momth is next month
            Date nomMonth = Date.today().toStartOfMonth().addMonths(1);
            //Date replyMonth = Date.today().addDays(3);

            String plainNewLine = '\r\n';
            String htmlNewLine = '<p>';
            String b1 = 'Please reply to this email with your nomination request for ' + getMonthName(nomMonth) + ' ' + nomMonth.year() + '.';

            for (Contact oc: tacts){
                String acctName = '';

                // get account name from target map
                try {
                    acctName = targetAcctMap.get(oc.Id);
                } catch (exception e) {
                    acctName = oc.Account.Name;
                }

                try{
                    //String accts = '';
                    
                    String rep = oc.CampaignMembers[0].Sales_Rep__r.Name;
                    String repMail = oc.CampaignMembers[0].Sales_Rep__r.Email;
                    Date replyMonth = oc.CampaignMembers[0].Campaign.StartDate;
                    //Decimal fom = oc.CampaignMembers[0].FOM_Nomination__c;
                    //Decimal dayFom = fom / Date.daysInMonth(nomMonth.year(), nomMonth.month()) * 1.0;
                    //dayFom = dayFom.setScale(2);

                    list<String> ccs = new list<String>();
                    ccs.add(oc.CampaignMembers[0].Sales_Rep__c);
                    
                    /*
                    for (Premises__c prem:oc.Premises1__r){
                        if (accts != ''){accts = accts + ', ';}
                        accts = accts + prem.Account_Number__c;
                    }
                    */

                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    String body = 'Hello ' + oc.FirstName + ',';
                    /*
                    String b2 = 'The estimated volume for your account(s) (Account Number(s): '+ accts 
                                    + ') is '+ fom 
                                    + ' dth for the month or ' + dayFom + ' per day. Without a confirmation from you this is the volume we will use.';
                    */
                    String p2 = 'The estimate volume for your account(s) is as follows:' + plainNewLine;
                    String b2 = 'The estimated volume for your account(s) is as follows:' +'<br/>'
                                + '<table><thead><tr><th>Account Number</th><th></th><th>Dth/Month</th><th></th><th>Dth/Day</th></tr></thead><tbody>';

                    for (Premises__c prem:oc.Premises1__r){
                        Decimal fom = prem.FOM_Nomination__c;
                        Decimal dayFom = fom / Date.daysInMonth(nomMonth.year(), nomMonth.month()) * 1.0;
                        dayFom = dayFom.setScale(2);

                        b2 = b2 + '<tr>'
                                + '<td>' + prem.Account_Number__c + '</td><td></td>' 
                                + '<td>' + fom + '</td><td></td>'
                                + '<td>' + dayFom + '</td>' 
                                + '</tr>';

                        p2 = p2 + 'Account # ' + prem.Account_Number__c + ': ' + fom + ' Dth/Month (' + dayFom + ' Dth/Day)' + plainNewLine;
                    } 

                    b2 = b2 + '</tbody></table><br/>' + 'Without a confirmation from you this is the volume we will use.';
                                    
                    String b3 = 'Please reply by ' + replyMonth.format() + '.';
                    String b4 = 'Thanks!';
                    String b5 = 'CenterPoint Energy Services, Inc.';

                    String pBody = body + plainNewLine + b1 + plainNewLine + p2 + plainNewLine + b3 + plainNewLine + b4 + plainNewLine + rep + plainNewLine + b5 + plainNewLine + repMail; 
                    String hBody = body + htmlNewLine + b1 + htmlNewLine + b2 + '<br/>' + b3 + htmlNewLine + b4 + '<br/>' + rep + '<br/>' + b5 + '<br/>' + repMail;
                    //system.debug(pbody);

                    mail.setTargetObjectId(oc.Id);
                    mail.setCcAddresses(ccs);
                    mail.setOrgWideEmailAddressId('0D20M000000L0qd'); //0D20M000000L0qd for prod, 0D230000000L03v for bmac
                    mail.setSubject('Nomination Request Reminder: ' + acctName + ', ' + getMonthName(nomMonth) + ', ' + nomMonth.year() + ' - REPLY NEEDED');
                    mail.setPlainTextBody(pBody);
                    mail.setHtmlBody(hBody);
                    if (oc.Email != null){
                    	theEmails.add(mail);
                    }
                } catch (exception e){}
            }

            list<Messaging.Email> allMails = new list<Messaging.Email>();
            for (Messaging.SingleEmailMessage mess: theEmails){
                allMails.add(mess);
            }
            
            Messaging.SendEmailResult[] results = Messaging.sendEmail(allMails);
        }
    }

    public static String getMonthName(Date inDate){
        String monthName;
        Integer num = inDate.month();
        if (num == 1){monthName = 'January';}
        else if (num == 2){monthName = 'February';}
        else if (num == 3){monthName = 'March';}
        else if (num == 4){monthName = 'April';}
        else if (num == 5){monthName = 'May';}
        else if (num == 6){monthName = 'June';}
        else if (num == 7){monthName = 'July';}
        else if (num == 8){monthName = 'August';}
        else if (num == 9){monthName = 'September';}
        else if (num == 10){monthName = 'October';}
        else if (num == 11){monthName = 'November';}
        else if (num == 12){monthName = 'December';}
        else {monthName = 'None';}

        return monthName;
    }

    //*****************************************************************************
	//*** CONTRACT TRIGGER METHODS ************************************************
	//*****************************************************************************

	public static void CESContractBeforeUpsertProcess(list<CESContract__c> CESCs, map<id, CESContract__c> oldmap){
        list <Rate__c> rates = new list<Rate__c>();
        map<Id, boolean> rateVolReqMap = new map<Id, boolean>();
        map<Id, Rate__c> rateMap = new map<Id, Rate__c>();
        boolean legacy = false;
        
        //kns 20200306 - I only wrapped the tc revision  changes in the killswitch to avoid breaking other processes...
         Trigger_Killswitch__mdt cesContractChangeKill = [SELECT Kill__c FROM Trigger_Killswitch__mdt where DeveloperName = 'CESContractTrigger'];
        
        //KNS 20200304 TC Revision 
        List <CESContract__c> tcContracts = New List <CESContract__c>();
        List <CESContract__c> tcFalseContracts = New List <CESContract__c>();
        List <CESContract__c> tcContractsToUpdate = New List <CESContract__c>();

        
        // check if contracts are part of the legacy process
        // BDM 04-01-19 16562: include surrendered storage pricing as non-legacy type
        for (CESContract__c con:CESCs){
            if (con.Record_Type_Name__c != 'Base Pricing' && 
                con.Record_Type_Name__c != 'Fixed Tier Pricing' &&
                con.Record_Type_Name__c != 'Spot Pricing' &&
                con.Record_Type_Name__c != 'Storage' &&
                con.Record_Type_Name__c != 'Surrendered Storage Pricing'){
                    legacy = true;
                }
        
        	//KNS 2020304 - moving logic to before upsert 
        
            //RC 2/27 adding logic for Revised TC Contract Changes
            
            //tcContracts = contracts that are not pending TC revision and are updated 
            //need to be marked as pending tc revision based on the changes made. 
            //kns 20200303 --- this should be pending tc revision == false based on how this is used
            //if(con.Contract_Status__c == 'Activated' && con.Confirmation_Status__c == 'Issued' && con.Pending_TC_Revision__c == true){
            if(!cesContractChangeKill.Kill__c){
            if(con.Contract_Status__c == 'Activated' && con.Confirmation_Status__c == 'Issued' && con.Pending_TC_Revision__c == false){
                System.debug('adding contracts to tcContracts');
                tcContracts.add(con);
            }
            
            //tcFalseContracts - should be contracts that we are switching back to false. aka revision is complete.
            //this logic is incorrect. the pending revision flag won't ALWAYS be true 
            //new pending tc revision value is false (contracts manually unchecked flag) but the tc revision details aren't null 
            
            //if(con.Pending_TC_Revision__c == false && con.TC_Revision_Requires_Review__c == true && con.TC_Revision_Details__c != null){
            if(con.Pending_TC_Revision__c == false && (con.TC_Revision_Requires_Review__c == true || con.TC_Revision_Details__c != null)){
                tcFalseContracts.add(con);
            }
            }// end of killswitch for TC Revision
        }
        
        //more TC Revision - kns 20200306
        if(!cesContractChangeKill.Kill__c){
        //RC 2/27 
        //tcContracts - this is to identify and flag contracts that are NOT already pending tc revision
        for (CESContract__c con : tcContracts){
            CESContract__c oldCon = oldmap.get(con.Id);
            
            //Requires Review
            if(con.Allow_Nomination_Change__c !=  oldCon.Allow_Nomination_Change__c ||
               con.Delivery_Point__c          !=  oldCon.Delivery_Point__c          ||
               con.Early_Termination_Date__c  !=  oldCon.Early_Termination_Date__c  ||
               con.TC_Pricing_Text__c         !=  oldCon.TC_Pricing_Text__c
               ){
                   
                //Set Contract Fields
                con.Pending_TC_Revision__c         = True;
                con.TC_Revision_Requires_Review__c = True;
                //TC_Revision_Details__c value
                String TcRevisionDetails           = con.TC_Revision_Details__c;
                //Populate TC_Revision_Details__c
                if(String.isBlank(TcRevisionDetails)){
                    con.TC_Revision_Details__c  = ' CES Contract Record';
                }
                //Add to TC_Revision_Details__c
                else{
                    con.TC_Revision_Details__c = TcRevisionDetails + '; Contract Record';
                }
            }
            
            
            //Does Not Require Review
            else if(con.Delivery_Obligation__c !=  oldCon.Delivery_Obligation__c ||
                    con.Auto_renew__c          !=  oldCon.Auto_renew__c          ||
                    con.Renewal_Term__c        !=  oldCon.Renewal_Term__c        ||
                    con.Renewal_Notice_Days__c !=  oldCon.Renewal_Notice_Days__c
               ){
                                   
                //Set Contract Fields
                con.Pending_TC_Revision__c         = True;
                //TC_Revision_Details__c value
                String TcRevisionDetails           = con.TC_Revision_Details__c;
                //Populate TC_Revision_Details__c
                if(String.isBlank(TcRevisionDetails)){
                    
                    con.TC_Revision_Details__c  = ' CES Contract Record';
                }
                //Add to TC_Revision_Details__c
                else{
                    con.TC_Revision_Details__c = TcRevisionDetails + '; Contract Record';
                }
               
            }
        }
        for (CESContract__c con : tcFalseContracts){
            CESContract__c oldCon = oldmap.get(con.Id);
            //Pending TC Changes to False
            if(con.Pending_TC_Revision__c !=  oldCon.Pending_TC_Revision__c){
                //Set Contract Fields
                con.Account_Name_Change__c         = false;
				con.TC_Revision_Date__c            = null;
                con.TC_Revision_Requires_Review__c = False;
                con.TC_Revision_Details__c           = null;
            }
        }
        }//end of TC Revision killswitch
        
        // only run if a legacy contract exists
        if (legacy){
        	rates = [select id, name, Contract_Volume_Required__c, CNP_MNG_Pricing_Type__c, Is_FOM_Price_Type__c from Rate__c where Plan__r.name = 'CES C&I Pricing Options'];
            
            // get margin custom settings
            CIMarginCalcInputs__c marginDefaults = CIMarginCalcInputs__c.getOrgDefaults();
    
            for (Rate__c r:rates){
                rateVolReqMap.put(r.id, r.Contract_Volume_Required__c);
                rateMap.put(r.id, r);
            }
    
            for (CESContract__c con:CESCs){
                boolean volRequired = false;
                CESContract__c oldc;
                if (oldmap != null){
                    oldc = oldmap.get(con.id);
                }
                if (con.Existing_Base_Agreement__c != null){//only TC's should hit this logic
                    try{
                        volRequired = (boolean)rateVolReqMap.get(con.Product_Subtype_Lookup__c);
                    } catch (exception e){volRequired=false;}
    
                    if (volRequired){//volumes are required so validate
                        if (oldc != null){//update
                            if (con.Term_New__c != oldc.Term_New__c || con.Start_Date_New__c != oldc.Start_Date_New__c){
                                con.Volume_Validation_Check__c = 'Failed: Volumes term does not match Contract Term';
                            }
                        } else {//insert
                            if (!con.Record_Type_Name__c.contains('Fixed Price')){
                                con.Volume_Validation_Check__c = 'Failed: Volumes term does not match Contract Term';
                            }
                        }
                    }
                }
    
                if (oldc == null){//insert
                    if (con.Field_Validation_Check__c == 'Passed System'){//populated from an external process, so make it passed
                        con.Field_Validation_Check__c = 'Passed';
                    } else{//usually populated from a clone, so not pass
                        con.Field_Validation_Check__c = 'Failed: Required fields missing values';
                    }
                    
                    try{
                        Rate__c prod = (Rate__c)rateMap.get(con.Product_Subtype_Lookup__c);
    
                        // set trueup type if contract volume is required.  this may change when contract is activated for fom with multi premises
                        if (prod.Contract_Volume_Required__c){
                            con.Trueup_Type__c = 'Account Level';
                        }
    
                        // set cnp mng product defaults for tc inserts only
                        if (prod.name == 'Index Guaranteed Supply'){
                            con.CNP_MNG_Product_Cost__c = marginDefaults.GSupply_Volumetric_Cost__c;
                        } else if (prod.name == 'Index Guaranteed Value plus Supply'){
                            con.CNP_MNG_Product_Cost__c = marginDefaults.GSupply_Volumetric_Cost__c;
                            con.CNP_MNG_Product_Margin__c = marginDefaults.GValue_Margin__c;
                        } else if (prod.name == 'Index Guaranteed Savings'){
                            con.CNP_MNG_Product_Margin__c = marginDefaults.GSavings_Base_Margin__c;
                        } else if (prod.name == 'Index Enhanced Supply'){
                            con.CNP_MNG_Product_Margin__c = marginDefaults.ESupply_Margin__c;
                        }
                    } catch (exception e){system.debug(e.getMessage());}
                } else {//update
                    if (con.Field_Validation_Check__c == 'Failed: Required fields missing values'){//if update succeeds, field validation passes
                        con.Field_Validation_Check__c = 'Passed';
                    }
                }
            }
        }
    }

    public static void CESContractAfterUpdateProcess(list<CESContract__c> CESCs, map<id, CESContract__c> oldmap){
        // *** CHANGED PROCESS TO ONLY RUN IF OFFICE IS NOT SET TO SYNC TO SAFARI.  
        // *** IF OFFICE IS SET TO SYNC WITH SAFARI, ACTIVATION IS HANDLED BY BUTTON ON CONTRACT
        // *** CHANGE APPROVAL PROCESS TO SET STATUS TO PENDING ACTIVATION INSTEAD OF ACTIVE FOR OFFICE SET TO SYNC TO SAFARI ***
        //list<Account> offs = new list<Account>();
        map<Id, String> offCodeMap = new map<Id, String>();
        list<AsyncRequest__c> reqs = new list<AsyncRequest__c>();
		
        // determine if any contracts are legacy
        boolean legacy = false;

        // check if contracts are part of the legacy process
        // BDM 04-01-19 16562: include surrendered storage pricing as non-legacy type
        for (CESContract__c con:CESCs){
            if (con.Record_Type_Name__c != 'Base Pricing' && 
                con.Record_Type_Name__c != 'Fixed Tier Pricing' &&
                con.Record_Type_Name__c != 'Spot Pricing' &&
                con.Record_Type_Name__c != 'Storage' &&
                con.Record_Type_Name__c != 'Surrendered Storage Pricing'){
                    legacy = true;
                }
            }
            
        // only run if a legacy contract exists
        if (legacy){
        
            //get office list and make a map
            offCodeMap = CESUtilities.getOfficeCodeMap();
           
            //*** Process TCs ***
            list<CESContract__c> conDateChanges = new list<CESContract__c>();
    
    
            /* moved to CESDataSyncUtilities
            //**** get object type and fields for user field change comparison ****
            list<Sync_User_Field_Value__c> valsToUpdate = new list<Sync_User_Field_Value__c>();
            
            CESDataSyncUtilities.SyncContractUserFieldObject syncObject = CESDataSyncUtilities.BuildContractSyncUserFieldObject(null, CESCs, offCodeMap);
            */
            CESDataSyncUtilities.upsertObjectSUFvalues(CESCs, oldmap, false);
    
    /*
            Schema.SObjectType targetType = Schema.getGlobalDescribe().get('CESContract__c');
            Map<String, Schema.sObjectField> targetFields = targetType.getDescribe().fields.getMap();
    
            //get sync field map
            Map<String, Sync_User_Field__c> sufMap = new Map<String, Sync_User_Field__c>();
            list<Sync_User_Field__c> sufs = [select id, name, Source_Object_Sync_Field_Name__c, Divide_by_Therm_Factor__c, Multiply_by_Therm_Factor__c 
                                                    from Sync_User_Field__c where Field_Type__c = 'Contract' order by name];
    
            system.debug('*********** building sufMap *******');
            for (Sync_User_Field__c suf:sufs){
                sufMap.put(suf.Source_Object_Sync_Field_Name__c, suf);
                system.debug('suf sync field: ' + suf.Source_Object_Sync_Field_Name__c + ', suf name: ' + suf.name);
            }
    
            //get existing sync field values for these contracts
            Set<Id> conIdSet = new Set<Id>();
            map<Id, map<String, Sync_User_Field_Value__c>> ufvMap = new map<Id, map<String, Sync_User_Field_Value__c>>();
            for (CESContract__c con:CESCs){
                conIdSet.add(con.id);
                ufvMap.put(con.id, new map<String, Sync_User_Field_Value__c>{});
    
            }
            list<Sync_User_Field_Value__c> ufVals = new list<Sync_User_Field_Value__c>();
            ufVals = [select id, name, CESContract__c, Value__c, Sync_User_Field__c, Sync_User_Field__r.name, Sync_User_Field__r.Source_Object_Sync_Field_Name__c, 
                    Sync_User_Field__r.Divide_by_Therm_Factor__c, Sync_User_Field__r.Multiply_by_Therm_Factor__c from Sync_User_Field_Value__c where CESContract__c in: conIdSet
                    order by CESContract__c, Sync_User_Field__r.name];
    
            //build mape of contract and its associated user field values
            if (ufVals.size()>0){
                for (Sync_User_Field_Value__c ufv:ufVals){
                    ufvMap.get(ufv.CESContract__c).put(ufv.Sync_User_Field__r.Source_Object_Sync_Field_Name__c,ufv);
                }
            }
    */
            //**** cycle through each contract ****
            for (CESContract__c con: CESCs){
                //try and get office code
                string offCode = null;
                try {
                    offCode = offCodeMap.get(con.CES_Office__c);
                } catch (exception e) {offCode = null;}
    
                //process activation if sync setting is false
                //only do this if sync setting is turned off for this office
                CESContract__c oldc = oldmap.get(con.id);//turned off async to process tc since it will be done by user now
                if (con.Active__c && !oldc.Active__c && con.Account__c != null){ //contract is active after update, not before, and has account
                    if (!con.Record_Type_Name__c.contains('Agreement')){ //not an agreement contract
                        boolean syncSetting = false;
                        
                        if (offCode != null){
                            system.debug('office is: '+ offCode);
                            if (!CESUtilities.getSafariSyncSetting(offCode)){//if this is not a sync office, then process the tc automatically
                                // this should not fire any longer since all offices are syncing.  converted to queueable anyway
                                reqs.add(new AsyncRequest__c(Type__c='ProcessTCActivation',Params__c=con.id,Queueable__c=true));
                            }
                        }
                    }
                }
                //**** check if dates were changed ****
                //to be used later to update related objects
                if (con.Start_Date_New__c != oldc.Start_Date_New__c || con.Current_End_Date__c != oldc.Current_End_Date__c){
                    conDateChanges.add(con);
                }
    
                /* moved to CESDataSyncUtilities
                //**** process user field changes ****
                //look to see if user fields have been previously created (on the old version, not updated to avoid activation updates firing this twice) and if they have changed with this update
                if (oldc.Sync_Field_Values_Created__c){
                    //field values have been created so now look for changes
                    for (String str : syncObject.targetFields.keyset()) { 
                        Sync_User_Field__c suf;
                        try { 
                            System.debug('Field name: '+str +'. New value: ' + con.get(str) +'. Old value: '+oldc.get(str)); 
                            if(con.get(str) != oldc.get(str)){ 
                                system.debug('******The value has changed!!!! ');
                                system.debug('******* target field name: ' + str);
                                suf = syncObject.UserFieldMapBySourceFieldName.get(str);
                            } 
                        } catch (Exception e) { System.debug('Error: ' + e); suf=null; }
    
                        //changed value is for a sync field so update it
                        if (suf != null){
                            Sync_User_Field_Value__c valFromMap;
                            try {
                                valFromMap = syncObject.ContractUserFieldValueMap.get(con.id).get(str);
                            } catch (exception e) {valFromMap = null;}
                            if (valFromMap != null){
                                try {
                                    Sync_User_Field_Value__c sval = CESDataSyncUtilities.UpdateSyncUserFieldValue(con, null, suf, valFromMap, syncObject.targetFields, offCode);
                                    if (sval != null){
                                        valsToUpdate.add(sval);
                                    }
                                } catch (exception e) {system.debug('Update Error: ' + e);}
                            }
                        } 
                    }
                }
                */
            }
            if (reqs.size()>0){insert reqs;}
            /* *** moved to CESDataSyncUtilities
            if (valsToUpdate.size()>0){update valsToUpdate;} 
            */
    
            //*** Process date changes on supporting objects ***
            if (conDateChanges.size()>0){//dates were changed so update any contract premises that matched the original dates and/or contract requests
                set<Id> conSet = new set<Id>();
                map<String, CESContract__c> conReqMap = new map<String,CESContract__c>();
                set<String> conReqSet = new set<String>();
                list<Contract_Premise__c> conPremsForDates = new list<Contract_Premise__c>();
                for (CESContract__c con:conDateChanges){
                    conSet.add(con.id);
                    if (con.Contract_Request__c!=null){
                        conReqSet.add(con.Contract_Request__c);
                        conReqMap.put(con.Contract_Request__c, con);
                    }
                }
                conPremsForDates = [select id, name, CESContract__c, Start_Date__c, End_Date__c, Premise__c from Contract_Premise__c where CESContract__c in: conSet order by CESContract__c, Premise__c];
                if (conPremsForDates.size()>0){
                    list<Contract_Premise__c> cPrems = new list<Contract_Premise__c>();
                    id currCESC = null;
                    map<Id, list<Contract_Premise__c>> CESCConPremMap = new map<Id, list<Contract_Premise__c>>();
    
                    for (Contract_Premise__c cp: conPremsForDates){
                        if (currCESC == null){ //first record of the loop
                            currCESC = cp.CESContract__c;
                            cPrems.add(cp);
                        }
                        else if(currCESC == cp.CESContract__c){ //this record is the same contract as last so add to existing list
                            cPrems.add(cp);
                        }
                        else{//this record has a different contract so add existing list with old contract and start new list for this contract
                            CESCConPremMap.put(currCESC,cPrems);
                            cPrems = new list<Contract_Premise__c>();
                            currCESC = cp.CESContract__c;
                            cPrems.add(cp);
                        }
                    }
                    //add the last iteration to the map
                    CESCConPremMap.put(currCESC,cPrems);
    
                    list<Contract_Premise__c> cPremsForUpdate = new list<Contract_Premise__c>();
                    for (CESContract__c con:conDateChanges){//now that contract premises are mapped to contracts, see if the start/end dates need to be updated
                        list<Contract_Premise__c> cps = new list<Contract_Premise__c>();
                        try {
                            cps = CESCConPremMap.get(con.id);
                        } catch (exception e){}
    
                        if (cps.size()>0){//contract premises were found, now check dates
                            CESContract__c oldc = oldmap.get(con.id);
                            for (Contract_Premise__c cp:cps){
                                boolean isUpdate = false;
                                if (cp.Start_Date__c == oldc.Start_Date_New__c && oldc.Start_Date_New__c != con.Start_Date_New__c){//conPrem matches original start date and start date was changed
                                    cp.Start_Date__c = con.Start_Date_New__c;
                                    isUpdate = true;
                                } else if (cp.Start_Date__c < con.Start_Date_New__c){//conPrem does not match original but is less than new start date
                                    cp.Start_Date__c = con.Start_Date_New__c;
                                    isUpdate = true;
                                }
                                if (cp.End_Date__c == oldc.Current_End_Date__c && oldc.Current_End_Date__c != con.Current_End_Date__c){//conPrem matches original end date and end date was changed
                                    cp.End_Date__c = con.Current_End_Date__c;
                                    isUpdate = true;
                                } else if (cp.End_Date__c > con.Current_End_Date__c){//conPrem does not match original but is greater than new end date
                                    cp.End_Date__c = con.Current_End_Date__c;
                                    isUpdate = true;
                                }
                                if (isUpdate){cPremsForUpdate.add(cp);}
                            }
                        }
                    }
                    if (cPremsForUpdate.size()>0){update cPremsForUpdate;}
                }
                //check for contract request settings to be updated
                list<Contract_Request__c> creqs = new list<Contract_Request__c>();
                try{
                    creqs = [select id, name, Start_Date__c, Term__c from Contract_Request__c where id in: conReqSet];
                } catch (exception e){}
                if (creqs.size()>0){
                    list<Contract_Request__c> crsToUpdate = new list<Contract_Request__c>();
                    for (Contract_Request__c cr:creqs){
                        CESContract__c cc;
                        try{
                            cc = conReqMap.get((String)cr.id);
                        } catch (exception e){}
                        if (cc != null){
                            cr.Start_Date__c = cc.Start_Date_New__c;
                            cr.Term__c = cc.Total_Term_Months__c;
                            crsToUpdate.add(cr);
                        }
                    }
                    if (crsToUpdate.size()>0){update crsToUpdate;}
                }
    
            }
            //*** USE WORKFLOW FIELD UPDATE SET_CONTRACT_PENDING_SAFARI_SYNC ***
        }
    }
    public static void CESContractBeforeDeleteProcess(list<CESContract__c> CESCs){
        Set<Id> tcSet = new Set<Id>();
        list<Position__c> pos = new list<Position__c>();
        list<Sync_User_Field_Value__c> vals = new list<Sync_User_Field_Value__c>();
        list<Customer_Charge__c> ccs = new list<Customer_Charge__c>();
		
        // determine if any contracts are legacy
        boolean legacy = false;
        
        // check if contracts are part of the legacy process
        // // BDM 04-01-19 16562: include surrendered storage pricing as non-legacy type
        for (CESContract__c con:CESCs){
            if (con.Record_Type_Name__c != 'Base Pricing' && 
                con.Record_Type_Name__c != 'Fixed Tier Pricing' &&
                con.Record_Type_Name__c != 'Spot Pricing' &&
                con.Record_Type_Name__c != 'Storage' &&
                con.Record_Type_Name__c != 'Surrendered Storage Pricing'){
                    legacy = true;
                }
        }
        
        // only run if a legacy contract exists
        if (legacy){
            for (CESContract__c con: CESCs){
                if (!con.Record_Type_Name__c.contains('Agreement')){//not an agreement contract
                    tcSet.add(con.Id);//get set of tc ids to get all positions related to deleted tcs
                }
            }
            if (tcSet.size()>0){
                pos = [select id, name, CES_Contract__c from Position__c where CES_Contract__c in: tcSet and CES_Contract__c != null];
                if (pos.size()>0){delete pos;}//get positions and delete
    
                vals = [select id, name, CESContract__c from Sync_User_Field_Value__c where CESContract__c in: tcSet and CESContract__c != null];
                if (vals.size()>0){delete vals;}//get sync values and delete
    
                ccs = [select id, name, Contract__c from Customer_Charge__c where Contract__c in: tcSet and Contract__c != null];
                if (ccs.size()>0){delete ccs;}// get contract charges and delete
            }
        }
    }

//*****************************************************************************
//*** POSITION METHODS *********************************************************
//*****************************************************************************
    public static list<Position__c> FillPositionsWithoutSave(CESContract__c cesc, boolean setSyncProperties){
        list<Position__c> posList = new list<Position__c>();
        if (cesc.term_new__c != null && cesc.start_date_new__c != null){
            integer mths = Integer.valueOf(cesc.Term_New__c);
            date period = cesc.start_date_new__c;
            string zero;
            
            while (mths > 0){ //cycle through the term and add records
                Position__c pos = new Position__c();
                if (period.month() < 10) zero = '0'; else zero = ''; //fill leading zero if less than 10
                
                pos.name = cesc.name + ': ' + zero + String.valueOf(period.month()) + '-' + String.valueOf(period.year());
                pos.CES_Contract__c = cesc.id;
                pos.Facility_List__c = cesc.Facility_List__c;
                pos.Contract_Month__c = period;
                if (setSyncProperties){
                    pos.Safari_Key__c = 'Pending-' + cesc.CES_Office__r.Customer_Number__c;
                    pos.Safari_Sync_Status__c = 'Pending Sync';
                }

                if (!cesc.Record_Type_Name__c.contains('Lock')){
                    pos.Customer_Price__c=cesc.sales_adder__c;
                    pos.Customer_PriceWACOG__c = cesc.Sales_Adder__c;
                    if(cesc.Index_Adder__c!=null) {
                        pos.Adder__c = cesc.Index_Adder__c; 
                        pos.AdderWACOG__c = cesc.Index_Adder__c; }
                    else{ 
                        pos.Adder__c=0;
                        pos.AdderWACOG__c=0;}
                    pos.Other_Charges__c=0;
                    pos.Balancing__c=0;
                    pos.DT_Basis__c=0;
                    pos.DT_Basis_Physical__c=0;
                    pos.DT_NYMEX__c=0;
                    pos.Fuel_Cost__c=0;
                    pos.PL_Commodity__c=0;
                    pos.PL_Demand__c=0;
                    pos.Swing_Cost__c=0;
                }

                pos.Contract_CES_Unit_Margin__c = cesc.UDF_CESUM__c;
                pos.Contract_Gross_Unit_Margin__c = cesc.UDF_GUM__c;
                pos.Contract_Total_Gross_Unit_Margin__c = cesc.UDF_GUM__c;
                pos.Contract_Consultant_Unit_Margin__c = cesc.Consultant_Unit_Margin__c;
                //get contract pricing information for monthly records
                if (cesc.Record_Type_Name__c.contains('Guaranteed') || cesc.Record_Type_Name__c.contains('Enhanced Supply')){
                    pos.contract_pricing_index__c = cesc.Utility_Rate_Name__c;}
                else if (cesc.Record_Type_Name__c.contains('Market Price')){
                    pos.contract_pricing_index__c = cesc.Market_Rate_Index_Name__c;}
                else {
                    pos.contract_pricing_index__c = cesc.Index_Rate_Name__c;
                    if (cesc.Product_Subtype_Lookup__r.Contract_Volume_Required__c){
                        pos.contract_over_index__c = cesc.Over_Index_Name__c;
                        pos.contract_over_adder__c = cesc.Over_Adder__c;
                        pos.contract_over_margin__c = cesc.Margin_on_Over__c;
                        pos.contract_under_index__c = cesc.Under_Index_Name__c;
                        pos.contract_under_adder__c = cesc.Under_Adder__c;
                        pos.contract_under_margin__c = cesc.Margin_on_Under__c;} 
                }

                // get cashout information
                if (cesc.Product_Subtype_Lookup__r.Cashout_Obligation_Applies__c){
                    pos.Cashout_Over_Index__c = cesc.Cashout_Over_Index_Name__c;
                    pos.Cashout_Over_Adder__c = cesc.Cashout_Over_Adder__c;
                    pos.Cashout_Over_Margin__c = cesc.Cashout_Over_Margin__c;
                    pos.Cashout_Under_Index__c = cesc.Cashout_Under_Index_Name__c;
                    pos.Cashout_Under_Adder__c = cesc.Cashout_Under_Adder__c;
                    pos.Cashout_Under_Margin__c = cesc.Cashout_Under_Margin__c;
                }
                
                posList.add(pos);
                period = period.addMonths(1); //increment date by 1 month
                mths--; //decrement remaining term by 1
            }
            //if (posList.size()>0){insert posList;}
        }

        return posList;
    }

    @TestVisible private static Position__c CreatePosition(CESContract__c cesc, boolean setSyncProperties, date period, string zero){
        Position__c pos = new Position__c();

        pos.name = cesc.name + ': ' + zero + String.valueOf(period.month()) + '-' + String.valueOf(period.year());
        pos.CES_Contract__c = cesc.id;
        pos.Facility_List__c = cesc.Facility_List__c;
        pos.Contract_Month__c = period;
        if (setSyncProperties){
            pos.Safari_Key__c = 'Pending-' + cesc.CES_Office__r.Customer_Number__c;
            pos.Safari_Sync_Status__c = 'Pending Sync';
        }

        if (!cesc.Record_Type_Name__c.contains('Lock')){
            pos.Customer_Price__c=cesc.sales_adder__c;
            pos.Customer_PriceWACOG__c = cesc.Sales_Adder__c;
            if(cesc.Index_Adder__c!=null) {
                pos.Adder__c = cesc.Index_Adder__c; 
                pos.AdderWACOG__c = cesc.Index_Adder__c; }
            else{ 
                pos.Adder__c=0;
                pos.AdderWACOG__c=0;}
            pos.Other_Charges__c=0;
            pos.Balancing__c=0;
            pos.DT_Basis__c=0;
            pos.DT_Basis_Physical__c=0;
            pos.DT_NYMEX__c=0;
            pos.Fuel_Cost__c=0;
            pos.PL_Commodity__c=0;
            pos.PL_Demand__c=0;
            pos.Swing_Cost__c=0;
        }

        pos.Contract_CES_Unit_Margin__c = cesc.UDF_CESUM__c;
        pos.Contract_Gross_Unit_Margin__c = cesc.UDF_GUM__c;
        pos.Contract_Total_Gross_Unit_Margin__c = cesc.UDF_GUM__c;
        pos.Contract_Consultant_Unit_Margin__c = cesc.Consultant_Unit_Margin__c;
        //get contract pricing information for monthly records
        // mod: consolidate contract indexes
        /*
        if (cesc.Record_Type_Name__c.contains('Guaranteed') || cesc.Record_Type_Name__c.contains('Enhanced Supply')){
            pos.contract_pricing_index__c = cesc.Utility_Rate_Name__c;}
        else if (cesc.Record_Type_Name__c.contains('Market Price')){
            pos.contract_pricing_index__c = cesc.Market_Rate_Index_Name__c;}
        else {
        */
            pos.contract_pricing_index__c = cesc.Index_Rate_Name__c;
            try {
                pos.LDC_Fuel_Rate__c = cesc.LDC_Fuel_Rate__c;
            } catch (exception e){}
            try {
                pos.Pipeline_Fuel_Rate__c = cesc.Pipeline_Fuel_Rate__c;
            } catch (exception e){}

            if (cesc.Product_Subtype_Lookup__r.Contract_Volume_Required__c || cesc.Product_Subtype_Lookup__r.Receipt_Obligation_Applies__c){
                pos.contract_over_index__c = cesc.Over_Index_Name__c;
                pos.contract_over_adder__c = cesc.Over_Adder__c;
                pos.contract_over_margin__c = cesc.Margin_on_Over__c;
                pos.contract_under_index__c = cesc.Under_Index_Name__c;
                pos.contract_under_adder__c = cesc.Under_Adder__c;
                pos.contract_under_margin__c = cesc.Margin_on_Under__c; 
                try {
                    pos.Over_LDC_Fuel_Rate__c = cesc.Over_LDC_Fuel_Rate__c;
                } catch (exception e){}
                try {
                    pos.Over_Pipeline_Fuel_Rate__c = cesc.Over_Pipeline_Fuel_Rate__c;
                } catch (exception e){}
                try {
                    pos.Under_LDC_Fuel_Rate__c = cesc.Under_LDC_Fuel_Rate__c;
                } catch (exception e){}
                try {
                    pos.Under_Pipeline_Fuel_Rate__c = cesc.Under_Pipeline_Fuel_Rate__c;
                } catch (exception e){}
            }
        //}
        // end mod: consolidate contract indexes

        // get cashout information
        if (cesc.Product_Subtype_Lookup__r.Cashout_Obligation_Applies__c){
            pos.Cashout_Over_Index__c = cesc.Cashout_Over_Index_Name__c;
            pos.Cashout_Over_Adder__c = cesc.Cashout_Over_Adder__c;
            pos.Cashout_Over_Margin__c = cesc.Cashout_Over_Margin__c;
            pos.Cashout_Under_Index__c = cesc.Cashout_Under_Index_Name__c;
            pos.Cashout_Under_Adder__c = cesc.Cashout_Under_Adder__c;
            pos.Cashout_Under_Margin__c = cesc.Cashout_Under_Margin__c;
        }

        return pos;
    }

    public static list<Position__c> RecalcPendingContractPositions(list<Position__c> positions, CESContract__c cesc){
        
        for (Position__c pos:positions){
            if (!cesc.Record_Type_Name__c.contains('Lock')){
                pos.Customer_Price__c=cesc.sales_adder__c;
                pos.Customer_PriceWACOG__c = cesc.Sales_Adder__c;
                if(cesc.Index_Adder__c!=null) {
                    pos.Adder__c = cesc.Index_Adder__c; 
                    pos.AdderWACOG__c = cesc.Index_Adder__c; }
                else{ 
                    pos.Adder__c=0;
                    pos.AdderWACOG__c=0;}

                pos.Other_Charges__c=0;
                pos.Balancing__c=0;
                pos.DT_Basis__c=0;
                pos.DT_Basis_Physical__c=0;
                pos.DT_NYMEX__c=0;
                pos.Fuel_Cost__c=0;
                pos.PL_Commodity__c=0;
                pos.PL_Demand__c=0;
                pos.Swing_Cost__c=0;
            }

            pos.Contract_CES_Unit_Margin__c = cesc.UDF_CESUM__c;
            pos.Contract_Gross_Unit_Margin__c = cesc.UDF_GUM__c;
            pos.Contract_Total_Gross_Unit_Margin__c = cesc.UDF_GUM__c;
            pos.Contract_Consultant_Unit_Margin__c = cesc.Consultant_Unit_Margin__c;

            //get contract pricing information for monthly records
            // mod: consolidate contract indexes
            /*
            if (cesc.Record_Type_Name__c.contains('Guaranteed') || cesc.Record_Type_Name__c.contains('Enhanced Supply')){
                pos.contract_pricing_index__c = cesc.Utility_Rate_Name__c;}
            else if (cesc.Record_Type_Name__c.contains('Market Price')){
                pos.contract_pricing_index__c = cesc.Market_Rate_Index_Name__c;}
            else {
            */
                pos.contract_pricing_index__c = cesc.Index_Rate_Name__c;
                try {
                    pos.LDC_Fuel_Rate__c = cesc.LDC_Fuel_Rate__c;
                } catch (exception e){}
                try {
                    pos.Pipeline_Fuel_Rate__c = cesc.Pipeline_Fuel_Rate__c;
                } catch (exception e){}

                if (cesc.Product_Subtype_Lookup__r.Contract_Volume_Required__c || cesc.Product_Subtype_Lookup__r.Receipt_Obligation_Applies__c){
                    pos.contract_over_index__c = cesc.Over_Index_Name__c;
                    pos.contract_over_adder__c = cesc.Over_Adder__c;
                    pos.contract_over_margin__c = cesc.Margin_on_Over__c;
                    pos.contract_under_index__c = cesc.Under_Index_Name__c;
                    pos.contract_under_adder__c = cesc.Under_Adder__c;
                    pos.contract_under_margin__c = cesc.Margin_on_Under__c; 
                    try {
                        pos.Over_LDC_Fuel_Rate__c = cesc.Over_LDC_Fuel_Rate__c;
                    } catch (exception e){}
                    try {
                        pos.Over_Pipeline_Fuel_Rate__c = cesc.Over_Pipeline_Fuel_Rate__c;
                    } catch (exception e){}
                    try {
                        pos.Under_LDC_Fuel_Rate__c = cesc.Under_LDC_Fuel_Rate__c;
                    } catch (exception e){}
                    try {
                        pos.Under_Pipeline_Fuel_Rate__c = cesc.Under_Pipeline_Fuel_Rate__c;
                    } catch (exception e){}
                }
            //}
            // end mod: consolidate contract indexes

            // get cashout information
            if (cesc.Product_Subtype_Lookup__r.Cashout_Obligation_Applies__c){
                pos.Cashout_Over_Index__c = cesc.Cashout_Over_Index_Name__c;
                pos.Cashout_Over_Adder__c = cesc.Cashout_Over_Adder__c;
                pos.Cashout_Over_Margin__c = cesc.Cashout_Over_Margin__c;
                pos.Cashout_Under_Index__c = cesc.Cashout_Under_Index_Name__c;
                pos.Cashout_Under_Adder__c = cesc.Cashout_Under_Adder__c;
                pos.Cashout_Under_Margin__c = cesc.Cashout_Under_Margin__c;
            }
        }

        return positions;
    }

    public static list<Position__c> FillPositionsWithoutSave1(CESContract__c cesc, boolean setSyncProperties){
        list<Position__c> posList = new list<Position__c>();
        if (cesc.term_new__c != null && cesc.start_date_new__c != null){
            integer mths = Integer.valueOf(cesc.Term_New__c);
            boolean daily = false;
            date period = cesc.start_date_new__c;
            string zero;

            if (cesc.Require_Daily_Positions__c){daily = true;}
            
            while (mths > 0){ //cycle through the term and add records
                
                if (period.month() < 10) zero = '0'; else zero = ''; //fill leading zero if less than 10
                
                if (daily){//cycle through each day of the month and create a position
                    date currPeriod = period;

                    while (currPeriod < period.addMonths(1)){
                        posList.add(CreatePosition(cesc, setSyncProperties, currPeriod, zero));

                        currPeriod = currPeriod.addDays(1);
                    }
                } else {//monthly so just add one record for the month
                    posList.add(CreatePosition(cesc, setSyncProperties, period, zero));
                }
                
                period = period.addMonths(1); //increment date by 1 month
                mths--; //decrement remaining term by 1
            }
        }

        return posList;
    }
	
	@TestVisible private static void FillPositions(CESContract__c cesc, boolean setSyncProperties)
    {
        if (cesc.term_new__c != null && cesc.start_date_new__c != null){
            list<Position__c> posList = new list<Position__c>();
            posList = FillPositionsWithoutSave(cesc, setSyncProperties);
            if (posList.size()>0){insert posList;}
        }
    }

    @TestVisible private static void ConvertMonthlyPositionsToDaily(list<Position__c> pos){
        list<Position__c> posList = new list<Position__c>();
        for (Position__c p:pos){
            date period = p.Contract_Month__c;
            date currPeriod = period.addDays(1);//start on day 2 since day one already exists for monthly record
            string zero;

            if (p.Contract_Month__c.month() < 10) zero = '0'; else zero = ''; //fill leading zero if less than 10

            while (currPeriod < period.addMonths(1)){
                Position__c np = p.clone(false,false,false,false);
                np.Contract_Month__c = currPeriod;

                posList.add(np);
                currPeriod = currPeriod.addDays(1);
            }
        }
        insert posList;
    }

    @TestVisible private static integer ConvertMonthlyPositionsToDaily1(list<Position__c> pos){
        list<Position__c> posList = new list<Position__c>();
        for (Position__c p:pos){
            date period = p.Contract_Month__c;
            date currPeriod = period.addDays(1);//start on day 2 since day one already exists for monthly record
            string zero;

            if (p.Contract_Month__c.month() < 10) zero = '0'; else zero = ''; //fill leading zero if less than 10

            while (currPeriod < period.addMonths(1)){
                Position__c np = p.clone(false,false,false,false);
                np.Contract_Month__c = currPeriod;

                posList.add(np);
                currPeriod = currPeriod.addDays(1);
            }
        }
        insert posList;

        return posList.size();
    }

    public static void updatePositionDataFromContract(id cid){
        CESContract__c cesc; 
        list<Position__c> ps = new list<Position__c>();

        cesc = [select id, name, Record_Type_Name__c, Sales_Adder__c, Index_Adder__c, UDF_CESUM__c, UDF_GUM__c, UDF_TGUM__c, Consultant_Unit_Margin__c, 
                Index_Rate_Name__c, Utility_Rate_Name__c, Market_Rate_Index_Name__c, Product_Subtype_Lookup__r.Contract_Volume_Required__c, Over_Index_Name__c,
                Over_Adder__c, Margin_on_Over__c, Under_Index_Name__c, Under_Adder__c, Margin_on_Under__c, Product_Subtype_Lookup__r.Cashout_Obligation_Applies__c, 
                Cashout_Over_Index_Name__c, Cashout_Over_Adder__c, Cashout_Over_Margin__c, Cashout_Under_Index_Name__c, Cashout_Under_Adder__c, Cashout_Under_Margin__c 
                from CESContract__c where id =: cid];

        ps = [select id, name, CES_Contract__c, Contract_Month__c, Customer_Price__c, Customer_PriceWACOG__c, Adder__c, AdderWACOG__c, Contract_CES_Unit_Margin__c, 
                Contract_Gross_Unit_Margin__c, Contract_Total_Gross_Unit_Margin__c, Contract_Consultant_Unit_Margin__c, Contract_Pricing_Index__c, 
                Contract_Over_Index__c, Contract_Over_Adder__c, Contract_Over_Margin__c, Contract_Under_Index__c, Contract_Under_Adder__c, Contract_Under_Margin__c,
                Cashout_Over_Index__c, Cashout_Over_Adder__c, Cashout_Over_Margin__c, Cashout_Under_Index__c, Cashout_Under_Adder__c, Cashout_Under_Margin__c 
                from Position__c where CES_Contract__c =: cid];

        for (Position__c pos:ps){

            if (!cesc.Record_Type_Name__c.contains('Lock')){
                pos.Customer_Price__c=cesc.sales_adder__c;
                pos.Customer_PriceWACOG__c = cesc.Sales_Adder__c;
                if(cesc.Index_Adder__c!=null) {
                    pos.Adder__c = cesc.Index_Adder__c; 
                    pos.AdderWACOG__c = cesc.Index_Adder__c; }
                else{ 
                    pos.Adder__c=0;
                    pos.AdderWACOG__c=0;}
                /*
                pos.Other_Charges__c=0;
                pos.Balancing__c=0;
                pos.DT_Basis__c=0;
                pos.DT_Basis_Physical__c=0;
                pos.DT_NYMEX__c=0;
                pos.Fuel_Cost__c=0;
                pos.PL_Commodity__c=0;
                pos.PL_Demand__c=0;
                pos.Swing_Cost__c=0;
                */
            }

            pos.Contract_CES_Unit_Margin__c = cesc.UDF_CESUM__c;
            pos.Contract_Gross_Unit_Margin__c = cesc.UDF_GUM__c;
            pos.Contract_Total_Gross_Unit_Margin__c = cesc.UDF_GUM__c;
            pos.Contract_Consultant_Unit_Margin__c = cesc.Consultant_Unit_Margin__c;
            //get contract pricing information for monthly records
            if (cesc.Record_Type_Name__c.contains('Guaranteed') || cesc.Record_Type_Name__c.contains('Enhanced Supply')){
                pos.contract_pricing_index__c = cesc.Utility_Rate_Name__c;}
            else if (cesc.Record_Type_Name__c.contains('Market Price')){
                pos.contract_pricing_index__c = cesc.Market_Rate_Index_Name__c;}
            else {
                pos.contract_pricing_index__c = cesc.Index_Rate_Name__c;
                if (cesc.Product_Subtype_Lookup__r.Contract_Volume_Required__c){
                    pos.contract_over_index__c = cesc.Over_Index_Name__c;
                    pos.contract_over_adder__c = cesc.Over_Adder__c;
                    pos.contract_over_margin__c = cesc.Margin_on_Over__c;
                    pos.contract_under_index__c = cesc.Under_Index_Name__c;
                    pos.contract_under_adder__c = cesc.Under_Adder__c;
                    pos.contract_under_margin__c = cesc.Margin_on_Under__c;
                }
            }

            // get cashout information
            if (cesc.Product_Subtype_Lookup__r.Cashout_Obligation_Applies__c){
                pos.Cashout_Over_Index__c = cesc.Cashout_Over_Index_Name__c;
                pos.Cashout_Over_Adder__c = cesc.Cashout_Over_Adder__c;
                pos.Cashout_Over_Margin__c = cesc.Cashout_Over_Margin__c;
                pos.Cashout_Under_Index__c = cesc.Cashout_Under_Index_Name__c;
                pos.Cashout_Under_Adder__c = cesc.Cashout_Under_Adder__c;
                pos.Cashout_Under_Margin__c = cesc.Cashout_Under_Margin__c;
            }
        }

        update ps;
    }
/*
    public static list<Position__c> CreatePositionsFromContractListCESR(){
        list<Position__c> posList = new list<Position__c>();
        list<CESContract__c> cescs = new list<CESContract__c>();

        cescs = [select id, name, Account__c, Account__r.name, Facility_List__c, Facility_List__r.name, Start_Date_New__c, End_Date__c, Current_End_Date__c, 
                CES_Office__r.Customer_Number__c, Safari_Key__c, Safari_Sync_Status__c, Sync_Batch__c, Incremental_Sync_OK__c, Contact_For_Confirmations__c, 
                Contact_for_Invoices__c, Contact_for_Invoices__r.name, Contact_for_Invoices__r.FirstName, Contact_for_Invoices__r.LastName, 
                Contact_for_Invoices__r.MailingStreet, Contact_for_Invoices__r.MailingCity, Contact_for_Invoices__r.MailingState, 
                Contact_for_Invoices__r.MailingPostalCode, Contact_for_Invoices__r.Phone, Contact_for_Invoices__r.Fax, Contact_for_Invoices__r.Email, 
                Contact_for_Notices__c, Contact_for_Notices__r.MailingStreet, Contact_for_Notices__r.MailingCity, Contact_for_Notices__r.MailingState, 
                Contact_for_Notices__r.MailingPostalCode, Contact_for_Notices__r.Phone, Contact_for_Notices__r.Fax, Delivery_Obligation__c, 
                Term_New__c, Record_Type_Name__c, Sales_Adder__c, Index_Adder__c, CES_Office__r.name, Utility_Rate_Name__c, Market_Rate_Index_Name__c, 
                Market_Rate_Index_Name__r.Frequency__c, Index_Rate_Name__c, Index_Rate_Name__r.Frequency__c, Product_Subtype_Lookup__r.Name, 
                Product_Subtype_Lookup__r.Contract_Volume_Required__c, Product_Subtype_Lookup__r.Cashout_Obligation_Applies__c, 
                Product_Subtype_Lookup__r.Receipt_Obligation_Applies__c, Product_Subtype_Lookup__r.Fuel_Rates_Apply__c, Over_Index_Name__c, Active__c, Over_Adder__c, 
                Margin_on_Over__c, Under_Index_Name__c, Under_Adder__c, Margin_on_Under__c, Cashout_Over_Index_Name__c, Cashout_Over_Adder__c, Cashout_Over_Margin__c, 
                Cashout_Under_Index_Name__c, Cashout_Under_Adder__c, Cashout_Under_Margin__c, Consultant__c, Consultant_Unit_Margin__c, UDF_TGUM__c, UDF_CESUM__c, 
                UDF_GUM__c, Default_Billing_Net_Terms__c, Date_Activated_by_Contract_Admin__c, UDF_Agency__c, UDF_All_Product_Type__c, UDF_Base_Contract__c, 
                UDF_Contract_Version__c, UDF_DealTranType__c, UDF_Product_Type__c, UDF_Storage_Val__c, UDF_Telemetry__c, UDF_Transport_Fuel__c, UDF_Upstream_Transport__c, 
                UDF_Utility_Meter_Read__c, UDF_Utility_Transport__c, Delivery_Point__c, Utility_Balancing__c, Utility_Cashout__c, Opportunity__c, Opportunity__r.OwnerId, 
                Opportunity__r.Name, Volume_Entry_Type__c, Daily_Volume_Type__c, Require_Daily_Positions__c, Contract_Program_Type__c, Utility_Lookup__r.Name, 
                Utility_Lookup__r.Utility_Code__c, Transport_Bill_Consolidation__c, Sync_Field_Values_Created__c, Contract_ID__c, Invoice_Accounts_Payable__c, 
                Invoice_Address_is_Notice_Address__c, Billing_Address__c, Billing_City__c, Billing_State__c, Billing_Postal_Code__c, Billing_Phone__c, Billing_Fax__c, 
                Billing_Email__c, LDC_Fuel_Rate__c, Pipeline_Fuel_Rate__c, Over_LDC_Fuel_Rate__c, Over_Pipeline_Fuel_Rate__c, Under_LDC_Fuel_Rate__c, 
                Under_Pipeline_Fuel_Rate__c from CESContract__c where GIS_Contract_ID__c != null];
        //system.debug(cescs.size());
        
        for (CESContract__c cesc:cescs){
            if (cesc.term_new__c != null && cesc.start_date_new__c != null){
                date period = Date.parse('04/01/2016'); //cesc.start_date_new__c;
                string zero;

                
                while (period <= cesc.End_Date__c){ //cycle through the term and add records
                    
                    if (period.month() < 10) zero = '0'; else zero = ''; //fill leading zero if less than 10
                    
                    posList.add(CreatePosition(cesc, true, period, zero));
                    
                    period = period.addMonths(1); //increment date by 1 month
                }
            }
        }
        //insert posList;
        
        return posList;
    }
*/

	//*****************************************************************************
	//*** POSITION TRIGGER METHODS ************************************************
	//*****************************************************************************
    public static void PositionBeforeDeleteProcess(list<Position__c> pos){
        /*
        // *** NO LONGER USED FROM TRIGGER ***
        list<AsyncRequest__c> ars = new list<AsyncRequest__c>();

        for (Position__c p:pos){
            if (p.Premise_Margin__c != null){//this is connected to margin
                if (p.Delete_Triggered_by_Margin_Deletion__c == false){//the margin deal is not deleted, so recalc premise margin for this contract position
                    ars.add(new AsyncRequest__c(Type__c='RecalcPremiseMarginAfterChange',Params__c=p.Premise_Margin__c,Queueable__c=true));
                }
            }
        }

        if (ars.size() > 0){ insert ars; }
        */
        list<Position__c> trigs = new list<Position__c>();
        list<Position__c> floats = new list<Position__c>();
        set<Id> floatIdSet = new set<Id>();

        for (Position__c p:pos){
            if (p.Floating_Component_Contract_Detail__c != null){
                // this is a trigger because the floating component is populated
                trigs.add(p);
            } else if (p.FLoating_Index__c != null){
                // this is a floating component because the floating index is populated
                floats.add(p);
                floatIdSet.add(p.id);
            }
        }
        if (trigs.size() > 0){
            CESContractUtils.ApplyTriggerVolumeToPositionRemainingVolume(trigs, true);
        }

        if (floats.size() > 0){
            list<Position__c> floatChildren = new list<Position__c>();
            floatChildren = [select id, name, Floating_Component_Contract_Detail__c from Position__c where Floating_Component_Contract_Detail__c in:floatIdSet];
            system.debug('float children:'); system.debug(floatChildren);
            delete floatChildren;
        }
    }

    // *** NO LONGER USED FROM TRIGGER ***
    public static void PositionAfterUpsertProcess(list<Position__c> pos, map<id, Position__c> oldmap){
        list<AsyncRequest__c> ars = new list<AsyncRequest__c>();

        for (Position__c p:pos){
            Position__c oldp;
            if (oldmap != null){
                oldp = oldmap.get(p.id);
            }

            if (p.Premise_Margin__c != null){
                if (oldp == null){//insert
                    if (p.Originated_From_Margin_Creation__c == false){//not an insert from the margin process, so recalc premise margin
                        ars.add(new AsyncRequest__c(Type__c='ReCalcPremiseMarginAfterChange',Params__c=p.Premise_Margin__c,Queueable__c=true));
                    }
                } else {//update, so recalc regardless of how it was updated
                    ars.add(new AsyncRequest__c(Type__c='ReCalcPremiseMarginAfterChange',Params__c=p.Premise_Margin__c,Queueable__c=true));
                }
            }
        }

        if (ars.size() > 0){ insert ars; } 
    }

    public static void PositionBeforeUpdateProcess(list<Position__c> pos, map<id, Position__c> oldmap){
        /* *** THIS PROCESS WAS ORIGINALLY USED TO CONVERT MONTHLY PS POSITIONS TO DAILY.  NOW THIS IS DONE VIA PROCESS BUILDER INVOKE
           *** LEAVING CODE FOR POSSIBLE LATER NEED

        // check for Allocate Volume Change Daily and pull period usages for those positions
        Set<Id> posIdSet = new Set<Id>();

        for (Position__c p:pos){
            Position__c oldp = oldmap.get(p.id);

            if (p.Allocate_Volume_Change_Daily__c){
                p.Allocate_Volume_Change_Daily__c = false; // flip the flag back to false
                posIdSet.add(p.Id);
            }
        }

        // pull positions with usage and then do updates
        if (posIdSet.size() > 0){
            list<Position__c> posWithAllocs = new list<Position__c>();
            list<Period_Usage__c> allUsages = new list<Period_Usage__c>();
            list<Period_Usage__c> usageToUpdate = new list<Period_Usage__c>();

            allUsages = [select id, name, Position__c, Period__c, Contract_Volume__c from Period_Usage__c where Position__c in:posIdSet order by Position__c, Period__c];
            map<Id, list<Period_Usage__c>> posUsageMap = new map<Id, list<Period_Usage__c>>();

            for (Position__c p:pos){
                list<Period_Usage__c> currUsageList = new list<Period_Usage__c>();

                for (Period_Usage__c u:allUsages){
                    if (p.Id == u.Position__c){ // usage is for this position
                        currUsageList.add(u);
                    }
                }

                if (currUsageList.size() > 0){
                    posUsageMap.put(p.Id, currUsageList);
                    posWithAllocs.add(p);
                }
            }

            for (Position__c p:posWithAllocs){
                
                list<Period_Usage__c> usages = posUsageMap.get(p.Id);
                
                if (usages.size() > 0){
                    // build period usages
                    Date startDay = p.Contract_Month__c.toStartOfMonth();
                    Date endDay = startDay.addMonths(1).addDays(-1);
                    Integer days = Date.daysInMonth(startDay.year(), startDay.month());
                    Integer dailyVol = 0;
                    Integer slush = 0;

                    if (p.Volume_Frequency__c == 'Monthly' && p.Volume__c.intValue() != 0){
                        dailyVol = p.Volume__c.intValue() / days;
                        slush = p.Volume__c.intValue() - (dailyVol * days);
                    } else {
                        dailyVol = p.Volume__c.intValue();
                        slush = 0;
                    }

                    for (Period_Usage__c usage:usages){
                        usage.Contract_Volume__c = dailyVol;
                    }

                    // dont know if this will work
                    if (slush != 0){usages[usages.size() - 1].Contract_Volume__c = usages[usages.size() - 1].Contract_Volume__c + slush;}

                    usageToUpdate.addAll(usages);
                }


            }

            update usageToUpdate;
        }
        */
    }

    public static void ApplyTriggerVolumeToPositionRemainingVolume(list<Position__c> trigs, boolean isDeletion){
        set<Id> floatIdSet = new set<Id>();

        for (Position__c t:trigs){
            floatIdSet.add(t.Floating_Component_Contract_Detail__c);
        }

        list<Position__c> floaters = new list<Position__c>();
        floaters = [select id, name, Remaining_Unapplied_Volume__c from Position__c where id in:floatIdSet];

        system.debug('isDeletion:'); system.debug(isDeletion); system.debug('floaters:'); system.debug(floaters);

        for (Position__c f:floaters){
            for (Position__c t:trigs){
                if (t.Floating_Component_Contract_Detail__c == f.id){
                    if (isDeletion){
                        // increase remaining volume since trigger is being deleted
                        f.Remaining_Unapplied_Volume__c = f.Remaining_Unapplied_Volume__c + t.Volume__c;
                    } else {
                        // decrease remaining volume since trigger is being inserted
                        f.Remaining_Unapplied_Volume__c = f.Remaining_Unapplied_Volume__c - t.Volume__c;
                    }                    
                }
            }
        }

        update floaters;
    }

    
    

}