public with sharing class RenewalEmailController {
	
	public integer OfferCount {get;set;} //how many plans should there be?
	public string Orderid {get;set;}

	public RenewalEmailController() {		
	}

	public order__c getO(){
		return [select id, first_name__c, last_name__c, rep_profile__r.name, rep_profile__r.id, Plan_Expiration__c, 
			kWh_rate_1000__c, green_order__c
			from order__c
			where id=:Orderid];
	}

	public decimal getVariable(){
		list<rep_profile__c> reps = [select id, Curent_CEHE__c from rep_profile__c 
		where Curent_CEHE__c != null ];
		decimal total=0;
		for(rep_profile__c r:reps){
			total = total + r.Curent_CEHE__c;
		}
		return total/reps.size();
	}

	public list<resultsContainer> getOffers(){
		boolean greenonly = false;
		boolean TwelvePresent=false;

		if (getO().green_order__c) greenonly=true;

		string APAid=ShopRemote.GetAPAfromOrder(Orderid);
		list<resultsContainer> matches = ShopRemote.ShopByAPA(APAid);
		//results containers come back unscored, but with prices.

		if (greenonly){
			matches=greenOnlyFilter(matches);
		}

		for (resultsContainer rc:matches){
			rc.total_score=1/rc.price; //higher price ==> lower score!
		}
		matches.sort(); //sorts them by price
		
		//if last order was 100 renewable
		
		//take the top 3?
		list<resultsContainer> output = new list<resultsContainer>();

		for (integer x=0; x<(math.min(OfferCount, matches.size())); x++){
				output.add(matches[x]);
				if (matches[x].rateplan.plan__r.Contract_Length__c==12) TwelvePresent=true;			
		}

		//if there weren't any 12s in the mix
		if (!TwelvePresent){
			for (integer x=0; x<(matches.size()); x++){
				if (
					matches[x].rateplan.plan__r.Contract_Length__c==12 //it's a 12
					&& //it's not equal to at least one of the other two plans!
					(
						(matches[x].rateplan.plan__r.rep_profile__r.Name != output[0].rateplan.plan__r.rep_profile__r.Name) 
						||
						(matches[x].rateplan.plan__r.rep_profile__r.Name != output[1].rateplan.plan__r.rep_profile__r.Name) 
					)	
				) {
					output[2]=matches[x];
					x=100000;
				}	
			}	
		}

		return output;

	} 

	public static list<resultsContainer> greenOnlyFilter(list<resultsContainer> input){
		list<resultsContainer> output = new list<resultsContainer>();

		for (resultsContainer rc:input){
			if (rc.rateplan.plan__r.Renewable_Content__c==100){
				output.add(rc);
			}
		}
		output.sort();
		return output;

	}
}