public with sharing class AsyncRequestProcessor {

    public AsyncRequestProcessor() {
        
    }

    public static void asyncFutureWrapper(list<AsyncRequest__c> ASRs){      
        for (AsyncRequest__c asr:ASRs){
            asyncFutureSingle(asr.id);
        }
    }

    @Future(callout=true)
    public static void asyncFutureSingle(id asyncid){
        list<AsyncRequest__c> ASRs = [Select ID, Params__c, type__c, Error_Message__c, Error_Stack_Trace_String__c, Error_Line_Number__c, Process_Date__c, Retry_Count__c, Slow__c, Queueable__c from AsyncRequest__c where id=:asyncid]; 
        processAsyncRequest(ASRs);  
    }

    public static void runAsyncQueue(){
        OrgWideSettings__c ows = OrgWideSettings__c.getInstance();
        boolean isActive = ows.Queueable_Active__c;
        if (isActive){
            ID jobID = System.enqueueJob(new AsyncQueue());

            system.debug(jobID);
        }
    }

    public static void processAsyncQueueRequestList(list<AsyncRequest__c> ars, boolean kickoff){
        for (AsyncRequest__c a:ars){
            list<AsyncRequest__c> listOfOne = new list<AsyncRequest__c>();
            listOfOne.add(a);
            processAsyncRequest(listOfOne);
        }
        try {
            // delete any kickoff requests since they are not being queried or used
            list<AsyncRequest__c> ks = new list<AsyncRequest__c>();
            ks = [select id, name, Type__c from AsyncRequest__c where slow__c=false and Queueable__c=true and Type__c='QueueKickoff'];
            delete ks;

            if (kickoff){
                // kick off the queue again since you cannot have callouts and chained queues
                AsyncRequest__c req = new AsyncRequest__c(Type__c='QueueKickoff',Params__c='Will Not Process',Queueable__c=true);
                insert req;
            }
        } catch (exception e){}
        
    }


    public static void processAsyncRequest(list<AsyncRequest__c> Alist){
        //triggers that I want to move to async: 
        //bulkified, but there should only be one ever!
        for (AsyncRequest__c a:Alist){
            try{
                //each potential type should have a "how to handle" here.  Keep this clean and put your SOQL and logic somewhere else so it can be used by other processes, too!    
                
                if (a.type__c =='KeepAlive' || a.type__c =='KickOffNymex'  || a.type__c =='KickOffNymex2' || a.type__c == 'QueueKickoff'){
                    //just in to run a trigger...no action, just delete it
                }

            //TrueCost
                else if (a.type__c =='RatingsUpdate'){ //ASR created in the updateStarAverage trigger
                    TrueCostUtilities.updateRatingsForREP(a.Params__c);
                    TrueCostCalc.UpdateREPSatRanking();
                }
                else if (a.type__c == 'TrueCostLeadConversion'){
                    TrueCostUtilities.ConvertLeadAsync(a.Params__c); //ASR created in the newAccount trigger
                }
                else if (a.type__c == 'ExpireOldOrders'){                   
                    TrueCostUtilities.expireOlderOrders(a.Params__c); //it requires a premise id;
                }
                else if (a.type__c == 'SetTrueCostOrderRecordType'){                    
                    TrueCostUtilities.SetTrueCostOrderRecordType(a.Params__c); //it requires a premise id;
                }
                else if (a.type__c == 'PIIfromOrder'){
                    TrueCostUtilities.UpdateAccountPIIfromOrder(a.Params__c); 
                }
                else if (a.type__c == 'RemoveExpirationDatesFromPreviousOrders'){                   
                    TrueCostUtilities.RemoveExpirationDatesFromPreviousOrders(a.Params__c);
                }
                else if (a.Type__c == 'TrueCostLoginTracking'){
                    TrueCostUtilities.incrementLoginCounterTimestampNow(a.Params__c); //the param is the email on the account
                }
                else if (a.Type__c == 'SetREPofRecord'){
                    TrueCostUtilities.SetREPofRecordAsync(a.Params__c); //the param is Order id
                }
                
                else if (a.Type__c=='UHITDaily'){
                    UHITAsync.MakeUHITCallout(a.Params__c);
                }
                
                else if (a.Type__c=='MakeUHITCleanupCallout'){
                    UHITAsync.MakeUHITCleanupCallout(a.Params__c);
                }       

                else if (a.Type__c=='UHITRequestError'){
                    UHITAsync.ProcessErrorASR(a.Params__c);
                }

                else if (a.Type__c=='DailyToMonthly'){
                    MeterDataUtilities.CompactMeterDataMonthly(a.Params__c);
                }
                else if (a.Type__c=='RateExceptionChange'){
                    TimeOfUseEngine.RateExceptionChangeASR(a.Params__c);
                }
                else if (a.Type__c=='BuildTOULoadProfile'){
                    TimeOfUseEngine.BuildAnnualLoadProfile(a.Params__c);
                }
                else if (a.Type__c=='ManualUsageUpload'){
                    UsageRequestManager.processManualUHM(a.Params__c);
                }
            //TrueCost REP APIs
                else if (a.Type__c=='CheckDirect'){
                    REPAPIChecks.CheckDirectOrder(a.Params__c);
                }
                else if (a.Type__c=='PlaceDirectOrder'){
                    NewLeafAPImrg.neworder(a.Params__c);
                }               
                else if (a.Type__c=='CheckCirro'){
                    REPAPIChecks.CheckCirro();
                }
                else if (a.Type__c=='PlaceTriEagleOrder'){
                    TriEagleAPI.TriEagleAsyncCall(a.Params__c);
                }
                else if (a.Type__c=='TriEagleOrderCheck'){
                    TriEagleAPI.TriEagleOrderCheck(a.Params__c);
                }
                //
            //Choice
                else if (a.type__c == 'CreateChoicePositions'){                 
                    order__c o = [select id from order__c where id =: a.Params__c limit 1];
                    GasChoiceUtilities.CreatePositions(o);
                }
                else if (a.type__c == 'lowCodeInventory'){      
                    ChatterUtils.mentionOnRecord(a.Params__c, '00530000008PQie' , 'This confirmation code was recently priced, and its plan is running low on codes');
                }
                else if (a.type__c == 'UsedUnactivatedCode'){                   
                    ChatterUtils.mentionOnRecord(a.Params__c, '00530000008PQie' , 'This unactivated code was used because no active, non-priced were available.  Please activate this code, and add more activate codes with pricing.');
                }
                else if (a.type__c == 'StaticChoiceCosts'){
                    GasChoiceCalc2.JustGetCosts(a.Params__c);                   
                }

                else if (a.type__c =='Choice Position Liquidation Future'){
                    GasChoiceUtilities.LiquidateFutureChoicePositions(a.Params__c);
                }
                else if (a.type__c =='LockChoiceRate'){
                    GasChoiceDynamicRatePicker.LockChoiceRate(a.Params__c);
                    RemoveDupes(a);
                }

                //two methods for testing/demo only.        
                else if (a.type__c == 'ChatterPostTest'){                   
                    FeedItem f = new FeedItem(body='the batch posted this2.', parentid=a.Params__c); insert f;
                    
                }
                else if (a.type__c == 'ChatterPostTestParamIsMessage'){
                    FeedItem f = new FeedItem(body=a.Params__c, parentid='00530000004bSMC'); insert f;
                }

            //C&I
            //*** Account
                else if (a.type__c == 'RefreshAccountActiveStateField'){
                    //AccountUtils.RefreshAccountActiveStateField(a.Params__c);
                }
                else if (a.type__c == 'RefreshPartnerAccountActiveStateField'){
                    //AccountUtils.RefreshPartnerAccountActiveStateField(a.Params__c);
                }
            //*** Premise
                else if (a.type__c == 'ApplyClosestWeatherStation'){
                    PremiseUtils.ApplyClosestWeatherStation(a.Params__c);
                }
            //*** Premise Status
                else if (a.type__c == 'ProcessFuturePremiseStatusNowCurrent'){
                    //CESUtilities.ProcessFuturePremiseStatusNowCurrentAsync(a.Params__c);
                }
                else if (a.Type__c == 'ProcessUpcomingPremiseStatus'){
                    //CESUtilities.ProcessUpcomingPremiseStatusAsync(a.Params__c);
                }
                else if (a.Type__c == 'ProcessUpcomingPremiseStatusDelete'){
                    //CESUtilities.ProcessUpcomingPremiseStatusDeleteAsync(a.Params__c);
                }
            //*** Contract
                else if (a.Type__c == 'ProcessTCActivation'){
                    CESUtilities.ProcessTCActivationAsync(a.Params__c);
                }
                else if (a.Type__c == 'ProcessRottingContractRequestReminder'){
                    CESUtilities.RottingContractRequestBulkAsync();
                }
                else if (a.Type__c == 'CloseOpportunityFromContract'){
                    OpportunityUtilities.CloseOpportunityFromContract(a.Params__c);
                }
            //*** Premise List
                else if (a.Type__c == 'ProcessPremiseListActivation'){
                    //CESUtilities.ProcessPremiseListActivationAsync(a.Params__c);
                }
                else if (a.Type__c == 'ProcessFuturePremiseFacilityListNowCurrent'){
                    //CESUtilities.ProcessFuturePremiseFacilityListNowCurrentAsync(a.Params__c);
                }
                else if (a.Type__c == 'UpdateFuturePremListProcessDate'){
                    //CESUtilities.UpdateFuturePremListProcessDateAsync(a.Params__c);
                }
                else if (a.Type__c == 'DeleteFuturePremListProcess'){
                    //CESUtilities.DeleteFuturePremListProcessAsync(a.Params__c);
                }
                else if (a.Type__c == 'CheckCurrentPremiseListAssignment'){
                    //CESUtilities.CheckCurrentPremiseListAssignmentAsync(a.Params__c);
                }
                else if (a.Type__c == 'ProcessPremiseListTermination'){
                    //CESUtilities.ProcessPremiseListTermination(a.Params__c, a.Process_Date__c);
                }
            //*** Renewal Batch / Contract Margin
                else if (a.Type__c == 'RolloverBatchDetailContract'){
                    CESUtilities.RolloverBatchDetailContract(a.Params__c);
                }
                else if (a.Type__c == 'ReCalcPremiseMarginAfterChange'){
                    CESUtilities.ReCalcPremiseMarginAfterChange(a.Params__c, a.Id);
                }
            //*** Informatica and Sync Batch
                else if (a.Type__c == 'CheckRecordsToSyncExist'){
                    CESDataSyncUtilities.CheckRecordsToSyncExist(a.Params__c);
                }
                else if (a.Type__c == 'CheckSyncBatchStatusForOffice'){
                    CESDataSyncUtilities.CheckSyncBatchStatusForOffice(a.Params__c);
                }
                else if (a.Type__c == 'ProcessRecordLock'){
                    CESUtilities.ProcessRecordLock(a.Params__c);
                }
                
            //*** Fixed Quote Price Checker
                else if (a.Type__c == 'FPQPriceCheck'){
                    fpqalerts.CheckQuote(a.Params__c);
                }



                else {
                    throw new AsyncTypeException('ASR type not found: ' +a.Type__c); //we don't want to lose them under any scenario (like a type on the type__c)
                }
                delete a; //if everything worked, we don't need the record anymore
            }catch(exception e){
                AsyncRecordCrash(a, e); //error logging, and record is preserved.  We'll keep trying until it succeeds.
            }
        }
        
    }

    public static void AsyncRecordCrash(AsyncRequest__c a, Exception ex)
    {
        a.Error_Message__c = ex.getMessage();
        a.Error_Stack_Trace_String__c =  ex.getStackTraceString();
        a.Error_Line_Number__c = string.valueof(ex.getLineNumber());
        if (a.Retry_Count__c ==null ){
            a.Retry_Count__c =1; 
        } else {
            a.Retry_Count__c = a.Retry_Count__c+1;
            if (a.Retry_Count__c==5){
                a.Slow__c = true;
            }
        }    
        
        update a;
        
        if (a.Retry_Count__c==2){
            id[] ShaneAndBen = new id[]{'00530000004bSMC', '00530000008PQie'};
            try{
                ChatterUtils.chatterTheAdmins(a.Params__c, 'Async Crash Alert! '+ex.getStackTraceString()+ ' : '+ex.getMessage());
            } catch (exception e){
                ChatterUtils.chatterTheAdmins(a.id, 'Async Crash Alert! '+ex.getStackTraceString()+ ' : '+ex.getMessage());         
            }
        }


    }

    //call this if you don't need it to run more than once!
    public static void RemoveDupes(AsyncRequest__c a){
        delete [select id from AsyncRequest__c where type__c =: a.type__c and Params__c=:a.Params__c and id!=:a.id];
    }
    
    //call this if you don't need it to run more than once!
    public static void RemoveDupesMap(list<AsyncRequest__c> asrs){
        //is is the same params and type and slowness and date (or lack thereof);
        set<string> testSet = new set<string>();
        list<AsyncRequest__c> stuffToDel = new list<AsyncRequest__c>();

        for (AsyncRequest__c asr:asrs){
            boolean Added = testSet.add(asr.Params__c+asr.Type__c+asr.Process_Date__c+string.valueof(asr.Slow__c));
            if (stuffToDel.size()==4500) break;
            if (!Added){
                stuffToDel.add(asr);
            }
        }
        delete stuffToDel;
    }

    public static list<AsyncRequest__c> AsyncDedupeSharedQuery(boolean slow){
        return [Select ID, Params__c, type__c, Error_Message__c, Error_Stack_Trace_String__c, Error_Line_Number__c, Process_Date__c, Retry_Count__c, Slow__c from AsyncRequest__c where slow__c=:slow and (Process_Date__c = null or Process_Date__c <=: date.today()) limit 49000];
    }


    public class AsyncTypeException extends Exception {}
}