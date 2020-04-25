public class ControllerForConfirmEstimatedUsage {

	list<monthly_usage__c> mulist {Get;set;}
	public AccountPremiseAssociation__c activeAPA{get;set;} 
	public list<decimal> stuffForChart {get;set;}
	
	public ControllerForConfirmEstimatedUsage(){
		system.debug('===============loading the constructor==============');
		ActiveAPA = APAUtilities.GetActiveAPA( TrueCostUtilities.getTheAccount(UserInfo.getUserId()) );
		if (ApexPages.CurrentPage().getParameters().get('mode')=='Adjust'){
			mulist = TrueCostUtilities.pullTheMonthlyUsage(ActiveAPA);
		} 	else {
				mulist = TrueCostEstimator.makeUsageEstimateList(ActiveAPA);		
			} 
		system.debug('===============finished constructor==============');
		stuffForChart = new decimal[12];
		updateStuffForChart();
	}
		
	public void MakeTheEstimate(){ 
		mulist = TrueCostEstimator.makeUsageEstimateList(ActiveAPA);
		system.debug('=============Controller knows mulist is ===========         ' + mulist);
		stuffForChart = new decimal[12];
		updateStuffForChart();
	}
	
	public list<monthly_usage__c> getmulistdata(){
		return mulist;
	}
	
	public void updateStuffForChart(){
	
			for (integer k = 0; k<12; k++){
				system.debug('==================starting iteration=================             ' + k  );				
				stuffForChart[k] = mulist[k].usage__c; system.debug('============adding   ' + mulist[k].usage__c + '   to list');
				
				}
			system.debug('==================list is now=================           ' + stuffForChart );
				
			
			system.debug('============================list complete============================');
		
		
	}
	
	
	public PageReference updateUsageEstimate(){	
		try{
			list<monthly_usage__c> existing = [select id from monthly_usage__c where APA__r.id =: ActiveAPA.id and isdeleted=false and id not in: mulist]; 	
			delete existing;
			
			} 	catch(DMLexception e){
				//could put a admin notification here?
				}	
		try{  //if it's a new one
			insert mulist;
		} catch(dmlexception e){update mulist;}
		updateStuffForChart();
		return null;
	}
	
	public PageReference updateUsageEstimateNoChart(){	
		try{
			list<monthly_usage__c> existing = [select id from monthly_usage__c where APA__r.id =: ActiveAPA.id and isdeleted=false and id not in: mulist]; 	
			delete existing;
			
			} 	catch(DMLexception e){
				//could put a admin notification here?
				}	
		try{  //if it's a new one
			insert mulist;
		} catch(dmlexception e){update mulist;}
		return null;
	}
	
	public pageReference ShopWithEstimateUsage(){ 
		updateUsageEstimate();
		return Page.ShopPlans;
	}
	
	public PageReference RaiseEstimate(){
		for (monthly_usage__c mu:mulist){
			if (! (mu.usage__c>0 ) ) mu.usage__c =0;
			mu.usage__c=math.round(1.05*mu.usage__c);
		}
		updateStuffForChart();
		return null;
		}
	
	public PageReference LowerEstimate(){
		for (monthly_usage__c mu:mulist){
			if (! (mu.usage__c>0 ) ) mu.usage__c =0;
			mu.usage__c=math.round(0.95*mu.usage__c);
		}
		updateStuffForChart();
		return null;	
		}
		
	public PageReference updateChart(){
		return null;
	}
}