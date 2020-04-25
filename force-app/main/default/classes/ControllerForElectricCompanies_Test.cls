@isTest

private class ControllerForElectricCompanies_Test {

	@isTest (seeAllData=true)
    static void testReplist(){        
        ControllerForElectricCompanies.getreplist();
    }


    @isTest (seeAllData=true)
    static void testInactiveRepList(){        
        ControllerForElectricCompanies.getInactiveReplist();
    }
 }