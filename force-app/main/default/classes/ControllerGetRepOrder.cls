public with sharing class ControllerGetRepOrder {

public string ssnx {get;set;}


	public ControllerGetRepOrder(){ 
			String order = ApexPages.currentPage().getParameters().get('id');	
			TrueCostSystemVariables__c tcsv = TrueCostSystemVariables__c.getOrgDefaults();
			
			String json;
			String session = userInfo.getSessionId();
			
			//String url = 'https://cs12.salesforce.com/services/apexrest/OrderSSN?id='+order;
			String url = tcsv.REST_URL__c+'OrderSSN?id=';
			url = url+order;
		
			http h = new http();
			httprequest req = new httprequest();


			req.setEndpoint(url);
			req.setMethod('POST');
			req.setHeader('Authorization', 'OAuth ' + session);
			req.setHeader('Content-Type', 'text/xml;charset=utf-8');
			req.setBody('{ \"order\": '+order+'}');
			req.setTimeout(60000);
 
			httpresponse res = h.send(req);
			String result = res.getBody();

			json = res.getBody().replace('\n', '');
			
			ssnx = json;
			ssnx = ssnx.replace('"','');
			ssnx = 'Customer : ' + ssnx;

}

}