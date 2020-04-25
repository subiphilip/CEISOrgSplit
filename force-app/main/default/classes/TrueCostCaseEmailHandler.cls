/**
 * Email services are automated processes that use Apex classes
 * to process the contents, headers, and attachments of inbound
 * email.
 */
 
 /*
 2/28/2012	Shane McLaughlin	Added isConverted to lead filter (you can't mess with converted leads without getting errors)
 
 */
global class TrueCostCaseEmailHandler implements Messaging.InboundEmailHandler {

    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
		
		TrueCost_Case__c tcc = new TrueCost_Case__c();
		//Is there an existing case open specified in the email?  If so, add this email and its attachments to the case
			integer casenumberstart;
			try{casenumberstart = email.plaintextbody.indexOf('Case-')+5;} catch(exception e){}
			
			if(casenumberstart!=4){
				string messagedivider = '**************************************************************************';
				string casenumber = email.plaintextbody.substring(casenumberstart, casenumberstart+7);
				system.debug('======================================The CaseNumber is ' + casenumber);
				tcc = [select id, status__c, description__c from TrueCost_Case__c where name =:('Case-'+casenumber)];
				tcc.status__c = 'New';
				tcc.description__c = tcc.description__c + '\n' + messagedivider + '\n';
				tcc.description__c = tcc.Description__c + system.now() + '\n';
				tcc.description__c = tcc.Description__c + email.plaintextbody;
				update tcc;
			} else{   //if it's not from an existing case
				//Check to see if it's someone we know--Accounts
				List<Account> AccountList = new List<Account>();
				AccountList = [select Name, Id from Account where email__c = :email.fromAddress or PersonEmail = :email.fromAddress limit 5000];
				if (AccountList.size() != 0) {
					TCC.Account__c = AccountList[0].Id;
				}
				
				//If it's not an account, maybe it's a lead?
				List<Lead> LeadList = new List<Lead>();
				LeadList = [select Name, Id from Lead where email= :email.fromAddress and isConverted = false];
				if (LeadList.size() != 0) {
					TCC.Lead__c= LeadList[0].Id; 
				}
				
				//If not, create the case
				tcc.Non_Account_Email__c = email.fromAddress;
				tcc.Origin__c = 'Email';
				tcc.Subject__c = email.subject;
				tcc.Description__c = email.plaintextbody;
				tcc.Caller_Name__c = email.fromname;
				tcc.priority__c = 'Medium';
				tcc.Status__c = 'New';
				tcc.Entity_Type__c = 'Customer';
				insert tcc;
				
			}
			//OK, now that we've added/updated the case, let's get the attachment(s)
		
		if (email.binaryAttachments != null && email.binaryAttachments.size() > 0) {
	      	for (integer i = 0 ; i < email.binaryAttachments.size() ; i++) {
	        Attachment attachment = new Attachment();
	        // attach to the newly created contact record
	        attachment.ParentId = tcc.Id;
	        attachment.Name = email.binaryAttachments[i].filename;
	        attachment.Body = email.binaryAttachments[i].body;
	        insert attachment;
	      }
    }
        return result;
    }
}