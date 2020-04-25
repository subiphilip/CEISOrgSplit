@RestResource(urlMapping='/OrderSSN/*')

global  without sharing class  REPSSNdecryptREST {
	private final order__c o;
	public string ssn;
	
	public REPSSNdecryptREST(ApexPages.StandardController stdcontroller){ 
		
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

			return null;
	

}

@HttpPost
    global static String doPost(RestRequest req, RestResponse res) {
    	string order = req.params.get('id');
    	system.debug('============ the order is ============= ' + order  );
        order__c[] o =[select id, SSN__C,payment_card_number__c,Payment_Card_3_digit_code__c from order__C where id = :order];

		if (o.size()>0) {
			
			system.debug('============ the ssn back is ============= ' + o[0] );
			return 'cc:'+o[0].payment_card_number__c+' ssn:'+ o[0].ssn__c+' 3 dig:'+o[0].Payment_Card_3_digit_code__c;
		} 
		else {
			return null;
		}
    }

	public string getidcheck(){
		id theorder = o.id;
		return theorder;
	}
}