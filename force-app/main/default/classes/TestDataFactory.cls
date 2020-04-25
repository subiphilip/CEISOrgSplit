@isTest
public class TestDataFactory {


	public static List<Account> createAccounts(Integer numOfRecords) {
        List<Account> AccountRecords = new List<Account>();
        Id rTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
        //RecordType rType = [select Id, Name from RecordType where SobjectType = 'Account' and Name = 'Business Account'];
        
        for(Integer i=0;i<numOfRecords;i++) {
            Account a = new Account(Name='TestAccount' + i);
            a.RecordTypeId = rTypeId;
            //a.RecordTypeId = rType.Id;
            a.Type = 'Commercial Customer';
            AccountRecords.add(a);
        }
        insert AccountRecords;
            
        return AccountRecords;
    }
    
    public static List<Contact> createContacts(Integer numOfRecords) {
        
        Id rTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
        //RecordType rType = [select Id, Name from RecordType where SobjectType = 'Account' and Name = 'Business Account'];
        Account a = new Account(Name='TestAccount', RecordTypeId = rTypeId,Type = 'Commercial Customer');
        
        List<Contact> cons = new List<Contact>();
        
        for(Integer i=0;i<numOfRecords;i++) {
            Contact c = new Contact(AccountId=a.Id,LastName = 'Doe');
            cons.add(c);
        }
        
        insert cons;
            
        return cons;
    }

    public static Supply_Pool__c createSupplyPool(Id UtilName) {

        Supply_Pool__c sp = new Supply_Pool__c(Name='Test Supply Pool',Capacity_Review_Applies__c = true,Active__c=true,External_ID__c='SP123',Utility__c=UtilName);
        
        insert sp;
            
        return sp;
    }  

    public static List<Premises__c> createPremises(Integer numOfRecords) {
        
        Id rTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
        //RecordType rType = [select Id, Name from RecordType where SobjectType = 'Account' and Name = 'Business Account'];
        Id prTypeId = Schema.SObjectType.Premises__c.getRecordTypeInfosByName().get('C&I Premise Gas').getRecordTypeId();
        //RecordType prType = [select Id, Name from RecordType where SobjectType = 'Premises__c' and Name = 'C&I Premise Gas'];
        Account a = new Account(Name='TestAccount', RecordTypeId = rTypeId,Type = 'Commercial Customer');
        User u = [Select id, name, email from User where id=: UserInfo.getUserId()];

        List<Premises__c> prems = new List<Premises__c>();
        
        Account TestCES = TestDataFactory.createCESOffice();
        
        TDSP__c TestUtility = TestDataFactory.createUtility(TestCES);        
        
        for(Integer i=0;i<numOfRecords;i++) {
            Premises__c p = new Premises__c(Account__c=a.Id,RecordTypeId = prTypeId,Premise_Type__c = 'Residential',
                                            ESID__c = '123', Electric_Service_Address_Zip__c='10101-1010',
                                            Sales_Rep__c=u.Id,Account_Number__c='111111111',
                                            
                                            // DCC 20200215
                                            TDSP_Lookup__c = TestUtility.id,
                                            External_Id__c = 'P_extid'+ '-' + i + '-' + Math.random()
                                           );
            prems.add(p);
        }
        
        insert prems;
            
        return prems;
    }
    

    public static List<Premises__c> createPremisesForAccounts(Integer numOfRecords, Account a, string ESIDValue ) {
        Id prTypeId = Schema.SObjectType.Premises__c.getRecordTypeInfosByName().get('C&I Premise Gas').getRecordTypeId();
        //RecordType prType = [select Id, Name from RecordType where SobjectType = 'Premises__c' and Name = 'C&I Premise Gas'];
        
        List<Premises__c> prems = new List<Premises__c>();
        User u = [Select id, name, email from User where id=: UserInfo.getUserId()];
        Id rTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Consultant').getRecordTypeId();
        //RecordType rType = [select Id, Name from RecordType where SobjectType = 'Account' and Name = 'Consultant'];
        Account a2 = new Account(Name='TestAccount', RecordTypeId = rTypeId,Type = 'Paid Consultant');
        insert a2;
        Account TestCES = TestDataFactory.createCESOffice();
        TDSP__c TestUtility = TestDataFactory.createUtility(TestCES);

        LDC_Rate_Class__c LDCRate = new LDC_Rate_Class__c(name = 'test',LDC__c=TestUtility.id);
        insert LDCRate;

        Pipeline__c pipe = new Pipeline__c(name='Testpipe');
        insert pipe;        

        for(Integer i=0;i<numOfRecords;i++) {
            Premises__c p = new Premises__c(
                Account__c=a.Id,
                RecordTypeId = prTypeId,
                Premise_Type__c = 'Residential',
                ESID__c = '1'+ESIDValue+i, 
                External_ID__c = 'extid'+ESIDValue+'-'+i,        
                Electric_Service_Address_Zip__c='10101-1010',
                Sales_Rep__c=u.Id,
                Property_Effective_Date__c = System.today().toStartOfMonth(),
                Consultant__c = a2.id,
                Default_Delivery_Obligation__c = 'Firm',
                MDQ__c = .05,
                TDSP_Lookup__c = TestUtility.id,
                LDC_Rate_Class__c = LDCRate.id,
                Zone__c = 'North',
                Fuel_Rate__c = 'PSCO Fuel',
                Utility_Zone__c = 'A',
                Telemetry_Option__c = '2',
                Safari_Premise_Key__c = '123',
                Account_Number__c='11111111'+ESIDValue+i,
                Meter_Number__c='12121212'+ESIDValue+i,
                Pipeline_Lookup__c = pipe.id

                );
            
            prems.add(p);
        }
        
        insert prems;
            
        return prems;
    }

