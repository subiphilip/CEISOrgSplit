@isTest(seeAllData=true)

public class TestCreateTrueCostLogoUpdate {

static testMethod void myUnitTest() {
makeREP();


 


list<REP_Profile__c> ids=new list<REP_Profile__c> ();
        ids= [select id from rep_profile__C where Name=:'Atom Energy' limit 1];

rep_rating__C reprating = new rep_rating__C();
reprating.REP_Profile__c=ids[0].id;


account acct= new account();
acct.lastname='Benavidez';
insert acct;
list<account> acctlist=new list<account> ();
acctlist=[select id from account where lastname='Benavidez' limit 1];
reprating.author__C= acctlist[0].id;
reprating.published__c=true;
insert reprating;

makePlan();
}

//test helper classes
    static void makeREP(){
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
        insert rp;
        
        attachment A= new attachment ();  //test the logo attachment trigger
        list<REP_Profile__c> ids=new list<REP_Profile__c> ();
        ids= [select id from rep_profile__C where Name=:'Atom Energy' limit 1];
        a.parentid=ids[0].id;
        a.name='testlogo';
        a.body=blob.valueof('x');
        insert a;
    }
    
    static void makePlan(){
        list<REP_Profile__c> ids=new list<REP_Profile__c> ();
        ids= [select id from rep_profile__C where Name=:'Atom Energy' limit 1];
        plan__c p = new plan__c();
        p.name='stupid plan name';
        p.recordtypeid=[select id from recordtype where name='Electric Plan'].id;
        p.renewable_content__c=100;
        p.Contract_Length__c=12;
        p.Plan_ID__c='x';
        p.REP_Profile__c=ids[0].id;
        p.Plan_Start_Date__c=System.today();
        p.Plan_End_Date__c=System.today()+365;
    insert p;
    }

}