public class AsyncQueue implements Queueable, Database.AllowsCallouts {
	
	public void execute(QueueableContext context) {
		list<AsyncRequest__c> allArs = new list<AsyncRequest__c>();
		list<AsyncRequest__c> ars = new list<AsyncRequest__c>();
		boolean hasMore = false;

		// get record count to process
		OrgWideSettings__c ows = OrgWideSettings__c.getInstance();
        integer recCount = (Integer)ows.Queueable_Process_Count__c;

		try {
			allArs = [select id, name, Type__c, Params__c, Process_Date__c, CreatedDate, Queueable__c from AsyncRequest__c 
					where slow__c=false and Queueable__c = true and Type__c != 'QueueKickoff' and (Process_Date__c = null or Process_Date__c <=: date.today()) 
					order by CreatedDate];

			if (allArs.size()<=recCount){
				// max is less than or equal to count so send them all through
				ars = allArs;
			} else {
				// only pass the first x through and set hasMore to true
				hasMore = true;
				
				for (Integer x=0; x<recCount; x++){
					ars.add(allArs[x]);
				}
				system.debug('request size: ');
				system.debug(ars.size());
			}
		} catch (exception e){}

		
		if (ars.size() > 0){
			try{
				AsyncRequestProcessor.processAsyncQueueRequestList(ars, hasMore);
				
			} catch (exception e){
				system.debug('encountered a queueable interface error: '+e.getMessage());
			}
			//ID jobID = System.enqueueJob(new AsyncQueue());

			//system.debug(jobID);
		}
	}
}