    public static List<Agreement__c> createAgrees(Integer numOfRecords, Account Acct) {
        
        //RecordType rType = [select Id, Name from RecordType where SobjectType = 'Account' and Name = 'Business Account'];
        Id rTypeInternalId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Internal Account').getRecordTypeId();
        //RecordType rTypeInternal = [select Id, Name from RecordType where SobjectType = 'Account' and Name = 'Internal Account'];
        //RecordType prType = [select Id, Name from RecordType where SobjectType = 'Premises__c' and Name = 'Electric Premise'];
        Account a = new Account(Name='TestAccount', RecordTypeId = rTypeInternalId,Type = 'Commercial Customer');
        Id agreeTypeId = Schema.SObjectType.Agreement__c.getRecordTypeInfosByName().get('Version 4 Enabling Agreement').getRecordTypeId();
        insert a;
        
        List<Agreement__c> agrees = new List<Agreement__c>();
        
        for(Integer i=0;i<numOfRecords;i++) {
            Agreement__c ag = new Agreement__c(Account__c=Acct.Id, Internal_Account__c=a.Id, RecordTypeId=agreeTypeId);
            agrees.add(ag);
        }
        
        insert agrees;
            
        return agrees;
    }
    
    public static List<Monthly_Usage__c> createUsages(Integer numOfRecords) {
        
        Id rTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
        //RecordType rType = [select Id, Name from RecordType where SobjectType = 'Account' and Name = 'Business Account'];
        Id prTypeId = Schema.SObjectType.Premises__c.getRecordTypeInfosByName().get('Electric Premise').getRecordTypeId();
        //RecordType prType = [select Id, Name from RecordType where SobjectType = 'Premises__c' and Name = 'Electric Premise'];
        Account a = new Account(Name='TestAccount', RecordTypeId = rTypeId,Type = 'Commercial Customer');
        Premises__c p = new Premises__c(RecordTypeId = prTypeId);
        
        List<Monthly_Usage__c> usages = new List<Monthly_Usage__c>();
        
        for(Integer i=0;i<numOfRecords;i++) {
            Monthly_Usage__c u = new Monthly_Usage__c(Premise__c=p.Id);
            usages.add(u);
        }
        
        insert usages;
            
        return usages;
    }
    
    public static List<Bill_Group__c> createBills(Integer numOfRecords) {
        
        //RecordType rType = [select Id, Name from RecordType where SobjectType = 'Account' and Name = 'CES Location'];
        Id rType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('CES Location').getRecordTypeId();
        Account a = new Account(Name='TestAccount', RecordTypeId = rType,Type = 'Residential Customer');
        Contact c = new Contact(FirstName='Mr.',AccountId=a.Id,LastName = 'Doe');
        Bill_Group_Batch__c bg = new Bill_Group_Batch__c(Name = 'testBatch',CES_Office__c=a.Id,Bill_Batch_Type__c='Calendar');
        insert a;
        insert c;
        insert bg;
        //Bill_Batch_Type_Safari_ID__c='1',
        List<Bill_Group__c> bills = new List<Bill_Group__c>();
        
        for(Integer i=0;i<numOfRecords;i++) {
            Bill_Group__c b = new Bill_Group__c(CES_Office__c=a.Id,Account__c=a.Id,Billing_Contact__c=c.Id,Last_Name__c=c.LastName,Bill_Group_Batch__c=bg.id);
            bills.add(b);
        }
        
        insert bills;
            
        return bills;
    }

	public static Account createCESOffice() {
        Account CESOfficeRecord = new Account();
        Id rTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('CES Location').getRecordTypeId();
        //RecordType rType = [select Id, Name from RecordType where SobjectType = 'Account' and Name = 'CES Location'];
        
        CESOfficeRecord.Name = 'CES Office Test' + System.now() + '-R' + System.Math.random();
        CESOfficeRecord.RecordTypeId = rTypeId;
        CESOfficeRecord.Type = 'Other';
        CESOfficeRecord.Customer_Number__c = 'HOU';
        
        CESOfficeRecord.External_ID__c = 'extid-CES Office Test-' + System.now() + '-R' + System.Math.random(); //<------------------- P3/Legacy data valiation rule exception
                    
        System.debug('in c TestDataFactory().quoteType' + CESOfficeRecord);
        
        insert CESOfficeRecord;
            
        return CESOfficeRecord;
    }

	public static TDSP__c createUtility(Account CESOffice) {
        Id rTypeId = Schema.SObjectType.TDSP__c.getRecordTypeInfosByName().get('LDC').getRecordTypeId();
        //RecordType rType = [select Id, Name from RecordType where SobjectType = 'TDSP__c' and Name = 'LDC'];
        
        TDSP__c UtilityRecord = new TDSP__c();
        UtilityRecord.Name = 'Test Utility Name';
        UtilityRecord.RecordTypeId = rTypeId;
        UtilityRecord.CES_Office__c = CESOffice.Id; //<-------------------CES Office needs to be Created
        UtilityRecord.CES_Team__c = 'Gulf Coast'; 
        UtilityRecord.Active__c = true;

        UtilityRecord.External_ID__c = 'extid-TDSP-'+ System.now() + '-R' + System.Math.random(); //<------------------- Premise23 valiation rule exception
        
        insert UtilityRecord;
            
        return UtilityRecord;
    }

