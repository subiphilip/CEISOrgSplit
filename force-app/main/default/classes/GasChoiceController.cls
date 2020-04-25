public with sharing class GasChoiceController {

	@RemoteAction
	public static list<premises__c> AddressSearch(string address){
		return GasChoiceUtilities.exactMatchServiceAddressGas(address);
	}

	@RemoteAction
	public static list<GasChoiceOffer> RemoteOffers(string premiseid, string year){
		try{
			premises__c p = GasChoiceUtilities.getPremiseDetailsByID(premiseid);        
			return GasChoiceCalc2.getAvailableOffersDynamicWideOpen(p, year, false);       
			} catch (exception e){
				DiagnosticEntry.RecordCrash(e);
				return null;
				} 
	}

	@RemoteAction
	public static rate__c RemoteConfCode(GasChoiceOffer o, premises__c thepremise){
		try{
		 return GasChoiceDynamicRatePicker.ConfirmationCodeManagement(O, thepremise);
		} catch(exception e){
				DiagnosticEntry.RecordCrash(e);
				return null;
			} 
	}

}