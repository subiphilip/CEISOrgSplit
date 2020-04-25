@RestResource(urlMapping='/OrderStatus/*')

global  without sharing class  OrderStatus {
    private final order__c o;
    public string ssn;
    
    public OrderStatus(ApexPages.StandardController stdcontroller){ 
        
    }
    
    public string getSSN(){
        order__c myorder= getTheOrder(); 
        return myorder.ssn__c;

    }
    
    public order__c getTheOrder(){
        
        order__c[] o =[select id, SSN__C from order__C where id =: o.id];
        if (o.size()>0) {
            system.debug('============ the order is ============= ' + o[0] );
            return o[0];
        } 
        else {
            return null;
        }
    }
    @HttpGet
global static String doGet() {

            return null;
    

}

@HttpPost
    global static String doPost(RestRequest req, RestResponse res) {
       string repid     = req.params.get('id');
       string orderid   = req.params.get('order');
       string status    = req.params.get('status');
      system.debug('============ the repid is ============= ' + repid  );
        //List<Order__c>  o =[select id, SSN__C from order__c where REP_Profile__c = :order];
        List<Order__c>  back  = new List<Order__c>();
        
        //Plan__r.Plan_ID__c,Rate__r.Name
       Order__c  o  = [SELECT id, Order_Status__c  FROM Order__c where name = :orderid  limit 1 ];
       o.Order_Status__c   = status;
       update o;   
    return JSON.serialize('{"successRequest" :"status changed""}');
        }

    public string getidcheck(){
        id theorder = o.id;
        return theorder;
    }
}