    public static Trigger_Type__c createTriggerType() {
        Trigger_Type__c TriggerTypeRec = new Trigger_Type__c();
        TriggerTypeRec.Name = 'Nymex Lock';
        TriggerTypeRec.Locks_Nymex__c = true;
        TriggerTypeRec.Lock_Type__c = 'Financial';
        TriggerTypeRec.Include_Contract_Margin__c = true;

        insert TriggerTypeRec;

        return TriggerTypeRec;
    }

    
    public static Storage_Strategy__c createStorageStrategy() {
        Storage_Strategy__c StorageStrateRec = new Storage_Strategy__c();
        StorageStrateRec.Name = 'Test Strategy';
        StorageStrateRec.External_ID__c = 'StrateExtId123';
        StorageStrateRec.Type__c = 'Normal';
        StorageStrateRec.January__c = .60;
        StorageStrateRec.February__c = .60;
        StorageStrateRec.March__c = .60;
        StorageStrateRec.April__c = .60;
        StorageStrateRec.May__c = .60;
        StorageStrateRec.June__c = .60;
        StorageStrateRec.July__c = .60;
        StorageStrateRec.August__c = .60;
        StorageStrateRec.September__c = .60;
        StorageStrateRec.October__c = .60;
        StorageStrateRec.November__c = .60;
        StorageStrateRec.December__c = .60;
        StorageStrateRec.Live_ID__c = 'StrateExtId123';      
        insert StorageStrateRec;

        return StorageStrateRec;
    }


	public static List<Opportunity> createOpportunities(Integer numOfRecordsPerParent, Account Acct, TDSP__c Utility) {

        Id rTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('CES C&I Gas with Credit Request').getRecordTypeId();
        //RecordType rType = [select Id, Name from RecordType where SobjectType = 'Opportunity' and Name = 'CES C&I Gas with Credit Request'];
        
        List<Opportunity> opps = new List<Opportunity>();

        for (Integer k=0;k<numOfRecordsPerParent;k++) {
            System.debug(Utility.Id);
            System.debug(Acct.Id);
            opps.add(new Opportunity(Name=acct.Name + ' Opportunity ' + k,
                                    StageName='Identify Opportunity',
                                    Type='New Business',
                                     
                                    LDC2__c=Utility.Id,   //<-------------------Utility needs to be Created
                                    Start_Date__c=System.today().toStartOfMonth(),
                                    CloseDate=System.today().addMonths(1).toStartOfMonth(),
                                    Term__c=12,
                                    Term_Volume__c=1000,
                                    Peak_Monthly_Volume__c = 1000,
                                    Credit_Type__c = 'Deposit',
                                     
                                    AccountId=Acct.Id, //<-------------------Account needs to be Created
                                    RecordTypeId=rTypeId,
                                    OwnerId=UserInfo.getUserId(),
                                    External_ID__c = 'extid-' + k + System.now() + '-R' + System.Math.random(), //<-------------------Oppt18 valiation rule exception
                                    // BDM 03-13-20 18301: populate manager and director
                                    Manager_for_Approvals__c = UserInfo.getUserId(),
                                    Director__c = UserInfo.getUserId()
                                    ));
        }

        // Insert all opportunities for all accounts.
        insert opps;

        return opps;
    }

	public static List<Opportunity> createOpportunities2(Integer numOfRecordsPerParent, Account Acct, TDSP__c Utility) {

        Id rTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('CES C&I Gas with Credit Request').getRecordTypeId();
        //RecordType rType = [select Id, Name from RecordType where SobjectType = 'Opportunity' and Name = 'CES C&I Gas with Credit Request'];
        
        List<Opportunity> opps = new List<Opportunity>();

        for (Integer k=0;k<numOfRecordsPerParent;k++) {
            opps.add(new Opportunity(Name=acct.Name + ' Opportunity ' + k,
                                    StageName='Identify Opportunity',
                                    Type='New Business',
                                    LDC2__c=Utility.Id,   //<-------------------Utility needs to be Created
                                    Start_Date__c=System.today().toStartOfMonth(),
                                    CloseDate=System.today().addMonths(1).toStartOfMonth(),
                                    Term__c=2,
                                    Term_Volume__c=1000,
                                    Peak_Monthly_Volume__c = 1000,
                                    Credit_Type__c = 'Deposit',
                                    AccountId=Acct.Id, //<-------------------Account needs to be Created
                                    RecordTypeId=rTypeId,
                                    OwnerId=UserInfo.getUserId(),
                                    External_ID__c = 'extid-' + k + System.now() + '-R' + System.Math.random(), //<-------------------Oppt18 valiation rule exception    
                                    // BDM 03-13-20 18301: populate manager and director
                                    Manager_for_Approvals__c = UserInfo.getUserId(),
                                    Director__c = UserInfo.getUserId()
                                    ));
        }

        // Insert all opportunities for all accounts.
        insert opps;

        return opps;
    }       

	public static List<Opportunity> createChildOpportunities(Integer numOfRecordsPerParent, Opportunity Opp, TDSP__c Utility) {

        Id rTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('CES C&I Gas with Credit Request').getRecordTypeId();
        //RecordType rType = [select Id, Name from RecordType where SobjectType = 'Opportunity' and Name = 'CES C&I Gas with Credit Request'];
        
        List<Opportunity> opps = new List<Opportunity>();

        for (Integer k=0;k<numOfRecordsPerParent;k++) {
            opps.add(new Opportunity(Name=Opp.Account.Name + ' Opportunity ' + k,
                                    StageName='Identify Opportunity',
                                    Type='New Business',
                                    LDC2__c=Utility.Id,   //<-------------------Utility needs to be Created
                                    Start_Date__c=System.today().toStartOfMonth(),
                                    CloseDate=System.today().addMonths(1).toStartOfMonth(),
                                    Term__c=12,
                                    Term_Volume__c=1000,
                                    Peak_Monthly_Volume__c = 1000,
                                    Credit_Type__c = 'Deposit',
                                    Opportunity_Group__c = Opp.id,
                                    AccountId=Opp.AccountId, //<-------------------Account needs to be Created
                                    RecordTypeId=rTypeId,
                                    OwnerId=UserInfo.getUserId(),
									External_ID__c = 'extid-' + k + System.now() + '-R' + System.Math.random() //<-------------------Oppt18 valiation rule exception
                                    ));
        }

        // Insert all opportunities for all accounts.
        insert opps;

        return opps;
    }    

