/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class ControllerForPlanDetails_Test {
    
    static testMethod void myUnitTest() {

        REP_Profile__c r = new REP_Profile__c();
        r.Name = 'Test Rep';
        r.Legal_Name__c = 'Test Legal';
        r.Business_Start_Date__c = Date.newInstance(2012, 12, 12);
        r.Star_ranking__c = .01;
        r.PUC_Scorecard_Ranking__c = '3';
        r.Deposit_Instructions__c = 'deposit';
        r.Maximum_Switch_Days__c = 1;
        r.Soonest_Switch_Date__c = 1;
        r.Soonest_Move_Date__c = 1;
        r.Mailing_Street_Address__c = '123 st';
        r.Mailing_City__c = 'Houston';
        r.Mailing_Zip__c = '77042';
        r.Customer_Service_Phone_Number__c = '7135551234';
        r.Home_Page__c = 'www.url.com';
        r.Order_Issues_Email__c = 'email@test.com';
        r.Order_Issues_Phone__c = '2818320884';
        r.General_Issues_Email__c = 'email2@test.com';
        r.General_Issues_Phone__c = '8325551234';
        r.Escalated_Issues_Email__c = 'email3@test.com';
        r.Escalated_Issues_Phone__c = '7135554321';
        insert r;
        
        Id planrType = Schema.SObjectType.Plan__c.getRecordTypeInfosByName().get('C&I Product').getRecordTypeId();
        //Id utilrType = Schema.SObjectType.TDSP__c.getRecordTypeInfosByName().get('TDSP').getRecordTypeId();
        
        TDSP__c testUtility = new TDSP__c(Name='Test Util 1');
        insert testUtility;
        
        Plan__c p = new Plan__c();
        //p.RecordTypeId = utilrType;
        p.RecordTypeId = planrType;
        p.Name = 'Test Plan';
        p.REP_Profile__c = r.Id;
        insert p;
        
        Rate__c rt = new Rate__c();
        rt.Plan__c = p.Id;
        rt.Name = 'Test Rate5';
        rt.TDSP__c = testUtility.Id;
        rt.Minimum_Annual_Usage__c = 1;
        rt.Maximum_Annual_Usage__c = 1;
        rt.Energy_Base_Rate_cents__c = 1;
        rt.non_demand_1500_kWh_rate_cents__c = 1;
        rt.non_demand_2500_kWh_rate_cents__c = 1;
        rt.non_demand_3500_kWh_rate_cents__c = 1;
        rt.Cancellation_Fee__c = 10.99;
        rt.Confirmation_Code_Year__c = '2012';
        insert rt;   


        user usero = TrueCostTestUtilities.createTestAccountContactUserPremiseAPA();
        list<Rate__C> rates = [select id from Rate__c limit 1];
        
        system.runAs(usero){
            PageReference pageRef=page.planDetails;        
            pageRef.getParameters().put('id', rates[0].id);
            test.setCurrentPageReference(pageref);
            ControllerForPlanDetails TheController= new ControllerForPlanDetails();
            /*
            TheController.getDetailPlan();
            //TheController.NavBacktoShopping();
            test.setCurrentPageReference(pageref);
            TheController.getdetailscostlist();
            TheController.getMonthNames();
            TheController.hasOrderinProgress();
            TheController.getEstimateforSelectedMonth();
            TheController.getMeterDataStatus();
           // TheController.getHowCalculated();
            TheController.PickAProfile();
            TheController.requestUsageEstimate();
            TheController.grantMeterDataPermission();
            //TheController.NavtoenrollmentScreen();
            //TheController.CloseLightBox();
            */
            
        }
    }
}