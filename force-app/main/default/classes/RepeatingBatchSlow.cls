global class RepeatingBatchSlow implements Database.Batchable<sObject>, Database.AllowsCallouts {
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('Select ID, Params__c, type__c, Error_Message__c, Error_Stack_Trace_String__c, Error_Line_Number__c, Process_Date__c, Retry_Count__c, Queueable__c from AsyncRequest__c where slow__c=true and queueable__c=false and (Process_Date__c = null or Process_Date__c <= ' + string.valueOf(date.today())+')');
    }
        
    global void execute(Database.BatchableContext BC, List<AsyncRequest__c> scope){
        AsyncRequestProcessor.processAsyncRequest(scope);
    }
    
    global void finish(Database.BatchableContext BC){
        //what creator of an autonomous AI doesn't at some point wish they'd included a kill switch?
        if (OrgWideSettings__c.GetOrgDefaults().Keep_Async_Object_Batch_Running__c){
        	ScheduleHandlerSlow.StartScheduler(0);
        }
    }
    
    public static void StartTheBatch()
    {
        RepeatingBatchSlow rb = new RepeatingBatchSlow();
        Database.executeBatch(rb, 1);
    }
}