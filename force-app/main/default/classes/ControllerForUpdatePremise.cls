public with sharing class ControllerForUpdatePremise {
	
	private premises__c thepremise;
	
	public premises__c getthepremise(){
		return thepremise;
	}
	
	
	
	public ControllerForUpdatePremise(){
		AccountPremiseAssociation__c  theAPA = APAUtilities.GetACtiveAPA(TrueCostUtilities.GetTheAccount(UserInfo.getUserId()));
		List<premises__c> p = new List<premises__c>();
		p = [select id, Heating_System__c, Occupants__c, Year_of_Construction__c, Year_Built__c, Pool__c, Square_Feet__c, Meter_Data_Status__c
		from premises__c
		where id=:theAPA.premise__r.id]; 
		if (!p.isEmpty()) {
			thepremise = p[0]; 
		}
	}
	
	public PageReference updatePremise(){		
        
        try {
            update thepremise;            
        } catch(DmlException e) {
            ApexPages.addMessages(e);
            return null;
        }
    return Page.MyAccount;
	}
	
	public PageReference MakeEstimate(){		
		TrueCostEstimator.MakeEstimateThenSave(thepremise);
        thepremise.Meter_Data_Status__c = 'Estimated';
		try {
            update thepremise;            
        } catch(DmlException e) {
            ApexPages.addMessages(e);
            return null;
        }        
        
		return Page.ShopPlans; //needs to be the new estimate confirmation page
	}
	
	
	public PageReference Back(){
		return Page.MyAccount;
	}
	
	public PageReference BacktoShop(){
		return Page.Shopplans;
	}
}