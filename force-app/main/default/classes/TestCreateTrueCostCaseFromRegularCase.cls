/*
2/10/2012	Shane McLaughlin	Deprecated (now use EmailToTrueCostCaes Service)
*/
@isTest
private class TestCreateTrueCostCaseFromRegularCase {
/*
    static testMethod void myUnitTest() {
        Case C = new Case(); //declare a case variable that we'll insert
        TrueCost_Case__c TCC = new TrueCost_Case__c(); //declare the one we hope the trigger will create
        system.debug('Entering Data in Test Case');
          C.Entity_Type__c = 'Customer';
          C.Subject = 'Dummy Subject';
          C.Current_REP__c = 'Dummy REP1';
          C.Description = 'Blah Blah Blah Blah';
          C.SuppliedEmail = 'testemail@testemaildomain.com';
          C.SuppliedPhone = '7132076453';
          C.SuppliedName = 'Dummy Testname';
          C.Permission_to_use_comments_in_marketing__c=True;
          C.Wants_Contact__c=True;
          C.Order_Number__c = 123456789;
          C.Order_Failure_Reason__c = 'Fraud';
          C.Origin = 'Email';
          C.Priority = 'Low';
          C.Reason = 'Dummy Reason';
          C.REP_for_Switch__c = 'Reliant';
          C.Type = 'Problem';
          C.Status ='New';
             system.debug('Test case data entered');
             system.debug('Creating Test Account');
          Account TestAccount = New Account();
          //TestAccount.Personemail = 'mclaughlin_shane@hotmail.com';
          TestAccount.email__c = 'testemail@testemaildomain.com';
          //TestAccount.Personemail = 'testemail@testemaildomain.com';
          TestAccount.Name = 'Shane McLaughlin';   
          TestAccount.RecordTypeId = '01230000000njET';
          insert TestAccount;
             system.debug('Test account created');   
             system.debug('Creating test lead');   
          Lead TestLead= New Lead();
          TestLead.email = 'testemail@testemaildomain.com';
          TestLead.LastName = 'McLaughlin';
          insert TestLead;    
             system.debug('Test lead created');
                       
       test.startTest();  
          system.debug('Starting Test');
          //next, let's create the case  
          upsert C;  //the trigger should have fired by now
          test.stopTest();
          system.debug('Test complete');
          //Get the new TrueCost Case we just created
          TCC = [select id, Account__c, Lead__c, Entity_Type__c, Subject__c, Current_REP__c, Non_Account_Email__c, 
          Non_Account_Phone__c, Caller_Name__c, Order_Number__c, Order_Failure_Reason__c, Origin__c, Priority__c, Reason__c,
          REP_for_Switch__c, Type__c, Status__c, Wants_Contact__c, Permission_to_use_comments_in_marketing__c
          from TrueCost_Case__c where Order_Number__c = 123456789];
          system.debug('Ran query for New TrueCost Case, starting assertions');
//verify that all the fields got copied
          System.assertEquals(TCC.Entity_Type__c, C.Entity_Type__c);
          System.assertEquals(TCC.Subject__c, C.Subject);
          System.assertEquals(TCC.Current_REP__c, C.Current_REP__c);
          //System.assertEquals(TCC.Description__c = C.Description);
          System.assertEquals(TCC.Non_Account_Email__c, C.SuppliedEmail);
          System.assertEquals(TCC.Non_Account_Phone__c, C.SuppliedPhone);
          System.assertEquals(TCC.Caller_Name__c , C.SuppliedName);
          System.assertEquals(TCC.Order_Number__c ,C.Order_Number__c);
          System.assertEquals(TCC.Order_Failure_Reason__c, C.Order_Failure_Reason__c);
          System.assertEquals(TCC.Origin__c, C.Origin);
          System.assertEquals(TCC.Priority__c , C.Priority);
          System.assertEquals(TCC.Reason__c ,C.Reason);
          System.assertEquals(TCC.REP_for_Switch__c ,C.REP_for_Switch__c);
          System.assertEquals(TCC.Type__c, C.Type);
          System.assertEquals(TCC.Status__c, C.Status);
          System.assertEquals(TCC.Permission_to_use_comments_in_marketing__c, C.Permission_to_use_comments_in_marketing__c);
          System.assertEquals(TCC.Wants_Contact__c, C.Wants_Contact__c);
          system.debug('Assertions complete on data');
//test the account append
          List<Account> TestAccount2 = New List <Account> ();
          TestAccount2 = [select id from Account where email__c = 'testemail@testemaildomain.com' or personEmail = 'testemail@testemaildomain.com'];
          system.assertEquals(TCC.Account__c, TestAccount2[0].id);
          system.debug('Asserted Account');
//test the lead append
          List<Lead> TestLead2 = New List<Lead>();
          TestLead2 = [select id from Lead where email = 'testemail@testemaildomain.com'];
          system.assertEquals(TCC.Lead__c, TestLead2[0].id);
          system.debug('Asserted Lead');
                
}*/
}