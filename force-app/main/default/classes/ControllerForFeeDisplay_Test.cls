/**
1/24/2012		Shane McLaughlin		Created
 */
@isTest

private class ControllerForFeeDisplay_Test {

    static testMethod void myUnitTest() {    
 // mccann fix by staging test data
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

        ControllerForFeeDisplay CFFD = new ControllerForFeeDisplay();
        list<rate__c>ratelist=[select id from rate__c limit 1];
        CFFD.therateid = ratelist[0].id;
        CFFD.getthefees();
        
    }
}