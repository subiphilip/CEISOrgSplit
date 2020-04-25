public with sharing class RewardList {
	
	public Rate__c TheRate;
	list<rate__c> theRates = new list<rate__c>();
	
	public RewardList(ApexPages.StandardController stdController){
		theRates = [select id, tdsp__c from Rate__c where id =:ApexPages.currentPage().getParameters().get('Id') ];	
		if ( theRates.size()>0 )theRate = theRates[0];
	}
	public id selectedreward {get;set;}
	public boolean refreshpage {get;set;}
	
	public list<rewards__c> GetRewards(){ 
		if ( theRates.size()>0 ) {
			set<id> blacklist = new set<id>();
			
			list<RateRewardAssociation__c> existing = [select id, reward__r.id from RateRewardAssociation__c where rate__r.id =: therate.id]; //don't show ones already used
			if (existing.size()>0 ) {			
				
				for (RateRewardAssociation__c RRA:existing){
					blacklist.add(RRA.reward__r.id);
				
				}
			}
			list<rewards__c> rewardList = [select name, Reward_End_Date__c, Reward_Start_Date__c, Reward_Type__c, Reward_Value__c  from Rewards__c where id not IN:blacklist order by name];
			blacklist.clear();
			return rewardList;
		} else {return null;}
	}

	public pagereference addReward(){
		RateRewardAssociation__c theRRA= new RateRewardAssociation__c ();
		theRRA.Rate__c = therate.id;
		theRRA.Reward__c = selectedreward;
		insert theRRA;
		refreshpage = true;
		return null;
	}
}