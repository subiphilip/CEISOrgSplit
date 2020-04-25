public with sharing class ContractMarginAndRenewal {
//*****************************************************************************
//*** CONTRACT MARGIN AND RENEWAL BATCH METHODS *******************************
//*****************************************************************************
	public class PremiseMargins {
        public Premises__c prem{get;set;}
        public list<Premise_Margin__c> margins{get;set;}

        public PremiseMargins(Premises__c p, list<Premise_Margin__c> ms){
            prem=p;
            margins=ms;
        }
    }

    public static void setContractMarginError(Contract_Margin__c cm, string errMsg){
        if (cm.Status__c != 'Processed'){
            cm.Status__c = 'Has Errors';
        }
        cm.Error_Message__c = errMsg;
        update cm;
    }
    //*****************************************************************************
    //*** CONTRACT RENEWAL BATCH METHODS ******************************************
    //*****************************************************************************
    public static void RolloverBatchDetailContract(id detailId){
        list<Contract_Margin__c> conMargins = new list<Contract_Margin__c>();

        Contract_Renewal_Batch_Detail__c detail = [select id, name, CESContract__c, Contract_Margin__c, Contract_Renewal_Batch__c, Error_Message__c, Is_Auto_Renewal__c, Process__C, 
                                                    Contract_Ending_Date_To_Process__c, Renewal_Term__c, Status__c, Margin_Record_Created__c, Contract_Is_Extended__c 
                                                    from Contract_Renewal_Batch_Detail__c where id =: detailId];

        CESContract__c cesc = [select id, name, Account__c, Facility_List__c, Start_Date_New__c, End_Date__c, Current_End_Date__c, CES_Office__r.Customer_Number__c, Safari_Key__c, Safari_Sync_Status__c, 
                                    Contact_For_Confirmations__c, Contact_for_Invoices__c, Delivery_Obligation__c, Term_New__c, Record_Type_Name__c, Sales_Adder__c, Index_Adder__c,
                                    Utility_Rate_Name__c, Market_Rate_Index_Name__c, Index_Rate_Name__c, Product_Subtype_Lookup__r.Contract_Volume_Required__c, Over_Index_Name__c,
                                    Over_Adder__c, Margin_on_Over__c, Under_Index_Name__c, Under_Adder__c, Margin_on_Under__c, Consultant__c, Consultant_Unit_Margin__c, UDF_CESUM__c, UDF_GUM__c, 
                                    Term_Renewal_Months__c
                                from CESContract__c where id =: detail.CESContract__c];

        boolean manageMargin = CESUtilities.getManageMarginSetting();

        //try rolling contract positions first if contract has not already been rolled successfully
        integer positionCount = 1;
        if (detail.Contract_Is_Extended__c == false){
            positionCount = RollContractPositions(cesc.id, detail.Contract_Ending_Date_To_Process__c.addDays(1), detail.Renewal_Term__c.intValue(), cesc.Product_Subtype_Lookup__r.Contract_Volume_Required__c);
            if (positionCount == 0){
                if (manageMargin){
                    detail.Status__c = 'Has Errors';
                    detail.Error_Message__c = 'Contract Pricing does not exist.  Pricing not extended and margins not created.  Please review the contract.';
                } else {
                    if (cesc.Term_Renewal_Months__c != null){
                        cesc.Term_Renewal_Months__c = cesc.Term_Renewal_Months__c + detail.Renewal_Term__c;
                    }else {
                        cesc.Term_Renewal_Months__c = detail.Renewal_Term__c;
                    }
                    update cesc;
                    detail.Contract_Is_Extended__c = true;
                    detail.Status__c = 'Processed';
                }
            } else if (positionCount == -1){
                detail.Status__c = 'Has Errors';
                detail.Error_Message__c = 'Contract Pricing is missing historical periods.  Pricing not extended and margins not created.  Please review the contract.';
            } else if (positionCount == -2) {
                detail.Status__c = 'Has Errors';
                detail.Error_Message__c = 'Contract Pricing could not be created for the renewal term.  Pricing not extended and margins not created.  Please review the contract.';
            } else if (positionCount == -3) {
                detail.Status__c = 'Has Errors';
                detail.Error_Message__c = 'Contract Pricing extends beyond the start of the Renewal Term.  Pricing not extended and margins not created.  Please review the contract.';
            } else if (positionCount > 0){
                if (cesc.Term_Renewal_Months__c != null){
                    cesc.Term_Renewal_Months__c = cesc.Term_Renewal_Months__c + detail.Renewal_Term__c;
                }else {
                    cesc.Term_Renewal_Months__c = detail.Renewal_Term__c;
                }
                update cesc;
                if (manageMargin){
                    integer cpCount = RollContractPremises(cesc.id, detail.Contract_Ending_Date_To_Process__c, detail.Contract_Ending_Date_To_Process__c.addDays(1).addMonths(detail.Renewal_Term__c.intValue()).addDays(-1));
                } else {
                    detail.Status__c = 'Processed';
                }
                detail.Contract_Is_Extended__c = true;
            }
        }
        if (manageMargin){
            if (positionCount > 0){
                if (detail.Margin_Record_Created__c == false){
                    conMargins = GenerateContractMarginTerms(cesc, detail.Contract_Ending_Date_To_Process__c.addDays(1), 
                                                                detail.Contract_Ending_Date_To_Process__c.addDays(1).addMonths(detail.Renewal_Term__c.intValue()).addDays(-1), null, detail.id);
                } else {
                    conMargins = [select id, name, CESContract__c, Consultant__c, Contract_Renewal_Batch_Detail__c, End_Date__c, Error_Message__c, 
                                    Margin__c, Margin_Type__c, Start_Date__c, Status__c, Term__c, Volume__c, CESContract__r.Product_Subtype_Lookup__r.Contract_Volume_Required__c
                                  from Contract_Margin__c where Contract_Renewal_Batch_Detail__c =: detail.id];
                }

                if (conMargins.size() > 0){
                    detail.Contract_Margin__c = conMargins[0].id;
                    detail.Margin_Record_Created__c = true;

                    //PUT MARGIN PROCESS HERE
                    integer marginProcessCount = 0;
                    for (Contract_Margin__c cm:conMargins){
                        marginProcessCOunt += ProcessPendingContractMargin(cm);
                    }
                    if (marginProcessCOunt == 0){
                        detail.Status__c = 'Has Errors';
                        detail.Error_Message__c = 'Margin Processing encountered errors.  Review Contract Margins.';
                    } else {                    
                        detail.Status__c = 'Processed';
                        detail.Error_Message__c = conMargins.size() + ' contract margins created, ' + marginProcessCOunt + ' premise margins processed.';
                    }
                }
                else{
                    detail.Contract_Margin__c = null;
                    detail.Margin_Record_Created__c = false;
                    detail.Status__c = 'Has Errors';
                    detail.Error_Message__c = 'Margin processing encountered errors.  Margin record was not created.';
                }
            }
        }
        update detail;
        //get current status of batch
        CheckContractRenewalBatchStatus(detail.Contract_Renewal_Batch__c);
    }

    public static integer RollContractPremises(id cescid, date currEndDate, date endDate){
        list<Contract_Premise__c> cps = new list<Contract_Premise__c>();

        cps = [select id, name, Premise__c, CESContract__c, Start_Date__c, End_Date__c from Contract_Premise__c where CESContract__c =:cescId and End_Date__c =:currEndDate];

        if (cps.size()>0){
            for (Contract_Premise__c cp:cps){
                cp.End_Date__c = endDate;
            }
            update cps;
        }

        return cps.size();
    }

    public static integer RollContractPositions(id cescId, date startdate, integer term, boolean volumeRequired){
        list<Position__c> conPositions = new list<Position__c>();
        map<date, Position__c> posMap = new map<date, Position__c>();
        list<Position__c> posToAdd = new list<Position__c>();

        date enddate = startdate.addMonths(term).addDays(-1);
        //get existing positions prior to new term start date
        conPositions = [select id, name, Active_Contract_Pricing__c, Adder__c, AdderWACOG__c, Assignment_From_Position__c, Balancing__c, BalancingWACOG__c, Basis_Option_Financial__c, Basis_Option__c, 
                                Basis_F_WACOG__c, Basis_Lock__c, Basis_P_WACOG__c, CES_Contract__c, CES_Margin__c, Closed__c, Consultant_Margin__c, Contract_CES_Unit_Margin__c, Contract_Consultant_Unit_Margin__c, 
                                Contract_Gross_Unit_Margin__c, Contract_Total_Gross_Unit_Margin__c, Contract_Month__c, Contract_Over_Adder__c, Contract_Over_Index__c, Contract_Over_Margin__c, Contract_Pricing_Index__c,
                                Contract_Under_Adder__c, Contract_Under_Index__c, Contract_Under_Margin__c, Customer_Price__c, Customer_PriceWACOG__c, Deal_Ticket__c, Do_Not_Sync_Update__c, DT_Basis__c, DT_Basis_Physical__c,
                                DT_Estimated_Margin__c, DT_NYMEX__c, Facility_List__c, Fuel_Cost__c, Fuel_Cost_WACOG__c, Fuel_Only_NYMEX_Memory__c, Hedged_Percent__c, Hedged_Volume__c, Historical_Volume__c, Notes__c,
                                NYMEX_Lock__c, NYMEX_WACOG__c, Order__c, Other_Charges__c, PL_Commodity__c, PL_Commodity_WACOG__c, PL_Demand__c, PL_Demand_WACOG__c, Position_AutoNumber__c, Premise__c, Premise_Margin__c, 
                                Swing_Cost__c, Swing_Cost_WACOG__c, Temp_BL__c, Temp_NL__c, Volume__c, Weatherized_Volume__c 
                                from Position__c
                                where CES_Contract__c =: cescId 
                                order by Contract_Month__c desc]; //and Contract_Month__c <: startdate
        if (conPositions.size() == 0){
            return 0;
        }
        for (Position__c cp:conPositions){//cycle to see if periods are beyond the start date of this renewal
            if (cp.Contract_Month__c >= startdate){
                return -3;//positions exist beyond the start of the renewal
            }
        }

        for (Position__c p: conPositions){
            posMap.put(p.Contract_Month__c, p);
        }

        for (integer i=0; i < term; i++){
            date mth = StartDate.addMonths(i);
            string zero='';
            if (mth.Month() < 10){ zero = '0';}
            Position__c pos;
            if (volumeRequired){//volume is required for this auto renewal, so look for currrent year, then previous year's month, then 2 year's ago month
                try{ pos = posMap.get(mth); } catch (exception e) { pos = null; }
                if (pos == null){
                    try { pos = posMap.get(mth.addYears(-1)); } catch (exception e) { pos = null; }
                    if (pos == null){
                        try { pos = posMap.get(mth.addYears(-2)); } catch (exception e) { pos = null; }
                        if (pos == null){ return -1; }//cannot find volume to roll for required volume contract
                    }
                }
            } else {
                try{ pos = conPositions[0]; } catch (exception e) { pos = null; } //get most recent position to copy
                if (pos == null){ return -1; }

                Position__c newPos = pos.clone(false,false,false,false);
                newPos.name = newPos.name.substring(0, newPos.name.indexOf(':') + 2) + zero + mth.Month() + '-' + mth.Year();
                newPos.Contract_Month__c = mth;

                posToAdd.add(newPos);
            }
        }

        if (posToAdd.size() == term){//position count matches term
            insert posToAdd;
            return posToAdd.size();
        } else if (posToAdd.size() == 0){ return 0;
        } else { return -2; }//position count does not match term and is not zero

    }

    public static void CheckContractRenewalBatchStatus(id batchId){
        //get current status of batch
        Contract_Renewal_Batch__c batch = [select id, name, Status__c, Status_Message__c, Pending_Contract_Count__c, Error_Contract_Count__c, Remaining_Margins_to_Create__c
                                            from Contract_Renewal_Batch__c where id =: batchId];
        if (batch.Pending_Contract_Count__c == 0){//this was the last run of the batch so update the status accordingly
            if (batch.Error_Contract_Count__c > 0){//there are some detail errors
                batch.Status__c = 'Margin Build Completed with Errors';
                batch.Status_Message__c = null;
            }else {
                batch.Status__c = 'Margin Build Completed Successfully';
                batch.Status_Message__c = null;
            }
            update batch;
        }
    }

    //*****************************************************************************
    //*** CONTRACT MARGIN METHODS *************************************************
    //*****************************************************************************

    //*** Create margin terms for contract ***
    public static list<Contract_Margin__c> GenerateContractMarginTerms(CESContract__c cesc, Date startdate, Date enddate, list<Premises__c> prems, id batchDetailID){
        list<Premise_List__c> pLists = new list<Premise_List__c>();
        set<Id> premIdSet = new set<Id>();
        list<Premises__c> premsToPass = new list<Premises__c>();
        list<Contract_Margin__c> existConMargins = new list<Contract_Margin__c>();
        list<Premise_Margin__c> existPremMargins = new list<Premise_Margin__c>();
        AggregateResult[] agMargins;
        map<date, list<date>> marginDateMap = new map<date, list<date>>();
        list<Contract_Margin__c> conMargins = new list<Contract_Margin__c>();
        set<Id> conMarginSet = new set<Id>();
        list<PremiseMargins> pMarginObjects = new list<PremiseMargins>();
        
        //get premises
        if (prems == null){//premises were not passed so build them with the facility list
            premsToPass = GetContractMarginPremises(cesc.Facility_List__c);

            if (premsToPass.size() == 0){//if not premises, then exit
                return conMargins;
            }
        } else {//premises were passed so use them
            premsToPass = prems;
        }

        //make premise set
        for (Premises__c p:premsToPass){
            premIdSet.add(p.id);
        }

        //get existing premise margins for this contract
        pMarginObjects = GetExistingPremiseMarginRecords(cesc.id, premIdSet, premsToPass);

        map<string, set<Id>> conMarginPremIgnoreMap = new map<string, set<Id>>();
        //add pending contract margin records in increments of 12 months
        conMargins = ConstructContractMarginTerms(cesc, startdate, enddate, pMarginObjects, conMarginPremIgnoreMap, batchDetailID, premsToPass.size());

        if (conMargins.size() > 0){
            insert conMargins;

            list<Premise_Margin__c> pMarginsToInsert = new list<Premise_Margin__c>();
            
            pMarginsToInsert = ConstructPremiseMarginRecordsWithoutIgnores(conMargins, conMarginPremIgnoreMap, premsToPass);
            if (pMarginsToInsert.size() > 0){ insert pMarginsToInsert; }
        }

        return conMargins;
    }

    public static list<Premises__c> GetContractMarginPremises(id flId){
        list<Premise_List__c> pLists = new list<Premise_List__c>();
        set<Id> premIdSet = new set<Id>();
        list<Premises__c> prems = new list<Premises__c>();

        pLists = [select id, name, Premise__c from Premise_List__c where Facility_List__c =: flId];
        if (pLists.size() > 0){
            for (Premise_List__c pl:pLists){
                premIdSet.add(pl.Premise__c);
            }
            prems = [select id, name from Premises__c where id in: premIdSet];
        }

        return prems;
    }

    public static list<PremiseMargins> GetExistingPremiseMarginRecords(id cescId, set<Id> premIdSet, list<Premises__c> premsToPass){
        list<Premise_Margin__c> existPremMargins = new list<Premise_Margin__c>();
        list<PremiseMargins> pMarginObjects = new list<PremiseMargins>();

        existPremMargins = [select id, name, Premise__c, Contract_Margin__c, Contract_Margin__r.Start_Date__c, Contract_Margin__r.End_Date__c 
                            from Premise_Margin__c where Contract_Margin__r.CESContract__c =: cescId and premise__c in: premIdSet
                            order by Premise__c, Contract_Margin__r.Start_Date__c, Contract_Margin__r.End_Date__c];
        if (existPremMargins.size() > 0){
            //cycle through premises and create PremiseMargins object with margin lists
            for (Premises__c prem:premsToPass){
                list<Premise_Margin__c> pMargins = new list<Premise_Margin__c>();
                for (Premise_Margin__c pm:existPremMargins){
                    if (prem.id == pm.Premise__c){
                        pMargins.add(pm);
                    }
                }
                system.debug('premise: ' + prem.name + ' has ' + pMargins.size() + ' margin records.');
                pMarginObjects.add(new PremiseMargins(prem, pMargins));
            }
        }

        return pMarginObjects;
    }

    public static list<Contract_Margin__c> ConstructContractMarginTerms(CESContract__c cesc, date startdate, date enddate, list<PremiseMargins> pMarginObjects, map<string, set<Id>> conMarginPremIgnoreMap, id batchDetailID, integer premCount){
        //get number of months
        integer totalTerm = startdate.monthsBetween(enddate) + 1;

        list<Contract_Margin__c> conMargins = new list<Contract_Margin__c>();
        if (totalTerm > 12){
            decimal termDivBy12 = totalTerm / 12;
            integer nbrOf12MthTerms = termDivBy12.intValue();
            integer remainingMths = totalTerm - (nbrOf12MthTerms * 12);

            for (integer i = 1, j = 0; i <= nbrOf12MthTerms; i++){
                //system.debug('round ' + i + ': start month = ' +
                //             startdate.addMonths(j) + ', end month = ' + startdate.addMonths(i * 12).addDays(-1));
                set<Id> premsToIgnore = FindMatchingPremiseMarginTerms(pMarginObjects, startdate.addMonths(j), startdate.addMonths(i * 12).addDays(-1));
                if (premsToIgnore == null || premsToIgnore.size() < premCount){//only create margin record if all prems are not ignored
                    system.debug('round ' + i + ': prems to ignore: ' + premsToIgnore.size());
                //if (FindMatchingStartEndDates(marginDateMap, startdate.addMonths(j), startdate.addMonths(i * 12).addDays(-1))==false){
                    Contract_Margin__c cmNew = addContractMarginRecord(cesc, startdate.addMonths(j), startdate.addMonths(i * 12).addDays(-1), 12, batchDetailID);
                    conMarginPremIgnoreMap.put(string.valueOf(cmNew.Start_Date__c.Month()) + '/' + 
                                                string.valueOf(cmNew.Start_Date__c.Day()) + '/' + string.valueOf(cmNew.Start_Date__c.Year()), premsToIgnore);
                    conMargins.add(cmNew);
                }

                j = j + 12;
            }

            if (remainingMths > 0){
                set<Id> premsToIgnore = FindMatchingPremiseMarginTerms(pMarginObjects, startdate.addMonths(nbrOf12MthTerms * 12), enddate);
                if (premsToIgnore == null || premsToIgnore.size() < premCount){//only create margin record if all prems are not ignored
                    system.debug('remaining mths: prems to ignore: ' + premsToIgnore.size());
                //if (FindMatchingStartEndDates(marginDateMap, startdate.addMonths(nbrOf12MthTerms * 12), enddate)==false){
                    Contract_Margin__c cmNew = addContractMarginRecord(cesc, startdate.addMonths(nbrOf12MthTerms * 12), enddate, remainingMths, batchDetailID);
                    conMarginPremIgnoreMap.put(string.valueOf(cmNew.Start_Date__c.Month()) + '/' + 
                                                string.valueOf(cmNew.Start_Date__c.Day()) + '/' + string.valueOf(cmNew.Start_Date__c.Year()), premsToIgnore);
                    conMargins.add(cmNew);
                }
            }
        } else{
            set<Id> premsToIgnore = FindMatchingPremiseMarginTerms(pMarginObjects, startdate, enddate);
            if (premsToIgnore == null || premsToIgnore.size() < premCount){//only create margin record if all prems are not ignored
                system.debug('under 13: prems to ignore: ' + premsToIgnore.size());
            //if (FindMatchingStartEndDates(marginDateMap, startdate, enddate)==false){
                Contract_Margin__c cmNew = addContractMarginRecord(cesc, startdate, enddate, totalTerm, batchDetailID);
                conMarginPremIgnoreMap.put(string.valueOf(cmNew.Start_Date__c.Month()) + '/' + 
                                            string.valueOf(cmNew.Start_Date__c.Day()) + '/' + string.valueOf(cmNew.Start_Date__c.Year()), premsToIgnore);
                conMargins.add(cmNew);
            }
        }

        return conMargins;
    }

    public static list<Premise_Margin__c> ConstructPremiseMarginRecordsWithoutIgnores(list<Contract_Margin__c> conMargins, map<string, set<Id>> conMarginPremIgnoreMap, list<Premises__c> premsToPass){
        list<Premise_Margin__c> pMarginsToInsert = new list<Premise_Margin__c>();
            
        for(Contract_Margin__c con:conMargins){
            set<Id> ignoreSet;
            try{
                ignoreSet = conMarginPremIgnoreMap.get(string.valueOf(con.Start_Date__c.Month()) + '/' + 
                                        string.valueOf(con.Start_Date__c.Day()) + '/' + string.valueOf(con.Start_Date__c.Year()));
            }catch (exception e) {}
            if (ignoreSet==null){
                system.debug('ConMargin to PremiseMargin: ignore Set is null');
            }else {system.debug('ConMargin to PremiseMargin: ignore Set count: ' + ignoreSet.size());}
            pMarginsToInsert.addAll(addPremiseMarginRecords(con, premsToPass, ignoreSet));
        }
        return pMarginsToInsert;
    }

    public static set<Id> FindMatchingPremiseMarginTerms(list<PremiseMargins> pmOs, date startdate, date enddate){
        set<Id> removePremSet = new set<Id>();
        if (pmOs.size() > 0){
            for (PremiseMargins pmO:pmOs){
                boolean isFound = false;
                if (pmo.margins.size() > 0){
                    for (Premise_Margin__c pm:pmo.margins){
                        if (pm.Contract_Margin__r.Start_Date__c == startdate && pm.Contract_Margin__r.End_Date__c == enddate){
                            isFound = true;
                        }
                    }
                }
                if (isFound){ removePremSet.add(pmo.prem.id); }
            }
        }

        return removePremSet;
    }

    public static Contract_Margin__c addContractMarginRecord(CESContract__c cesc, date StartDate, date EndDate, integer Term, id batchDetailID){
        string mType='New';

        if (batchDetailID != null){
            mType='Renewal';
        }

        Contract_Margin__c cMargin = new Contract_Margin__c(Account__c=cesc.Account__c, CESContract__c=cesc.Id, Consultant__c=cesc.Consultant__c,
                                                            End_Date__c=EndDate, Start_Date__c=StartDate, Status__c='Pending', Term__c=Term, Margin_Type__c=mType, 
                                                            Contract_Renewal_Batch_Detail__c=batchDetailID);
        return cMargin;
    }    

    public static list<Premise_Margin__c> addPremiseMarginRecords(Contract_Margin__c conMargin, list<Premises__c> prems, set<Id> ignoreSet){
        decimal premiseCountPctg = 1;
        list<Premise_Margin__c> pMargins = new list<Premise_Margin__c>();

        premiseCountPctg = premiseCountPctg / prems.size();

        for (Premises__c p:prems){//add premise margins to list for insert
            boolean process = true;
            if (ignoreSet != null && ignoreSet.size() > 0){
                if (ignoreSet.contains(p.id)){ process=false; }
            }
            if (process){
                pMargins.add(new Premise_Margin__c(Contract_Margin__c=conMargin.id, Premise__c=p.id, Premise_Pctg_of_Contract_Volume__c=premiseCountPctg, Status__c='Pending', Process__c=true, Margin_Type__c='New'));
            }
        }
        return pMargins;
        //insert pMargins;
    }

    //*** process the margin terms and populate volume and margin totals ***
    public static integer ProcessPendingContractMargin(Contract_Margin__c conMargin){
        set<Id> premIdSet = new set<Id>();
        list<Premises__c> prems = new list<Premises__c>();
        set<Premises__c> premSet = new set<Premises__c>();
        map<id, Premises__c> premMap = new map<id, Premises__c>();

        list<Premise_Margin__c> existPremMargins = new list<Premise_Margin__c>();
        set<Premise_Margin__c> existPremMarginSet = new set<Premise_Margin__c>();
        list<Premise_Margin__c> pMargins = new list<Premise_Margin__c>();

        list<Position__c> conPositions = new list<Position__c>();
        set<Id> conPositionSet = new set<Id>();
        list<Position__c> premPositions = new list<Position__c>();
        list<Position__c> premPosToAdd = new list<Position__c>();
        map<date, Position__c> posMap = new map<date, Position__c>();

        map<id, map<integer, Monthly_Usage__c>> premHistUseMap = new map<id, map<integer, Monthly_Usage__c>>();
        map<id, decimal> premTotHistUseMap = new map<id, decimal>();

        decimal contractUsage = 0;
        decimal contractVol;
        date uStartDate;
        date uEndDate;
        string premiseUsageErrorString = '';
        boolean usePositionVolume = false;

        usePositionVolume = conMargin.CESContract__r.Product_Subtype_Lookup__r.Contract_Volume_Required__c;
        if (conMargin.Term__c == 12){//set historical usage begin and end dates
            uStartDate = date.today().toStartOfMonth().addMonths(-1).addYears(-1);
            uEndDate = uStartDate.addYears(1).addDays(-1);
        } else {
            integer mYear;
            if (conMargin.End_Date__c.month() < date.today().toStartOfMonth().addMonths(-1).month()){
                mYear = date.today().year();
            } else {
                mYear = date.today().addYears(-1).year();
            }
            uEndDate = date.newInstance(mYear, conMargin.End_Date__c.month(), 1).addMonths(1).addDays(-1);
            uStartDate = uEndDate.addMonths(-(conMargin.Term__c.intValue() - 1)).toStartOfMonth();
        }
        system.debug('start date: ' + uStartDate + ', end date: ' + uEndDate);

        //get all premise margin records regardless of status so all premises can be used to determine premise volume percentage
        existPremMargins = [select id, name, Contract_Margin__c, End_Date__c, Margin__c, Margin_Type__c, Premise__c, Premise_Pctg_of_Contract_Volume__c, Start_Date__c, Status__c, Volume__c, Process__c 
                            from Premise_Margin__c where Contract_Margin__c =:conMargin.id];
        
        //initialize contract margin status for re-process
        if (conMargin.Status__c != 'Processed'){
            conMargin.Status__c = 'Pending';
            conMargin.Error_Message__c = null;
        }

        if (existPremMargins.size() > 0){
            boolean marginIsPending = false;
            boolean isProcess = false;
            for (Premise_Margin__c pm:existPremMargins){
                if (pm.Status__c != 'Processed'){//check to see if premise margin record has already been processed
                    marginIsPending = true;
                    if (pm.Process__c){
                        isProcess = true;
                    }
                }
                premIdSet.add(pm.Premise__c);
            }
            if (marginIsPending == false){
                setContractMarginError(conMargin, 'All Premise Margin records have previously been successfully processed.');
                return 0;
            }
            if (isProcess == false){
                setContractMarginError(conMargin, 'No Premise Margin records are set to be processed.');
                return 0;
            }
        }else {
            setContractMarginError(conMargin, 'Premises Margin records do not exist for this contract margin record');
            return 0;
        }

        prems = [select id, name from Premises__c where id in: premIdSet];
        for (Premises__c p:prems){
            premSet.add(p);
            premMap.put(p.id, p);
        }

        AggregateResult[] agPositions = [select CES_Contract__c, SUM(Volume__c) Volume, COUNT(id) posCount from Position__c 
                                        where CES_Contract__c =: conMargin.CESContract__c and Contract_Month__c >=: conMargin.Start_Date__c and Contract_Month__c <=: conMargin.End_Date__c and Premise__c = null
                                        group by CES_Contract__c];
        if (agPositions.size() > 0){
            system.debug('position size: ' + agPositions[0].get('posCount'));
            if ((integer)agPositions[0].get('posCount') != conMargin.Term__c){
                setContractMarginError(conMargin, 'Contract has a gap in positions');
                return 0;
            }else{
                conPositions = [select id, name, Active_Contract_Pricing__c, Adder__c, AdderWACOG__c, Assignment_From_Position__c, Balancing__c, BalancingWACOG__c, Basis_Option_Financial__c, Basis_Option__c, 
                                Basis_F_WACOG__c, Basis_Lock__c, Basis_P_WACOG__c, CES_Contract__c, CES_Margin__c, Closed__c, Consultant_Margin__c, Contract_CES_Unit_Margin__c, Contract_Consultant_Unit_Margin__c, 
                                Contract_Gross_Unit_Margin__c, Contract_Total_Gross_Unit_Margin__c, Contract_Month__c, Contract_Over_Adder__c, Contract_Over_Index__c, Contract_Over_Margin__c, Contract_Pricing_Index__c,
                                Contract_Under_Adder__c, Contract_Under_Index__c, Contract_Under_Margin__c, Customer_Price__c, Customer_PriceWACOG__c, Deal_Ticket__c, Do_Not_Sync_Update__c, DT_Basis__c, DT_Basis_Physical__c,
                                DT_Estimated_Margin__c, DT_NYMEX__c, Facility_List__c, Fuel_Cost__c, Fuel_Cost_WACOG__c, Fuel_Only_NYMEX_Memory__c, Hedged_Percent__c, Hedged_Volume__c, Historical_Volume__c, Notes__c,
                                NYMEX_Lock__c, NYMEX_WACOG__c, Order__c, Other_Charges__c, PL_Commodity__c, PL_Commodity_WACOG__c, PL_Demand__c, PL_Demand_WACOG__c, Position_AutoNumber__c, Premise__c, Premise_Margin__c, 
                                Swing_Cost__c, Swing_Cost_WACOG__c, Temp_BL__c, Temp_NL__c, Volume__c, Weatherized_Volume__c, Delete_Triggered_by_Margin_Deletion__c, Originated_From_Margin_Creation__c 
                                from Position__c
                                where CES_Contract__c =: conMargin.CESContract__c and Contract_Month__c >=: conMargin.Start_Date__c and Contract_Month__c <=: conMargin.End_Date__c
                                order by Contract_Month__c];
                
                for (Position__c cp:conPositions){//make contract position set and check for ces margin
                    if (cp.Contract_CES_Unit_Margin__c == null){
                        setContractMarginError(conMargin, 'Contract positions are missing CES Unit Margin.');
                        return 0;
                    }
                    conPositionSet.add(cp.id);
                }

                premPositions = [select id, name, Active_Contract_Pricing__c, Adder__c, AdderWACOG__c, Assignment_From_Position__c, Balancing__c, BalancingWACOG__c, Basis_Option_Financial__c, Basis_Option__c, 
                                Basis_F_WACOG__c, Basis_Lock__c, Basis_P_WACOG__c, Contract_Position__c, CES_Margin__c, Closed__c, Consultant_Margin__c, Contract_CES_Unit_Margin__c, Contract_Consultant_Unit_Margin__c, 
                                Contract_Gross_Unit_Margin__c, Contract_Total_Gross_Unit_Margin__c, Contract_Month__c, Contract_Over_Adder__c, Contract_Over_Index__c, Contract_Over_Margin__c, Contract_Pricing_Index__c,
                                Contract_Under_Adder__c, Contract_Under_Index__c, Contract_Under_Margin__c, Customer_Price__c, Customer_PriceWACOG__c, Deal_Ticket__c, Do_Not_Sync_Update__c, DT_Basis__c, DT_Basis_Physical__c,
                                DT_Estimated_Margin__c, DT_NYMEX__c, Facility_List__c, Fuel_Cost__c, Fuel_Cost_WACOG__c, Fuel_Only_NYMEX_Memory__c, Hedged_Percent__c, Hedged_Volume__c, Historical_Volume__c, Notes__c,
                                NYMEX_Lock__c, NYMEX_WACOG__c, Order__c, Other_Charges__c, PL_Commodity__c, PL_Commodity_WACOG__c, PL_Demand__c, PL_Demand_WACOG__c, Position_AutoNumber__c, Premise__c, Premise_Margin__c, 
                                Swing_Cost__c, Swing_Cost_WACOG__c, Temp_BL__c, Temp_NL__c, Volume__c, Weatherized_Volume__c, Delete_Triggered_by_Margin_Deletion__c, Originated_From_Margin_Creation__c
                                from Position__c
                                where Contract_Position__c in: conPositionSet
                                order by Premise_Margin__c, Premise__c, Contract_Month__c];
                
                if (premPositions.size() > 0){//cycle through positions and delete thenm if the premise margin is not processed
                    list<Position__c> premPosToDelete = new list<Position__c>();
                    for (Premise_Margin__c pm:existPremMargins){
                        if (pm.Status__c != 'Processed'){
                            for (Position__c pp:premPositions){
                                if (pm.id == pp.Premise_Margin__c){
                                    premPosToDelete.add(pp);
                                }
                            }
                        }
                    }
                    if (premPosToDelete.size() > 0){ delete premPosToDelete; }
                }
            }
        }else {
            setContractMarginError(conMargin, 'Contract has no positions');
            return 0;
        }

        AggregateResult[] agUsage = [select premise__c, COUNT(id) usageCount, SUM(Usage__c) termUsage from Monthly_Usage__c 
                                        where premise__c in: premSet and Start_Date__c >=: uStartDate and Start_Date__c <=: uEndDate 
                                        group by premise__c];
        


        if (usePositionVolume){//check to see if the contract should have volumes
            try{contractVol = (decimal)agPositions[0].get('Volume');}catch (exception e){}
            if (contractVol == null){
                premiseUsageErrorString += ' Required contract volumes do not exist. ';
            }
        }

        if (agUsage.size()>0){
            for (AggregateResult agr:agUsage){//create the premise maps with empty usage map
                premTotHistUseMap.put((id)agr.get('premise__c'), (decimal)agr.get('termUsage'));
                premHistUseMap.put((id)agr.get('premise__c'), new map<integer, Monthly_Usage__c>{});
                contractUsage += (Decimal)agr.get('termUsage');
            }
            list<Monthly_Usage__c> usages = [select id, name, Premise__c, Start_Date__c, Usage__c from Monthly_Usage__c
                                             where premise__c in: premSet and Start_Date__c >=: uStartDate and Start_Date__c <=: uEndDate
                                             order by Premise__c, Start_Date__c];
            
            for (Monthly_Usage__c u:usages){//populate each premise with a map of monthly usage records
                try {premHistUseMap.get(u.Premise__c).put(u.Start_Date__c.Month(), u);}
                catch (exception e){}
            }

            for (Premises__c p:prems){
                try{
                    map<integer, Monthly_Usage__c> pm = premHistUseMap.get(p.id);
                    if (pm.size() != conMargin.Term__c){
                        premiseUsageErrorString += p.name + ' has a gap in historical usage. ';
                    }
                } catch (exception e){//premise does not have a usage map
                    premiseUsageErrorString += p.name + ' has no historical usage. ';
                }
            }

            if (premiseUsageErrorString != ''){
                setContractMarginError(conMargin, premiseUsageErrorString);
                return 0;
            }

            integer processedCount = 0;
            for (Premise_Margin__c pm:existPremMargins){//go through each prem margin record
                decimal totalVolume = 0;
                decimal totalMargin = 0;
                
                if (pm.Status__c != 'Processed' && pm.Process__c){//build premise positions if set to process and has not been previously processed
                    processedCount++;
                    if (contractUsage > 0){
                        pm.Premise_Pctg_of_Contract_Volume__c = (decimal)premTotHistUseMap.get(pm.Premise__c) / contractUsage;} 
                    for (Position__c cp:conPositions){//clone each position, add lookups, and change volume
                        Position__c premPos = cp.clone(false,false,false,false);
                        premPos.name = 'Margin-' + pm.name + premPos.name.substring(premPos.name.indexOf(':'));
                        premPos.Contract_Position__c = cp.id;
                        premPos.CES_Contract__c = null;
                        premPos.Premise__c = pm.Premise__c;
                        premPos.Premise_Margin__c = pm.id;
                        premPos.Originated_From_Margin_Creation__c = true;
                        if (premPos.Volume__c != null){
                            premPos.Volume__c = premPos.Volume__c * pm.Premise_Pctg_of_Contract_Volume__c;}
                        premPos.Weatherized_Volume__c = premHistUseMap.get(pm.Premise__c).get((Integer)premPos.Contract_Month__c.Month()).Usage__c;

                        if (usePositionVolume){
                            totalVolume += premPos.Volume__c;
                            totalMargin += (premPos.Volume__c * premPos.Contract_CES_Unit_Margin__c);
                        } else {
                            totalVolume += premPos.Weatherized_Volume__c;
                            totalMargin += (premPos.Weatherized_Volume__c * premPos.Contract_CES_Unit_Margin__c);
                        }
                        premPosToAdd.add(premPos);
                    }

                    pm.Status__c = 'Processed';
                    pm.Volume__c = totalVolume;
                    pm.Margin__c = totalMargin;
                }
            }
            
            if (premPosToAdd.size() > 0){ insert premPosToAdd; }
            if (processedCount > 0){
                update existPremMargins;

                conMargin.Status__c = 'Processed';
                update conMargin;
                return processedCount;
            }else{
                premiseUsageErrorString += 'No premise margins were available to process. '; 
                setContractMarginError(conMargin, premiseUsageErrorString);
                return 0;
            }
        } else { 
            premiseUsageErrorString += 'No premises have historical usage. '; 
            setContractMarginError(conMargin, premiseUsageErrorString);
            return 0;
        }
    }

    //*** TRIGGERS ***
    //*****************************************************************************
    //*** CONTRACT MARGIN *********************************************************
    //*****************************************************************************
    public static void ContractMarginBeforeDeleteProcess(list<Contract_Margin__c> cms){
        //this process is designed to delete all positions related to the premise margins related to the contract margins
        //this is because a master delete does not kick off the detail records triggers
        set<Id> cmSet = new set<Id>();
        list<Premise_Margin__c> pms = new list<Premise_Margin__c>();

        for (Contract_Margin__c cm:cms){
            cmSet.add(cm.id);//get set of contract margin ids to get all premise margins to delete, which will then delete all related positions in prem margin trigger
        }
        if (cmSet.size()>0){
            pms = [select id, name, Contract_Margin__c from Premise_Margin__c where Contract_Margin__c in: cmSet];
            if (pms.size()>0){delete pms;}//get premise margins and delete
        }
    }

    //*****************************************************************************
    //*** PREMISE MARGIN **********************************************************
    //*****************************************************************************
    public static void PremiseMarginBeforeDeleteProcess(list<Premise_Margin__c> pms){
        Set<Id> pmSet = new Set<Id>();
        list<Position__c> pos = new list<Position__c>();

        for (Premise_Margin__c pm: pms){
            pmSet.add(pm.Id);//get set of margin ids to get all positions related to deleted margins
        }
        if (pmSet.size()>0){
            pos = [select id, name, Premise_Margin__c, Premise__c, Delete_Triggered_by_Margin_Deletion__c from Position__c where Premise_Margin__c in: pmSet and Premise_Margin__c != null];
            if (pos.size()>0){//get positions, mark them as complete margin deletions and then delete
                for (Position__c p:pos){
                    p.Delete_Triggered_by_Margin_Deletion__c = true;
                }
                update pos;
                delete pos;
            }
        }
    }

    public static void ReCalcPremiseMarginAfterChange(id pMarginId, id arId){
        list<AsyncRequest__c> ars = new list<AsyncRequest__c>();
        list<Position__c> pPos = new list<Position__c>();

        //get any other asyncs for this process and id and delete since this async will do the job
        ars = [select id, name, Type__c, Params__c from AsyncRequest__c where Type__c = 'ReCalcPremiseMarginAfterChange' and Params__c =: pMarginId and id !=: arID];
        if (ars.size() > 0){ delete ars;}

        Premise_Margin__c pMargin = [select id, name, Contract_Margin__c, End_Date__c, Margin__c, Margin_Type__c, Premise__c, Premise_Pctg_of_Contract_Volume__c,
                                        Process__c, Start_Date__c, Status__c, Status_Message__c, Volume__c
                                     from Premise_Margin__c where id=:pMarginId];

        pPos = [select id, name, Volume__c, Weatherized_Volume__c, Contract_CES_Unit_Margin__c from Position__c where Premise_Margin__c =: pMargin.id];

        decimal volume = 0;
        decimal margin = 0;
        if (pPos.size() > 0){//there still are premise positions so calc the new amount for the premise margin
            for (Position__c p:pPos){
                if (p.Volume__c != null){//use contract volumes
                    volume += p.Volume__c;
                    margin += (p.Volume__c * p.Contract_CES_Unit_Margin__c);
                } else {//use premise usage
                    volume += p.Weatherized_Volume__c;
                    margin += (p.Weatherized_Volume__c * p.Contract_CES_Unit_Margin__c);
                }
            }
        }

        pMargin.Margin__c = margin;
        pMargin.Volume__c = volume;
        update pMargin;
    }

    //*****************************************************************************
    //*** CONTRACT RENEWAL BATCH DETAIL *******************************************
    //*****************************************************************************
    public static void ContractRenewalBatchDetailBeforeDeleteProcess(list<Contract_Renewal_Batch_Detail__c> details){
        //*** this deletes contract margin records, which will delete any premise margins and premise positions
        set<Id> dSet = new set<Id>();
        list<Contract_Margin__c> ms = new list<Contract_Margin__c>();

        for (Contract_Renewal_Batch_Detail__c d:details){
            dSet.add(d.id);
        }
        if (dSet.size()>0){
            ms = [select id, name, Contract_Renewal_Batch_Detail__c from Contract_Margin__c 
                    where Contract_Renewal_Batch_Detail__c in: dSet and Contract_Renewal_Batch_Detail__c != null];
            if (ms.size()>0){delete ms;}//delete contract margins assigned to these renewal batch detail records
        }
    }
}