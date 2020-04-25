public without sharing class DiagnosticEntry {
	
	//try catch block because it could be executed from DML or getter methods
	public static void RecordCrash(Exception ex)
	{
		Diagnostic_Entry__c de = new Diagnostic_Entry__c(Line_Number__c = ex.getLineNumber(), 
									Body__c = ex.getMessage(), Stack_Trace__c = ex.getStackTraceString() );
		try{
			insert de;
			}catch (exception e){}
	}
	
	public static void RecordDebugEntry(String message)
	{
		Diagnostic_Entry__c de = new Diagnostic_Entry__c(Body__c = message);
		try{
			insert de;
			}catch (exception e){}
	}


	public static void SendDiagnosticLog()
	{
		List<Diagnostic_Entry__c> entries = [Select ID, CreatedDate, Body__c, Stack_Trace__c, Line_Number__c from Diagnostic_Entry__c Order By CreatedDate Desc limit 500];
		if(entries.size()==0) return;
		
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		List<String> toAddresses = new List<String> {'yoursupportemail@email.com'};
		mail.setToAddresses(toAddresses);
		mail.setSenderDisplayName('Our application calling home');
		mail.setSubject('Diagnostic Logs');
		mail.setUseSignature(false);
		String outputtext;
		outputtext = 'Org: ' + userinfo.getOrganizationName() + ' ID: ' + userinfo.getOrganizationId() + '\r\n';
		List<string> currentdata;
		Boolean foundone = false;
		
		for(Diagnostic_Entry__c entry: entries)
		{
			outputtext += String.ValueOf(entry.CreatedDate) + ':';
			outputtext += entry.Body__c;
			if(entry.Line_Number__c != null) outputtext += '\r\nError on line: ' + String.ValueOf(entry.Line_Number__c);
			if(entry.Stack_Trace__c !=null) outputtext += '\r\nStackTrace: ' + entry.Stack_Trace__c;
			outputtext += '\r\n';
		}

		mail.setPlainTextBody(outputtext);
		List<Messaging.SendEmailResult> results = Messaging.SendEmail(new List<Messaging.Email>{mail});

		delete entries;	

		// Note - in real code be sure to ask permission
		// Consider not deleting after - but instead doing cleanup of older than N hours and recording 
		// in a custom setting the earliest date to send
		// Consider emptying the recycling bin
		
	}
	

}