	public static List<Quote> createQuotes(Integer numOfRecords, Opportunity Opp, String quoteType) {
        List<Quote> QuoteRecords = new List<Quote>();
        Id rTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('Quote').getRecordTypeId();
        //RecordType rType = [select Id, Name from RecordType where SobjectType = 'Quote' and Name = 'Quote'];

        Trigger_Type__c TriggerTypeRec = [select Id, Name, Include_Contract_Margin__c, Locks_Nymex__c, Lock_Type__c from Trigger_Type__c where Name = 'Nymex Lock' limit 1 ];
        System.debug(TriggerTypeRec);
        Agreement__c agree = [select Id, Name, Account__c from Agreement__c where Account__c = :Opp.AccountId limit 1];

        CnISystemVariables__c sysVars = CnISystemVariables__c.getOrgDefaults(); 
        //Id recTypeIdContractBase = Schema.SObjectType.CESContract__c.getRecordTypeInfosByName().get('Base Pricing').getRecordTypeId();
        //Id recTypeIdContractFixed = Schema.SObjectType.CESContract__c.getRecordTypeInfosByName().get('Fixed Tier Pricing').getRecordTypeId();
        
        //Account TestCES = TestDataFactory.createCESOffice();        
        //TDSP__c TestUtility = TestDataFactory.createUtility(TestCES);
        //List<TDSP__c> util = [SELECT Id, Name FROM TDSP__c WHERE Id = : Opp.LDC2__c LIMIT 1];

        system.debug('Opp.AccountId:  ' + quoteType + ' | accountId ' + Opp.AccountId + ' | Utility LDC2 ' + Opp.LDC2__c);
        
        for(Integer i=0;i<numOfRecords;i++) {
            Quote q = new Quote();
            q.Name='TestQuote-' + quoteType + '-' + i;
            q.OpportunityId = Opp.Id;
            //q.Quote_Type__c = quoteType;
            if(quoteType == 'Base Pricing') {q.Quote_Type__c = sysVars.QuoteBasePrice__c;}
            if(quoteType == 'Fixed Price Tier') {q.Quote_Type__c = sysVars.QuoteFixedPrice__c;} // sysVars.QuoteFixedPrice__c;
            //q.Utility__r.Utility_Code__c = 'NIPSCO';
            
            // should we add a validation rule on Quote to make sure Utility.External_Id is not null like the others.
            q.Utility__c = Opp.LDC2__c;
            
            q.Term__c = Opp.Term__c;
            q.Start_Date__c = Opp.Start_Date__c;
            q.RecordTypeId = rTypeId;
            q.Days__c = 10;
            q.Trigger_Type__c = TriggerTypeRec.Id;
            q.Pricing_Method__c = 'WACOG';
            //q.Transaction_Type__c = 'Sell';
            //q.AccountId = Opp.AccountId;   // field is not writable
            q.Agreement__c = agree.Id;
            q.Sales_Rep__c = UserInfo.getUserId();
            q.Account_for_Filtering__c = Opp.AccountId;
            q.Complex_Contract_Type__c = null;
            
            q.External_ID__c = 'extid-' + i + System.now() + '-R' + System.Math.random(); //<-------------------CESC48 P3/Legacy data valiation rule exception
            
            QuoteRecords.add(q);
        }
        system.debug('QAcct: '+QuoteRecords[0].Id+' Account '+QuoteRecords[0].AccountId);
        
        insert QuoteRecords;
        system.debug('QAcct: '+QuoteRecords[0].Id+' Account '+QuoteRecords[0].AccountId);
            
        return QuoteRecords;
    }
    
