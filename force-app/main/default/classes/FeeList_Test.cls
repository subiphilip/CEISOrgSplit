@isTest
private class FeeList_Test{

    static testMethod void test(){
        Account TestCES = TestDataFactory.createCESOffice();
        //System.assertEquals(true, (TestCES != null)) ;
        TestCES.Customer_Number__c = 'HOU';
        update TestCES;
        
        TDSP__c TestUtility = TestDataFactory.createUtility(TestCES);

        List<REP_Profile__c> rep = new List<REP_Profile__c>();
        for(Integer i=0;i<1;i++) {
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
            rep.add(r);
        }
        upsert rep;
        
        Id planrType = Schema.SObjectType.Plan__c.getRecordTypeInfosByName().get('C&I Product').getRecordTypeId();
        
        List<Plan__c> plan = new List<Plan__c>();
        for(Integer i=0;i<1;i++) {
            Plan__c p = new Plan__c();
            p.RecordTypeId = planrType;
            p.Name = 'Test Plan';
            p.REP_Profile__c = rep[0].Id;
            plan.add(p);
        }
        upsert plan;
        
        List<Rate__c> rat = new List<Rate__c>();
        for(Integer i=0;i<1;i++) {
            Rate__c r = new Rate__c();
            r.Plan__c = plan[0].Id;
            r.Name = 'Test Rate5';
            r.TDSP__c = TestUtility.Id;
            r.Minimum_Annual_Usage__c = 1;
            r.Maximum_Annual_Usage__c = 1;
            r.Energy_Base_Rate_cents__c = 1;
            r.non_demand_1500_kWh_rate_cents__c = 1;
            r.non_demand_2500_kWh_rate_cents__c = 1;
            r.non_demand_3500_kWh_rate_cents__c = 1;
            r.Cancellation_Fee__c = 10.99;
            r.Confirmation_Code_Year__c = '2012';
            rat.add(r);
        }
        upsert rat;

        fee__c fee = new fee__c();
        insert fee;
        
        rate__c rate = new rate__c();
        rate = [select id, tdsp__c from rate__c limit 1];
        
        FeeList fees = new FeeList(null);
        
        fees.GetFees();
    }
}