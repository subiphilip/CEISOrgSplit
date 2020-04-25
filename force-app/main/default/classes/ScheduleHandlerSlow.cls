public class ScheduleHandlerSlow implements ScheduledDispatcherSlow.IScheduleDispatched {
	
	public void execute(SchedulableContext sc)
    {
        system.abortJob(sc.getTriggerID());	// Always abort the job on completion
        RepeatingBatchSlow.StartTheBatch();
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
		

    	if(ScheduledInContext) return;

		ScheduledInContext = true;
    	
        List<CronTrigger> jobs = [SELECT Id, CronJobDetail.Name, State, NextFireTime
                                  FROM CronTrigger where CronJobDetail.Name='slow_async'];
    	if(jobs.size()>0 && jobs[0].state!='COMPLETED' && 
           jobs[0].state!='ERROR' && jobs[0].state!='DELETED') return;	// Already running

        Set<String> activejobstates = new Set<String>{'Queued','Processing','Preparing'};
		List<AsyncApexJob> apexjobs = [Select ID, ApexClass.Name from AsyncApexJob 
                                           where ApexClass.Name = 'RepeatingBatchSlow' And Status in :activejobstates];
		if(apexjobs.size()>0) return;  // The batch is running
    	
    	//if (Datetime.Now().addSeconds(60)>jobs[0].NextFireTime) return; //we're about to run it anyway, why bother scheduling another one?

    	if (jobs.size()>0) system.abortJob(jobs[0].id); //it exists, but not soon enough, so we delete it.

		try{
			System.schedule('slow_async', 
	          GetSchedulerExpression(DateTime.Now().addMinutes(5)), 
	          new ScheduledDispatcherSlow());
			}catch (exception e){}
    	
    }
}