	public static List<CESContract__c> createContracts(Integer numOfRecords, Quote quoteRec, String ContractType, Id AcctId, Id BaseContractId) {
        
        System.debug('TestDataFactory - insert ContractRecords - stage 190 | ' + numOfRecords);        
        System.debug('TestDataFactory - insert ContractRecords - stage 190 | ' + quoteRec);     
        System.debug('TestDataFactory - insert ContractRecords - stage 190 | ' + quoteRec.Quote_Type__c);   
        System.debug('TestDataFactory - insert ContractRecords - stage 190 | ' + quoteRec.Utility__c);
        System.debug('TestDataFactory - insert ContractRecords - stage 190 | ' + ContractType);     
        System.debug('TestDataFactory - insert ContractRecords - stage 190 | ' + AcctId);     
        System.debug('TestDataFactory - insert ContractRecords - stage 190 | ' + BaseContractId);             
        
        List<CESContract__c> ContractRecords = new List<CESContract__c>();
        List<Contract_Premise__c> ContractPremiseRecords = new List<Contract_Premise__c>();

        Id rTypeId = Schema.SObjectType.CESContract__c.getRecordTypeInfosByName().get(ContractType).getRecordTypeId();
        //RecordType rType = [select Id, Name from RecordType where SobjectType = 'CESContract__c' and Name = :ContractType];
        Division dType = [select Id, Name from Division where Name = 'C&I Sales'];
        system.debug('quoteRec: '+quoteRec.Opportunity.Account);
        for(Integer i=0;i<numOfRecords;i++) {
            CESContract__c c = new CESContract__c();
            c.Quote__c = quoteRec.Id;
            c.Account__c = AcctId;
            c.Opportunity__c = quoteRec.OpportunityId;
            c.Utility_Lookup__c = quoteRec.Utility__c;
            c.Contract_Recipient__c = 'Sales Rep';
            c.Division = dType.Id;
            c.Renewal_Type__c = 'Autorenew';
            c.Effective_Date__c = quoteRec.Start_Date__c;
            c.Start_Date_New__c = quoteRec.Start_Date__c;
            c.Term_New__c = quoteRec.Term__c;   // this needs to be changed to term__c
            c.MDQ_Unit__c = 'MMBtu';
            c.RecordTypeId = rTypeId;
            c.Delivery_Obligation__c = 'Interruptible';
            c.Parent_Contract__c = BaseContractId;
            c.Sales_Rep__c = UserInfo.getUserId();
            
            c.External_Id__c = 'CC_extid-' + i + System.now() + '-R' + System.Math.random(); //<-------------------CESC48 valiation rule exception
            

            System.debug('TestDataFactory - insert ContractRecords - stage 199 | ' + c.External_Id__c);
            
            ContractRecords.add(c);
        }
        
        System.debug('TestDataFactory - insert ContractRecords - stage 200 | ' + ContractRecords);
        
        try {
            insert ContractRecords;
        } Catch (Exception ex) {
            System.debug(ex);
        }
        
        System.debug('TestDataFactory - insert ContractRecords - stage 201');
        
        list<Premises__c> PremRecords = [Select Id from Premises__c where Account__c = :AcctId ]; 

        for(CESContract__c c :ContractRecords) {
            for (Premises__c p: PremRecords) {
                Contract_Premise__c cp = new Contract_Premise__c();
                cp.CESContract__c = c.Id;
                cp.Premise__c = p.id;
                cp.Start_Date__c = quoteRec.Start_Date__c.addMonths(-6);
                cp.End_Date__c = quoteRec.Start_Date__c.addMonths(24);
                
                System.debug('TestDataFactory - ContractPremise  Premise | ' + cp.Premise__r.External_Id__c);                 
                System.debug('TestDataFactory - ContractPremise  Contract | ' + cp.CESContract__r.External_Id__c);                 
                
                cp.External_ID__c = 'extid-' + p + System.now() + '-R' + System.Math.random(); //<-------------------CESC48 P3/Legacy data valiation rule exception
                
                ContractPremiseRecords.add(cp);
            }
            List<Line_Item__c> liList = new List<Line_Item__c>();
            for (integer i=0; i< c.Term_New__c; i++) {
                Line_Item__c li = new Line_Item__c();
                li.Contract__c = c.id;
                //mccann contract line items should not reference quote??
                //li.Quote__c = c.Quote__c;
                li.Volume__c = 1000;
                li.Forecasted_Volume__c = 1000;
                li.Contract_Month__c = quoteRec.Start_Date__c.addMonths(i);
                
                li.External_ID__c = 'extid-' + i + System.now() + '-R' + System.Math.random(); //<-------------------CESC48 P3/Legacy data valiation rule exception
                
                liList.add(li);
            }

        	System.debug('TestDataFactory - Line_Item__c | ' + liList);               
            
            insert liList;
        }

        System.debug('TestDataFactory - ContractPremiseRecords | ' + ContractPremiseRecords);   
        
        insert ContractPremiseRecords;
            
        return ContractRecords;
    }

	public static List<Line_Item__c> createLineItems(Integer numOfRecords, SObject obj, String RecType, List<Line_Item__c> objLineItems) {
		
        
        Id ContractLineItemRecordTypeId = Schema.SObjectType.Line_Item__c.getRecordTypeInfosByName().get('Contract Line Item').getRecordTypeId();
        //Recordtype ContractLineItemRecordType = [select Id from RecordType where Name = 'Contract Line Item' limit 1];
        Id QuoteLineItemRecordTypeId = Schema.SObjectType.Line_Item__c.getRecordTypeInfosByName().get('Quote Line Item').getRecordTypeId();
        //Recordtype QuoteLineItemRecordType = [select Id from RecordType where Name = 'Quote Line Item' limit 1];
        
        //objLineItems is used to pass in parent line items --- this will only be used for fixed tier contract line items
        Map<date,Id> objLIs = new Map<date,Id>();
        
        if (objLineItems != null){
        
            for (Line_Item__c oli: objLineItems) {
                objLIs.put(oli.Contract_Month__c, oli.Id);
            }
        }
        

        List<Line_Item__c> LineItemList = new List<Line_Item__c>();
        List<Line_Item_Day__c> LineItemDayList = new List<Line_Item_Day__c>();
        Id rTypeId = Schema.SObjectType.Line_Item__c.getRecordTypeInfosByName().get(RecType).getRecordTypeId();
        //RecordType rType = [select Id, Name from RecordType where SobjectType = 'Line_Item__c' and Name = :RecType];
        for(Integer i=0;i<numOfRecords;i++) {
            Line_Item__c li = new Line_Item__c();
            li.RecordTypeId = rTypeId;
            li.Contract_Month__c = System.today().addMonths(i).toStartOfMonth();
            li.Forecasted_Volume__c=1000;
            li.Actual_Volume__c=1000;
            li.Volume__c=1000;
            //li.Keepwhole_Cashout_Over_Adder__c = 100;
            //li.Parent_Line_Item__c =
            if (RecType=='Quote Line Item') {
                li.Quote__c =Obj.Id; 
                if (objLineItems != null){
                li.Parent_Line_Item__c = objLIs.get(li.Contract_Month__c);
                li.RecordTypeId = QuoteLineItemRecordTypeId;
                }
            }
            if (RecType=='Contract Line Item') {
                li.Contract__c=Obj.Id;
                if (objLineItems != null){
                li.Parent_Line_Item__c = objLIs.get(li.Contract_Month__c);
                li.RecordTypeId = ContractLineItemRecordTypeId;
                li.Keepwhole_Cashout_Over_Adder__c = 100;
                }   
            }  // used for Base, Fixed and Storage Contracts
            
            li.External_ID__c = 'LI_2019-01-01-TEST-' + System.Math.random();
            
            LineItemList.add(li);
            
        }
        insert LineItemList;
        for (Line_Item__c li: LineItemList){
            Line_Item_Day__c liday = new Line_Item_Day__c();
            liday.Line_Item__c = li.Id;
            liday.Volume__c = 1000;
            liday.Contract_Day__c = System.today().toStartOfMonth();
            LineItemDayList.add(liday);
        }
        insert LineItemDayList;

/*
        Schema.SObjectType sObjectType = records.getSObjectType();
        if (sObjectType == 'Quote') {
            
        } else if(sObjectType == 'CESContract__c') {

        }
        
*/
            
        return LineItemList;
    }
    
