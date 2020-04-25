global class EmailToChatter implements Messaging.InboundEmailHandler {
/*-----------------------------------------------------------------------------------------------
* Written by Evan Callahan, copyright (c) 2010 Groundwire, 1402 3rd Avenue, Suite 1000, Seattle, WA 98101
* This program is released under the GNU General Public License. http://www.gnu.org/licenses/
* 
* Inbound email handler that creates Chatter posts 
*
* Automatically posts to the user Chatter feed for the user who sends the email
* Support for:
	- Email attachments - posts each file to the Chatter feed
	- Forwarded email - Chatters the text up to the forward, and then posts the entire forward as a file
* 
* To configure, go to Setup => Develop => Email Services.  Create an email service:
	- Name: Chatter
	- Apex Class: ChatterEmail
	- Accept Attachments: All
	- Accept Email From: [your organization's domain name]
	- Truncate Oversize: [checked]
	- Convert Text Attachments: [checked]
	- Active: [checked]
*
* Next, click New Email Address.
	- Email Address: chatter
	- Active: [checked]
	- Context User: [name of system administrator]
	- Accept Email From: [your organization's domain name]
*		
* Make note of the email address - users can send or forward email and attachments to 
* that address to post to their Chatter feed. 
-----------------------------------------------------------------------------------------------*/
	
	global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, Messaging.InboundEnvelope env){
		
		// Create an inboundEmailResult object for returning 
		// the result of the Force.com Email Service
		Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
		
		
		// Try to lookup the user
		user[] u = [Select Id From user Where Email = :email.fromAddress and usertype=:'Standard'  Limit 1];
		if (email.fromAddress.contains('mytruecost.com') ){
			u = [Select Id From user Where id = :TrueCostUtilities.lookuptheAdmin()  Limit 1];
		}
			
		if (u.isEmpty()) {
			result.success = false;
			result.message = 'Please send your Chatter email from an email address associated with a Salesforce user.';
		} else {
			// Add a new post containing the content of the email				
			try {
				id fromUser = u[0].id;
	  			list<FeedItem> posts = new list<FeedItem>();
		  					  			
	  			// create the main post
	  			FeedItem fp = new FeedItem(
            		ParentId = fromUser,	// attach to the senders feed
	            	Body = email.subject	// post the subject	            	
	  			);

	  			// append up to 10 lines of body text from the email
	        	if (email.plainTextBody != null && email.plainTextBody.trim().length() > 0) {
		  			string[] emailLines = email.plainTextBody.split('\n', 11);
		  			for (string s : emailLines) {
		  				// stop if you hit the signature or forward
		  				if (s.startsWith('-') || s.toLowerCase().contains('forwarded message'))
		  					break;

		  				// append this line to the chatter post body
		  				fp.body += '\n' + s;
		  			}
	  			}		  			
	
            	// attach the email if it is a forwarded message
            	if (email.plainTextBody != null && email.plainTextBody.toLowerCase().contains('forwarded message')) {	            		
            		// use html if there is any, otherwise text
		        	if (email.htmlBody != null && email.htmlBody.trim().length() > 0) {
		            	fp.ContentData = blob.valueOf(email.htmlBody);	            		            	
						fp.ContentFileName = 'ForwardedEmail' + system.now().format('MMddhhmm') + '.htm';
		        	} else {	            		
	        			fp.ContentData = blob.valueOf(email.plainTextBody);
    	    			fp.ContentFileName = 'ForwardedEmail' + system.now().format('MMddhhmm') + '.txt';
		        	}
				}
					
				// also post each attachment
				set<string> fileNames = new set<string>();
				if (email.BinaryAttachments != null) {
					for (messaging.InboundEmail.BinaryAttachment ba : email.BinaryAttachments) {
						// make sure not to attach the same file twice
						if (!fileNames.contains(ba.filename)) {
							if (fp.contentFileName == null) {
								// attach the first attachment to the main post
								fp.ContentData = ba.body;         		            	
								fp.ContentFileName = ba.filename;
							} else {
								// post other attachments separately
					  			FeedItem fpa = new FeedItem(
				            		ParentId = fromUser,
					            	ContentData = ba.body,  	            		            	
									ContentFileName = ba.filename
					  			);
					  			posts.add(fpa);
							}
							fileNames.add(ba.filename);
						}
					}
				}
				if (email.TextAttachments != null) {
					for (messaging.InboundEmail.TextAttachment ba : email.TextAttachments) {
						// make sure not to attach the same file twice
						if (!fileNames.contains(ba.filename)) {
							if (fp.contentFileName == null) {
								// attach the first attachment to the main post
								fp.ContentData = blob.valueOf(ba.body);
								fp.ContentFileName = ba.filename;
							} else {								
								// post other attachments separately
					  			FeedItem fpa = new FeedItem(
				            		ParentId = fromUser,
					            	ContentData = blob.valueOf(ba.body), 	
									ContentFileName = ba.filename
					  			);
					  			posts.add(fpa);
							}
						}
					}
				}
					
				// insert the posts
				posts.add(fp);					
            	insert posts;
            	system.debug(posts);
				result.success = true;
			} catch (exception e) {
				result.message = 'Error while running the Chatter to Email converter: \n' + e.getMessage() + 'fromUser ==' + u;
				result.success = false;
				system.debug(e);				
			}
		} 
		
		// Return the result for the Force.com Email Service
		return result;
	}
		
	static testMethod void testChatterEmail() {
		set<id> oldposts = new set<id>();
		for (feeditem fi:[select id from Feeditem where createdbyid = :UserInfo.getUserId()]){
        	oldposts.add(fi.id);
        }
				
		
		// Create a new email and envelope object
		test.startTest();
		Messaging.InboundEmail email = new Messaging.InboundEmail();
		Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();		
		email.subject = 'chatter this test please';
		email.plainTextBody = 'Here is my plainText body of the email.\n The first line gets chattered.\n---Forwarded message---\nThe message.';
		user u = [select email from user where id = :userInfo.getUserId() limit 1];
		email.fromAddress = u.email;
		
		// Add attachments
		messaging.InboundEmail.TextAttachment ta = new messaging.InboundEmail.TextAttachment();
		ta.filename='this_is_only_a_test.txt';
		ta.body='test';
		list<messaging.InboundEmail.TextAttachment> talist = new list<messaging.InboundEmail.TextAttachment>();
		talist.add(ta);
		email.TextAttachments = talist;
		messaging.InboundEmail.BinaryAttachment ba = new messaging.InboundEmail.BinaryAttachment();
		ba.filename='this_is_only_another_test.txt';
		ba.body=blob.valueOf('test');
		list<messaging.InboundEmail.BinaryAttachment> balist = new list<messaging.InboundEmail.BinaryAttachment>();
		balist.add(ba);
		email.BinaryAttachments = balist;
		
		// Simulate sending the email
		EmailToChatter handler = new EmailToChatter();
		handler.handleInboundEmail(email, env);
		test.stopTest();
				
		// Did it work?
		list<feeditem> postsAfter = [select type, Body, ContentFileName from feeditem 
			where createdbyid = :UserInfo.getUserId() and id not in : oldposts];
		system.debug(postsAfter);				
		system.assertEquals(3, postsAfter.size());

		// also try a bad address, just for coverage
		email.fromAddress = 'nobody@nodomain.net';
		handler.handleInboundEmail(email, env);		

	} 
}