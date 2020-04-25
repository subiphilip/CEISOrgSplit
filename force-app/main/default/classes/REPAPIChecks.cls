public with sharing class REPAPIChecks {
	
	public static void CheckCirro(){
		orderapimanager vir = new orderapimanager();
		vir.checkcirrostatus();
	}

	public class OrderStatusException extends exception {}

	
	public static void CheckDirectOrder(string orderid){
		order__c o = [select id, order_status__c, reporderid__c, Rep_Profile__r.Name
			from order__c 
			where id=:orderid limit 1];
		system.debug('order'+o);


	//let's get that lovely token
	HttpRequest req = NewLeafAPImrg.BuildTokenRequest(o.Rep_Profile__r.Name);

	String token = '';
	Http http = new Http();
	HTTPResponse res = http.send(req);
	System.debug(res.getBody());
	token = NewLeafAPImrg.parseToken(res);
	System.debug('Token' + token);
	 //End get token call
	

	PartnerAPI__c Papi = PartnerAPI__c.getInstance(o.Rep_Profile__r.Name);
	string repstring = Papi.brand_string__c;

	//req = new HttpRequest();
	String body1 =repstring+'_xml='+
		+'<?xml version=\"1.0\"?>'
			+'<'+repstring+'_api>'
			+'<request>'
			+'<type>get_order_status</type>'
			+'<token>'+token+'</token>'
			+'<order_id>'+o.reporderid__c+'</order_id>'
			+'</request>'
			+'</'+repstring+'_api>';
	
	System.debug('req'+body1);
	
	req.setbody(body1);

	Http http1 = new Http();
	
	HTTPResponse res1 = http1.send(req);
	System.debug(res1.getBody());

	//Handle response
	List<String> orderResponse =new List<String>();
		List<String> orderResponse1 =new List<String>();
	Dom.Document docRes = new Dom.Document();
		
		docRes.load(res1.getBody());
		
		//Retrieve the root element for this document.
		
		Dom.XMLNode EnvelopeRes = docRes.getRootElement();
		
		Dom.XMLNode BodyRes= EnvelopeRes.getChildElements()[0];
		
		system.debug('raw response' +res1.getBody());
		system.debug('raw response' +BodyRes);
		String order_result = '';
		string id_validated = '';
		String order_created = '';
		String order_id = '';
		String deposit_required = '';
		String deposit_due = '';
		String payment_required = '';    
		String payment_due = '';
		String authCode = '';
		String result   = '';
		String orderStatus = '';
		String orderStatusDescription = '';
		for(Dom.XMLNode childRes : BodyRes.getChildElements()) {
			
		if (childres.getName() == 'order_status_id')
			orderStatus = childRes .getText();
		if (childres.getName() == 'order_status_description')
			orderStatusDescription = childRes .getText();   
		
				
		orderResponse1.add(childres.getName());
		orderResponse.add(childRes .getText());
		}
		system.debug('orderresponse'+ orderresponse);
		system.debug( 'authcode'+ authcode );
		system.debug( 'result'+ result );
	
		if ( orderStatusDescription == 'accepted') o.Order_Status__c = 'Confirmed';
		if ( orderStatusDescription == 'declined') o.Order_Status__c = 'Rejected';		  
		
	 update o; //updates that list of orders

	}
}