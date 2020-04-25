@istest
 public class TestControllerforREPOrderProcessing {
 
     public static testMethod void setupthedata(){
         account a=new account();
         list<order__c> orderlist = new list<order__c>();
         a.lastname='DummyLastName';
         insert a;
         list<account> alist= [select id from account where lastname = 'DummyLastName' limit 1];
         a=alist[0];
         for (integer x=0; x<25; x++){
            order__c o=new order__c(Parent_account__c=a.id);
                    
            o.contract_length__c = 5;                       
            insert o;
         }
         
         
     }
     static testMethod void loadAPage(){
         PageReference pageRef=page.neworders;
         test.setCurrentPageReference(pageref);
         OrderProcessing TheController= new OrderProcessing();
         TheController.getNewOrderList();
         TheController.getPendingConfirmationOrdersList();
         TheController.getConfirmedOrdersList();
         TheController.Approve();
         TheController.Renew();
         TheController.Confirm();
         TheController.Fail();
         //TheController.FinishFail();
         TheController.Fail();
         TheController.CancelFail();
         //TheController.OrderListResetter();
         TheController.startReject();
         //TheController.FinishReject();
         TheController.startReject();
         TheController.CancelReject();
     }

}

/*
@isTest
private class TestControllerforZipCodeSearch {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        string ST='77066';
        PageReference pageRef=Page.CustomerServiceZipCodeCheck;
        Test.setCurrentPageReference(pageRef);
        ControllerforZipCodeSearch myPageCon=new ControllerforZipCodeSearch();
        mypageCon.getSearchText();
        myPageCon.setSearchText(ST);
        myPageCon.search();
        myPageCon.getResult();
        myPageCon.navigate();
        
        
        
    }
}*/