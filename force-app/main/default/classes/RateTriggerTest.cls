@isTest
private class RateTriggerTest {
	
	@isTest (seeAllData=true) static void test_method_one() {
		// stage data
		Id planrType = Schema.SObjectType.Plan__c.getRecordTypeInfosByName().get('C&I Product').getRecordTypeId();
        Id utilrType = Schema.SObjectType.TDSP__c.getRecordTypeInfosByName().get('TDSP').getRecordTypeId();
        Id raterType = Schema.SObjectType.Rate__c.getRecordTypeInfosByName().get('Residential').getRecordTypeId();
		Id raterType2 = Schema.SObjectType.Rate__c.getRecordTypeInfosByName().get('Residential TOU').getRecordTypeId();
        
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
        rt.RecordTypeId = raterType;
        insert rt;
        
        // Implement test code
		rate__c r = [select Energy_base_rate_cents__c, id, recordtypeid from rate__c where record_type_name__c = 'Residential'][0]	;
		//id newRecordTypeid = [select id from recordtype where name = 'Residential TOU'].id;
		//r.recordtypeid = newRecordTypeid;
		r.RecordTypeId = raterType2;
        update r;
		r.Energy_Base_Rate_cents__c = r.Energy_Base_Rate_cents__c+.004;
		update r;
	}


	
}