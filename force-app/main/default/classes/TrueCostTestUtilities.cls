/*
***************Modification Log******************************************
Hemanth Chandra     02/06/2010      Converted it to test class, so we dont need test class for this class as it is utility class for code coverage (Winter 12 feature)
                                    Added utility methods getPersonAccount,getFAQ,getContent_Item
Shane McLaughlin    02/15/2012      Added owner to Account to prevent error that was happening in QA                                    
*/
@isTest
public with sharing class TrueCostTestUtilities {
    
    public static void createAlltheData(){
        createTestZipCodes();
        makeREP();
        makePlan();
        createTestPremisewithUsage();
        createTestAccountContactUserPremiseAPA();
        
    }
    
    //Person Account
    public static Account getPersonAccount(){
        RecordType accRecordType = [select id from RecordType where Name = 'Person Account'];
        Account oAccount = new Account(RecordTypeID = accRecordType.ID,Personemail = 'test@test.com',LastName = 'test');
        insert oAccount;
        return oAccount;
    }
    
    public static faq__c getFAQ(){
     faq__c faq = new faq__c(Public__c = true,category__c = 'test',top_faq__c = true);
     insert faq;
     return faq;
    }
    
    public static content_item__c getContent_Item(){        
        content_item__c item = new content_item__c(glossary_term__c = true, fee__c = true);
        insert item;
        return item;
    }
    
    public static void MakeReviews(id repId){
        //REP_Profile__c rep = getREPProfile();
        REP_Rating__c rat = new REP_Rating__c(REP_Profile__c=repId, Published__c=true, Rating__c=4, Review__c='they suck');
        REP_Rating__c rat2 = new REP_Rating__c(REP_Profile__c=repId, Published__c=true, Rating__c=3, Review__c='they really suck');

        insert rat; insert rat2;
    }

    public static rep_profile__C getREPProfile(){
        rep_profile__C rp= new rep_profile__C();
        rp.Name='Atom Energy';
        rp.Legal_Name__c='Acme Company DBA Atom Energy';
         rp.Business_Start_Date__c=system.today();
        rp.Mailing_Street_Address__c='1234 Anywhere Ave';
        rp.Mailing_City__c='Anytown';
        rp.Mailing_Zip__c='77123';
        rp.Customer_Service_Phone_Number__c='(832) 594-0111';
        rp.Fax_Number__c='(832) 594-0123';
        rp.Home_Page__c='http://www.centerpointenergy.com';
        rp.active__c = true;
        insert rp;
        return rp;
    }

    public static void makeREP(){
        getREPProfile();
        attachment A= new attachment ();  //test the logo attachment trigger
        list<REP_Profile__c> ids=new list<REP_Profile__c> ();
        ids= [select id from rep_profile__C where Name=:'Atom Energy' limit 1];
        a.parentid=ids[0].id;
        a.name='testlogo';
        a.body=blob.valueof('x');
        insert a;
    }
    
    public static void makePlan(){
        list<REP_Profile__c> ids=new list<REP_Profile__c> ();
        
        ids= [select id from rep_profile__C where Name=:'Atom Energy' limit 1];
        plan__c p = new plan__c();
        p.name='stupid plan name';
        p.recordtypeid = [select id from recordtype where name='Electric Plan'].id;
        p.renewable_content__c=100;
        p.Contract_Length__c=12;
        p.Plan_ID__c='x';
        p.REP_Profile__c=ids[0].id;
        p.active__c = true;
        p.suspended__c=false;
        p.plan_end_date__c = system.today().adddays(1000);
        p.plan_start_date__c = system.today().adddays(-50);
    insert p;
    }
    
    public static void createTestPremisewithUsage(){
        premises__c x = new premises__c();
        x.recordtypeid = [select id from recordtype where name = 'Electric Premise'].id;
        x.duns__c = 57437234;
        x.esid__c = '3987234587583';
        x.premise_type__c = 'Residential';
        x.Electric_Service_Address__c = '123 Fake street';
        x.Electric_Service_Address_Zip__c = '57473';
        x.ESI_ID_Status__c = 'Active';
        insert x;
        id xid = x.id;
        for (integer i=1;i<13;i++){
            monthly_usage__c mu = new monthly_usage__c();
            mu.premise__c=x.id;
            mu.month_number__c=i;
            mu.usage__c=100*i;
            insert mu;
        }
    }   
    
    
    public static user createTestAccountContactUserPremiseAPA(){
        account x = new account();
        x.OwnerId = TrueCostUtilities.lookuptheAdmin();
        x.LastName = 'TestUser3';
        x.FirstName = 'SuperFake3';
        x.search_zip_code__c = '77066';
        insert x;
        list<contact> y = new list<contact>();
        y = [select id from contact where accountID =: x.id];
        user u = new user();
        u.ContactId = y[0].id;
        u.Username = 'testusername3@testusernamedomain.com';
        u.lastname = x.lastname;
        u.email = u.username;
        u.alias = 'test98';
        u.CommunityNickname = 'TestUser3 SuperFake3';
        u.TimeZoneSidKey = 'Pacific/Kiritimati';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        profile p = [select id from profile  where name= 'TrueCost Customer' limit 1];
        u.ProfileID = p.id;
        u.LanguageLocaleKey = 'en_US';
        insert u;
        
        premises__c prem = new premises__c();
        prem.Square_Feet__c = 1000;
        prem.Year_of_Construction__c = 2000;
        prem.recordtypeid = [select id from recordtype where name = 'Electric Premise'].id;
        prem.duns__c = 57437234;
        prem.esid__c = '398723458517583';
        prem.premise_type__c = 'Residential';
        prem.Electric_Service_Address__c = '123 Fake street';
        prem.Electric_Service_Address_Zip__c = '57473';
        prem.ESI_ID_Status__c = 'Active';
        //place for premise tdsp and rate class?
        insert prem;
        
        APAUtilities.makeapa(x.id, prem.id);
        AccountPremiseAssociation__c APA = [select id from AccountPremiseAssociation__c where account__r.id =: x.id and premise__r.id =: prem.id][0];
        
        
        for (integer i=1;i<13;i++){
            monthly_usage__c mu = new monthly_usage__c();
            mu.estimated__c=false;
            mu.apa__c = APA.id; 
            mu.premise__c=prem.id;
            mu.month_number__c=i;
            mu.usage__c=100*i;
            insert mu;
        }
        
        APA.meter_data_request_status__c='Complete'; 
        APA.selected__c = true;
        APA.meter_data_permission__c = true;
        update APA;
        
        return u;
    }
    
     public static user createTestAccountContactUserNoPremise(){
        account x = new account();
        x.OwnerId = TrueCostUtilities.lookuptheAdmin();
        x.LastName = 'TestUser4';
        x.FirstName = 'SuperFake4';
        insert x;
        list<contact> y = new list<contact>();
        y = [select id from contact where accountID =: x.id];
        user u = new user();
        u.ContactId = y[0].id;
        u.Username = 'testusername4@testusernamedomain.com';
        u.lastname = x.lastname;
        u.email = u.username;
        u.alias = 'test99';
        u.CommunityNickname = 'TestUser4 SuperFake4';
        u.TimeZoneSidKey = 'Pacific/Kiritimati';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        profile p = [select id from profile  where name= 'TrueCost Customer' limit 1];
        u.ProfileID = p.id;
        u.LanguageLocaleKey = 'en_US';
        insert u;
        
  
        return u;
    }
    
    
    public static void createTestZipCodes(){        
        validzipcode__c x = new validzipcode__C();
        x.TDSP__c = 'CenterPoint Energy';
        x.Served_by_TrueCost__c=true;
        x.name = '00001';
        insert x;
        x.clear();                      
        x.TDSP__c = 'CenterPoint Energy';
        x.Served_by_TrueCost__c=false;
        x.name = '00002';
        insert x;
    }
    
    /*
    public static void giveInvites(user u){
        id acctid = TrueCostUtilities.getTheAccount(u.id);      
        beta_invite__C bi = new beta_invite__c();
        bi.Sender__c = acctid;
        bi.Status__c = 'New';
        insert bi;
        
    }*/
    
}