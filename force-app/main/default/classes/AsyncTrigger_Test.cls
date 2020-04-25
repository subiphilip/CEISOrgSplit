@isTest(seeAllData=true)

private class AsyncTrigger_Test{
               
    static testMethod void testAsyncTrigger() {        
        AsyncRequest__c ar =new  AsyncRequest__c(type__c='KeepAlive');
        insert ar;     
    }

    static testMethod void testAsyncTriggerSlow() {        
        AsyncRequest__c ar =new  AsyncRequest__c(slow__c=true ,type__c='WatchForSlowChildren');
        insert ar;     
    }

    static testMethod void testAsyncTriggerNYMEX() {        
        AsyncRequest__c ar =new  AsyncRequest__c(type__c='KickOffNymex');
        insert ar;     
    }



}