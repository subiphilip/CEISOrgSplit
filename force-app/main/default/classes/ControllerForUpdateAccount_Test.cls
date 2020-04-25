/*
2/2/2012    Shane McLaughlin    I commented out this whole test class because it was throwing errors in PRD and blocking other change sets from deploying.

*/

@isTest
private class ControllerForUpdateAccount_Test{
    
    static testMethod void test(){
      
        User oUser = TrueCostTestUtilities.createTestAccountContactUserPremiseAPA();        
        ControllerForUpdateAccount controller = new ControllerForUpdateAccount();
        System.Runas(oUser){
            controller = new ControllerForUpdateAccount();
            controller.user.Street = null;
            controller.user.City = null;
            controller.user.PostalCode = null;
            controller.user.State = null;
            controller.getUser();
            controller.save();
            controller.cancel();            
        }
        
        controller.getIsEdit();
        controller.edit();
        controller.changePassword();
        controller.Back();        
        Contact c = new Contact();
        c.LastName = 'TestContact';
        insert c;      
      
  }
 }