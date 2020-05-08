@isTest(SeeAllData=true)

private class TrueCostUtilities_Test {
    
    static testMethod void test(){
        // mccann fix, stage data
        Id planrType = Schema.SObjectType.Plan__c.getRecordTypeInfosByName().get('C&I Product').getRecordTypeId();
        Id utilrType = Schema.SObjectType.TDSP__c.getRecordTypeInfosByName().get('TDSP').getRecordTypeId();
        
        REP_Profile__c rp = new REP_Profile__c();
        rp.Name = 'Test Rep';
        rp.Legal_Name__c = 'Test Legal';
        rp.Business_Start_Date__c = Date.newInstance(2012, 12, 12);
        rp.Star_ranking__c = .01;
        rp.PUC_Scorecard_Ranking__c = '3';
        rp.Deposit_Instructions__c = 'deposit';
        rp.Maximum_Switch_Days__c = 1;
        rp.Soonest_Switch_Date__c = 1;
        rp.Soonest_Move_Date__c = 1;
        rp.Mailing_Street_Address__c = '123 st';
        rp.Mailing_City__c = 'Houston';
        rp.Mailing_Zip__c = '77042';
        rp.Customer_Service_Phone_Number__c = '7135551234';
        rp.Home_Page__c = 'www.url.com';
        rp.Order_Issues_Email__c = 'email@test.com';
        rp.Order_Issues_Phone__c = '2818320884';
        rp.General_Issues_Email__c = 'email2@test.com';
        rp.General_Issues_Phone__c = '8325551234';
        rp.Escalated_Issues_Email__c = 'email3@test.com';
        rp.Escalated_Issues_Phone__c = '7135554321';
        insert rp;
        
        TDSP__c util = new TDSP__c();
        util.Name = 'CenterPoint TestClass';
        util.RecordTypeId = utilrType;
        insert util;

        Plan__c p = new Plan__c();
        p.RecordTypeId = planrType;
        p.Name = 'Test Plan';
        p.REP_Profile__c = rp.Id;
        insert p;
        
        Rate__c rt = new Rate__c();
        rt.Plan__c = p.Id;
        rt.Name = 'Test Rate5';
        rt.TDSP__c = util.Id;
        rt.Minimum_Annual_Usage__c = 1;
        rt.Maximum_Annual_Usage__c = 1;
        rt.Energy_Base_Rate_cents__c = 1;
        rt.non_demand_1500_kWh_rate_cents__c = 1;
        rt.non_demand_2500_kWh_rate_cents__c = 1;
        rt.non_demand_3500_kWh_rate_cents__c = 1;
        rt.Cancellation_Fee__c = 10.99;
        rt.Confirmation_Code_Year__c = '2012';
        
        Load_Curve__c lc = new Load_Curve__c();
        lc.Name = 'CenterPoint TestClass';
        lc.January__c = 978;
        lc.February__c = 807;
        lc.March__c = 743;
        lc.April__c = 831;
        lc.May__c = 981;
        lc.June__c = 1232;
        lc.July__c = 1573;
        lc.August__c = 1676;
        lc.September__c = 1616;
        lc.October__c = 1374;
        lc.November__c = 1048;
        lc.December__c = 860;
        lc.Usage_Profile__c = '1000 kWh';
        lc.TDSP__c = util.Id;
        insert lc;
        
        
        TrueCostUtilities.CalculateCommission(6);
        TrueCostUtilities.showOnlyPublished();
        TrueCostUtilities.getRatingWrapperForREP();
        list <REP_Profile__c> REPlist = [select id from REP_Profile__c ];
        for (REP_Profile__c r:REPlist){
            TrueCostUtilities.getRatingWrapperForREP(r.id);
        }
    
        list<TDSP__c> tdsplist = [select id from TDSP__c where name!=:'None' and name like '%centerpoint%'];
        for (TDSP__c tdsp:tdsplist){
            //TrueCostUtilities.pullAverageUsage(tdsp.id, '500 kWh');
            //TrueCostUtilities.pullAverageUsage(tdsp.id, '1000 kWh');
            //TrueCostUtilities.pullAverageUsage(tdsp.id, '2000 kWh');
        }
        TrueCostUtilities.pullGuestMonthlyUsage();
        user usero = TrueCostTestUtilities.createTestAccountContactUserPremiseAPA();
        TrueCostUtilities.getTheAPAs(usero.id);
    
    //test saved plans
    /*
        Rate__c rate = [select id from rate__c limit 1];
        AccountPremiseAssociation__c APA =  [select id from AccountPremiseAssociation__c where id =: TrueCostUtilities.getTheAPAs(usero.id) ];
        TrueCostUtilities.SavePlan(  APA    , rate.id);
        list<saved_plan__c> sps = TrueCostUtilities.fetchSavedPlans(APA);
        TrueCostUtilities.UnsavePlan(APA    , rate.id);
      */  
        
    }
    
    
}