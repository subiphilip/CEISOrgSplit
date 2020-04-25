/*
1/24/2012   Barry Glasco    Created to pull Ssn's for rep order page
*/ 

@RestResource(urlMapping='/Orders/*')

global  without sharing class  RestOrders {
    private final order__c o;
    public string ssn;
    
    public RestOrders(ApexPages.StandardController stdcontroller){ 
        
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
       // string ordera = req.params.get('id');
       string ordera = userInfo.getUserId();
        //string back = '';
        system.debug('============ the repid is ============= ' + ordera  );
        //List<Order__c>  o =[select id, SSN__C from order__c where REP_Profile__c = :order];
        List<Order__c>  back  = new List<Order__c>();
        
        //Plan__r.Plan_ID__c,Rate__r.Name
       //List<Order__c>  o  = [SELECT parent_Account__c,export__c,Authorized_Representative__c,Bill_Doc_Credited__c,Commission__c,Contract_Length__c,Critical_Care__c,Customer_Date_of_Birth__c,Customer_Email__c,Customer_IP_Address__c,Customer_Phone_Number__c,Email_Address__c,Enrollment_Type__c,ESIID_Number__c,Expected_Confirmation_Date__c,First_Name__c,InitialDateofService__c,Last_4_SSN_of_Authorized__c,Last_Name__c,Mailing_City__c,Mailing_State__c,Mailing_Street_Address__c,Mailing_Zip_Code__c,Order_Confirmed_Date__c,Order_Expiration_Date__c,Order_Status__c,Name_as_it_appears_on_Payment_Card__c,Payment_Card_Address_City__c,Payment_Card_Address_Line_1__c,Payment_Card_Address_State__c,Payment_Card_Address_Zip__c,Payment_Card_Month__c,Payment_Card_Number__c,Payment_Card_3_digit_code__c ,Payment_Card_Type__c,Payment_Card_Year__c,Phone_of_Authorized__c,Plan_Expiration__c,Service_Address__c,Service_City__c,Service_State__c,Service_Zip__c,Tax_Id__c,ssn__c,Fixed_Energy_Rate__c,LastModifiedDate FROM Order__c where ownerid =:ordera and (order_status__c = 'New/Successfully Submitted' or order_status__c = 'New' or order_status__c = 'Pending Information' or order_status__c = 'Pending Switch Hold' or order_status__c = 'Approved Pending Deposit' or order_status__c = 'Approved Pending Confirmation'or order_status__c = 'Confirmed')   ];
       List<Order__c>  o  = [SELECT parent_Account__c,export__c,Authorized_Representative__c,Bill_Doc_Credited__c,Commission__c,Contract_Length__c,Critical_Care__c,Customer_Date_of_Birth__c,Customer_Email__c,Customer_IP_Address__c,Customer_Phone_Number__c,Email_Address__c,Enrollment_Type__c,ESIID_Number__c,Expected_Confirmation_Date__c,First_Name__c,InitialDateofService__c,Last_4_SSN_of_Authorized__c,Last_Name__c,Mailing_City__c,Mailing_State__c,Mailing_Street_Address__c,Mailing_Zip_Code__c,Order_Confirmed_Date__c,Order_Expiration_Date__c,Order_Status__c,Name_as_it_appears_on_Payment_Card__c,Payment_Card_Address_City__c,Payment_Card_Address_Line_1__c,Payment_Card_Address_State__c,Payment_Card_Address_Zip__c,Payment_Card_Month__c,Payment_Card_Number__c,Payment_Card_3_digit_code__c ,Payment_Card_Type__c,Payment_Card_Year__c,Phone_of_Authorized__c,Plan_Expiration__c,Service_Address__c,Service_City__c,Service_State__c,Service_Zip__c,Tax_Id__c,ssn__c,Fixed_Energy_Rate__c,LastModifiedDate FROM Order__c where ownerid =:ordera and (order_status__c = 'New/Successfully Submitted' )   ];
 
       for (Order__c ord : o)
       {
        Order__c order = new Order__c();
order.parent_Account__c    =           ord.parent_Account__c;
order.export__c         =       ord.ssn__c ;
order.Authorized_Representative__c   =   ord.Authorized_Representative__c;
order.Bill_Doc_Credited__c      =    ord.Bill_Doc_Credited__c;
//order.Commission__c            =   ord.Commission__c;
order.Contract_Length__c    =       ord.Contract_Length__c;
order.Critical_Care__c          =    ord.Critical_Care__c;
order.Customer_Date_of_Birth__c =       ord.Customer_Date_of_Birth__c;
order.Customer_Email__c          =   ord.Customer_Email__c;
order.Customer_IP_Address__c    =       ord.Customer_IP_Address__c;
order.Customer_Phone_Number__c  =       ord.Customer_Phone_Number__c;
order.Email_Address__c           =   ord.Email_Address__c;
//order.Enrollment_Type__c       =   ord.Enrollment_Type__c;
order.ESIID_Number__c            =   ord.ESIID_Number__c;
//order.Expected_Confirmation_Date__c    =   ord.Expected_Confirmation_Date__c;
order.First_Name__c         =    ord.First_Name__c;
order.InitialDateofService__c       =    ord.InitialDateofService__c;
order.Last_4_SSN_of_Authorized__c   =    ord.Last_4_SSN_of_Authorized__c;
order.Last_Name__c          =    ord.Last_Name__c;
order.Mailing_City__c       =       ord.Mailing_City__c;
order.Mailing_State__c      =       ord.Mailing_State__c;
order.Mailing_Street_Address__c     =    ord.Mailing_Street_Address__c;
order.Mailing_Zip_Code__c   =       ord.Mailing_Zip_Code__c;
order.Order_Confirmed_Date__c       =    ord.Order_Confirmed_Date__c;
order.Order_Expiration_Date__c      =    ord.Order_Expiration_Date__c;
order.Order_Status__c       =       ord.Order_Status__c;
order.Payment_Card_Address_City__c   =   ord.Payment_Card_Address_City__c;
order.Payment_Card_Address_Line_1__c    =    ord.Payment_Card_Address_Line_1__c;
order.Payment_Card_Address_State__c   =  ord.Payment_Card_Address_State__c;
order.Payment_Card_Address_Zip__c   =    ord.Payment_Card_Address_Zip__c;
order.Payment_Card_Month__c     =    ord.Payment_Card_Month__c;
order.Payment_Card_Number__c    =       ord.Payment_Card_Number__c;
order.Payment_Card_Type__c      =    ord.Payment_Card_Type__c;
order.Payment_Card_Year__c      =    ord.Payment_Card_Year__c;
order.Phone_of_Authorized__c    =       ord.Phone_of_Authorized__c;
order.Plan_Expiration__c        =    ord.Plan_Expiration__c;
order.Service_Address__c        =    ord.Service_Address__c;
order.Service_City__c           =    ord.Service_City__c;
order.Service_State__c          =    ord.Service_State__c;
order.Service_Zip__c    =       ord.Service_Zip__c;
order.Tax_Id__c        =       ord.Tax_Id__c;

back.add(order);
       }
       
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