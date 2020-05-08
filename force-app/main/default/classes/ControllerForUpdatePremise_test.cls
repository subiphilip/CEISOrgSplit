@isTest
private class ControllerForUpdatePremise_test{
    private testmethod static void test(){
        /*Account acc = [select id from Account where isPersonAccount = true limit 1];
        Contact cont = [select id from Contact where accountID = :acc.ID limit 1];
        User oUser = [select contactId from User where contactId =: cont.ID limit 1];
        
        String searchESID = 'sic12345';
        Premises__c premise = new Premises__c (ESID__c = searchESID);
        insert premise;
        
        AccountPremiseAssociation__c apa = new AccountPremiseAssociation__c(Premise__c = premise.ID,account__c = acc.ID);
        insert apa;*/
             
        user oUser = TrueCostTestUtilities.createTestAccountContactUserPremiseAPA();
             
        System.Runas(oUser){
            ControllerForUpdatePremise controller = new ControllerForUpdatePremise();
            //controller.updatePremise();
            /*
            controller.MakeEstimate();
            controller.Back();
            controller.BacktoShop();
            controller.getthepremise();
            */
        }
    }
}