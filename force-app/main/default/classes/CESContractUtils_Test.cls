@isTest(SeeAllData=false)
public with sharing class CESContractUtils_Test {

    @isTest
    static void testCESContractUtils() {
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
        
        List<Position__c> pos2 = new List<Position__c>();
        for(Integer i=0;i<1;i++) {
            Position__c pos12 = new Position__c();
            pos12.Premise__c = TestPremises[0].Id;
            pos12.Name = 'Test Position';
            pos12.CES_Contract__c = TestLockContracts[0].Id;
            pos12.Contract_Month__c = Date.newInstance(2012, 12, 12);
            pos2.add(pos12);
        }
        insert pos2;
        
        // ******************************* End Creating Data ***************************

        Test.startTest();

        //QuoteLightningData.changeVolumeSource(TestBaseQuotes[0]);  CES_Office__r.Customer_Number__c == 'HOU'
        CESContractUtils.ProcessTCActivation(TestBaseContractsCESOffice[0].Id);
        CESContractUtils.ProcessTCActivation1(TestBaseContractsCESOffice[0]);
        CESContractUtils.RottingContractRequestBulkAsync();
        CESContractUtils.getMonthName(Date.newInstance(2012, 12, 12));
        CESContractUtils.CEIPFOMNominationAlert();
        CESContractUtils.CESContractBeforeUpsertProcess(TestBaseContractsCESOffice,idConMap);
        //CESContractUtils.CESContractAfterUpdateProcess(TestBaseContractsCESOffice2,idConMap);
        //CESContractUtils.CESContractBeforeDeleteProcess(TestLegacyContracts);
        //CESContractUtils.FillPositionsWithoutSave(TestBaseContractsCESOffice[0],true);
        //CESContractUtils.CreatePosition(TestBaseContractsCESOffice[0], true, Date.newInstance(2012, 12, 12), null);
        //CESContractUtils.FillPositions(TestBaseContracts[0], true);
        CESContractUtils.ConvertMonthlyPositionsToDaily(pos);
        CESContractUtils.ConvertMonthlyPositionsToDaily1(pos);
        CESContractUtils.updatePositionDataFromContract(TestBaseContracts[0].Id);
        CESContractUtils.PositionBeforeDeleteProcess(pos);
        CESContractUtils.PositionAfterUpsertProcess(pos, idPosMap);
        CESContractUtils.PositionBeforeUpdateProcess(pos, idPosMap);
        CESContractUtils.ApplyTriggerVolumeToPositionRemainingVolume(pos, true);
        
        Test.stopTest();
    }
    
    @isTest
    static void testCESContractUtils2() {
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
        // Create Base Quotes
        List<Quote> TestBaseQuotes;
        for (Opportunity o: TestOpps) {
            TestBaseQuotes = TestDataFactory.createQuotes(numOfQuotes, o, 'Base Pricing'  );
        }
        System.assertEquals((numOfOpps*numOfQuotes), TestBaseQuotes.Size()) ;      
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
        TestCES.Customer_Number__c = 'LIVE';
        TestBaseContractsCESOffice[0].Start_Date_New__c = Date.newInstance(2012, 10, 10);
        TestBaseContractsCESOffice[0].Term_New__c = 2;
        TestBaseContractsCESOffice[0].Term_Renewal_Months__c = 2;
        update TestCES;
        update TestBaseContractsCESOffice;
        
        // ******************************* End Creating Data ***************************

        Test.startTest();
        
        CESContractUtils.ProcessTCActivation(TestBaseContractsCESOffice[0].Id);
        
        Test.stopTest();

    }

    @isTest
    static void testCESContractUtils3() {
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
        TestCES.Customer_Number__c = 'MPLS';
        TestBaseContractsCESOffice[0].Start_Date_New__c = Date.newInstance(2012, 10, 10);
        TestBaseContractsCESOffice[0].Term_New__c = 2;
        TestBaseContractsCESOffice[0].Term_Renewal_Months__c = 2;
        update TestCES;
        update TestBaseContractsCESOffice;system.debug('current_end_date__c: '+TestBaseContractsCESOffice[0].current_end_date__c);system.debug('Term_New__c: '+TestBaseContractsCESOffice[0].Term_New__c);system.debug('Start_Date_New__c: '+TestBaseContractsCESOffice[0].Start_Date_New__c);
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
        
        List<Position__c> pos2 = new List<Position__c>();
        for(Integer i=0;i<1;i++) {
            Position__c pos12 = new Position__c();
            pos12.Premise__c = TestPremises[0].Id;
            pos12.Name = 'Test Position';
            pos12.CES_Contract__c = TestLockContracts[0].Id;
            pos12.Contract_Month__c = Date.newInstance(2012, 12, 12);
            pos2.add(pos12);
        }
        insert pos2;
        
        // ******************************* End Creating Data ***************************

        Test.startTest();

        //QuoteLightningData.changeVolumeSource(TestBaseQuotes[0]);  CES_Office__r.Customer_Number__c == 'HOU'
        CESContractUtils.ProcessTCActivation(TestBaseContractsCESOffice[0].Id);
        CESContractUtils.ProcessTCActivation1(TestBaseContractsCESOffice[0]);
        CESContractUtils.RottingContractRequestBulkAsync();
        CESContractUtils.getMonthName(Date.newInstance(2012, 12, 12));
        CESContractUtils.CEIPFOMNominationAlert();
        CESContractUtils.CESContractBeforeUpsertProcess(TestBaseContractsCESOffice,idConMap);
        //CESContractUtils.CESContractAfterUpdateProcess(TestBaseContractsCESOffice2,idConMap);
        //CESContractUtils.CESContractBeforeDeleteProcess(TestLegacyContracts);
        //CESContractUtils.FillPositionsWithoutSave(TestBaseContractsCESOffice[0],true);
        //CESContractUtils.CreatePosition(TestBaseContractsCESOffice[0], true, Date.newInstance(2012, 12, 12), null);
        //CESContractUtils.FillPositions(TestBaseContracts[0], true);
        CESContractUtils.ConvertMonthlyPositionsToDaily(pos);
        CESContractUtils.ConvertMonthlyPositionsToDaily1(pos);
        CESContractUtils.updatePositionDataFromContract(TestBaseContracts[0].Id);
        CESContractUtils.PositionBeforeDeleteProcess(pos);
        CESContractUtils.PositionAfterUpsertProcess(pos, idPosMap);
        CESContractUtils.PositionBeforeUpdateProcess(pos, idPosMap);
        CESContractUtils.ApplyTriggerVolumeToPositionRemainingVolume(pos, true);
        
        Test.stopTest();

    }
    
    @isTest
    static void testCESContractUtils4() {
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
        TestCES.Customer_Number__c = '12345';
        upsert TestCES;
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
        TestCES.Customer_Number__c = 'STL';
        TestBaseContractsCESOffice[0].Start_Date_New__c = Date.newInstance(2012, 10, 10);
        TestBaseContractsCESOffice[0].Term_New__c = 2;
        TestBaseContractsCESOffice[0].Term_Renewal_Months__c = 2;
        update TestCES;
        update TestBaseContractsCESOffice;system.debug('current_end_date__c: '+TestBaseContractsCESOffice[0].current_end_date__c);system.debug('Term_New__c: '+TestBaseContractsCESOffice[0].Term_New__c);system.debug('Start_Date_New__c: '+TestBaseContractsCESOffice[0].Start_Date_New__c);
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
        
        List<Position__c> pos2 = new List<Position__c>();
        for(Integer i=0;i<1;i++) {
            Position__c pos12 = new Position__c();
            pos12.Premise__c = TestPremises[0].Id;
            pos12.Name = 'Test Position';
            pos12.CES_Contract__c = TestLockContracts[0].Id;
            pos12.Contract_Month__c = Date.newInstance(2012, 12, 12);
            pos2.add(pos12);
        }
        insert pos2;
        
        // ******************************* End Creating Data ***************************

        Test.startTest();

        //QuoteLightningData.changeVolumeSource(TestBaseQuotes[0]);  CES_Office__r.Customer_Number__c == 'HOU'
        CESContractUtils.ProcessTCActivation(TestBaseContractsCESOffice[0].Id);
        CESContractUtils.ProcessTCActivation1(TestBaseContractsCESOffice[0]);
        CESContractUtils.RottingContractRequestBulkAsync();
        CESContractUtils.getMonthName(Date.newInstance(2012, 12, 12));
        CESContractUtils.CEIPFOMNominationAlert();
        CESContractUtils.CESContractBeforeUpsertProcess(TestBaseContractsCESOffice,idConMap);
        //CESContractUtils.CESContractAfterUpdateProcess(TestBaseContractsCESOffice2,idConMap);
        //CESContractUtils.CESContractBeforeDeleteProcess(TestLegacyContracts);
        //CESContractUtils.FillPositionsWithoutSave(TestBaseContractsCESOffice[0],true);
        //CESContractUtils.CreatePosition(TestBaseContractsCESOffice[0], true, Date.newInstance(2012, 12, 12), null);
        //CESContractUtils.FillPositions(TestBaseContracts[0], true);
        CESContractUtils.ConvertMonthlyPositionsToDaily(pos);
        CESContractUtils.ConvertMonthlyPositionsToDaily1(pos);
        CESContractUtils.updatePositionDataFromContract(TestBaseContracts[0].Id);
        CESContractUtils.PositionBeforeDeleteProcess(pos);
        CESContractUtils.PositionAfterUpsertProcess(pos, idPosMap);
        CESContractUtils.PositionBeforeUpdateProcess(pos, idPosMap);
        CESContractUtils.ApplyTriggerVolumeToPositionRemainingVolume(pos, true);
        
        Test.stopTest();

    }
}