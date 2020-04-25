@isTest
private class FeeList_Test{

    static testMethod void test(){
    
        fee__c fee = new fee__c();
        insert fee;
        
        rate__c rate = new rate__c();
        rate = [select id, tdsp__c from rate__c limit 1];
        
        FeeList fees = new FeeList(null);
        
        fees.GetFees();
    }
}