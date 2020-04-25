public with sharing class ControllerForCustomerRewardsView {
	public id therateid {get;set;}
	public Rate__c rate {get;set;}
	public id program {get;set;}
	
	public 	ControllerForCustomerRewardsView(){
	}
	
	public list<rewards__c> getTheRewards(){
		//first get the REP offering the rate in the URL parameter.  We'll check for universal plans
		list<rewards__c> rewardlist = new list<rewards__c>();
		try{
			rate = [select id, plan__r.REP_Profile__r.id from Rate__c where id=:therateid]; //match the rate with an REP and get its ID
		} catch(exception e){return rewardlist;}
				
		list<RateRewardAssociation__c> RRAlist = [select id, reward__r.program__c, rate__r.plan__r.REP_Profile__r.id, reward__r.id from RateRewardAssociation__c 
			where rate__r.id=:therateid];
		list<id> rewardIDlist = new list<id>();
		for (RateRewardAssociation__c RRA:RRAlist){
			rewardIDlist.add(RRA.reward__r.id);
		}
				
		rewardlist=[select id, Choice__c, Program__c, name, Percentage_Value__c, Reward_Value__c, Reward_Program__c,reward_program__r.id,  Reward_Description__c, 
							Time_from_start_of_contract_in_months__c, New_Customer_Only__c 
							from rewards__c 
							where ((id in: rewardIDlist or reward_program__r.id in:rewardIDlist) or (Applies_to_all_plans__c=:true and rep_profile__r.id =: rate.plan__r.rep_profile__r.id)) and ((Reward_Start_Date__c<=:System.today() and Reward_End_Date__c>=:System.today()) or (Reward_Start_Date__c=:null and Reward_End_Date__c=:null))
							order by Program__c, Reward_Program__c, Time_from_start_of_contract_in_months__c ASC, choice__c
					];
		system.debug('==================rewardslist contains' + rewardlist);
		list<rewards__c> rewardlist2 = new list<rewards__c>();
		for (Rewards__c reward :rewardlist){
			if (reward.program__c){ //if it's a program
				rewardlist2.add(reward);//gather each program into your list	
				system.debug('==================added program' + reward.name);
				for (Rewards__c subreward :rewardlist){ //look through all the rewards again
					system.debug('====================checking reward + subreward' + subreward.name);
					if (subreward.Reward_Program__r.id == reward.id){ //find all the rewards that are part of that program
						rewardlist2.add(subreward); // add them so that the display order to the customer makes sense
						system.debug('==================added subreward + subreward.name');
					} 	else {system.debug('==================did not add subreward + subreward.name');}
				}
			}		  
		}
		for (Rewards__c reward:rewardlist){ //now grab the rewars taht are not part of a program and list them.
                    if (!reward.program__c && reward.reward_Program__c ==null){
                        rewardlist2.add(reward);
                    }
                        
                }
		
		return rewardlist2;
	}
	
	
}