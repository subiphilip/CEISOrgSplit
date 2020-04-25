trigger RateException on Rate_Exception__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {

	list<asyncrequest__c> asyncs = new list<asyncrequest__c>();


	if(Trigger.isDelete){
		for (integer x=0; x<trigger.old.size(); x++ ){			
			asyncs.add(new asyncrequest__c(type__c='RateExceptionChange', params__c = trigger.old[x].rate__c));
		}
	}

	if (!Trigger.isDelete){
		for (integer x=0; x<trigger.new.size(); x++ ){			
			asyncs.add(new asyncrequest__c(type__c='RateExceptionChange', params__c = trigger.new[x].rate__c));
		}
	}

	insert asyncs;
}