@isTest 
public class CESCommonObjectControllerTest {
    static testMethod void test1() {
        Account acc = new Account();
        acc.Name = 'Test';
        // BDM specify record type otherwise not recognized
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
        insert acc;
        
        // BDM CESOffice and Bill Group Batch record creation required for legacy bill groups
        Account office = new Account(Name='CES-Illinios', Customer_Number__c='LIVE', AccountNumber='1', Location_Code__c='IL');
        office.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('CES Location').getRecordTypeId();
        insert office;
        
        Bill_Group_Batch__c bgb = new Bill_Group_Batch__c(Name='Test Billing Batch', CES_Office__c=office.id, Bill_Batch_Type__c='Calendar', Active__c=true);
        insert bgb;
        
        Bill_Group__c bg = new Bill_Group__c();
        bg.Account__c = acc.Id;
        // BDM field population required for legacy field validations
        bg.First_Name__c = 'Test';
        bg.Last_Name__c = 'Billing';
        bg.Phone__c = '713-207-1234';
        bg.Fax__c = '713-207-3456';
        bg.Email__c = 'billtest@test.com';
        bg.CES_Office__c = office.Id;
        bg.Bill_Group_Batch__c = bgb.id;
        insert bg;
        
        Profile p = [
            SELECT Id, Name
            FROM Profile
            WHERE Name ='MyCES Consultant'
            LIMIT 1
        ];
        
        
		System.debug('CESCommonObjectControllerTest | getCommonAccountRecordList as admin');        
        // as admin
        List<Account> testAccountsAsAdmin = CESCommonObjectController.getCommonAccountRecordList();
        
        // Setup test data
        // Create a unique UserName
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile myTestUserProfile = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User myTestUser = new User(Alias = 'standt', Email='standarduser@testorg.com',
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = myTestUserProfile.Id,
                            TimeZoneSidKey='America/Los_Angeles',
                            UserName=uniqueUserName);
        


        System.runAs(myTestUser) {
            // as user
            // 
			System.debug('CESCommonObjectControllerTest | getCommonAccountRecordList as Standard User');
            List<Account> testAccountsAsUser = CESCommonObjectController.getCommonAccountRecordList();
        }
        
        CESCommonObjectController.getCommonMonthMap ();
        CESCommonObjectController.getCommonMonthList ();
        CESCommonObjectController.getCommonBillingGroupList(acc.Id);
        //CESCommonObjectController.isMyCESProfileValid(p);
        CESCommonObjectController.getAccountRecordName(acc.Id);
        CESCommonObjectController.getCommonBillingGroupListByReferencedDate(acc.Id);
        
        CESCommonObjectController.getBillGroupRecordName(bg.Id);
        CESCommonObjectController.logRecentlyViewedBillGroupForReference(bg.Id);
        
		boolean isMyCESProfileValid;
	
		isMyCESProfileValid = CESCommonObjectController.isMyCESProfileValid(p);

        p = [
            SELECT Id, Name
            FROM Profile
            WHERE Name ='The System Q219'
            LIMIT 1
        ];		
		
        isMyCESProfileValid = CESCommonObjectController.isMyCESProfileValid(p);        
        
        List<Profile> profileList = CESCommonObjectController.getMyCESProfileList();
     
        // testing CommonAccountRecordList for actual contact
        // 
        //AccountContactRelation acr = new AccountContactRelation();
        //acr.Accountid = acc.id;
        //acr.Contactid = c.id;
        //acr.IsActive = true;
        //insert acr;


        // Setup test data
        //
        // Create Group for Trigger Logic
		Group testGroup = new Group(Name='CES Community All Members');
        
        // Create a unique UserName
        String uniqueUserName2 = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // Adding Contact
        // 
        Contact c = new Contact();
            c.firstname = 'test';
            c.lastname = uniqueUserName2;
            c.phone = '(612) 321-5081';
            c.fax = '(612) 321-5081';
            c.email = 'standarduser@testorg.com';
            c.accountid = acc.id;
		insert c;
         
System.debug('CESCommonObjectControllerTest | myTestContact : ' + c);
        
        // This code runs as the system user
        Profile myCommunityUserProfile2 = [SELECT Id FROM Profile WHERE Name='MyCES ExtFA'];
        
        User myTestUser2 = new User(Alias = 'standt', Email='standarduser@testorg.com',
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = myCommunityUserProfile2.Id,
                            TimeZoneSidKey='America/Los_Angeles',
                            UserName=uniqueUserName2, ContactId=c.Id);        
        insert myTestUser2;
System.debug('CESCommonObjectControllerTest | myTestUser2 : ' + myTestUser2);
        
        System.runAs(myTestUser2) {
            // as user
            // 
			System.debug('CESCommonObjectControllerTest | getCommonAccountRecordList as myCES User');            
            List<Account> testAccountsAsUser = CESCommonObjectController.getCommonAccountRecordList();
        }
        
    }
    
    @IsTest(SeeAllData=true)
    static void testWithAllDataAccess() {
        
        // Setup test data
        // Create a unique UserName
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile myTestUserProfile = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User myTestUser = new User(Alias = 'standt', Email='standarduser@testorg.com',
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = myTestUserProfile.Id,
                            TimeZoneSidKey='America/Los_Angeles',
                            UserName=uniqueUserName);
        
		insert myTestUser;

System.debug('CESCommonObjectControllerTest - testWithAllDataAccess | myTestUser: ' + myTestUser);            
        
        Account acc = new Account();
        acc.Name = 'Test Account-ChatterAPI';
        // BDM specify record type otherwise not recognized
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
        
        acc.OwnerId = myTestUser.Id;
        insert acc;        
        
System.debug('CESCommonObjectControllerTest - testWithAllDataAccess | Account: ' + acc);        
        
        CESCommonObjectController.chatterCommunityActivity('myCES', 'monthly usage review', acc.Id, '98d');
        //CESCommonObjectController.chatterCommunityActivity(null, 'monthly usage review', acc.Id, '98d');        
        //CESCommonObjectController.chatterCommunityActivity('myCES', 'monthly usage review', acc.Id, null);
		//CESCommonObjectController.chatterCommunityActivity('myCES', 'monthly usage review', null, null);       
		//CESCommonObjectController.chatterCommunityActivity(null, 'monthly usage review', null, null);        
		//CESCommonObjectController.chatterCommunityActivity('myCES', null, null, null);                       
    }
}