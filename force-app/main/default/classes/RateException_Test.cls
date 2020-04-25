@isTest (seeAllData=true)
private class RateException_Test{
               
    static testMethod void testRateExceptionTriggerOld() {
        
        Rate__c r = new Rate__c();
        Rate_Exception__c re = new Rate_Exception__c();
        AsyncRequest__c asyncs = new AsyncRequest__c();
        
        re.Name = 'Test Rate Exception Uno';
        re.Rate__c = r.id;
        re.Start_Day__c = 'Monday';
        re.Start_Hour__c = '0';
        re.Energy_Charge_Cents__c = 0.00508;
        re.End_Hour__c = '0';
        insert re;
        
        asyncs.Type__c = 'RateExceptionChange';
        insert asyncs;   
     }

    static testMethod void testRateExceptionTriggerNew() {    
        
        Rate__c r = new Rate__c();
        Rate_Exception__c re = new Rate_Exception__c();
        AsyncRequest__c asyncs = new AsyncRequest__c();
        
        re.Name = 'Test Rate Exception Dos';
        re.Rate__c = r.id;
        re.Start_Day__c = 'Tuesday';
        re.Start_Hour__c = '0';
        re.Energy_Charge_Cents__c = 0.00509;
        re.End_Hour__c = '0';
        insert re;
        
        asyncs.Type__c = 'RateExceptionChange';
        insert asyncs; 
           
    }
}