    //create fee type -- prerequisite for deal fee
    public static Fee_Type__c createFeeTypes(String CostGroup, String Name) {
        List<Fee_Type__c> feeTypes = new List<Fee_Type__c>();
        Division dType = [select Id, Name from Division where Name = 'C&I Sales'];

            Fee_Type__c c = new Fee_Type__c();
            c.Active__c = true;
            c.Cost_Group__c = CostGroup;
            c.Allow_User_Select__c = true;
            c.Name = Name;
        	c.External_ID__c = 'FT_Extid-' + Math.random(); 
            feeTypes.add(c);
        
        insert c;
            
        return c;
    }
    
    //deal fees - prerequisite for line item fees
    public static List<Deal_Fee__c> createDealFees(Id RecId, String FeeTypeName, string ExtId, string rtype) {
        List<Deal_Fee__c> dealFees = new List<Deal_Fee__c>();
        Division dType = [select Id, Name from Division where Name = 'C&I Sales'];
        //Fee_Type__c feeType= [SELECT Id FROM Fee_Type__c WHERE Name =:  FeeTypeName limit 1] ;
        List<Fee_Type__c> feeType= [SELECT Id FROM Fee_Type__c] ;

        for (Fee_Type__c f: feeType) {
            Deal_Fee__c c = new Deal_Fee__c();
            if (rType == 'Contract') {c.Contract__c = RecId;}
            if (rType == 'Quote') {c.Quote__c = RecId;}
            c.Flex_Option__c = 'float';
            c.Fee_Type__c = f.Id;
            c.Fee_Method__c = 'Flat';
            c.Fee_Category__c = 'Commodity Price';
            c.External_ID__c = ExtId+f;
            c.Invoice_Rollup_Category__c = 'Other';
            //c.Fee_Volume_Type__c = 'Test Fee Other';
            c.TC_Float_Desc__c = 'Test Desc';
            dealFees.add(c);
        }
        insert dealFees;
            
        return dealFees;
    }
    
    //deal fees - prerequisite for line item fees
    public static List<Deal_Fee__c> createDealFeesFix(Id RecId, String FeeTypeName, string ExtId, string rtype) {
        List<Deal_Fee__c> dealFees = new List<Deal_Fee__c>();
        Division dType = [select Id, Name from Division where Name = 'C&I Sales'];
        //Fee_Type__c feeType= [SELECT Id FROM Fee_Type__c WHERE Name =:  FeeTypeName limit 1] ;
        List<Fee_Type__c> feeType= [SELECT Id FROM Fee_Type__c] ;

        for (Fee_Type__c f: feeType) {
            Deal_Fee__c c = new Deal_Fee__c();
            if (rType == 'Contract') {c.Contract__c = RecId;}
            if (rType == 'Quote') {c.Quote__c = RecId;}
            c.Flex_Option__c = 'fix';
            c.Fee_Type__c = f.Id;
            c.Fee_Method__c = 'Flat';
            c.Fee_Category__c = 'Commodity Price';
            c.External_ID__c = ExtId+f;
            c.Invoice_Rollup_Category__c = 'Other';
            c.Fee_Volume_Type__c = 'Surrendered Storage';
            dealFees.add(c);
        }
        insert dealFees;
            
        return dealFees;
    }
    

    
    public static List<Line_Item_Fee__c> createLineItemFees (Id RecId, string rtype){
        
        List<Line_Item_Fee__c> lineItemFees = new List<Line_Item_Fee__c> ();
        List<Deal_Fee__c> dealFees = new List<Deal_Fee__c> ();
        List<Line_Item__c> lineItems = new List<Line_Item__c> ();
        List<Line_Item__c> lineItemsParent = new List<Line_Item__c> ();
         if (rType == 'Contract'){
//            CES_Contract__c c = [select Id, Name from CES_Contract__c where id = :RecId ];
            lineItems = [SELECT Id, Parent_Line_Item__c
                         	FROM Line_Item__c 
                         	WHERE Contract__c =: RecId    
            ];
            // lineItemsParent = [SELECT Id
            //              	FROM Line_Item__c 
            //              	WHERE Contract__c =: RecId    
            // ];
                        
            dealFees = [SELECT Id
                        FROM Deal_Fee__c 
                        WHERE Contract__c =: RecId
                
            ];
        }
        else if (rType == 'Quote'){
            lineItems = [SELECT Id
                         	FROM Line_Item__c 
                         	WHERE Quote__c =: RecId  
                        ];
             dealFees = [SELECT Id
                        FROM Deal_Fee__c 
                        WHERE Quote__c =: RecId
                
            ];
        }
        System.debug(dealFees);
        System.debug(lineItems);
        for(Deal_Fee__c df: dealFees){
            for (Line_Item__c li:lineItems){
                Line_Item_Fee__c lif = new Line_Item_Fee__c();
                lif.Fee__c = df.Id;
                lif.Line_Item__c = li.Id;
                
                lineItemFees.add(lif);
            }
           
        }
        

        
        insert lineItemFees;
        System.debug(lineItemFees);
        
        return lineItemFees;
        
        
    }

