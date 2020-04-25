public with sharing class ManageOrders2Controller{
    
    list<order__c> orders;
    order__c singleOrder;
    
    public ManageOrders2Controller (ApexPages.StandardSetController stdController){ 
        orders = (list<order__c>)stdController.getSelected();
    }
    
    public ManageOrders2Controller (ApexPages.StandardController stdController){ 
        singleOrder = (order__c)stdController.getRecord();
    }
    
    public PageReference ApproveSingle(){
        singleOrder.order_status__c = 'Approved Pending Confirmation';
        update singleOrder;
        return page.manageOrders2;
    }
    
    public PageReference ConfirmSingle(){
        singleOrder.order_status__c = 'Confirmed';
        update singleOrder;
        return page.manageOrders2;
    }
    
    
    public PageReference Approve(){
        for (order__c o:orders) {
            o.order_status__c = 'Approved Pending Confirmation';
        }	
        update orders;
        return page.manageOrders2;
    }
   
    public PageReference Confirm(){
        for (order__c o:orders) {
            o.order_status__c = 'Confirmed';
        }	
        update orders;
        return page.manageOrders2;
    }
    
    
}