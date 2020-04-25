@isTest
private class Reminders_test {

    static testMethod void TestReminders() {
    	user CurrentUser = TrueCostTestUtilities.createTestAccountContactUserPremiseAPA();
    	system.runAs(CurrentUser){
        	Reminders r = new reminders();
        	r.prem.Current_Plan_Expiration_not_TrueCost__c = (system.today());
        	r.save();
    	}
    }
}