    public static List<Term_Extension__c> createQuoteTermExtension(Integer numOfRecords, CESContract__c contractRec, String ContractType) {
        //RecordType rType = [select Id, Name from RecordType where SobjectType = 'CESContract__c' and Name = :ContractType];
        Date startDate = System.today().toStartOfMonth();
        
        List<Term_Extension__c> termExtRecords = new List<Term_Extension__c>();
        for(Integer i=0;i<numOfRecords;i++) {
            Term_Extension__c termExtRecord = new Term_Extension__c();
            termExtRecord.Contract__c = contractRec.Id;
            termExtRecord.Quote__c = contractRec.Quote__c;
            integer addMonthsVar = (integer)contractRec.Term_New__c+1;
            //If (ContractType == 'Phase 3 Index Full Req') {startDate = System.today();} else {startDate = System.today().addMonths(addMonthsVar);}
            termExtRecord.Start_Date__c = startDate.addMonths(1);
            termExtRecord.Term__c = contractRec.Term_New__c-1;
            termExtRecord.status__c = null;
            termExtRecords.add(termExtRecord);
        }
        for(Integer i=0;i<numOfRecords;i++) {
            Term_Extension__c termExtRecord = new Term_Extension__c();
            termExtRecord.Contract__c = contractRec.Id;
            termExtRecord.Quote__c = contractRec.Quote__c;
            integer addMonthsVar = (integer)contractRec.Term_New__c+1;
            //If (ContractType == 'Phase 3 Index Full Req') {startDate = System.today();} else {startDate = System.today().addMonths(addMonthsVar);}
            termExtRecord.Start_Date__c = startDate.addMonths(1);
            termExtRecord.Term__c = contractRec.Term_New__c-1;
            termExtRecord.status__c = 'Approved';
            termExtRecords.add(termExtRecord);
        }        
        insert termExtRecords;

        return termExtRecords;
    }

/*
    public static void createDefaultData () {

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
        List<Quote> TestBaseQuotes;
        for (Opportunity o: TestOpps) {
            TestBaseQuotes = TestDataFactory.createQuotes(numOfQuotes, o, 'Base Pricing'  );
        }
        System.assertEquals((numOfOpps*numOfQuotes), TestBaseQuotes.Size()) ;
        List<Quote> TestBaseQuotesWoContracts;
        for (Opportunity o: TestOpps) {
            TestBaseQuotesWoContracts = TestDataFactory.createQuotes(numOfQuotes, o, 'Base Pricing' );
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
        // Create Base Contracts with Term Ext
        List<CESContract__c> TestBaseContractswTermExt;
        for (Quote o: TestBaseQuoteswTermExt) {
            TestBaseContractswTermExt = TestDataFactory.createContracts(numOfBaseContracts, o, 'Base Pricing', TestAccts[0].Id, null ); 
        }
        System.assertEquals((numOfQuotes*numOfBaseContracts), TestBaseContracts.Size()) ;        
        // Create Fixed Contracts
        List<CESContract__c> TestFixedContracts;
        for (Quote o: TestFixedQuotes) {
            TestFixedContracts = TestDataFactory.createContracts(numOfFixedContracts, o, 'Phase 3 Index Full Req',TestAccts[0].Id,TestBaseContracts[0].Id  );
        }
        System.assertEquals((numOfQuotes*numOfFixedContracts), TestFixedContracts.Size()) ;
        // Create Storage Contracts
        List<CESContract__c> TestStorageContracts;
        for (Quote o: TestBaseQuotes) {
            TestStorageContracts = TestDataFactory.createContracts(numOfFixedContracts, o, 'Storage',TestAccts[0].Id,TestBaseContracts[0].Id  );
        }
        System.assertEquals((numOfQuotes*numOfFixedContracts), TestStorageContracts.Size()) ;        
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
        
        List<Term_Extension__c> TestQuoteTermExtBase2;
        for (CESContract__c o: TestBaseContracts) {
            TestQuoteTermExtBase2 = TestDataFactory.createQuoteTermExtension(numOfQuoteTermExt, o ,'Base Pricing');
        }        

        // Create Term Ext for Fixed Contracts
        List<Term_Extension__c> TestQuoteTermExtFixed;
        for (CESContract__c o: TestFixedContracts) {
            TestQuoteTermExtFixed = TestDataFactory.createQuoteTermExtension(numOfQuoteTermExt, o,'Phase 3 Index Full Req' );
        }
        System.assertEquals((numOfFixedContracts*numOfQuoteTermExt*2), TestQuoteTermExtFixed.Size()) ;
        // Create Fee Type
        Fee_Type__c TestFeeTypes  = TestDataFactory.createFeeTypes('01 - NYMEX', 'NYMEX');
        // Create Deal Fees
        List<Deal_Fee__c> TestDealFees;
        for (CESContract__c o: TestBaseContracts) {
            TestDealFees = TestDataFactory.createDealFees(o.Id, 'NYMEX','Ext1','Contract');
        }
        
        List<Deal_Fee__c> TestDealFees2;
        for (Quote o: TestBaseQuotes) {
            TestDealFees2 = TestDataFactory.createDealFees(o.Id, 'NYMEX','Ext2','Quote');
        }



        List<Line_Item_Fee__c> TestLineItemFees = new List<Line_Item_Fee__c>();
        for (Line_Item__c LI: TestBaseContractLineItems) {
            Line_Item_Fee__c LIF = new Line_Item_Fee__c();
            LIF.Line_Item__c = LI.Id;
            LIF.Fee__c = TestDealFees2[0].Id;
            TestLineItemFees.add(LIF);
        }

    }
*/

public static Supply_Pool__c createSupplyPool(string supplyPoolName, string utilityId) {
    Supply_Pool__c sp = new Supply_Pool__c( name=supplyPoolName, Start_Date__c = System.today().addMonths(-12), External_ID__c='SP1234',Active__c=true,Capacity_Review_Applies__c=true,Utility__c=utilityId );
    insert sp;

    return sp;
}

public static Service_Type__c createServiceType(string serviceTypeName) {
    Service_Type__c st = new Service_Type__c(name =serviceTypeName, External_ID__c='ST1234',Active__c=true,Basis_Trigger_Setting__c='Allowed',Nymex_Trigger_Setting__c='Allowed',Phy_Prem_Trigger_Setting__c='Allowed');
    insert st;
    return st;
}

public static Pricing_Scheme__c createPricingScheme(string schemeName, Supply_Pool__c sp, Service_Type__c st) {
    // BDM 03-13-20 18339: set the financial basis group for test data creation
    Pricing_Scheme__c ps = new Pricing_Scheme__c(name = schemeName,Start_Date__c = System.today().addMonths(-12),Supply_Pool__c=sp.id,Service_Type__c=st.id,Rollover_Allowed__c=true,Rollover_Type__c='Autorenew with Refresh',Financial_Basis_Group__c='same basis');
    insert ps;
    Fee_Type__c ft = new Fee_Type__c(Name='FeeType',Active__c=true,External_ID__c='FT1234',Cost_Group__c='01 - NYMEX');
    insert ft;
    Fee_Type__c ft2 = new Fee_Type__c(Name='FeeType',Active__c=true,External_ID__c='FT12345',Cost_Group__c='04 - Margin',Allow_User_Select__c=true);
    insert ft2;
    Pricing_Fee__c pf = new Pricing_Fee__c(Pricing_Scheme__c = ps.id, Fee_Type__c=ft.id, name='PFName');
    insert pf;
    return ps;

}
public static Pricing_Scheme__c createPricingSchemeNymex(string schemeName, Supply_Pool__c sp, Service_Type__c st) {
    // BDM 03-13-20 18339: set the financial basis group for test data creation
    Pricing_Scheme__c ps = new Pricing_Scheme__c(name = schemeName,Start_Date__c = System.today().addMonths(-12),Supply_Pool__c=sp.id,Service_Type__c=st.id,Rollover_Allowed__c=true,Rollover_Type__c='Autorenew with Refresh',Financial_Basis_Group__c='same basis');
    insert ps;
    Fee_Type__c ft = new Fee_Type__c(Name='NYMEX',Active__c=true,External_ID__c='FT1234',Cost_Group__c='01 - NYMEX');
    insert ft;
    Fee_Type__c ft2 = new Fee_Type__c(Name='FeeType',Active__c=true,External_ID__c='FT12345',Cost_Group__c='04 - Margin',Allow_User_Select__c=true);
    insert ft2;
    Pricing_Fee__c pf = new Pricing_Fee__c(Pricing_Scheme__c = ps.id, Fee_Type__c=ft.id, name='PFName');
    insert pf;
    return ps;

}

public static Trigger_Type__c createTriggerType(string triggerTypeName) {
    Trigger_Type__c tt = new Trigger_Type__c(name =triggerTypeName, External_ID__c='TT1234',Lock_Type__c='Financial');
    insert tt;
    return tt;
}

public static void createCustomSettings(){
    insert new CnISystemVariables__c(
        FeeCategoryPrice__c = 'Price',
        FeeGroupBasis__c='02 - FinBasis',
        FeeGroupConsultant__c='05 - Consultant',
        FeeGroupMargin__c='04 - Margin',
        FeeGroupNymex__c='01 - NYMEX',
        FeeGroupPhyPrem__c='03 - PhyPrem',
        FeeLockablePPName__c='Additional Phys Premium',
        FlexOptionChoice__c='choice',
        FlexOptionFix__c='fix',
        FlexOptionFloat__c='float',
        PricingMethodMonthly__c='Monthly',
        PricingMethodWacog__c='WACOG',
        QuoteBasePrice__c='Base Pricing',
        QuoteFixedPrice__c='Fixed Price Tier',
        QuoteSpotPrice__c='Spot Pricing',
        QuoteStatusNew__c='New',
        // BDM 03-11-20 18338: new custom setting field
        LegacyAccountCutoffDate__c=Date.today().addDays(2)
        );

}

