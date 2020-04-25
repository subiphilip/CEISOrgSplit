@RestResource(urlMapping='/RepOrders/*')

global  without sharing class  RepOrders {
    private final order__c o;
    public string ssn;
    
    public RepOrders(ApexPages.StandardController stdcontroller){ 
        
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
       string repid = req.params.get('id');
      
      system.debug('============ the repid is ============= ' + repid  );
        //List<Order__c>  o =[select id, SSN__C from order__c where REP_Profile__c = :order];
        List<Order__c>  back  = new List<Order__c>();
        
        //Plan__r.Plan_ID__c,Rate__r.Name
       List<Order__c>  o  = [SELECT Fixed_Energy_Rate__c,LastModifiedDate, Payment_Card_3_digit_code__c,Name_as_it_appears_on_Payment_Card__c,name, export__c,Authorized_Representative__c,Contract_Length__c,Critical_Care__c,Customer_Date_of_Birth__c,Customer_Email__c,Customer_Phone_Number__c,Email_Address__c,Enrollment_Type__c,ESIID_Number__c,Expected_Confirmation_Date__c,First_Name__c,InitialDateofService__c,Last_4_SSN_of_Authorized__c,Last_Name__c,Mailing_City__c,Mailing_State__c,Mailing_Street_Address__c,Mailing_Zip_Code__c,Order_Status__c,Payment_Card_Address_City__c,Payment_Card_Address_Line_1__c,Payment_Card_Address_State__c,Payment_Card_Address_Zip__c,Payment_Card_Month__c,Payment_Card_Number__c,Payment_Card_Type__c,Payment_Card_Year__c,Phone_of_Authorized__c,Service_Address__c,Service_City__c,Service_State__c,Service_Zip__c,Tax_Id__c,ssn__c ,plan__r.name,rate__r.name FROM Order__c where plan__c != null and rate__c !=null and ownerid =:repid and (order_status__c = 'New/Successfully Submitted' )   ];
  system.debug('ordre:'+o);
      
       
        if (o.size()>0) {
            
            system.debug('============ the order back is ============= ' + o );
            String JSONString = JSON.serialize(o);
             
             system.debug('============ JSON order back is str============= ' + JSONString );
             
            return JSONString;
        } 
        else {
            return null;
        }
    }

    public string getidcheck(){
        id theorder = o.id;
        return theorder;
    }
}