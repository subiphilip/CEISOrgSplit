@isTest
private class ControllerforContentItems_Test {
static testmethod void testControllerforContentItems(){
        ControllerforContentItems c = new ControllerforContentItems();
        c.whichcontent='testcontent';
        c.getmycontent();
        
        //flip the flag to get the other else statement to work
        /*TrueCostSystemVariables__c tcsv = TrueCostSystemVariables__c.getOrgDefaults();
        tcsv.Show_only_Published_content__c = !tcsv.Show_only_Published_content__c;
        update tcsv;
        //rerun the test from above     
        c.getmycontent();
        */
                    }
    }