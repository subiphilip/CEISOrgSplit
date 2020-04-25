@isTest
private class UHITRequestTriggerTest {
	
	@isTest static void test_method_one() {
		UHITRequest__c UHR= new UHITRequest__c();
		insert UHR;
		UHR.StatusCode__c='7';
		update UHR;
	}
	
	@isTest static void test_method_two() {
		// Implement test code
	}
	
}