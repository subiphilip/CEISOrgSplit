/**
1/24/2012		Shane McLaughlin		Created
 */
@isTest

private class ControllerForFeeDisplay_Test {

    static testMethod void myUnitTest() {    	
        ControllerForFeeDisplay CFFD = new ControllerForFeeDisplay();
        list<rate__c>ratelist=[select id from rate__c limit 1];
        CFFD.therateid = ratelist[0].id;
        CFFD.getthefees();
        
    }
}