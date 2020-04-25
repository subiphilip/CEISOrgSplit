@isTest(SeeAllData=false)
public with sharing class APAUtilities_Test {

    @isTest
    static void testAPAUtilities() {
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
        for(Quote fQuote :TestFixedQuotes){
            fQuote.Quote_Type__c = 'Fixed Price Tier';
        }upsert TestFixedQuotes;
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
        for(Line_Item__c cli :TestBaseContractLineItems){
            cli.Actual_Volume__c = 1;
        }
        upsert TestBaseContractLineItems;
        
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
        
        //String tDate = '"startDate" : "2018-05-01"';
        String tDate = '2019-10-2 11:13:10';
        
        List<Contract_Premise__c> TestConPrems = new List<Contract_Premise__c>();
        
        for(integer i=0; i<1; i++){
            Contract_Premise__c cp = new Contract_Premise__c();
            cp.CESContract__c = TestBaseContracts[0].Id;
            cp.Premise__c = TestPremises[0].Id;
            cp.Active__c = true;
            cp.Start_Date__c = TestOpps[0].Start_Date__c;
            cp.End_Date__c = System.today();
            TestConPrems.add(cp);
        }
        
        insert TestConPrems;
        
        List<Contract_Premise__c> TestConPremsFixed = new List<Contract_Premise__c>();
        
        for(integer i=0; i<1; i++){
            Contract_Premise__c cp = new Contract_Premise__c();
            cp.CESContract__c = TestFixedContracts[0].Id;
            cp.Premise__c = TestPremises[0].Id;
            cp.Active__c = true;
            cp.Start_Date__c = TestOpps[0].Start_Date__c;
            cp.End_Date__c = System.today();
            TestConPremsFixed.add(cp);
        }
        
        insert TestConPremsFixed;
        
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        // ******************************* End Creating Data ***************************

        Test.startTest();
        
        AccountPremiseAssociation__c APA = new AccountPremiseAssociation__c();
        APAUtilities.APAWrapper AA = new APAUtilities.APAWrapper(APA);
        APAUtilities.getActiveAPA(u.Id);
        APAUtilities.GetAllAPAs (u.Id);
        APAUtilities.makeapa(TestAccts[0].Id, TestPremises[0].Id);
        APAUtilities.ChangeSelectedAPA (APA.Id, TestAccts[0].Id);
        APAUtilities.GetMaxFromStringList('1.99');
        
        Test.stopTest();

    }
}