public with sharing class InformaticaRunner {


 	@future (callout=true)
 	public static void runFuture(string jobtype, string taskID){
 		runInformaticaTaskV2(jobtype, taskID);
 	}

	public pageReference RunFromButton(){
		string jobtype=ApexPages.CurrentPage().getParameters().get('jobtype');
		string taskid=ApexPages.CurrentPage().getParameters().get('taskid');
		runInformaticaTaskV2(jobtype, taskid);
		return new PageReference('/'+ApexPages.CurrentPage().getParameters().get('returl')); 
	}

	//returns a string containing icSessionId, serverURL
	public static string loginInformaticaTaskV2() {
		string icSessionID = '';
		string icServerURL = '';
		PartnerAPI__c Papi = PartnerAPI__c.getInstance('InformaticaCloud');

		HttpRequest req = new HttpRequest();
		HttpResponse res = new HttpResponse();
		Http http = new Http();                     

		req.setEndPoint(Papi.Endpoint__c);
		req.setHeader('HTTP', '1.0');
		req.setHeader('Content-Type', 'application/xml');
		req.setHeader('Accept', 'application/xml');
		req.setBody('<login><username>' + Papi.Username__c + '</username><password>' + Papi.Password__c + '</password></login>');                          
		req.setMethod('POST');

		try {
			res = http.send(req);
			system.debug(res.getBody());
			if(res.getBody().contains('<icSessionId>')){
				
				icSessionId = getValueFromXMLString(res.getBody(), 'icSessionId');
				icServerUrl = getValueFromXMLString(res.getBody(), 'serverUrl');
				//CacheLoginResponse(icServerUrl, icSessionId);
				//stored the endpoint/sessionId
				return  icSessionId+','+icServerUrl;
			}else{
				throw new InformaticaAPIException('Login Error: ' + res.ToString());
			}          
		} catch(Exception e) {             
			throw new InformaticaAPIException(' - Response: ' + res.ToString(), e);
		}                     
		
	}

	public static void CacheLoginResponse(string endpoint, string token){
		PartnerAPI__c Papi = PartnerAPI__c.getInstance('InformaticaCloud');		
		Papi.Saved_Token__c = token;
		Papi.Dynamic_Endpoint__c = endpoint;
		upsert Papi;
	}

	//returns a string containing icSessionId, serverURL
	public static string CachedloginInformaticaTaskV2() {		
		try{
			PartnerAPI__c Papi = PartnerAPI__c.getInstance('InformaticaCloud');
			return Papi.Saved_Token__c+','+Papi.Dynamic_Endpoint__c;
			} catch (NullPointerException npe){
				loginInformaticaTaskV2();
				PartnerAPI__c Papi = PartnerAPI__c.getInstance('InformaticaCloud');
				return Papi.Saved_Token__c+','+Papi.Dynamic_Endpoint__c;
			}
	}

	public static string getValueFromXMLString(string xmlString, string keyField){
		string valueFound = '';
		if(xmlString.contains('<' + keyField + '>') && xmlString.contains('</' + keyField + '>')){
			try{
				valueFound = xmlString.substring(xmlString.indexOf('<' + keyField + '>') + keyField.length() + 2, xmlString.indexOf('</' + keyField + '>'));   
			}catch (exception e){
				system.debug('Error in getValueFromXMLString.  Details: ' + e.getMessage() + ' keyfield: ' + keyfield);
			}           
		}
		return valueFound;
	}

	//ID can be found from the URL while in informatica. example looks like 000O0C0I00000000000N (CES Basis Futures to Salesforce)
	/*Type of task or taskflow. Use one of the following options:-
            DSS. Data synchronization task.-
            Workflow. Task flow.-
            MTT. Custom integration task.-

		Options you probably won't use
            AVS. Contact Validation task.-
            DLS. Data loader task.-
            DMASK. Data masking task.-
            DQA. Data assessment task.-
            DRS. Data replication task.-
            PCS. PowerCenter task.-            
            DNB_WORKFLOW. D&B360 workflow.
    */
	public static void runInformaticaTaskV2(string jobtype, string taskID) {
        
		//string loginResults = loginInformaticaTaskV2();
		string loginResults = CachedloginInformaticaTaskV2();

		string icServerURL=loginResults.split(',')[1];
		string icSessionId=loginResults.split(',')[0];

        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();                      
        
        req.setEndPoint(icServerURL + '/api/v2/job');
        req.setHeader('HTTP', '1.0');
        req.setHeader('Content-Type', 'application/xml');
        req.setHeader('Accept', 'application/xml');
        req.setHeader('icSessionId', icSessionId);
        /*Type of task or taskflow. Use one of the following options:-
            AVS. Contact Validation task.-
            DLS. Data loader task.-
            DMASK. Data masking task.-
            DQA. Data assessment task.-
            DRS. Data replication task.-
            DSS. Data synchronization task.-
            MTT. Custom integration task.-
            PCS. PowerCenter task.-
            Workflow. Task flow.-
            DNB_WORKFLOW. D&B360 workflow.
        */
        req.setBody('<job>' + '<taskId>' + taskID + '</taskId>' + '<taskType>' + jobType + '</taskType>' + '</job>');
                             
        req.setMethod('POST');
                 
        try {
            res = http.send(req);
            system.debug('error body is ' +res.getBody());
            //if the session is expired (UI_13406), we'll request a new session from login
            if (res.getBody().contains('UI_13406')){
            	loginResults = loginInformaticaTaskV2();
            	icServerURL=loginResults.split(',')[1];
				icSessionId=loginResults.split(',')[0];

				req.setEndPoint(icServerURL + '/api/v2/job');
				req.setHeader('icSessionId', icSessionId);
				res = http.send(req);
				CacheLoginResponse(icServerURL, icSessionId);
        	} else if(res.getBody().contains('Forbidden')){ //If not successful, there will be a response with a forbidden error         	
				throw new InformaticaAPIException('Error Starting Job: ' + res.ToString());
        	}             
        } catch(Exception e) {             
        	//loginInformaticaTaskV2();
        	//only throw exception if status is not null.  This is a new error with the summer 14 release that can be avoided.
        	if (res.toString() != 'System.HttpResponse[Status=null, StatusCode=0]')
            	throw new InformaticaAPIException('Error Starting Job - Response: ' + res.ToString()+ '. Credentials obtained were '+loginResults, e);
        }                          
	}





	public class InformaticaAPIException extends Exception{}

}