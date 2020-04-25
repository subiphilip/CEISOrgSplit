public with sharing class OrderProcessing {

    public list<xOrder> neworders {get; set;}
    public list<xOrder> pendingConfirmation{get; set;}
    public list<xOrder> pendingDeposit{get;set;}
    public list<xOrder> confirmedOrders {get; set;}
    public Order__c Rejectedorder {get; set;}
    public Order__c Failedorder {get; set;}
    public String repprofile {get; set;}
       
//This feeds the data to the new Orders tab 
    public List<xOrder> getNewOrderList() {
        if(newOrders == null) {
            neworders = new List<xOrder>();
            for (Order__c o: [ select ID, name, InitialDateofService__c, order_status__c,  Order_Expiration_Date__c, CreatedDate, ESIID_Number__c, Parent_Account__r.Name, Parent_Account__r.IsPersonAccount,
                              Failure_Reason__c,Order_Failure_Comments__c, Order__c.Rejection_Reason__c,Order__c.Order_Rejection_Comments__c,Premise_Order_Type__c,REP_Profile__c  from Order__c where (order_status__c = 'New' or order_status__c = 'New/Successfully Submitted')]){
                repprofile= o.REP_Profile__c;
                neworders.add(new xOrder(o));
            }
        }
        return neworders;
    }
//This feeds the data to the Pending Deposit tab 
    public List<xOrder> getPendingDepositOrderList() {
        if(pendingDeposit== null) {
            pendingDeposit= new List<xOrder>();
            for (Order__c o: [ select ID, InitialDateofService__c, Order_Expiration_Date__c, name, order_status__c,  CreatedDate, ESIID_Number__c, Parent_Account__r.Name, Parent_Account__r.IsPersonAccount,
                            Failure_Reason__c,Order_Failure_Comments__c, Order__c.Rejection_Reason__c,Order__c.Order_Rejection_Comments__c,Premise_Order_Type__c,REP_Profile__c from Order__c where order_status__c = 'Approved Pending Deposit']){
                pendingDeposit.add(new xOrder(o));
            }
        }
        return pendingDeposit;
    }
    
//This feeds the data to the Pending Orders tab 
    public List<xOrder> getPendingConfirmationOrdersList() {
        if(pendingConfirmation== null) {
            pendingConfirmation= new List<xOrder>();
            for (Order__c o: [ select ID, InitialDateofService__c, Order_Expiration_Date__c, name, order_status__c,  CreatedDate, ESIID_Number__c, Parent_Account__r.Name, Parent_Account__r.IsPersonAccount,
                            Failure_Reason__c,Order_Failure_Comments__c, Order__c.Rejection_Reason__c,Order__c.Order_Rejection_Comments__c,Premise_Order_Type__c,REP_Profile__c from Order__c where order_status__c = 'Approved Pending Confirmation']){
                pendingConfirmation.add(new xOrder(o));
            }
        }
        return pendingConfirmation;
    }
//This feeds the data to the Confirmed Orders tab 
    public List<xOrder> getConfirmedOrdersList() {
        if(confirmedorders == null) {
            confirmedorders= new List<xOrder>();
            
            for (Order__c o: [ select ID, InitialDateofService__c, name, Order_Expiration_Date__c, order_status__c,  CreatedDate, ESIID_Number__c, Parent_Account__r.Name, Parent_Account__r.IsPersonAccount, 
                            Failure_Reason__c,Order_Failure_Comments__c, Order__c.Rejection_Reason__c,Order__c.Order_Rejection_Comments__c,Premise_Order_Type__c,REP_Profile__c from Order__c where order_status__c = 'Confirmed' order by lastmodifieddate limit 500]){
                confirmedorders.add(new xOrder(o));
            }
        }
        return confirmedorders;
    }
    public void OrderListResetter() {
        pendingDeposit.clear();
        neworders.clear();
        pendingconfirmation.clear();
        confirmedorders.clear();
        rejectedOrder=null;
        FailedOrder=null;
        for (Order__c o: [ select ID, InitialDateofService__c, Order_Expiration_Date__c, name, order_status__c,  CreatedDate, ESIID_Number__c, Parent_Account__r.Name, Parent_Account__r.IsPersonAccount,
                            Failure_Reason__c,Order_Failure_Comments__c, Order__c.Rejection_Reason__c,Order__c.Order_Rejection_Comments__c,Premise_Order_Type__c,REP_Profile__c
                            from Order__c 
                            where order_status__c = 'New' or order_status__c = 'New/Successfully Submitted']){
                neworders.add(new xOrder(o));
            }
        for (Order__c o: [ select ID, InitialDateofService__c, name, Order_Expiration_Date__c, order_status__c,  CreatedDate, ESIID_Number__c, Parent_Account__r.Name, Parent_Account__r.IsPersonAccount,
                            Failure_Reason__c,Order_Failure_Comments__c, Order__c.Rejection_Reason__c,Order__c.Order_Rejection_Comments__c,Premise_Order_Type__c,REP_Profile__c
                            from Order__c
                            where order_status__c = 'Approved Pending Confirmation']){
                pendingConfirmation.add(new xOrder(o));
        }
        for (Order__c o: [ select ID, InitialDateofService__c, name, Order_Expiration_Date__c, order_status__c,  CreatedDate, ESIID_Number__c, Parent_Account__r.Name, Parent_Account__r.IsPersonAccount,
                            Failure_Reason__c,Order_Failure_Comments__c, Order__c.Rejection_Reason__c,Order__c.Order_Rejection_Comments__c,Premise_Order_Type__c,REP_Profile__c
                            from Order__c
                            where order_status__c = 'Confirmed' order by lastmodifieddate limit 500]){
                confirmedorders.add(new xOrder(o));
            }    
        for (Order__c o: [ select ID, InitialDateofService__c, name, Order_Expiration_Date__c, order_status__c,  CreatedDate, ESIID_Number__c, Parent_Account__r.Name, Parent_Account__r.IsPersonAccount,
                            Failure_Reason__c,Order_Failure_Comments__c, Order__c.Rejection_Reason__c,Order__c.Order_Rejection_Comments__c,Premise_Order_Type__c,REP_Profile__c
                            from Order__c
                            where order_status__c = 'Approved Pending Deposit']){
                pendingDeposit.add(new xOrder(o));
            }   
    }   
        
//This changes the orders from new to Approved pending confirmation
   public pageReference Approve() {
        List<order__c> CheckedOrders = new list<order__c>();
        for(xOrder xOrd:GetNewOrderList()){
            if(xOrd.selected == true) {
                CheckedOrders.add(xOrd.ord);
            }
        }
        for(xOrder xOrd:GetPendingDepositOrderList()){
            if(xOrd.selected == true) {
                CheckedOrders.add(xOrd.ord);
            }
        }
        
        for(Order__c ord: CheckedOrders){    
            ord.order_status__c='Approved Pending Confirmation';
            
        }
        update CheckedOrders;
        neworders.clear();
        pendingconfirmation.clear();
        confirmedorders.clear();
        orderlistresetter();
        return null;
    }
    //changes orders from new to approved pending deposit
    public pageReference ApproveWithDeposit() {
        List<order__c> CheckedOrders = new list<order__c>();
        for(xOrder xOrd:GetNewOrderList()){
            if(xOrd.selected == true) {
                CheckedOrders.add(xOrd.ord);
            }
        }        
        for(Order__c ord: CheckedOrders){    
            ord.order_status__c='Approved Pending Deposit';            
        }
        update CheckedOrders;
        neworders.clear();
        pendingconfirmation.clear();
        confirmedorders.clear();
        orderlistresetter();
        return null;
    }
    
    
//This changes the orders from new to Confirmed
   public pageReference Renew() {
        List<order__c> CheckedOrders = new list<order__c>();
        for(xOrder xOrd:GetNewOrderList()){
            if(xOrd.selected == true) {
                CheckedOrders.add(xOrd.ord);
            }
        }
        
        for(Order__c ord: CheckedOrders){    
            ord.order_status__c='Confirmed';
            
        }
        update CheckedOrders;
        neworders.clear();
        pendingconfirmation.clear();
        confirmedorders.clear();
        orderlistresetter();  
        return null;
    }        
//This changes the orders from Approved pending confirmation to confirmed
   public pageReference Confirm() {
        List<order__c> CheckedOrders = new list<order__c>();
        for(xOrder xOrd:getPendingConfirmationOrdersList()){
            if(xOrd.selected == true) {
                CheckedOrders.add(xOrd.ord);
            }
        }
        
        for(Order__c ord: CheckedOrders){    
            ord.order_status__c='Confirmed';
            
        }
        update CheckedOrders;
        orderlistresetter();
        return null;
    }
    public pageReference DepositRequired() {
        List<order__c> CheckedOrders = new list<order__c>();
        for(xOrder xOrd:getPendingConfirmationOrdersList()){
            if(xOrd.selected == true) {
                CheckedOrders.add(xOrd.ord);
            }
        }
        for(Order__c ord: CheckedOrders){    
            ord.order_status__c='Approved Pending Deposit';            
        }
        update CheckedOrders;
        orderlistresetter();
        return null;
    }
    
    public PageReference Fail() {
        system.debug('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~fail section started');
        List<order__c> CheckedOrders = new list<order__c>();
        for(xOrder xOrd:getpendingConfirmationOrdersList()){
            if(xOrd.selected == true) {
                CheckedOrders.add(xOrd.ord);
            }
        }
        if (CheckedOrders.size()==1){
            FailedOrder=CheckedOrders[0];
            }
            else{
                if (CheckedOrders.size()>1){
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'You have to fail orders one at a time'));   
                }
            }
            return null;
    }
    public PageReference FinishFail() {
        if (failedorder.failure_reason__c == 'Other (enter comments)' && (failedorder.order_failure_comments__c == '' || failedorder.order_failure_comments__c == null) ){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'You have to add comments if you select "other" '));
            return null;
        }      
        failedOrder.order_status__c='Failed';
        update failedOrder;
        failedOrder=null;
        pendingconfirmation.clear();
        orderlistresetter();
        return null;
    }
    public PageReference CancelFail() {
        failedorder=null;
        orderlistresetter();
        return null;
        
    }
        
        
    public PageReference startReject() {
        List<order__c> CheckedOrders = new list<order__c>();
        for(xOrder xOrd:getNewOrderList()){
            if(xOrd.selected == true) {
                CheckedOrders.add(xOrd.ord);
            }
        }
        
        if (CheckedOrders.size()==1){
            RejectedOrder=CheckedOrders[0];
            }
            else{
                if (CheckedOrders.size()>1){
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'You have to reject orders one at a time'));   
                }
            }
        return null;    
    }
    public PageReference RejectFromDeposit() {
        List<order__c> CheckedOrders = new list<order__c>();
        for(xOrder xOrd:getPendingDepositOrderList()){
            if(xOrd.selected == true) {
                CheckedOrders.add(xOrd.ord);
            }
        }
        
        if (CheckedOrders.size()==1){
            RejectedOrder=CheckedOrders[0];
            }
            else{
                if (CheckedOrders.size()>1){
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'You have to reject orders one at a time'));   
                }
            }
        return null;    
    }
    
    
    
    
    public PageReference FinishReject() {
        if (rejectedOrder.rejection_reason__c == 'Other (enter comments)' && (rejectedOrder.order_rejection_comments__c == '' || rejectedOrder.order_rejection_comments__c == null) ){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'You have to add comments if you select "other" '));
            return null;
        }
        rejectedOrder.order_status__c='Rejected';
        update rejectedOrder;
        orderlistresetter();
        return null;
   }
   public PageReference CancelReject() {
        rejectedorder=null;
        orderlistresetter();
        return null;
        
    }
    
    public class xOrder {
          public Order__c ord {get; set;}
          public Boolean selected {get; set;}    
          public xOrder(Order__c x) {
            ord = x;
            selected = false;
        }
   }
    public pageReference nada(){
        
        return null;
    }    
    
}