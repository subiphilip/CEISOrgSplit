@isTest
private class ControllerforContactUs_Test {
static testmethod void testSubmitCase(){
        PageReference pageRef=Page.ContactUs;
        Test.setCurrentPageReference(pageRef);
        ControllerforContactUs thecontroller=new ControllerforContactUs ();
        thecontroller.saveCase();
    }
}