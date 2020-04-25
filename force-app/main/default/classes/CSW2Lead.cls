public with sharing class CSW2Lead {
    public CSR_Transaction__c CSRT;
    
    public void setStart(){
       CSRT=new CSR_Transaction__c();
       CSRT.Start__c=System.Now();
       }
     
    public lead l {get; set;}
    public CSW2Lead(){
        l=new Lead();
        }
    public list<Lead> Existing = new list<lead>();
    public PageReference email() {
            CSRT.Stop__c=System.Now();
            CSRT.Outcome__c='Email';
           //CSRT.CSR__c=l.CSR_Name__c;
            l.LastName='None';
            //l.SFGA__Web_Source__c='Customer Service W2L';
            insert l;
            insert CSRT;
            PageReference acctPage = Page.CustomerServiceZipCodeCheck;
            acctPage.setRedirect(true);
            return acctPage;
        }
     public PageReference call() {
            CSRT.Stop__c=System.Now();
            CSRT.Outcome__c='Phone Transfer';
            //CSRT.CSR__c=l.CSR_Name__c;
            l.LastName='None';
            //l.SFGA__Web_Source__c='Customer Service W2L';
            insert l;
            insert CSRT;
            PageReference acctPage = Page.CustomerServiceZipCodeCheck;
            acctPage.setRedirect(true);
            return acctPage;
        }
     public PageReference decline() {
            CSRT.Stop__c=System.Now();
            CSRT.Outcome__c='Decline';
            //CSRT.CSR__c=l.CSR_Name__c;
            insert CSRT;
            PageReference acctPage = Page.CustomerServiceZipCodeCheck;
            acctPage.setRedirect(true);
            return acctPage;
     }
}