@isTest
public class PremiseUtils_Test {
    @isTest
    static void testPremiseUtilsProcess() {
        // Create All Prep Data
        Integer NumOfAccounts = 1;
        Integer numOfOpps = 1;
        Integer numOfQuotes = 1;
        Integer numOfBaseContracts = 1;
        Integer numOfFixedContracts = 1;
        Integer numOfQuoteTermExt = 1;
        Integer NumOfPremises = 1;        
        
        // ******************************* Start Creating Data ***************************       
        // Create Accounts
        List<Account> TestAccts = TestDataFactory.createAccounts(NumOfAccounts);
        System.assertEquals(NumOfAccounts, TestAccts.Size()) ;
        // Create Premises
        List<Premises__c> TestPremises = TestDataFactory.createPremisesForAccounts(NumOfPremises,TestAccts[0],'1');
        System.assertEquals(NumOfPremises, TestPremises.Size()) ;        
        // Create CES Office Accounts
        Account TestCES = TestDataFactory.createCESOffice();
        System.assertEquals(true, (TestCES != null)) ;
        // Create Trigger Type
        Trigger_Type__c TriggerTypeRec = TestDataFactory.createTriggerType();
        System.assertNotEquals(TriggerTypeRec, null) ;  
        // Create Utility
        TDSP__c TestUtility = TestDataFactory.createUtility(TestCES);
        System.assertEquals(true, (TestUtility != null)) ;
        // Create Supply Pool
        Supply_Pool__c TestSupplyPool =  TestDataFactory.createSupplyPool(TestUtility.Id);
        System.assertEquals(true, (TestSupplyPool != null)) ;
        // Create Opportunities`````
        List<Opportunity> TestOpps;
        for (Account a: TestAccts) {
            TestOpps = TestDataFactory.createOpportunities(numOfOpps, a, TestUtility );
        }
        List<Opportunity> TestChildOpps;
        for (Opportunity a: TestOpps) {
            TestChildOpps = TestDataFactory.createChildOpportunities(numOfOpps, a, TestUtility );
        }        
        System.assertEquals((numOfOpps*NumOfAccounts), TestOpps.Size()) ;
        // Create Base Quotes
        // List<Quote> TestBaseQuotes;
        // for (Opportunity o: TestOpps) {
        //     TestBaseQuotes = TestDataFactory.createQuotes(numOfQuotes, o, 'Base Pricing'  );
        // }
        // System.assertEquals((numOfOpps*numOfQuotes), TestBaseQuotes.Size()) ;
        // List<Quote> TestBaseQuotesWoContracts;
        // for (Opportunity o: TestOpps) {
        //     TestBaseQuotesWoContracts = TestDataFactory.createQuotes(numOfQuotes, o, 'Base Pricing' );
        // }
        // System.assertEquals((numOfOpps*numOfQuotes), TestBaseQuotes.Size()) ;        
        // // Create Base Quotes with Term Extensions
        // List<Quote> TestBaseQuoteswTermExt;
        // for (Opportunity o: TestOpps) {
        //     TestBaseQuoteswTermExt = TestDataFactory.createQuotes(numOfQuotes, o, 'Base Pricing' );
        // }
        // System.assertEquals((numOfOpps*numOfQuotes), TestBaseQuotes.Size()) ;        
        // // Create Fixed Quotes
        // List<Quote> TestFixedQuotes;
        // for (Opportunity o: TestOpps) {
        //     TestFixedQuotes = TestDataFactory.createQuotes(numOfQuotes, o, 'Fixed Price Tier' );
        // }
        // System.assertEquals((numOfOpps*numOfQuotes), TestFixedQuotes.Size()) ;
        // List<Quote> TestFixedQuotesWoContracts;
        // for (Opportunity o: TestOpps) {
        //     TestFixedQuotesWoContracts = TestDataFactory.createQuotes(numOfQuotes, o, 'Fixed Price Tier' );
        // }
        // System.assertEquals((numOfOpps*numOfQuotes), TestFixedQuotes.Size()) ;        
        // // Create Base Contracts
        // List<CESContract__c> TestBaseContracts;
        // for (Quote o: TestBaseQuotes) {
        //     TestBaseContracts = TestDataFactory.createContracts(numOfBaseContracts, o, 'Base Pricing', TestAccts[0].Id, null ); 
        // }
        // System.assertEquals((numOfQuotes*numOfBaseContracts), TestBaseContracts.Size()) ; 
        // // Create Base Contracts with Term Ext
        // List<CESContract__c> TestBaseContractswTermExt;
        // for (Quote o: TestBaseQuoteswTermExt) {
        //     TestBaseContractswTermExt = TestDataFactory.createContracts(numOfBaseContracts, o, 'Base Pricing', TestAccts[0].Id, null ); 
        // }
        // System.assertEquals((numOfQuotes*numOfBaseContracts), TestBaseContracts.Size()) ;        
        // // Create Fixed Contracts
        // List<CESContract__c> TestFixedContracts;
        // for (Quote o: TestFixedQuotes) {
        //     TestFixedContracts = TestDataFactory.createContracts(numOfFixedContracts, o, 'Phase 3 Index Full Req',TestAccts[0].Id,TestBaseContracts[0].Id  );
        // }
        // System.assertEquals((numOfQuotes*numOfFixedContracts), TestFixedContracts.Size()) ;
        // // Create Storage Contracts
        // List<CESContract__c> TestStorageContracts;
        // for (Quote o: TestBaseQuotes) {
        //     TestStorageContracts = TestDataFactory.createContracts(numOfFixedContracts, o, 'Storage',TestAccts[0].Id,TestBaseContracts[0].Id  );
        // }
        // System.assertEquals((numOfQuotes*numOfFixedContracts), TestStorageContracts.Size()) ;        
        // // Create Base Quote Line Items
        // List<Line_Item__c> TestBaseQuoteLineItems;
        // for (Quote o: TestBaseQuotes) {
        //     TestBaseQuoteLineItems = TestDataFactory.createLineItems(1, o, 'Quote Line Item',null );
        // }
        // System.assertEquals((numOfBaseContracts*1), TestBaseQuoteLineItems.Size()) ;                
        // // Create Base Contract Line Items
        // List<Line_Item__c> TestBaseContractLineItems;
        // for (CESContract__c o: TestBaseContracts) {
        //     TestBaseContractLineItems = TestDataFactory.createLineItems(1, o, 'Contract Line Item',null );
        // }
        // System.assertEquals((numOfBaseContracts*1), TestBaseContractLineItems.Size()) ;        
        
        // // Create Term Ext for Base Contracts
        // List<Term_Extension__c> TestQuoteTermExtBase;
        // for (CESContract__c o: TestBaseContractswTermExt) {
        //     TestQuoteTermExtBase = TestDataFactory.createQuoteTermExtension(numOfQuoteTermExt, o ,'Base Pricing');
        // }
        // System.assertEquals((numOfFixedContracts*numOfQuoteTermExt*2), TestQuoteTermExtBase.Size()) ;
        
        // List<Term_Extension__c> TestQuoteTermExtBase2;
        // for (CESContract__c o: TestBaseContracts) {
        //     TestQuoteTermExtBase2 = TestDataFactory.createQuoteTermExtension(numOfQuoteTermExt, o ,'Base Pricing');
        // }        
        
        // // Create Term Ext for Fixed Contracts
        // List<Term_Extension__c> TestQuoteTermExtFixed;
        // for (CESContract__c o: TestFixedContracts) {
        //     TestQuoteTermExtFixed = TestDataFactory.createQuoteTermExtension(numOfQuoteTermExt, o,'Phase 3 Index Full Req' );
        // }
        // System.assertEquals((numOfFixedContracts*numOfQuoteTermExt*2), TestQuoteTermExtFixed.Size()) ;
        // // Create Fee Type
        // Fee_Type__c TestFeeTypes  = TestDataFactory.createFeeTypes('01 - NYMEX', 'NYMEX');
        // // Create Deal Fees
        // List<Deal_Fee__c> TestDealFees;
        // for (CESContract__c o: TestBaseContracts) {
        //     TestDealFees = TestDataFactory.createDealFees(o.Id, 'NYMEX','Ext1','Contract');
        // }
        
        // List<Deal_Fee__c> TestDealFees2;
        // for (Quote o: TestBaseQuotes) {
        //     TestDealFees2 = TestDataFactory.createDealFees(o.Id, 'NYMEX','Ext2','Quote');
        // }
        
         
        
        // List<Line_Item_Fee__c> TestLineItemFees = new List<Line_Item_Fee__c>();
        // for (Line_Item__c LI: TestBaseContractLineItems) {
        //     Line_Item_Fee__c LIF = new Line_Item_Fee__c();
        //     LIF.Line_Item__c = LI.Id;
        //     LIF.Fee__c = TestDealFees2[0].Id;
        //     TestLineItemFees.add(LIF);
        // }
        

        // List<Contract_Premise__c> camsCPs = new List<Contract_Premise__c>();
        // for (Integer i = 0; i < 20; i++) {
        //     Contract_Premise__c cp = new Contract_Premise__c();
        //     cp.CESContract__c = TestBaseContracts[0].Id;
        //     cp.Premise__c = TestPremises[0].Id;
        //     camsCPs.add(cp);
            
        // }
        // insert camsCPs;

        Supply_Pool__c sp = TestDataFactory.createSupplyPool('SPName',TestUtility.Id);
        Service_Type__c st = TestDataFactory.createServiceType('STName');
        Pricing_Scheme__c ps = TestDataFactory.createPricingScheme('PSName', sp, st);
        Trigger_Type__c tt = TestDataFactory.createTriggerType('TTName');

        
        // ******************************* End Creating Data ***************************    
        Pipeline__c pipe = new Pipeline__c(name='Testpipe');
        insert pipe;
        List<Date_Effective_Property__c> depl = new List<Date_Effective_Property__c>();
        Date_Effective_Property__c dep = new Date_Effective_Property__c(name = 'Consultant',Property_Type__c='Premise' );
        depl.add(dep);
        dep = new Date_Effective_Property__c(name = 'Delivery Type',Property_Type__c='Premise' );
        depl.add(dep);
        dep = new Date_Effective_Property__c(name = 'MDQ',Property_Type__c='Premise' );
        depl.add(dep);
        dep = new Date_Effective_Property__c(name = 'Rate Class',Property_Type__c='Premise' );
        depl.add(dep);
        dep = new Date_Effective_Property__c(name = 'Pipeline',Property_Type__c='Premise' );
        depl.add(dep);
        dep = new Date_Effective_Property__c(name = 'Area',Property_Type__c='Premise' );
        depl.add(dep);    
        dep = new Date_Effective_Property__c(name = 'Fuel Rate',Property_Type__c='Premise' );
        depl.add(dep);     
        dep = new Date_Effective_Property__c(name = 'Zone',Property_Type__c='Premise' );
        depl.add(dep);   
        dep = new Date_Effective_Property__c(name = 'Telemetry Option',Property_Type__c='Premise' );
        depl.add(dep);                            
        insert depl;
        list<Premises__c> ciPrems = [select Id, Name,Record_Type_Name__c,CES_Office__c,Weather_Station__c,Assignment_From_Premise__c,Property_Effective_Date__c,Consultant__c,Default_Delivery_Obligation__c,MDQ__c,CES_Office_Code__c,LDC_Rate_Class__c,Pipeline_Lookup__c,Telemetry_Option__c,Utility_Zone__c,Fuel_Rate__c,Zone__c from Premises__c];

        //PremiseUtils.CIPremiseAfterInsertProcess(ciPrems);
        
        Property_Value__c pv = new Property_Value__c(Premise__c = ciPrems[0].id,Property__c =dep.id );
        insert pv;
        map<string, id> map1 = PremiseUtils.BuildPropertyMap('Premise');
        List<Property_Value__c> pvl = [select Id, Name from Property_Value__c];

            RecordType prType = [select Id, Name from RecordType where SobjectType = 'Premises__c' and Name = 'C&I Premise Gas'];
            User u = [Select id, name, email from User where id=: UserInfo.getUserId()];
             RecordType rType = [select Id, Name from RecordType where SobjectType = 'Account' and Name = 'Consultant'];
        Account a2 = new Account(Name='TestAccount', RecordTypeId = rType.Id,Type = 'Paid Consultant');
            insert a2;
        Account TestCES2 = TestDataFactory.createCESOffice();
        TDSP__c TestUtility2 = TestDataFactory.createUtility(TestCES);

        LDC_Rate_Class__c LDCRate = new LDC_Rate_Class__c(name = 'test',LDC__c=TestUtility2.id);
        LDC_Rate_Class__c LDCRate2 = new LDC_Rate_Class__c(name = 'test',LDC__c=TestUtility.id);
        
        insert LDCRate;            
        insert LDCRate2;
            Premises__c pTest = new Premises__c(
                Account__c=TestAccts[0].Id,
                RecordTypeId = prType.Id,
                Premise_Type__c = 'Residential',
                ESID__c = '56756423', 
                Electric_Service_Address_Zip__c='10101-1010',
                Sales_Rep__c=u.Id,
                Property_Effective_Date__c = System.today().toStartOfMonth(),
                Consultant__c = a2.id,
                Default_Delivery_Obligation__c = 'Firm',
                MDQ__c = .05,
                TDSP_Lookup__c = TestUtility2.id,
                LDC_Rate_Class__c = LDCRate.id,
                Zone__c = 'Central',
                Fuel_Rate__c = 'KGS T System / No Fuel',
                Utility_Zone__c = 'B',
                Telemetry_Option__c = '2',
                Pipeline_Lookup__c = pipe.id
                );

        list<Premises__c> pTestl = new list<Premises__c>();   
        pTestl.add(pTest);
        
        map<id, Premises__c> premiseMap = new map<id, Premises__c>();
        premiseMap.put(ciPrems[0].Id, ciPrems[0]);
        PremiseUtils.BuildPremisePropertyValues(ciPrems,premiseMap);
        PremiseUtils.CreatePropertyValuesForPremise(ciPrems[0],map1,pvl,pTest);
        //PremiseUtils.CIPremiseBeforeDeleteProcess(ciPrems);
        //PremiseUtils.CIPremiseBeforeUpdateProcess(pTestl,premiseMap);
        Premise_Status__c ps2 = new Premise_Status__c(Premise__c=ciPrems[0].id);
        insert ps2;
        //PremiseUtils.ApplyNowEffectiveStatus(System.Today());
        List<Premise_Status__c> ps2l = [select Id, name,Safari_Key__c,Status_Date__c from Premise_Status__c];
        PremiseUtils.ApplyClosestWeatherStation(TestPremises[0].id);
        PremiseUtils.PremiseStatusDeletionRecords(ps2l);

        
        
    }
}