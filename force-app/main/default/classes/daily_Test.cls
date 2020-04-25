@isTest 
private class daily_Test{
    
    static testMethod void DailyUsageTest(){
    
    Daily_Usage__c daily = new Daily_Usage__c();
    
    insert daily;
    delete daily;
    
    }
    
    }