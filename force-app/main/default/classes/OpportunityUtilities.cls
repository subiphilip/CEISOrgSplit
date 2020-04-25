public without sharing class OpportunityUtilities {
	
	public static void CloseOpportunityFromContract(id contractId){
        cesContract__c cesc = [select id, opportunity__c, contract_status__c from cesContract__c where id=:contractId];

        opportunity o=[select StageName, Opty_Peak_Daily_Volume__c, Opty_Credit_Price__c from opportunity where id=:cesc.opportunity__c]; 
        o.StageName = 'Closed Won';
        if (o.Opty_Peak_Daily_Volume__c == null) {o.Opty_Peak_Daily_Volume__c = 0;}
        if (o.Opty_Credit_Price__c == null) {o.Opty_Credit_Price__c = 0;}
        update o;
    
    } 

    public static void CheckOpportunityOverlap(list<Id> optyIds){
    	set<Id> acctIdSet = new set<Id>();

    	list<Messaging.SingleEmailMessage> theEmails = new list<Messaging.SingleEmailMessage>();
    	list<Opportunity> optys = [select id, name, AccountId, Account.Name, Start_Date__c, Term__c, End_Date__c, Owner.Id, Owner.Name,
    								LDC2__r.Name, LDC2__r.State__c 
    								from Opportunity where id in:optyIds];

    	// for initial release, send all emails to Brandon Blackburn
    	User bb = [select id, name, FirstName, LastName 
    				from User 
    				where LastName = 'Blackburn' and FirstName = 'Brandon' and EmployeeNumber = '00209201' and IsActive = true
    				limit 1];

    	// for testing, cc Ben McCann
    	list<Id> bmIds = new list<Id>();
    	User bm = [select id, name, FirstName, LastName 
    				from User 
    				where LastName = 'McCann' and FirstName = 'Ben' and EmployeeNumber = '00067294' and IsActive = true
    				limit 1];
    	bmIds.add(bm.Id);

    	for (Opportunity o:optys){
    		acctIdSet.add(o.AccountId);
    	}

    	list<Account> accts = [select id, name, (select id, name, Start_Date__c, Term__c, End_Date__c, Owner.Id, Owner.Name, LDC2__r.Name, LDC2__r.State__c from Opportunities where id not in:optyIds) from Account where id in:acctIdSet];

    	map<Id, Account> acctMap = new Map<Id, Account>(accts);

    	// for each opty, check if other optys overlap
    	for (Opportunity o:optys){
    		Account a;
    		try {
    			a = acctMap.get(o.AccountId);
			} catch (exception e){
				a = null;
			}

			if (a != null){
				list<Opportunity> aOps = a.Opportunities;
				if (aOps.size() > 0){
					list<Opportunity> oLapOps = new list<Opportunity>();
					integer lapCount = 0;
					for (Opportunity ao:aOps){
						if ((ao.Start_Date__c <= o.Start_Date__c && ao.End_Date__c > o.Start_Date__c) ||
							(ao.Start_Date__c > o.Start_Date__c && ao.Start_Date__c <= o.End_Date__c)){
							oLapOps.add(ao);
						}
					}

					if (oLapOps.size() > 0){
						Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

						String body = o.Owner.Name + ' just created an Opportunity for <a href="https://centerpointenergy.my.salesforce.com/' + o.AccountId + '">' + o.Account.Name + '</a>' +' which has existing Opportunities with overlapping terms.' + 
										'<div style="margin-top:20px;margin-bottom:10px;">New Opportunity:</div>' + 
										'<table><thead><tr><th>Opportunity Name</th><th></th><th>Start Date</th><th></th><th>End Date</th><th></th><th>Sales Rep</th><th></th><th>LDC</th><th></th><th>LDC Primary State</th><th></th></tr></thead><tbody>' +
										'<tr>'
		                                + '<td>' + o.Name + '</td><td></td>' 
		                                + '<td>' + o.Start_Date__c.format() + '</td><td></td>'
		                                + '<td>' + o.End_Date__c.format() + '</td><td></td>'
		                                + '<td>' + o.Owner.Name + '</td><td></td>' 
		                                + '<td>' + o.LDC2__r.Name + '</td><td></td>' 
		                                + '<td>' + o.LDC2__r.State__c + '</td><td></td>' 
		                                + '</tr>'
		                                + '</tbody></table>' + '<p></p><p></p>' +
										'<div style="margin-top:20px;margin-bottom:10px;">Overlapping Opportunities:</div>' + 
										+ '<table><thead><tr><th>Opportunity Name</th><th></th><th>Start Date</th><th></th><th>End Date</th><th></th><th>Sales Rep</th><th></th><th>LDC</th><th></th><th>LDC Primary State</th><th></th></tr></thead><tbody>';
						String b2 = '';
						for (Opportunity mo:oLapOps){
	                        b2 = b2 + '<tr>'
	                                + '<td>' + mo.Name + '</td><td></td>' 
	                                + '<td>' + mo.Start_Date__c.format() + '</td><td></td>'
	                                + '<td>' + mo.End_Date__c.format() + '</td><td></td>'
	                                + '<td>' + mo.Owner.Name + '</td><td></td>' 
	                                + '<td>' + mo.LDC2__r.Name + '</td><td></td>' 
	                                + '<td>' + mo.LDC2__r.State__c + '</td><td></td>' 
	                                + '</tr>';
	                    }

	                    b2 = b2 + '</tbody></table>';

	                    String hBody = body + '<p>' + b2;

	                    //mail.setTargetObjectId(o.Owner.Id);
	                    // for initial release, send all emails to Brandon Blackburn
	                    mail.setTargetObjectId(bb.Id);
	                    mail.setCcAddresses(bmIds);

	                    mail.setOrgWideEmailAddressId('0D230000000L03v'); //0D230000000L03v for prod, 0D230000000L03v for bmac
	                    mail.setSubject('Overlapping Opportunity Notice for '+ o.Account.Name);
	                    mail.setPlainTextBody(hBody);
	                    mail.setHtmlBody(hBody);
	                    mail.saveAsActivity = false;
	                    theEmails.add(mail);
					}
				}
			}
    	}

    	if (theEmails.size()>0){
	    	list<Messaging.Email> allMails = new list<Messaging.Email>();
	        for (Messaging.SingleEmailMessage mess: theEmails){
	            allMails.add(mess);
	        }
	        
	        Messaging.SendEmailResult[] results = Messaging.sendEmail(allMails);
    	}
    }
}