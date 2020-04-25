public class FeeList {
	
	public Rate__c TheRate;
	list<rate__c> theRates = new list<rate__c>();
	
	public FeeList(ApexPages.StandardController stdController){
		theRates = [select id, tdsp__c from Rate__c where id =:ApexPages.currentPage().getParameters().get('Id') ];	
		if ( theRates.size()>0 )theRate = theRates[0];
	}
	public id selectedfee {get;set;}
	public boolean refreshpage {get;set;}
	
	public list<fee__c> GetFees(){ 
		if ( theRates.size()>0 ) {
			set<id> blacklist = new set<id>();
			
			list<Maintained_Fees__c> existing = [select id, fee__r.id from Maintained_Fees__c where rate__r.id =: therate.id]; //don't show ones already used
			if (existing.size()>0 ) {			
				
				for (Maintained_Fees__c mf:existing){
					blacklist.add(mf.fee__r.id);
				
				}
			}
			list<fee__c> feelist = [select name, value__c, basis__c, tdsp__c from fee__c where tdsp__c =: theRate.tdsp__c and rate_class__c = 'Residential' and id not IN:blacklist order by name];
			blacklist.clear();
			return feelist;
		} else {return null;}
	}

	public pagereference addFee(){
		Maintained_Fees__c theNewMaintainedFee = new Maintained_Fees__c ();
		theNewMaintainedFee.Rate__c = therate.id;
		theNewMaintainedFee.Fee__c = selectedfee;
		theNewMaintainedFee.Additional_Charge__c = true;
		insert theNewMaintainedFee;
		refreshpage = true;
		return null;
	}
}