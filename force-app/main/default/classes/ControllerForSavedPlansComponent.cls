public with sharing class ControllerForSavedPlansComponent {
	public list<saved_plan__c> sp {get;set;}
	public id APAid{get;set;}
	AccountPremiseAssociation__c APA {get;set;}
	
	public ControllerForSavedPlansComponent(){
		try{
		if (APAid!=null) {
			APA = [select id from AccountPremiseAssociation__c where id=:APAid];
		} else {
			APA = [select id from AccountPremiseAssociation__c where id=: TrueCostUtilities.getTheAPAs(UserInfo.getUserId())];
		}
		sp = TrueCostUtilities.fetchSavedPlans(APA);	
		} catch(exception e){}
	}
}