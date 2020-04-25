/*
1/24/2012   Barry Glasco    Created to pull UHIT Data for external requests
*/  

@RestResource(urlMapping='/UHITRest/*') 


global  without sharing class  UHITRest {
	/*private final order__c o;
	public string ssn;
	
	public UHITRest(ApexPages.StandardController stdcontroller){ 
		
	}
	
	public string getSSN(){
		order__c myorder= getTheOrder(); 
		return myorder.ssn__c;

	}
	
	public order__c getTheOrder(){
		
		order__c[] o =[select id, SSN__C from order__C where id =: o.id];
		if (o.size()>0) {
			system.debug('============ the order is ============= ' + o[0] );
			return o[0];
		} 
		else {
			return null;
		}
	}
	@HttpGet

global static String doGet() {

			return 'help';
	*/

} 
/*
@HttpPost  
    global static String doPost(RestRequest req1, RestResponse res) {
    	//return JSON.serialize('{"error" :"Error Description"}');
    	//return test;
		  string esiid = ''; 
		  string meter = '';
		  String requestIdResp = '';
		  List<AccountPremiseAssociation__c> apa;
		  id Account   = '00130000011hadx'; // barry
		  esiid = req1.params.get('esiid'); 
		  meter = req1.params.get('meter');
		   system.debug('esid'+ esiid);
		   system.debug('meter'+ meter); 
		   
		  if (esiid == null || meter == null)
		  //return  '{\n' +    ' "error" :"No ESID or No meter passed"\n' +   '}';
		  return JSON.serialize('{"error" :"No ESID or No meter passed"}');
		  
		   
		  if (esiid == '' || meter == '')
		  return JSON.serialize('{"error" :"No ESID or No meter passed"}');
		 
		  
		
		  // check to see if we have a premise for this esiid
		  premises__c selectedpremise2 = [select id, Electric_Service_Address_City__c,Premise_Type__c, Electric_Service_Address__c, 
		                                                    Electric_Service_Address_State2__c, Electric_Service_Address_Zip__c, tdsp_lookup__r.name,meter_number__c 	                                                    
		                                                    from premises__C where ESID__c =:esiid limit 1];
		                                                    
		   
		  if ( selectedPremise2.id ==  null)
		  return JSON.serialize('{"error" :"No premise available for this ESID"}');
		  
		  // check to see if we already have an apa for this premise/esid
		    apa = [select Account__c, Id, Meter_Data_Estimated__c,Meter_Data_Permission__c,Meter_Data_Request_Status__c,Premise__c,lastdaily__c, RequestId__c FROM AccountPremiseAssociation__c 
		              where        premise__c =: selectedPremise2.id and account__c =: account limit 1];
		  
		   if ( apa.size() > 0 )
		   {
		   	system.debug('hava apa'+ apa);
		    List<Daily_Usage__c> daily = [SELECT  Date__c,  Intervals__c,Max_for_the_day__c,   Total_for_the_day__c FROM Daily_Usage__c where Account_Premise_Association__c =: apa[0].id and premise__c =: selectedpremise2.id ];
		     If  ( daily.size() > 0){
		     String JSONString = JSON.serialize(daily);
		     return  JSONString;
		     }
		  }else{
		     	system.debug('no apa');
		     	accountpremiseassociation__c newapa = new accountpremiseassociation__c(); 
		    
		        newapa.account__c=  account;
		        newapa.premise__c=selectedPremise2.id;
		        newapa.selected__c=true;
		        newapa.Meter_Data_Permission__c     = true;
		        newapa.Meter_Data_Request_Status__c = 'Complete';
		        selectedPremise2.meter_number__c = meter;
		        update selectedPremise2;
		        insert newapa;
		        apa = [select Account__c, Id, Meter_Data_Estimated__c,Meter_Data_Permission__c,Meter_Data_Request_Status__c,Premise__c,lastdaily__c, RequestId__c FROM AccountPremiseAssociation__c 
		              where        premise__c =: selectedPremise2.id and id =: newapa.id limit 1];
		              calluhit(  esiid,   apa[0].id,   selectedpremise2.id, meter);
		     }

	
		return JSON.serialize('{"successRequest" :"request sent""}');	
		
    }
@future (callout=true)
private static void calluhit(String esid, String apa, String premise,String meter)
{
  List<AccountPremiseAssociation__c> lstApa = new List<AccountPremiseAssociation__c>();
       List<UHITRequest__c> requestList = new List<UHITRequest__c >();
       LIST<UsageRequestInterval.PremiseHistoricalUsageRequest> lst = new  LIST<UsageRequestInterval.PremiseHistoricalUsageRequest>(); 
        UsageRequestInterval.PremiseHistoricalUsageRequestList reqList = new UsageRequestInterval.PremiseHistoricalUsageRequestList();
      
      	  List<accountpremiseassociation__c>      apalst = [select Account__c, Id, Meter_Data_Estimated__c,Meter_Data_Permission__c,Meter_Data_Request_Status__c,Premise__c,lastdaily__c, RequestId__c FROM AccountPremiseAssociation__c 
		              where        premise__c =: premise and id =: apa limit 1];
		              
      
    Premises__c premises = [select id, meter_number__C, meter_data_permission__c, 
                          square_feet__c, Year_of_Construction__c, Year_Built__c, Occupants__c, Heating_System__c, Pool__c,
                          Electric_Service_Address__c, ESID__c, Electric_Service_Address_City__c,  Electric_Service_Address_State2__c,Electric_Service_Address_Zip__c
                        from Premises__c where ESID__c =: esid];
   
  
     UsageRequestInterval.PremiseHistoricalUsageRequest req = new  UsageRequestInterval.PremiseHistoricalUsageRequest() ;
        
        req.AuthorizationType                                       = 'Unlimited';
        req.AuthorizationOnFile                                     = true;
        req.ESIID                                                   = premises.ESID__c;
        req.MeterNumber                                             = meter;
        req.ServiceAddress                                          = premises.Electric_Service_Address__c;
        req.ServiceCity                                             = premises.Electric_Service_Address_City__c;
        req.ServiceState                                            = premises.Electric_Service_Address_State2__c;
        req.ServiceZip                                              = premises.Electric_Service_Address_Zip__c.substring(0,5);
      //  req.TypeOfData                                              = 'Summary Billing Data';
        req.TypeOfData                                              = 'Interval Data';
        req.CustomerNameGrantingAuthorization                       = 'IES';
        req.CustomerTitleGrantingAuthorization                      = 'Owner';
        req.CustomerTelephoneNumberGrantingAuthorization            = '7132073204';
        req.CustomerBillingStreetAddressGrantingAuthorization       = '1111 Louisiana';
        req.CustomerBillingCityGrantingAuthorization                = 'Houston';
        req.CustomerBillingStateGrantingAuthorization               = 'Tx';
        if (premises.Electric_Service_Address_Zip__c != null)
        {
        req.CustomerBillingZipGrantingAuthorization                 = premises.Electric_Service_Address_Zip__c.substring(0,5);
        }else
        {
        req.CustomerBillingZipGrantingAuthorization                 = premises.Electric_Service_Address_Zip__c;
        }
        date mydate = date.today()-1;
       
        req.OriginalAuthorizationDate = mydate;
       
     
       
        
        lst.add(req);

        reqList.PremiseHistoricalUsageRequest = lst;
        
     
        UsageRequestINterval.ExecutePortType prt = new UsageRequestInterval.ExecutePortType();
        TrueCostSystemVariables__c tcsv = TrueCostSystemVariables__c.getOrgDefaults();
        
        String Party        = 'ThirdParty';
        String ReqId        = '838611739';
        String CallBackURI  = 'https://centerpoint.muleion.com/uhit/HistoricalUsage';
       
        String techEmail    = 'barry.glasco@centerpointenergy.com';
        
     
        
        try{
            
        //This is the real call which is currently disabled till people get there crap together 
        UsageRequestInterval.PremiseHistoricalUsageRequestAckList_element[] rep ;
         system.debug('requestmgr reqList'+reqList);
        system.debug('requestmgr req result'+rep);
        rep = prt.RequestForHistoricalUsage(Party, ReqId, CallBackURI, techEmail, reqList );
       
       
        
        // so we have to take the essid and go get the apa and premise info to handle update
        String requestId = rep[0].PremiseHistoricalUsageAck.RequestID;
        Integer responseCode = rep[0].PremiseHistoricalUsageAck.RequestStatusCode;
        String esiiD1 = rep[0].PremiseHistoricalUsageAck.ESIID;
        system.debug('requestmgr req id'+requestId);
        
       
        UHITRequest__c  request = new UHITRequest__c();
       
        
        
        ///request.APA__c = apa.id;
        request.requestId__c = requestId;
        request.ESID__c = esiiD1;
        //requestIdResp = requestId;
        
        insert request;
        apalst[0].RequestId__c = requestId;
        update apalst;
       
      
        }
         catch (CalloutException e)
        {
         system.debug('callout exception ' +e);
        // return  '{\n' +    ' "error" :"Fatal Callout Exception"\n' +   '}';
          //return JSON.serialize('{"error" :"Fatal Callout Exception"}');
        }
}
*/

/*

	public string getidcheck(){
		id theorder = o.id;
		return theorder;
	}


}
*/