    public static void createIndexFutures() {

            //Get the Endur endpoint Username and Password from custom metadata. 
            C_I_References__mdt custMetaVariables = [SELECT Username__c, Password__c, Environment__c, NYMEX_INDEX__c FROM C_I_References__mdt where DeveloperName = 'EndurAPI' and Type__c = 'Credentials']; 
          
        
            List<Index_Future__c> indexFutureList = new List<Index_Future__c>();
            List<Index__c> indexList = new List<Index__c>();
            List<String> lstOfStr = new List<String>{'DTN GNG'};
                
            //List<String> lstOfStr = new List<String>{'DTN HO DELAYED','DTN Propane DELAYED','DTN CL DELAYED','DTN GNG DELAYED'};
                
            for(integer i=0;i<lstOfStr.size();i++){
                Index__c idx = new Index__c();
                idx.name = lstOfStr[i];
                idx.Index_cost__c = 0.1111;
                idx.Adder_Current_Year_Plus1__c = 0.2222;
                idx.Adder_Current_Year_PlusN__c = 0.3333;
                
                idx.Entegrate_Index_Key__c = custMetaVariables.NYMEX_INDEX__c;
                
                indexList.add(idx);
            }

			system.debug('indexList: ' + indexList);           
        
            insert indexList;
            
            // initialize with actual start date based on method
            Date startDeliveryDate = NymexNaturalGasFuturePriceTableCtrl.getFirstFutureMonthDate();
    
            startDeliveryDate = startDeliveryDate.addMonths(-24);   // Start two year back  
        
            for(integer i=0; i < 72; i++){
                Index_Future__c inf = new Index_Future__c();
                inf.name = 'NYMEX Test Index Future';
                inf.Index__c = indexList[0].id;   //; 'DTN GNG'
                
                inf.Price__c = 1.345;
                
                inf.Ask__c = 1.05;
                inf.Bid__c = 1.10;
                inf.Last__c = 1.07;            
                
                inf.Delivery_Date__c = startDeliveryDate;
                inf.Expiration_Date__c = startDeliveryDate.addMonths(1);
                
                indexFutureList.add(inf);
                
                // add one month for each delivery period out to 60 months
                startDeliveryDate = startDeliveryDate.addMonths(1);
    
                System.debug('createIndexFutures | ' + inf);            
            }
            insert indexFutureList;
    }    
    
}