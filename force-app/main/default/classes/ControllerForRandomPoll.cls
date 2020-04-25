public with sharing class ControllerForRandomPoll {
	public string thescript{get;set;}
	public integer pollcount{get;set;}
	
	public ControllerForRandomPoll(){
		list<polls__C> pollList = polls__c.getall().values();
		pollcount = pollList.size();		
        try{
		if (pollcount>0){
			//integer whichpoll = math.mod( datetime.now().second() , pollcount);
            integer whichpoll = math.min(pollcount-1, math.round((math.random()*pollcount)));
			thescript = pollList[whichpoll].script__c;
		}
        } catch (exception e) {pollcount=0;}
		
	}
	
	public list<polls__C> getAllPolls(){
        if (Apexpages.currentPage().getparameters().get('id')==null){
            list<polls__C> AllpollList = polls__c.getall().values();
            return AllpollList;
        } else {
            try{
                list<polls__C> AllpollList = [select id, script__c from polls__c where id =: Apexpages.currentPage().getparameters().get('id')];
                return AllpollList;
            }catch(exception e){
            	list<polls__C> AllpollList = polls__c.getall().values();
           		return AllpollList;
            }
        } 
        return null;
	}
	
	
}