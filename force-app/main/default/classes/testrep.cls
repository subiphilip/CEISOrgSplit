public class testrep {

    public  void ActionDoer(){
    		
    		String json;
            String session = userInfo.getSessionId();
            String userid  = userInfo.getUserId();
            
            String token = gettoken();
          
            
            Try {
		            String url = 'https://na1.salesforce.com/services/apexrest/RepOrders?id=00530000007an27';
		           
		            http h = new http();
		            httprequest req = new httprequest();
		
		
		            req.setEndpoint(url);
		            req.setMethod('POST');
		            req.setHeader('Content-Type', 'text/json;charset=utf-8');
		            req.setHeader('Authorization', 'OAuth ' + token);
		            req.setHeader('Content-Length','0');
		           
		            req.setTimeout(60000);
		 
		            httpresponse res = h.send(req);
		            String result = res.getBody();
		            system.debug('result_____________'+result);
		            result = result.replace('\\','');
		                        }
            catch(exception e){
            
            system.debug(e);
            }
  
   
    }
    
    
    
      
    
    
    private string gettoken()
    {
            String json;
         
			String httpURL      	= 'https://login.salesforce.com/services/oauth2/token';
			String clientID     	= '3MVG99OxTyEMCQ3gu7v8WaS4myRV2HMVBXiurPl4UN5T_S.g_ffg7.eUKt2CUsgChdLfuiBObHQan48kVca3N';
			String clientSecret 	= '6282016071229520133';
			String userName         = 'sphilip@cies.com.cnp2';
			String uhitPW           = 'Autumn12oBDnGWmHnjmRkPrsTr6ZV3ZK6';
            String url = httpURL+'?grant_type=password&client_id='+clientID+'&client_secret='+clientSecret+'&username='+userName+'&password='+uhitPW+'&';
          
            http h = new http();
            httprequest req = new httprequest();


            req.setEndpoint(url);
            req.setMethod('POST');
           
            req.setHeader('Content-Type', 'text/json;charset=utf-8');
          
            req.setTimeout(60000);
 
            httpresponse res = h.send(req);
            String result = res.getBody();
            system.debug('result'+ result);
   
			 String id  = '';
			 String issued_at = '';
			 String instance_url = '';
			 String signature  = '';
			 String access_token  = '';

				system.Jsonparser parser = system.Json.createParser(result);
				while (parser.nextToken() != JSONToken.END_OBJECT) {
							if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
								String text = parser.getText();
								if (parser.nextToken() != JSONToken.VALUE_NULL) {
									if (text == 'id') {
										id = parser.getText();
									} else if (text == 'issued_at') {
										issued_at = parser.getText();
									} else if (text == 'instance_url') {
										instance_url = parser.getText();
									} else if (text == 'signature') {
										signature = parser.getText();
									} else if (text == 'access_token') {
										access_token = parser.getText();
				                        system.debug('token     ___________________________________'+access_token);
									} else {
										System.debug(LoggingLevel.WARN, 'Root consuming unrecognized property: '+text);
										//consumeObject(parser);
									}
								}
							}
						}
						return access_token;
				    }
				   
}