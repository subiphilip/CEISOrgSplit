@isTest
private class ControllerForAddMeToCampaign_test {

    static testMethod void myUnitTest() {
    	Campaign camp = new Campaign();
    	camp.name = 'My Test Campaign';
    	insert camp;
    	
    	Lead l = new lead();
    	l.firstname = 'TestFirstName';
    	l.LastName = 'TestLastName';
    	l.Email = 'testemail@testdomain.com';
    	l.Street = '123 Test Boulevard';
    	insert l;
       	
        ControllerForAddMeToCampaign c = new ControllerForAddMeToCampaign();
        ApexPages.currentPage().getParameters().put('campaign',camp.id);
        ApexPages.currentPage().getParameters().put('lead',l.id);
        c.getCampaignName();
        c.saveCampaignMember();
        
        //Let's get the DML exception?
        c = new ControllerForAddMeToCampaign();
        ApexPages.currentPage().getParameters().put('campaign',TrueCostUtilities.lookuptheAdmin()); //valid id, but not a campaign  :)
        ApexPages.currentPage().getParameters().put('lead',l.id);
        c.getCampaignName();
        c.saveCampaignMember();
        
    }
}