public class ScheduleHandler implements ScheduledDispatcher.IScheduleDispatched {
	
	public void execute(SchedulableContext sc)
    {
        system.abortJob(sc.getTriggerID());	// Always abort the job on completion
        RepeatingBatch2.StartTheBatch();
    } 

    public static String GetSchedulerExpression(Datetime dt) {
        return ('' + dt.second() + ' ' + dt.minute() + ' ' + dt.hour() + ' ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year());
    }

	private static Boolean ScheduledInContext = false;

    public static void StartScheduler(Integer AsyncCount)
    {
		if(AsyncCount>0)
		{
			List<AsyncRequest__c> newrequests = new List<AsyncRequest__c>();
	       	for(Integer x = 0; x< AsyncCount; x++) {
				newrequests.add(new AsyncRequest__c(Params__c = 'some parameters'));
	       	}
	       	insert newrequests;
		}
		/*else

		{
			List<AsyncRequest__c> requests = [Select ID, Params__c, Type__c from AsyncRequest__c Limit 1];
			if(requests.size()==0) return;
		}*/


    	if(ScheduledInContext) return;

		ScheduledInContext = true;

		OrgWideSettings__c ows = OrgWideSettings__c.getInstance();
		string jobname = ows.FastJobName__c;

        List<CronTrigger> jobs = [SELECT Id, CronJobDetail.Name, State, NextFireTime
                                  FROM CronTrigger where CronJobDetail.Name=:jobname];
    	if(jobs.size()>0 && jobs[0].state!='COMPLETED' && 
           jobs[0].state!='ERROR' && jobs[0].state!='DELETED') return;	// Already running

        Set<String> activejobstates = new Set<String>{'Queued','Processing','Preparing'};
		List<AsyncApexJob> apexjobs = [Select ID, ApexClass.Name from AsyncApexJob 
                                           where ApexClass.Name = 'RepeatingBatch2' And Status in :activejobstates];
		if(apexjobs.size()>0) return;  // The batch is running
    	
    	//if (Datetime.Now().addSeconds(60)>jobs[0].NextFireTime) return; //we're about to run it anyway, why bother scheduling another one?

    	if (jobs.size()>0) system.abortJob(jobs[0].id); //it exists, but not soon enough, so we delete it.

    	//if there aren't any more non-slow ASRs, grab a few from slow and make them non-slow
    	/*try{
    		if ([select count() from AsyncRequest__c where slow__c=false and (Process_Date__c = null or Process_Date__c <=: system.today())] ==0 && [select count() from AsyncRequest__c where slow__c=true and (Process_Date__c = null or Process_Date__c <=: system.today())]>500)
    		{
	            list<AsyncRequest__c> Slows = [select id, slow__c from AsyncRequest__c where slow__c=true and (Process_Date__c = null or Process_Date__c <=: system.today()) and Retry_Count__c = null order by createddate desc limit 3];
	            for (AsyncRequest__c slow:Slows){
	                slow.Slow__c=false;
	            }
	            update Slows;
	        }
    	} catch (exception e){}
        */

		try{
			System.schedule(jobname, 
	          GetSchedulerExpression(DateTime.Now().addSeconds(4)), 
	          new ScheduledDispatcher());
			}catch (exception e){}
    	
    }

}