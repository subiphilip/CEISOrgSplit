public with sharing class ExportToExcel {
 
  public Order__c ord {get;set;} // new account to create
  public List<Order__c> orders {get;set;}
  public List<Order__c> ordersx {get;set;}
  public Account accounts {get;set;}
  public String profile {get;set;}
public string ssnx {get;set;}

  
  public ExportToExcel() {
  
    
    // get the current search string
    profile = System.currentPageReference().getParameters().get('id');
   // contact = new Contact(id=searchString);
   // this.contact = (Contact)stdController.getRecord();
    
     //orders = [SELECT Account__c,export__c,Authorized_Representative__c,Bill_Doc_Credited__c,Clawback_Date__c,Clawback_Value__c,Commission__c,ConnectionReceivedId,ConnectionSentId,Contract_Length__c,CreatedById,CreatedDate,Credit_Memo__c,Critical_Care__c,Customer_Acceptance_of_Plan_Terms__c,Customer_Date_of_Birth__c,Customer_Email__c,Customer_IP_Address__c,Customer_Phone_Number__c,Customer_Service_Email_For_Order__c,Customer_Service_Phone_Number_For_Order__c,Date_of_Birth_Day__c,Date_of_Birth_Year__c,Date_of_Birth__c,Deposit_Info__c,Drivers_License_Number__c,Drivers_License_State__c,EFL_URL_For_Order__c,Email_Address__c,Enrollment_Type__c,ESIID_Number__c,Expected_Confirmation_Date__c,Failure_Reason__c,First_Name__c,Free_Order__c,Id,InitialDateofService__c,Last_4_SSN_of_Authorized__c,Last_Name__c,Mailing_City__c,Mailing_State__c,Mailing_Street_Address__c,Mailing_Zip_Code__c,Moveout_REP_Email__c,Move_Out_Date__c,Move_out_ESID__c,Move_out_REP__c,Name,Name_as_it_appears_on_Payment_Card__c,Order_Bill_Doc__c,Order_Confirmed_Date__c,Order_Expiration_Date__c,Order_Failure_Comments__c,Order_Rejection_Comments__c,Order_Status_TS__c,Order_Status__c,Parent_Account__c,Payment_Card_Address_City__c,Payment_Card_Address_Line_1__c,Payment_Card_Address_State__c,Payment_Card_Address_Zip__c,Payment_Card_Month__c,Payment_Card_Number__c,Payment_Card_Type__c,Payment_Card_Year__c,Phone_of_Authorized__c,Plan_Expiration__c,Plan_ID__c,Plan__c,PMVI_Flag__c,Premise__c,Rate__c,Rejection_Reason__c,Replacement_Order__c,REP_email__c,REP_Profile__c,Service_Address__c,Service_City__c,Service_State__c,Service_Zip__c,Shortpay__c,SSN__c,Tax_Id__c,Time_to_Approve_Reject__c,Time_to_Confirm_Fail__c,TOS_URL_For_Order__c,YRAAC_URL_For_Order__c FROM Order__c where REP_Profile__c =: profile limit 9];
    ordersx = new List<order__c>();
    //for (Order__c ord : orders)
    {
     //System.debug('ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff'+GetRepOrder(ord.id));
    // String funk = GetRepOrder(ord.id);
    // if (funk != null)
    // ord.export__c = funk;
 
    String order = GetRepOrder(profile);
    order = order.replace('\\','');
    order = order.replace('__c','');
    
    //order = order.replace('false','"false"');
    //order = order.replace('[{','{');
    //order = order.replace('}]','}');
    String passcrap = order;
    passcrap = '"'+passcrap+'"';
System.debug('ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff'+passcrap);
system.Jsonparser parser = system.Json.createParser(passcrap);
      
       // while (parser.nextToken() != JSONToken.END_OBJECT ) {
        //  system.debug('_______________________________________________________________start_______________________________________________________________________');
      
        
       while (parser.nextToken() != JSONToken.END_ARRAY) {
            if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                 
                String text = parser.getText();
            system.debug('_______________________________________________________________start_______________________________________________________________________'+parser.getText());   
                    if (text == 'attributes') {
                        ord = new Order__c();
                        //attributes = new Attributes(parser);
                    } else if (text == 'Service_City') {
                        parser.nextvalue();
                        ord.Service_City__c = parser.getText();
                    } else if (text == 'Authorized_Representative') {
                        parser.nextvalue();
                        ord.Authorized_Representative__c = parser.getText();
                    }else if (text == 'Mailing_Zip_Code') {
                        parser.nextvalue();
                        ord.Mailing_Zip_Code__c = parser.getText();
                    } else if (text == 'Mailing_Street_Address') {
                        parser.nextvalue();
                        ord.Mailing_Street_Address__c = parser.getText();
                    } else if (text == 'Critical_Care') {
                        parser.nextvalue();
                        ord.ExportCritCare__c = string.valueof(parser.getbooleanvalue());
                    } else if (text == 'Customer_Email') {
                        parser.nextvalue();
                        ord.Customer_Email__c = parser.getText();
                    } else if (text == 'Contract_Length') {
                        parser.nextvalue();
                        ord.Contract_Length__c = parser.getIntegerValue();
                    } else if (text == 'First_Name') {
                        parser.nextvalue();
                        ord.First_Name__c = parser.getText();
                    } else if (text == 'Service_Zip') {
                        parser.nextvalue();
                        ord.Service_Zip__C = parser.getText();
                    } else if (text == 'Order_Expiration_Date') {
                        parser.nextvalue();
                        ord.Order_Expiration_Date__c = parser.getDatetimeValue();
                    } else if (text == 'Last_Name') {
                        parser.nextvalue();
                        ord.Last_Name__c = parser.getText();
                    } else if (text == 'Email_Address') {
                        parser.nextvalue();
                        ord.Email_Address__c = parser.getText();
                    } else if (text == 'Service_Address') {
                        parser.nextvalue();
                        ord.Service_Address__C = parser.getText();
                    } else if (text == 'Commission') {
                        parser.nextvalue();
                        ord.exportCommision__c = string.valueof(parser.getDoubleValue()); 
                    } else if (text == 'ESIID_Number') {
                        parser.nextvalue();
                        ord.ESIID_Number__c = parser.getText()+'"';
                    } else if (text == 'Order_Status') {
                        parser.nextvalue();
                        ord.Order_Status__c = parser.getText();
                    } else if (text == 'Expected_Confirmation_Date') {
                        parser.nextvalue();
                        ord.Exported_Confirmation_Date__c = parser.getDateValue();
                    } else if (text == 'Mailing_City') {
                        parser.nextvalue();
                        ord.Mailing_City__c = parser.getText();
                    } else if (text == 'Id') {
                        //ord.Id = parser.getText();
                    } else if (text == 'Mailing_State') {
                        parser.nextvalue();
                        ord.Mailing_State__c = parser.getText();
                    } else if (text == 'Service_State') {
                        parser.nextvalue();
                        ord.Service_State__c = parser.getText();
                    } else if (text == 'Customer_Phone_Number') {
                        parser.nextvalue();
                        ord.Customer_Phone_Number__c = parser.getText();
                    } else if (text == 'Enrollment_Type') {
                        parser.nextvalue();
                        ordersx.add(ord);
                        ord.exportEnrollment_Type__c = parser.getText();
                    } else if (text == 'InitialDateofService') {
                        parser.nextvalue();
                        ord.InitialDateofService__c = parser.getDateValue();
                    } else if (text == 'Plan_Expiration') {
                        parser.nextvalue();
                        ord.Plan_Expiration__c = parser.getDateValue();
                    } 
                    else if (text == 'ssn') {
                        parser.nextvalue();
                        ord.export__c = parser.gettext();
                        //ordersx.add(ord);
                    } 
        system.debug('_______________________________________________________________stopt_______________________________________________________________________'+ord);

        }
       }
system.debug('_______________________________________________________________endwhile_______________________________________________________________________'+ord);

 //JSON2Apex test1 = new  JSON2Apex(system.Json.createParser(passcrap.trim()));

//System.debug('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'+test1);
//ordersx = 
  //        (List<Order__c>)JSON.deserialize(passcrap, List<Order__c>.class);
        
   //ordersx = new List<order__c>();
     ordersx.add(ord);
    }
    
  }
        public static String GetRepOrderSSN(String order){ 
            //String order = ApexPages.currentPage().getParameters().get('id'); 
            TrueCostSystemVariables__c tcsv = TrueCostSystemVariables__c.getOrgDefaults();
            
            String json;
            String session = userInfo.getSessionId();
            String userid  = userInfo.getUserId();
            system.debug('____________'+ userid);
            String url = tcsv.REST_URL__c+'OrderSSN?id='+order; 
            //String url = 'https://cs12.salesforce.com/services/apexrest/OrderSSN?id='+order;  <--what Barry did!
           // String url = tcsv.REST_URL__c+'Orders?id=';
           
        
            http h = new http();
            httprequest req = new httprequest();


            req.setEndpoint(url);
            req.setMethod('POST');
            req.setHeader('Authorization', 'OAuth ' + session);
            req.setHeader('Content-Type', 'text/json;charset=utf-8');
            req.setBody('{ \"order\": '+order+'}');
            req.setTimeout(60000);
 
            httpresponse res = h.send(req);
            String result = res.getBody();

            json = res.getBody().replace('\n', '');
            
          string  ssnx = json;
            //ssnx = ssnx.replace('"','');
            //ssnx = 'Custom SSN: ' + ssnx;
     return ssnx;
}
    public String GetRepOrder(String order){ 
            //String order = ApexPages.currentPage().getParameters().get('id'); 
            TrueCostSystemVariables__c tcsv = TrueCostSystemVariables__c.getOrgDefaults();
            
            String json;
            String session = userInfo.getSessionId();
            String userid  = userInfo.getUserId();
            system.debug('____________'+ userid);
            //String url = 'https://cs12.salesforce.com/services/apexrest/OrderSSN?id='+order;
            String url = tcsv.REST_URL__c+'Orders?id=';
            url = url+order;
        
            http h = new http();
            httprequest req = new httprequest();


            req.setEndpoint(url);
            req.setMethod('POST');
            req.setHeader('Authorization', 'OAuth ' + session);
            req.setHeader('Content-Type', 'text/json;charset=utf-8');
            req.setBody('{ \"order\": '+order+'}');
            req.setTimeout(60000);
 
            httpresponse res = h.send(req);
            String result = res.getBody();

            json = res.getBody().replace('\n', '');
            
            ssnx = json;
            //ssnx = ssnx.replace('"','');
            //ssnx = 'Custom SSN: ' + ssnx;
     return ssnx;
}
}