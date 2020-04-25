@isTest(SeeAllData=false)
public with sharing class TriEagleAPI_Test {

    @isTest
    static void testTriEagleAPI() {
        // Create All Prep Data
        Integer NumOfAccounts = 1;
        Integer numOfOpps = 1;
        Integer numOfQuotes = 1;
        Integer numOfBaseContracts = 1;
        Integer numOfFixedContracts = 1;
        Integer numOfQuoteTermExt = 1;
        Integer NumOfPremises = 1;
        Integer NumOfAgreemnts = 1;

    // ******************************* Start Creating Data ***************************    
    	// Create custom settings
        TestDataFactory.createCustomSettings();
        // Create Accounts
        List<Account> TestAccts = TestDataFactory.createAccounts(NumOfAccounts);
        System.assertEquals(NumOfAccounts, TestAccts.Size()) ;
        // Create Agreement 
        List<Agreement__c> TestAgreement = TestDataFactory.createAgrees(NumOfAgreemnts, TestAccts[0]);
        // Create Premises
        List<Premises__c> TestPremises = TestDataFactory.createPremisesForAccounts(NumOfPremises,TestAccts[0],'1');
        System.assertEquals(NumOfPremises, TestPremises.Size()) ;        
        // Create CES Office Accounts
        Account TestCES = TestDataFactory.createCESOffice();
        System.assertEquals(true, (TestCES != null)) ;
        TestCES.Customer_Number__c = 'HOU';
        update TestCES;
        TestCES = [SELECT Customer_Number__c, Name, RecordTypeId, Type FROM Account WHERE Id = :TestCES.Id ];
        // Create Trigger Type
        Trigger_Type__c TriggerTypeRec = TestDataFactory.createTriggerType();
        System.assertNotEquals(TriggerTypeRec, null) ;  
        // Create StorageStrategy
        Storage_Strategy__c StorageStratRec = TestDataFactory.createStorageStrategy();
        System.assertNotEquals(StorageStratRec, null) ;          
        // Create Utility
        TDSP__c TestUtility = TestDataFactory.createUtility(TestCES);
        System.assertEquals(true, (TestUtility != null)) ;
        // Create Supply Pool
        Supply_Pool__c TestSupplyPool =  TestDataFactory.createSupplyPool(TestUtility.Id);
        System.assertEquals(true, (TestSupplyPool != null)) ;
        // Create Service Type
        Service_Type__c TestServiceType = TestDataFactory.createServiceType('testServiceType');
        // Create Opportunities
        List<Opportunity> TestOpps;
        for (Account a: TestAccts) {
            TestOpps = TestDataFactory.createOpportunities(numOfOpps, a, TestUtility );
        }
        // List<Opportunity> TestChildOpps;
        // for (Opportunity a: TestOpps) {
        //     TestChildOpps = TestDataFactory.createChildOpportunities(numOfOpps, a, TestUtility );
        // }        
        // System.assertEquals((numOfOpps*NumOfAccounts), TestOpps.Size()) ;
        // Create Base Quotes
        List<Quote> TestBaseQuotes;
        for (Opportunity o: TestOpps) {
            TestBaseQuotes = TestDataFactory.createQuotes(numOfQuotes, o, 'Base Pricing'  );
        }
        System.assertEquals((numOfOpps*numOfQuotes), TestBaseQuotes.Size()) ;
        // List<Quote> TestBaseQuotesWoContracts;
        // for (Opportunity o: TestOpps) {
        //     TestBaseQuotesWoContracts = TestDataFactory.createQuotes(numOfQuotes, o, 'Base Pricing' );
        // }
        // System.assertEquals((numOfOpps*numOfQuotes), TestBaseQuotes.Size()) ;        
        // Create Base Quotes with Term Extensions
        List<Quote> TestBaseQuoteswTermExt;
        for (Opportunity o: TestOpps) {
            TestBaseQuoteswTermExt = TestDataFactory.createQuotes(numOfQuotes, o, 'Base Pricing' );
        }
        System.assertEquals((numOfOpps*numOfQuotes), TestBaseQuotes.Size()) ;        
        // Create Fixed Quotes
        List<Quote> TestFixedQuotes;
        for (Opportunity o: TestOpps) {
            TestFixedQuotes = TestDataFactory.createQuotes(numOfQuotes, o, 'Fixed Price Tier' );
        }
        System.assertEquals((numOfOpps*numOfQuotes), TestFixedQuotes.Size()) ;
        List<Quote> TestFixedQuotesWoContracts;
        for (Opportunity o: TestOpps) {
            TestFixedQuotesWoContracts = TestDataFactory.createQuotes(numOfQuotes, o, 'Fixed Price Tier' );
        }
        System.assertEquals((numOfOpps*numOfQuotes), TestFixedQuotes.Size()) ;        
        // Create Base Contracts
        List<CESContract__c> TestBaseContracts;
        for (Quote o: TestBaseQuotes) {
            TestBaseContracts = TestDataFactory.createContracts(numOfBaseContracts, o, 'Base Pricing', TestAccts[0].Id, null ); 
        }
        System.assertEquals((numOfQuotes*numOfBaseContracts), TestBaseContracts.Size()) ; 
        // Create Base Contract with CES Office
        List<CESContract__c> TestBaseContractsCESOffice;
        
        TestBaseContractsCESOffice = TestDataFactory.createContracts(numOfBaseContracts, TestBaseQuotes[0], 'Base Pricing', TestAccts[0].Id, null ); 
        TestBaseContractsCESOffice[0].CES_Office__c = TestCES.Id;
        
        TestBaseContractsCESOffice[0].Start_Date_New__c = Date.newInstance(2012, 10, 10);
        TestBaseContractsCESOffice[0].Term_New__c = 2;
        TestBaseContractsCESOffice[0].Term_Renewal_Months__c = 2;
        
        update TestBaseContractsCESOffice;system.debug('current_end_date__c: '+TestBaseContractsCESOffice[0].current_end_date__c);system.debug('Term_New__c: '+TestBaseContractsCESOffice[0].Term_New__c);system.debug('Start_Date_New__c: '+TestBaseContractsCESOffice[0].Start_Date_New__c);
        TestBaseContractsCESOffice = [SELECT CES_Office__c, CES_Office__r.Customer_Number__c, Start_Date_New__c, Term_New__c, Term_Renewal_Months__c, Safari_Key__c FROM CESContract__c WHERE Id = :TestBaseContractsCESOffice[0].Id];
        system.debug('TestBaseContractsCESOffice[0].CES_Office__r.Customer_Number__c'+TestBaseContractsCESOffice[0].CES_Office__r.Customer_Number__c);
        // Create Base Contract with CES Office with Start Date New
        List<CESContract__c> TestBaseContractsCESOffice2;
        
        TestBaseContractsCESOffice2 = TestDataFactory.createContracts(numOfBaseContracts, TestBaseQuotes[0], 'Base Pricing', TestAccts[0].Id, null ); 
        TestBaseContractsCESOffice2[0].CES_Office__c = TestCES.Id;
        TestBaseContractsCESOffice2[0].Start_Date_New__c = Date.newInstance(2012, 11, 11);
        TestBaseContractsCESOffice2[0].Term_New__c = 2;
        TestBaseContractsCESOffice2[0].Term_Renewal_Months__c = 2;
        TestBaseContractsCESOffice2[0].Contract_Status__c = 'Submitted for SCA Approval';
        TestBaseContractsCESOffice2[0].Last_Approval_Activity__c = Datetime.now().addDays(-3);
        upsert TestBaseContractsCESOffice2;
        // Create Base Contracts with Term Ext
        List<CESContract__c> TestBaseContractswTermExt;
        for (Quote o: TestBaseQuoteswTermExt) {
            TestBaseContractswTermExt = TestDataFactory.createContracts(numOfBaseContracts, o, 'Base Pricing', TestAccts[0].Id, null ); 
        }
        System.assertEquals((numOfQuotes*numOfBaseContracts), TestBaseContracts.Size()) ;        
        // Create Fixed Contracts
        List<CESContract__c> TestFixedContracts;
        for (Quote o: TestFixedQuotes) {
            TestFixedContracts = TestDataFactory.createContracts(numOfFixedContracts, o, 'Fixed Tier Pricing',TestAccts[0].Id,TestBaseContracts[0].Id  );
        }
        
        // Create Base Quote Line Items
        List<Line_Item__c> TestBaseQuoteLineItems;
        for (Quote o: TestBaseQuotes) {
            TestBaseQuoteLineItems = TestDataFactory.createLineItems(1, o, 'Quote Line Item',null );
        }
        System.assertEquals((numOfBaseContracts*1), TestBaseQuoteLineItems.Size()) ;                
        // Create Base Contract Line Items
        List<Line_Item__c> TestBaseContractLineItems;
        for (CESContract__c o: TestBaseContracts) {
            TestBaseContractLineItems = TestDataFactory.createLineItems(1, o, 'Contract Line Item',null );
        }
        System.assertEquals((numOfBaseContracts*1), TestBaseContractLineItems.Size()) ;        
        // Create Term Ext for Base Contracts
        List<Term_Extension__c> TestQuoteTermExtBase;
        for (CESContract__c o: TestBaseContractswTermExt) {
            TestQuoteTermExtBase = TestDataFactory.createQuoteTermExtension(numOfQuoteTermExt, o ,'Base Pricing');
        }
        System.assertEquals((numOfFixedContracts*numOfQuoteTermExt*2), TestQuoteTermExtBase.Size()) ;
        // Create Term Ext for Fixed Contracts
        List<Term_Extension__c> TestQuoteTermExtFixed;
        for (CESContract__c o: TestFixedContracts) {
            TestQuoteTermExtFixed = TestDataFactory.createQuoteTermExtension(numOfQuoteTermExt, o,'Fixed Tier Pricing' );
        }
        System.assertEquals((numOfFixedContracts*numOfQuoteTermExt*2), TestQuoteTermExtFixed.Size()) ;

        system.debug('TestQuoteTermExtFixed: '+TestQuoteTermExtFixed);
        // Create Fee Type
        Fee_Type__c TestFeeTypes  = TestDataFactory.createFeeTypes('01 - NYMEX', 'NYMEX');        
        // Create Deal Fees
        List<Deal_Fee__c> TestDealFees;
        for (CESContract__c o: TestBaseContracts) {
            TestDealFees = TestDataFactory.createDealFees(o.Id, 'NYMEX', 'Ext123','Contract');
        }
        
        List<Id> TestConIds = new List<Id>(); system.debug('testBaseContracts'+TestBaseContracts);
        for (CESContract__c o: TestBaseContracts) {
            //TestConIds.add(o.Id);
        }
        
        Pricing_Scheme__c TestPricingScheme = TestDataFactory.createPricingScheme('testSchemeName', TestSupplyPool, TestServiceType);
        
        Date TestDate = Date.today();
        String jsonDatetime = JSON.serialize(TestDate);
        
        String data = '2019-05-03T00:26:01.711-02:00';
        Datetime dt = (DateTime)JSON.deserialize('"' + data + '"', DateTime.class);
        
        Date dt2 = Date.today();
        String myDtString = dt2.format();
        
        String tDate = '"startDate" : "2018-05-01"';
        
        List<Contact> TestContact = TestDataFactory.createContacts(1);
        
        Lead ld = new Lead();
        ld.LastName = 'TestLastName';
        insert ld;
        
        Campaign cam = new Campaign();
        cam.Name = 'CEIP Nominations';
        insert cam; system.debug('cam.Name: '+cam.Name);
        
        CampaignMember cm = new CampaignMember();
        cm.CampaignId = cam.Id;
        cm.Contact = TestContact[0];
        cm.Status = 'Sent';
        cm.LeadId = ld.Id;
        //cm.Campaign.Name = 'CEIP Nominations';
        insert cm;
        //select id, Contact.Id, Contact.Account.Name, Target_Account__c, Target_Account__r.Name from CampaignMember where Campaign.Name = 'CEIP Nominations'
        
        Map<Id, CESContract__c> idConMap = new Map<Id, CESContract__c>();
        for(CESContract__c con :TestBaseContractsCESOffice){
            idConMap.put(con.Id, con);
        }
        
        List<Position__c> pos = new List<Position__c>();
        for(Integer i=0;i<1;i++) {
            Position__c pos1 = new Position__c();
            pos1.Premise__c = TestPremises[0].Id;
            pos1.Name = 'Test Position';
            pos1.CES_Contract__c = TestBaseContracts[0].Id;
            pos1.Contract_Month__c = Date.newInstance(2012, 12, 12);
            pos.add(pos1);
        }
        insert pos;
        
        Map<Id, Position__c> idPosMap = new Map<Id, Position__c>();
        for(Position__c pos3 :pos){
            idPosMap.put(pos3.Id, pos3);
        }
        
        List<CESContract__c> TestLegacyContracts;
        for (Quote o: TestBaseQuotes) {
            TestLegacyContracts = TestDataFactory.createContracts(1, o, 'Index Fixed Volume', TestAccts[0].Id, null ); 
        }system.debug('TestLegacyContracts: '+TestLegacyContracts[0]);
        
        List<CESContract__c> TestLockContracts;
        for (Quote o: TestBaseQuotes) {
            TestLockContracts = TestDataFactory.createContracts(1, o, 'Lock NYMEX', TestAccts[0].Id, null ); 
        }system.debug('TestLockContracts: '+TestLockContracts[0]);
        
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
            r.Name = '12345';
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
        
        List<Order__c> ord = new List<Order__c>();
        for(Integer i=0;i<1;i++) {
            Order__c o = new Order__c();
            o.Rate__c = rat[0].Id;
            o.Contract_Length__c = 2;
            o.Confirmation_Code_Year__c = '2012';
            o.REP_Profile__c = rep[0].Id;
            //o.REP_Profile__r.Name = rep[0].Name;
            o.Confirmation_Code__c = '12345';
            o.Customer_Phone_Number__c = '7135551234';
            o.SSN__c = '654321098';
            o.reporderid__c = '';
            ord.add(o);
        }
        upsert ord;
        
        // ******************************* End Creating Data ***************************

        Test.startTest();

        TriEagleAPI te = new TriEagleAPI();
        Order__c ord1 = [SELECT Id, Name, Rate__c, Contract_Length__c, Confirmation_Code_Year__c, REP_Profile__c, REP_Profile__r.Name, Confirmation_Code__c, Customer_Phone_Number__c, SSN__c FROM Order__c WHERE Id = :ord[0].Id];
        system.debug('ord1.REP_Profile__r.Name: '+ord1.REP_Profile__r.Name);system.debug('ord[0].Id: '+ord[0].Id);
        //TriEagleAPI.TriEagleAsyncCall(ord1.Id);
        //TriEagleAPI.TriEagleOrderCheck(ord1.Id);
        TriEagleAPI.BusinessHoursDate(Date.newInstance(2012, 12, 12));
        te.placeOrder(ord);
        TriEagleAPI.isSaturday(Date.newInstance(2012, 12, 12));
        TriEagleAPI.isSunday(Date.newInstance(2012, 12, 12));
        
        
        Test.stopTest();
    }
}