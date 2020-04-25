public class OrderAPIManager {
    public boolean enabled = false;
    public order__C[] orderlist;
    public void placeOrder(order__C[] orderlist)
    {
        //, String rep, String rateId
         
        
    System.debug('api list'+ orderlist[0]);
    System.debug('name' +orderlist[0].rep_profile__r.name );
    

     
        
        system.debug('pmvi flag!!!!!!!!!!!!!!!!!!!!!!!!!!'+  orderlist[0]);
        system.debug('name sent!!!!!!!!!!!!!!!!!!!!!!!!!!'+  orderlist[0].name);
        system.debug('rateid !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'+ orderlist[0].Rate__c);
        
        String enrollmenttype = '';
        if  (orderlist[0].PMVI_Flag__c)      
        {
         enrollmenttype = 'MI';
        }else
        {
        enrollmenttype = 'NB';
        }
     if (orderlist[0].rep_profile__r.name == 'Cirro Energy' && orderlist[0].reporderid__c == null )
     {
        system.debug('orderid passes'+orderlist[0].name);
        
        
  
        
        callCirro(orderlist[0].ssn__c,orderlist[0].Critical_Care__c, orderlist[0].name, orderlist[0].id, orderlist[0].First_Name__c,orderlist[0].Last_Name__c,orderlist[0].Customer_Date_of_Birth__c,orderlist[0].Mailing_City__c,orderlist[0].Mailing_State__c,orderlist[0].Mailing_Street_Address__c,orderlist[0].Mailing_Zip_Code__c,orderlist[0].Service_Address__c,orderlist[0].Service_City__c,orderlist[0].Service_State__c,orderlist[0].Service_Zip__c,orderlist[0].InitialDateofService__c,enrollmenttype, orderlist[0].Plan_ID__c,orderlist[0].ESIID_Number__c,orderlist[0].Customer_Email__c, orderlist[0].Customer_Phone_Number__c,orderlist[0].rate__c);
   
        }else{
        
        
        // set system not available code
        
        }
        
 
        
     
    }
    @Future(callout=true)
   private static void callCirro(String ssn, boolean criticalcare, String name, String orderid, String FirstName, String LastName,Date CustomerDateofBirth, String MailingCity,String MailingState, String MailingStreetAddress,String MailingZipCode,String ServiceAddress,String ServiceCity,String ServiceState, String ServiceZip,Date InitialDateofService,String enrollmenttype,String plan,String esiid,String email, String phone, String rate)
   {
   	
   	 List<order__c> order = [select id,name , reporderid__c, exception__c, repstatus__c, REPOrderSubStatus__c,order_status__c from order__c where id =:orderid];
   	try{
   	triggerhelper.recursiveHelper(true);
    boolean exitError = false;
    List<order__c> orderName = [select id,name , reporderid__c, repstatus__c, order_status__c from order__c where id =:orderid];
    name = orderName[0].name;
    System.debug('id passed to cirro'+ orderid);
    System.debug('id passed to cirro ssn'+ ssn);
    System.debug('id passed to cirro cc'+criticalcare); 
System.debug('id passed to cirro name'+ name);
System.debug('id passed to cirro id'+ orderid); 
System.debug('id passed to cirro  first'+ FirstName);
System.debug('id passed to cirro last'+ LastName);
System.debug('id passed to cirro dob'+ CustomerDateofBirth); 
System.debug('id passed to cirro mailcity'+ MailingCity);
System.debug('id passed to cirro mail st'+ MailingState); 
System.debug('id passed to cirro mail str'+ MailingStreetAddress);
System.debug('id passed to cirro mail zip'+ MailingZipCode);
System.debug('id passed to cirro svc addr'+ ServiceAddress);
System.debug('id passed to cirro svc city'+ ServiceCity);
System.debug('id passed to cirro svc st'+ ServiceState); 
System.debug('id passed to cirro svc zip'+ ServiceZip);
System.debug('id passed to cirro svc dos'+ InitialDateofService);
System.debug('id passed to cirro svc enrollment'+ enrollmenttype);
System.debug('id passed to cirro svc enrollment'+ plan);// this goes for rate id
System.debug('id passed to cirro svc esiid'+ esiid);
System.debug('id passed to cirro svc email'+ email);
System.debug('id passed to cirro svc email'+ phone);

System.debug('rateid '+ rate);

List<rate__c> rateName = [SELECT Name FROM Rate__c WHERE Id =: rate limit 1];


 
   if (InitialDateofService == null)
     {
     InitialDateofService = date.today();
     InitialDateofService.addDays(3);
     }
    
    
        VirginiaPowerEnroll.RetailOrderAutomationServiceSoap status = new VirginiaPowerEnroll.RetailOrderAutomationServiceSoap();
        VirginiaPowerEnroll.CheckSystemStatus   newStat = new VirginiaPowerEnroll.CheckSystemStatus();
        VirginiaPowerEnroll.CheckSystemStatusResponse resp = new VirginiaPowerEnroll.CheckSystemStatusResponse();
        VirginiaPowerEnroll.CreateOrderResponse orderResp = new VirginiaPowerEnroll.CreateOrderResponse();
        
       // try{
        resp = status.CheckSystemStatus(newStat);
       // }
       
       // catch (CalloutException e)
       // {
        //system.debug('callout exception ' +e);
        // order[0].exception__c = e.getMessage();
        // order[0].Order_Status__c  = 'Failed';
        //update order; 
        //exitError = True;
        //}
        //catch (Exception e)
        ///{
        //system.debug(' exception ' +e);
        // order[0].exception__c = e.getMessage();
       // order[0].Order_Status__c  = 'Failed';
       // update order; 
        //exitError = True;
        //}
        
        system.debug('response!!!!!!!!!!!!!!!!!!!!!!!!!!'+ resp);
        if ( resp.ResponseCode == '00')
        {
        system.debug('response!!!!!!!!!!!!!!!!!!!!!!!!!!'+ resp);
        
        String resp1 = null;
        cirro.BasicHttpBinding_IService1 svc = new cirro.BasicHttpBinding_IService1();
        system.debug('ssn!!!!!!!!!!!!!'+ssn);
        ssn   = ssn.replace('-', '');
        //try {
        resp1 =    svc.getData(integer.valueof(ssn));
        system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'+ resp1.substring(13,resp1.length()));
        //}
       
        
       
        
       // order[0].exception__c = order[0].exception__c + esiid;
        //order[0].exception__c = order[0].exception__c + 'past ssn enc';
        VirginiaPowerEnroll.CreateOrderRequest req = new VirginiaPowerEnroll.CreateOrderRequest();
        //System Information
        req.ClientSystem                        = 'TCOST';
        req.UserId                              = '10000663';
        req.Token                               = 'myTokenId';
        req.AgentId                             = '161';
        req.LeadSource                          = 'AGT'; 
        req.UdcNameCode                         = 'CNP1';
        req.UdcAccountNum                       = esiid;
        req.CreditCheckInd                      = 'Y';
        req.ValidationInd                       = 'N'; 
        // Customer Information
        VirginiaPowerEnroll.CustomerInfo customerInfo = new VirginiaPowerEnroll.CustomerInfo();
        customerInfo.CustomerType           = 'Residential';
        customerInfo.CustomerFirstName      = FirstName;
       
        customerInfo.CustomerLastName       = LastName;
        integer month                       = Customerdateofbirth.month();
        integer day                         = Customerdateofbirth.day();
        String dayS                         = string.valueof(Customerdateofbirth.day());
        String monthS                       = string.valueof(Customerdateofbirth.month());
        String zero                         = '0';
        if (string.valueof(month).length() == 1){
  
        monthS = zero + string.valueof(month);
        }
        
        if (string.valueof(day).length() == 1){
            
        dayS = zero + string.valueof(day);
        
        }
        //customerInfo.Birthdate                = '0214'; MMDD
        customerInfo.Birthdate              =  monthS + dayS;
        system.debug('dob'+monthS + dayS);
        customerInfo.SocialSecurityNum      =  resp1.substring(13,resp1.length());
        customerInfo.BillingLanguage        = 'English';
        if( CriticalCare)
        {
        customerInfo.LifeSupportIndicator   = 'Y';
        }else{
        customerInfo.LifeSupportIndicator   = 'N';
        }
        req.CustomerInfo = customerInfo;
        //Address Information
        //contact info
        
        VirginiaPowerEnroll.ContactInfo contactInfo = new VirginiaPowerEnroll.ContactInfo();
        VirginiaPowerEnroll.ArrayOfPhoneInfo phoneArray = new VirginiaPowerEnroll.ArrayOfPhoneInfo();
        List<VirginiaPowerEnroll.PhoneInfo> pi   = new List<VirginiaPowerEnroll.PhoneInfo>();
        VirginiaPowerEnroll.PhoneInfo  phoneInfoHM = new VirginiaPowerEnroll.PhoneInfo();
        VirginiaPowerEnroll.PhoneInfo  phoneInfoOU = new VirginiaPowerEnroll.PhoneInfo();
        contactInfo.EmailAddr = email;
        contactInfo.ContactType = 'CS';
        //
        String phone1 = phone.replace('(', '');
        String phone2 = phone1.replace(')','');
        String phone3 = phone2.replace(' ','');
        String phone4 = phone3.replace('-','');
        system.debug('______________________'+ phone4);
        phoneInfoHM.PhoneNumber = phone4;
        phoneInfoHM.PhoneType = 'HM';
        pi.add(phoneInfoHM);
        phoneInfoOU.PhoneNumber = phone4;
        phoneInfoOU.PhoneType = 'OU';
        pi.add(phoneInfoOU);
            
        phoneArray.PhoneInfo = pi;
        req.ContactInfo = contactInfo;
        req.ContactInfo.PhoneInfoArray = phoneArray;
        
        
        //end contact info
        VirginiaPowerEnroll.ArrayOfAddressInfo  aiArray = new VirginiaPowerEnroll.ArrayOfAddressInfo();
        //VirginiaPowerEnroll.AddressInfo arAddreInfo = new VirginiaPowerEnroll.AddressInfo();
        VirginiaPowerEnroll.AddressInfo ai    = new VirginiaPowerEnroll.AddressInfo();
        List<VirginiaPowerEnroll.AddressInfo> bi    = new List<VirginiaPowerEnroll.AddressInfo>();
        ai.PrimaryResidenceInd                  = 'Y';
        
        
        ai.AddressType                          = 'Billing';
        ai.AddressLine1                         = MailingStreetAddress;
        ai.AddressLine2                         = '';
        ai.City                                 =  MailingCity;
        ai.StateCode                            =  MailingState;
        
        if ( MailingZipCode !=null)
        {
        ai.Zip                                  =  MailingZipCode.substring(0,5);
        }else
        {
        
        ai.Zip                                   =  '';
        }
        
        
        bi.add(ai);
        VirginiaPowerEnroll.AddressInfo ais    = new VirginiaPowerEnroll.AddressInfo();
        ais.PrimaryResidenceInd                     = 'Y';
        ais.AddressType                             = 'Service';
        
        ais.AddressLine1                            = ServiceAddress;
        ais.AddressLine2                            = '';
        ais.City                                    = ServiceCity;
        ais.StateCode                               = ServiceState;
        ais.Zip                                     = ServiceZip.substring(0,5);
        bi.add(ais);
        aiArray.AddressInfo = bi;
        
        
        system.debug('address2    '+ aiArray);
        
    
        req.AddressInfoArray = aiArray;
        

        
        VirginiaPowerEnroll.ArrayOfOrderInfo orderArray = new VirginiaPowerEnroll.ArrayOfOrderInfo();
        VirginiaPowerEnroll.OrderInfo orderInfo = new VirginiaPowerEnroll.OrderInfo();
        List<VirginiaPowerEnroll.OrderInfo> orderLst = new List<VirginiaPowerEnroll.OrderInfo>();
        orderInfo.ExternalReference         = name;
        orderInfo.ProductType               = 'E';
        //MI move in 
        //NB switch
        if (enrollmenttype == '')
        {
        enrollmenttype = 'NB';
        }
        orderInfo.OrderType                 = enrollmenttype;
        //orderInfo.CampaignOfferId           = 'ECNP1ELEC031202/3453/12/M';
        //orderInfo.CampaignOfferId           = 'ECNP1ELEC061203/3781/12/M';
        orderInfo.CampaignOfferId           = ratename[0].name;
        if ('MI'.equals(enrollmenttype) )
        {
        orderInfo.MoveInType                = 'MNP';
        }
   list<BusinessHours> REPhours = [select id from BusinessHours where name = 'REP SLA']; //Finds the REP business hours 
   
   Datetime newdate = BusinessHours.add(REPhours[0].id, InitialDateofService, 1); 
            system.debug('=============created=========  ' + newdate);
    
            if (InitialDateofService != null)
        {
                
        system.debug('service start date' + newdate);
        
        integer month1                       = newdate.month();
        integer day1                         = newdate.day();
        String dayS1                          = string.valueof(newdate.day());
        String monthS1                        = string.valueof(newdate.month());
        String zero1                         = '0';
        if (string.valueof(month1).length() == 1){
  
        monthS1 = zero1 + string.valueof(month1);
        }
        
        if (string.valueof(day1).length() == 1){
            
        dayS1 = zero1 + string.valueof(day1);
        
        }
  
  
        system.debug('initdateofservice' +monthS1+dayS1+newdate.year());
        orderInfo.ServiceStartDate          =  monthS1+dayS1+newdate.year();
        }else
        {
        
        orderInfo.ServiceStartDate          =  string.valueof(InitialDateofService);
        }
       
        
        orderLst.add(orderInfo);
        system.debug('order list                            ' + orderLst);
        orderArray.OrderInfo = orderLst;
        req.OrderInfoArray = orderArray;
        // not calling order yet
        VirginiaPowerEnroll.CreateOrderResponse orderResp1 = new VirginiaPowerEnroll.CreateOrderResponse();
        List<VirginiaPowerEnroll.OrderResponse> ordRespArray = new List<VirginiaPowerEnroll.OrderResponse>();
        VirginiaPowerEnroll.CreateOrderResponse_element response_x;
       // List<order__c> order = [select id,name , reporderid__c, repstatus__c, order_status__c from order__c where id =:orderid];
        //order[0].exception__c = order[0].exception__c + 'before create callout';
       // try{
        orderResp1 = status.CreateOrder(req);
        
        ordRespArray = orderResp1.OrderResponse.OrderResponse;
        system.debug('Response: ______________' + orderResp1.OrderResponse.OrderResponse);
            VirginiaPowerEnroll.ArrayOfChargeInfo ChargeInfo ;
            List<VirginiaPowerEnroll.ChargeInfo> chginf = new List<VirginiaPowerEnroll.ChargeInfo>();
        ChargeInfo = ordRespArray[0].ChargeInfo;
        system.debug('Response: ______________' +ordRespArray[0].ChargeInfo);
        chginf = ChargeInfo.ChargeInfo;
        system.debug('response chginf' + chginf);
      
        system.debug('Response: ______________' +ordRespArray[0].OrderId);
        system.debug('Response: ______________' +ordRespArray[0].OrderStatus);
        system.debug('Response: ______________' +ordRespArray[0].ServiceStartDt);
    
        //Approved Pending Confirmation
        //Rejected 
        //Confirmed
        //REPOrderId__c
        //REPStatus--c
        
        order[0].reporderid__c = ordRespArray[0].OrderId;
        order[0].repstatus__c  = ordRespArray[0].OrderStatus;
       // }
     
        // map cirro to truecost status
       if ( !exitError) {
       	// Changed on Aug 26 2013 per email from ramazon
       //if ('Active'.equals(ordRespArray[0].OrderStatus) )
       if ('Approved'.equals(ordRespArray[0].OrderStatus) )
       {
         order[0].Order_Status__c           = 'Approved';
       	 order[0].REPStatus__c         		= ordRespArray[0].OrderStatus;
         order[0].REPOrderSubStatus__c		= ordRespArray[0].OrderSubStatus;
       
       }
       if ('Cancelled'.equals(ordRespArray[0].OrderStatus) )
       {
         order[0].Order_Status__c           = 'Cancelled';
       	 order[0].REPStatus__c         		= ordRespArray[0].OrderStatus;
         order[0].REPOrderSubStatus__c		= ordRespArray[0].OrderSubStatus;
       
       }
       
       if ('Pending'.equals(ordRespArray[0].OrderStatus) )
       {
         order[0].Order_Status__c           = 'Pending';
       	 order[0].REPStatus__c         		= ordRespArray[0].OrderStatus;
         order[0].REPOrderSubStatus__c		= ordRespArray[0].OrderSubStatus;
       
       }
        
      
        update order;
        }
      
        
        
        }
   	}
       catch (CalloutException e)
       {
        system.debug('callout exception ' +e);
        exceptions__c ex = new exceptions__c();
        ex.error__c = e.getMessage();
        upsert ex;
         order[0].exception__c = e.getMessage();
         order[0].Order_Status__c  = 'Pending';
        update order; 
       
        }
        catch (Exception e)
        {
        system.debug(' exception ' +e);
         order[0].exception__c = e.getMessage();
        order[0].Order_Status__c  = 'Pending';
        update order; 
        
        }
       
    
    
    }
    
    private static Date knownSaturday = Date.newInstance(2009, 1, 10);
    private static Date knownSunday = Date.newInstance(2009, 1, 11);

    public static Boolean isSaturday(Date d) {
        // daysBetween() is always positive
        Integer diff = knownSaturday.daysBetween(d);
        return (Math.mod(diff, 7) == 0);
    }
    
    public static Boolean isSunday(Date d) {
        Integer diff = knownSunday.daysBetween(d);
        return (Math.mod(diff, 7) == 0);
    }

public boolean checkifItisWorkingDay(Date currentDate,List<Holiday> holidays){
                 Date weekStart  = currentDate.toStartofWeek();
                for(Holiday hDay:holidays){
                        if(currentDate.daysBetween(hDay.ActivityDate) == 0){
                                 return false;
                        }
                }
               if(weekStart.daysBetween(currentDate) ==0 || weekStart.daysBetween(currentDate) == 6){
                       return false;
                } else 
                       return true;
  }
//@future (callout = true)
public  void checkCirroStatus(){
	String success = '';
		//New/Successfully Submitted
	//List<order__c> orderlist = [select id,order_status__c, REPOrderId__c ,
	//repstatus__c from Order__c where rep_profile__r.name = 'Cirro Energy' and repstatus__c = 'pending' and order_status__c != 'Approved pending deposit' 
	//and order_status__c != 'Approved' and order_status__c != 'Cancelled'];
	List<order__c> orderlist = [select id,order_status__c, REPOrderId__c ,
	repstatus__c from Order__c where rep_profile__r.name = 'Cirro Energy'  and order_status__c != 'Approved' 
	 and order_status__c != 'Cancelled' and order_status__c != 'Confirmed' and REPOrderId__c != null];
	//List<order__c> orderlist = [select id,order_status__c, REPOrderId__c ,
	//repstatus__c from Order__c where rep_profile__r.name = 'Cirro Energy' and repstatus__c = 'pending' and order_status__c != 'Approved pending deposit' 
	//and order_status__c != 'Approved' and order_status__c != 'Cancelled'];
    List<order__c> updateOrder = new List<order__c>();
   system.debug('size__________________________________________________________________________________'+orderlist.size());
   integer count = 0;
   if ( orderlist.size() > 0){
   for (order__c order:orderlist)
   {
   	
   	
    	VirginiaPowerEnroll.RetailOrderAutomationServiceSoap status = new VirginiaPowerEnroll.RetailOrderAutomationServiceSoap();
    	VirginiaPowerEnroll.CheckSystemStatus   newStat = new VirginiaPowerEnroll.CheckSystemStatus();
    	VirginiaPowerEnroll.CheckSystemStatusResponse resp = new VirginiaPowerEnroll.CheckSystemStatusResponse();
    	VirginiaPowerEnroll.CreateOrderResponse orderResp = new VirginiaPowerEnroll.CreateOrderResponse();
    	VirginiaPowerEnroll.CheckOrderStatusResponse checkResp = new VirginiaPowerEnroll.CheckOrderStatusResponse();
    	
    	
    	
    	
    	
    	VirginiaPowerEnroll.CheckOrderStatus	req = new VirginiaPowerEnroll.CheckOrderStatus();
    	
    	//System Information
    	req.ClientSystem 						= 'TCOST';
    	req.UserId       						= '10000663';
    	req.Token        						= 'myTokenId';
    	req.Type_x		    					= 'ORDERID';
    	req.Id                                  = order.REPOrderId__c; 
    	//req.Id									= '1759247426032012';
    	req.ProductType							= 'E';
    	
    checkResp = status.CheckOrderStatus(req);
     
  
    //order.InitialDateofService__c 	= date.valueof(checkresp.OrderResponse.ServiceStartDt);
     system.debug('status____________________________________________________' +checkresp);
    system.debug('status orderid____________________________________________' +checkresp.OrderResponse.OrderId);
    system.debug('status status_____________________________________________' +checkresp.OrderResponse.OrderStatus);
    system.debug('status substatus____________________________________________________' +checkresp.OrderResponse.OrderSubStatus);
    system.debug('status start date________________________________________' +checkresp.OrderResponse.ServiceStartDt);
    
       if ('Approved'.equals(checkresp.OrderResponse.OrderStatus))
       {
         order.Order_Status__c          = 'Approved';
 		 order.REPStatus__c         		= checkresp.OrderResponse.OrderStatus;
    	 order.REPOrderSubStatus__c		= checkresp.OrderResponse.OrderSubStatus;
       
       }
    
       if ('Pending'.equals(checkresp.OrderResponse.OrderStatus) && 'MI'.equals(checkresp.OrderResponse.OrderSubStatus))
       {
         order.Order_Status__c          = 'Pending Information';
 		 order.REPStatus__c         		= checkresp.OrderResponse.OrderStatus;
    	 order.REPOrderSubStatus__c		= checkresp.OrderResponse.OrderSubStatus;
       
       }
       
       if ('Pending'.equals(checkresp.OrderResponse.OrderStatus) && 'MI'.equals(checkresp.OrderResponse.OrderSubStatus))
       {
         order.Order_Status__c          = 'Pending Information';
 		 order.REPStatus__c         		= checkresp.OrderResponse.OrderStatus;
    	 order.REPOrderSubStatus__c		= checkresp.OrderResponse.OrderSubStatus;
       
       }
       
       if ('Pending'.equals(checkresp.OrderResponse.OrderStatus) && 'PP'.equals(checkresp.OrderResponse.OrderSubStatus))
       {
         order.Order_Status__c          = 'Approved Pending Deposit';
 		 order.REPStatus__c         		= checkresp.OrderResponse.OrderStatus;
    	 order.REPOrderSubStatus__c		= checkresp.OrderResponse.OrderSubStatus;
       
       }
       
       if ('Pending'.equals(checkresp.OrderResponse.OrderStatus) && 'AA'.equals(checkresp.OrderResponse.OrderSubStatus))
       {
         order.Order_Status__c          = 'Approved';
 		 order.REPStatus__c         		= checkresp.OrderResponse.OrderStatus;
    	 order.REPOrderSubStatus__c		= checkresp.OrderResponse.OrderSubStatus;
       
       }
      if ('Approved'.equals(checkresp.OrderResponse.OrderStatus) && 'AA'.equals(checkresp.OrderResponse.OrderSubStatus))
       {
         order.Order_Status__c          = 'Approved';
 		 order.REPStatus__c         		= checkresp.OrderResponse.OrderStatus;
    	 order.REPOrderSubStatus__c		= checkresp.OrderResponse.OrderSubStatus;
       
       }
              
       if ('Pending'.equals(checkresp.OrderResponse.OrderStatus) && 'HB'.equals(checkresp.OrderResponse.OrderSubStatus))
       {
         order.Order_Status__c          = 'Pending Switch Hold';
 		 order.REPStatus__c         		= checkresp.OrderResponse.OrderStatus;
    	 order.REPOrderSubStatus__c		= checkresp.OrderResponse.OrderSubStatus;
       
       }
       
       if ('Cancelled'.equals(checkresp.OrderResponse.OrderStatus) )
       {
         order.Order_Status__c          = 'Cancelled';
 		 order.REPStatus__c         		= checkresp.OrderResponse.OrderStatus;
    	 order.REPOrderSubStatus__c		= checkresp.OrderResponse.OrderSubStatus;
       
       }
    updateOrder.add(order);
    count++;
    if (count == 10)
    {
       break;
    }
}
update updateOrder;
   }
   //redo orders with no api status
   	//order__c[]orderlist2 = [select id,SSN__c,rep_profile__r.name,order_status__c, premise__r.id, premise__c,Plan_ID__c,  order_expiration_date__c, createddate, rate__c,name,First_Name__c,Last_Name__c,Customer_date_of_birth__c,Critical_Care__c,Mailing_Street_Address__c,Mailing_City__c,Mailing_State__c,Mailing_Zip_Code__c,Service_Address__c,Service_State__c,Service_City__c,Service_Zip__c,InitialDateofService__c,PMVI_Flag__c,ESIID_Number__c,Customer_Email__c, Customer_Phone_Number__c from Order__c where rep_profile__r.name = 'Cirro Energy'  and REPOrderId__c != null 
	//and order_status__c = 'New/Successfully Submitted' ];
	//if ( orderlist2.size() > 0)
	//{
	//this.placeOrder(orderlist2);
	//}
   
}
 public void orderFix()
{
   	order__c[]orderlist = [select id,SSN__c,rep_profile__r.name,order_status__c, premise__r.id, premise__c,Plan_ID__c,  order_expiration_date__c, createddate, rate__c,name,First_Name__c,Last_Name__c,Customer_date_of_birth__c,Critical_Care__c,Mailing_Street_Address__c,Mailing_City__c,Mailing_State__c,Mailing_Zip_Code__c,Service_Address__c,Service_State__c,Service_City__c,Service_Zip__c,InitialDateofService__c,PMVI_Flag__c,ESIID_Number__c,Customer_Email__c, Customer_Phone_Number__c from Order__c where rep_profile__r.name = 'Cirro Energy'  and REPOrderId__c = null 
	and order_status__c = 'New/Successfully Submitted' ];
	system.debug('_________________________________'+ orderlist);
	       String enrollmenttype = '';
        if  (orderlist[0].PMVI_Flag__c)      
        {
         enrollmenttype = 'MI';
        }else
        {
        enrollmenttype = 'NB';
        }
	//this.placeOrder(orderlist2);
	 callCirroFix(orderlist[0].ssn__c,orderlist[0].Critical_Care__c, orderlist[0].name, orderlist[0].id, orderlist[0].First_Name__c,orderlist[0].Last_Name__c,orderlist[0].Customer_Date_of_Birth__c,orderlist[0].Mailing_City__c,orderlist[0].Mailing_State__c,orderlist[0].Mailing_Street_Address__c,orderlist[0].Mailing_Zip_Code__c,orderlist[0].Service_Address__c,orderlist[0].Service_City__c,orderlist[0].Service_State__c,orderlist[0].Service_Zip__c,orderlist[0].InitialDateofService__c,enrollmenttype, orderlist[0].Plan_ID__c,orderlist[0].ESIID_Number__c,orderlist[0].Customer_Email__c, orderlist[0].Customer_Phone_Number__c,orderlist[0].rate__c);
   
}  

 private static string callCirroFix(String ssn, boolean criticalcare, String name, String orderid, String FirstName, String LastName,Date CustomerDateofBirth, String MailingCity,String MailingState, String MailingStreetAddress,String MailingZipCode,String ServiceAddress,String ServiceCity,String ServiceState, String ServiceZip,Date InitialDateofService,String enrollmenttype,String plan,String esiid,String email, String phone,String rate)
   {
    
    List<order__c> orderName = [select id,name , reporderid__c, repstatus__c, order_status__c from order__c where id =:orderid];
    name = orderName[0].name;
    System.debug('id passed to cirro'+ orderid);
    System.debug('id passed to cirro ssn'+ ssn);
    System.debug('id passed to cirro cc'+criticalcare); 
System.debug('id passed to cirro name'+ name);
System.debug('id passed to cirro id'+ orderid); 
System.debug('id passed to cirro  first'+ FirstName);
System.debug('id passed to cirro last'+ LastName);
System.debug('id passed to cirro dob'+ CustomerDateofBirth); 
System.debug('id passed to cirro mailcity'+ MailingCity);
System.debug('id passed to cirro mail st'+ MailingState); 
System.debug('id passed to cirro mail str'+ MailingStreetAddress);
System.debug('id passed to cirro mail zip'+ MailingZipCode);
System.debug('id passed to cirro svc addr'+ ServiceAddress);
System.debug('id passed to cirro svc city'+ ServiceCity);
System.debug('id passed to cirro svc st'+ ServiceState); 
System.debug('id passed to cirro svc zip'+ ServiceZip);
System.debug('id passed to cirro svc dos'+ InitialDateofService);
System.debug('id passed to cirro svc enrollment'+ enrollmenttype);
System.debug('id passed to cirro svc enrollment'+ plan);// this goes for rate id
System.debug('id passed to cirro svc esiid'+ esiid);
System.debug('id passed to cirro svc email'+ email);
System.debug('id passed to cirro svc email'+ phone);
System.debug('rateid '+ rate);

List<rate__c> rateName = [SELECT Name FROM Rate__c WHERE Id =: rate limit 1];
   if (InitialDateofService == null)
     {
     InitialDateofService = date.today();
     InitialDateofService.addDays(3);
     }
    
    
        VirginiaPowerEnroll.RetailOrderAutomationServiceSoap status = new VirginiaPowerEnroll.RetailOrderAutomationServiceSoap();
        VirginiaPowerEnroll.CheckSystemStatus   newStat = new VirginiaPowerEnroll.CheckSystemStatus();
        VirginiaPowerEnroll.CheckSystemStatusResponse resp = new VirginiaPowerEnroll.CheckSystemStatusResponse();
        VirginiaPowerEnroll.CreateOrderResponse orderResp = new VirginiaPowerEnroll.CreateOrderResponse();
        
        
        resp = status.CheckSystemStatus(newStat);
        system.debug('response!!!!!!!!!!!!!!!!!!!!!!!!!!'+ resp);
        if ( resp.ResponseCode == '00')
        {
        system.debug('response!!!!!!!!!!!!!!!!!!!!!!!!!!'+ resp);
        
        String resp1 = null;
        cirro.BasicHttpBinding_IService1 svc = new cirro.BasicHttpBinding_IService1();
        system.debug('ssn!!!!!!!!!!!!!'+ssn);
        ssn   = ssn.replace('-', '');
        try {
        resp1 =    svc.getData(integer.valueof(ssn));
        system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'+ resp1.substring(13,resp1.length()));
        }
        catch(exception e)
        {
         List<order__c> order = [select id,name , reporderid__c, repstatus__c, order_status__c from order__c where id =:orderid];
        
        order[0].Order_Status__c   = 'Encryption not Available';
        update order;
        
        }
        
        
        VirginiaPowerEnroll.CreateOrderRequest req = new VirginiaPowerEnroll.CreateOrderRequest();
        //System Information
        req.ClientSystem                        = 'TCOST';
        req.UserId                              = '10000663';
        req.Token                               = 'myTokenId';
        req.AgentId                             = '161';
        req.LeadSource                          = 'AGT'; 
        req.UdcNameCode                         = 'CNP1';
        req.UdcAccountNum                       = esiid;
        req.CreditCheckInd                      = 'Y';
        req.ValidationInd                       = 'N'; 
        // Customer Information
        VirginiaPowerEnroll.CustomerInfo customerInfo = new VirginiaPowerEnroll.CustomerInfo();
        customerInfo.CustomerType           = 'Residential';
        customerInfo.CustomerFirstName      = FirstName;
       
        customerInfo.CustomerLastName       = LastName;
        integer month                       = Customerdateofbirth.month();
        integer day                         = Customerdateofbirth.day();
        String dayS                         = string.valueof(Customerdateofbirth.day());
        String monthS                       = string.valueof(Customerdateofbirth.month());
        String zero                         = '0';
        if (string.valueof(month).length() == 1){
  
        monthS = zero + string.valueof(month);
        }
        
        if (string.valueof(day).length() == 1){
            
        dayS = zero + string.valueof(day);
        
        }
        //customerInfo.Birthdate                = '0214'; MMDD
        customerInfo.Birthdate              =  monthS + dayS;
        system.debug('dob'+monthS + dayS);
        customerInfo.SocialSecurityNum      =  resp1.substring(13,resp1.length());
        customerInfo.BillingLanguage        = 'English';
        if( CriticalCare)
        {
        customerInfo.LifeSupportIndicator   = 'Y';
        }else{
        customerInfo.LifeSupportIndicator   = 'N';
        }
        req.CustomerInfo = customerInfo;
        //Address Information
        //contact info
        
        VirginiaPowerEnroll.ContactInfo contactInfo = new VirginiaPowerEnroll.ContactInfo();
        VirginiaPowerEnroll.ArrayOfPhoneInfo phoneArray = new VirginiaPowerEnroll.ArrayOfPhoneInfo();
        List<VirginiaPowerEnroll.PhoneInfo> pi   = new List<VirginiaPowerEnroll.PhoneInfo>();
        VirginiaPowerEnroll.PhoneInfo  phoneInfoHM = new VirginiaPowerEnroll.PhoneInfo();
        VirginiaPowerEnroll.PhoneInfo  phoneInfoOU = new VirginiaPowerEnroll.PhoneInfo();
        contactInfo.EmailAddr = email;
        contactInfo.ContactType = 'CS';
        //
        String phone1 = phone.replace('(', '');
        String phone2 = phone1.replace(')','');
        String phone3 = phone2.replace(' ','');
        String phone4 = phone3.replace('-','');
        system.debug('______________________'+ phone4);
        phoneInfoHM.PhoneNumber = phone4;
        phoneInfoHM.PhoneType = 'HM';
        pi.add(phoneInfoHM);
        phoneInfoOU.PhoneNumber = phone4;
        phoneInfoOU.PhoneType = 'OU';
        pi.add(phoneInfoOU);
            
        phoneArray.PhoneInfo = pi;
        req.ContactInfo = contactInfo;
        req.ContactInfo.PhoneInfoArray = phoneArray;
        
        
        //end contact info
        VirginiaPowerEnroll.ArrayOfAddressInfo  aiArray = new VirginiaPowerEnroll.ArrayOfAddressInfo();
        //VirginiaPowerEnroll.AddressInfo arAddreInfo = new VirginiaPowerEnroll.AddressInfo();
        VirginiaPowerEnroll.AddressInfo ai    = new VirginiaPowerEnroll.AddressInfo();
        List<VirginiaPowerEnroll.AddressInfo> bi    = new List<VirginiaPowerEnroll.AddressInfo>();
        ai.PrimaryResidenceInd                  = 'Y';
        
        
        ai.AddressType                          = 'Billing';
        ai.AddressLine1                         = MailingStreetAddress;
        ai.AddressLine2                         = '';
        ai.City                                 =  MailingCity;
        ai.StateCode                            =  MailingState;
        
        if ( MailingZipCode !=null)
        {
        ai.Zip                                  =  MailingZipCode.substring(0,5);
        }else
        {
        
        ai.Zip                                   =  '';
        }
        
        
        bi.add(ai);
        VirginiaPowerEnroll.AddressInfo ais    = new VirginiaPowerEnroll.AddressInfo();
        ais.PrimaryResidenceInd                     = 'Y';
        ais.AddressType                             = 'Service';
        
        ais.AddressLine1                            = ServiceAddress;
        ais.AddressLine2                            = '';
        ais.City                                    = ServiceCity;
        ais.StateCode                               = ServiceState;
        ais.Zip                                     = ServiceZip.substring(0,5);
        bi.add(ais);
        aiArray.AddressInfo = bi;
        
        
        system.debug('address2    '+ aiArray);
        
    
        req.AddressInfoArray = aiArray;
        
//<ret:CampaignOfferId>ECNP1ELEC031202/3453/12/M</ret:CampaignOfferId>
//<ret:CampaignOfferId>ECNP1ELEC031202/3453/12/M</ret:CampaignOfferId>
        
        VirginiaPowerEnroll.ArrayOfOrderInfo orderArray = new VirginiaPowerEnroll.ArrayOfOrderInfo();
        VirginiaPowerEnroll.OrderInfo orderInfo = new VirginiaPowerEnroll.OrderInfo();
        List<VirginiaPowerEnroll.OrderInfo> orderLst = new List<VirginiaPowerEnroll.OrderInfo>();
        orderInfo.ExternalReference         = name;
        orderInfo.ProductType               = 'E';
        //MI move in 
        //NB switch
        if (enrollmenttype == '')
        {
        enrollmenttype = 'NB';
        }
        orderInfo.OrderType                 = enrollmenttype;
        //orderInfo.CampaignOfferId           = 'ECNP1ELEC031202/3453/12/M';
        //orderInfo.CampaignOfferId           = 'ECNP1ELEC061203/3781/12/M';
        orderInfo.CampaignOfferId           = rateName[0].name;
        if ('MI'.equals(enrollmenttype) )
        {
        orderInfo.MoveInType                = 'MNP';
        }
   list<BusinessHours> REPhours = [select id from BusinessHours where name = 'REP SLA']; //Finds the REP business hours 
   
   Datetime newdate = BusinessHours.add(REPhours[0].id, InitialDateofService, 1); 
            system.debug('=============created=========  ' + newdate);
    
            if (InitialDateofService != null)
        {
                
        system.debug('service start date' + newdate);
        
        integer month1                       = newdate.month();
        integer day1                         = newdate.day();
        String dayS1                          = string.valueof(newdate.day());
        String monthS1                        = string.valueof(newdate.month());
        String zero1                         = '0';
        if (string.valueof(month1).length() == 1){
  
        monthS1 = zero1 + string.valueof(month1);
        }
        
        if (string.valueof(day1).length() == 1){
            
        dayS1 = zero1 + string.valueof(day1);
        
        }
  
  
        
        /*
        date mydate = date.parse('07/15/2012');

   list<BusinessHours> REPhours = [select id from BusinessHours where name = 'REP SLA']; //Finds the REP business hours 
   
   Datetime newdate = BusinessHours.add(REPhours[0].id, mydate, 1); 
            system.debug('=============created=========  ' + newdate)
        
        
        
        */
        
        //MMDDYYYY
        //orderInfo.ServiceStartDate          =  string.valueof(InitialDateofService);
        system.debug('initdateofservice' +monthS1+dayS1+newdate.year());
        orderInfo.ServiceStartDate          =  monthS1+dayS1+newdate.year();
        }else
        {
        
        orderInfo.ServiceStartDate          =  string.valueof(InitialDateofService);
        }
        //orderInfo.LocationInfoArray.LocationInfo.
        
        orderLst.add(orderInfo);
        system.debug('order list                            ' + orderLst);
        orderArray.OrderInfo = orderLst;
        req.OrderInfoArray = orderArray;
        // not calling order yet
        VirginiaPowerEnroll.CreateOrderResponse orderResp1 = new VirginiaPowerEnroll.CreateOrderResponse();
        List<VirginiaPowerEnroll.OrderResponse> ordRespArray = new List<VirginiaPowerEnroll.OrderResponse>();
        VirginiaPowerEnroll.CreateOrderResponse_element response_x;
        List<order__c> order = [select id,name , reporderid__c, repstatus__c, order_status__c from order__c where id =:orderid];
        try{
        orderResp1 = status.CreateOrder(req);
        }
        catch (CalloutException e)
        {
         system.debug('callout exception ' +e);
         order[0].exception__c = e.getMessage();
         update order; 
         return null;
        }
        ordRespArray = orderResp1.OrderResponse.OrderResponse;
        system.debug('Response: ______________' + orderResp1.OrderResponse.OrderResponse);
            VirginiaPowerEnroll.ArrayOfChargeInfo ChargeInfo ;
            List<VirginiaPowerEnroll.ChargeInfo> chginf = new List<VirginiaPowerEnroll.ChargeInfo>();
        ChargeInfo = ordRespArray[0].ChargeInfo;
        system.debug('Response: ______________' +ordRespArray[0].ChargeInfo);
        chginf = ChargeInfo.ChargeInfo;
        system.debug('response chginf' + chginf);
        /*
        if ( chginf.size() > 0)
        {
        for (integer i = 0; i == chginf.size(); i++) {
            system.debug('response:_______________' + chginf[i].ChargeAmount);
            system.debug('response:_______________' + chginf[i].ChargeType);
            }
        system.debug('response:_______________' + chginf[0].ChargeAmount);
        system.debug('response:_______________' + chginf[0].ChargeType);
        }
        */
        system.debug('Response: ______________' +ordRespArray[0].OrderId);
        system.debug('Response: ______________' +ordRespArray[0].OrderStatus);
        system.debug('Response: ______________' +ordRespArray[0].ServiceStartDt);
    
        //Approved Pending Confirmation
        //Rejected 
        //Confirmed
        //REPOrderId__c
        //REPStatus--c
       
        order[0].reporderid__c = ordRespArray[0].OrderId;
        order[0].repstatus__c  = ordRespArray[0].OrderStatus;
        
        
        // map cirro to truecost status
   	// Changed on Aug 26 2013 per email from ramazon
       //if ('Active'.equals(ordRespArray[0].OrderStatus) )
       if ('Approved'.equals(ordRespArray[0].OrderStatus) )
       {
         order[0].Order_Status__c           = 'Approved';
       	 order[0].REPStatus__c         		= ordRespArray[0].OrderStatus;
         order[0].REPOrderSubStatus__c		= ordRespArray[0].OrderSubStatus;
       
       }
       if ('Cancelled'.equals(ordRespArray[0].OrderStatus))
       {
         order[0].Order_Status__c           = 'Cancelled';
       	 order[0].REPStatus__c         		= ordRespArray[0].OrderStatus;
         order[0].REPOrderSubStatus__c		= ordRespArray[0].OrderSubStatus;
       
       }
       
       if ('Pending'.equals(ordRespArray[0].OrderStatus))
       {
         order[0].Order_Status__c           = 'Pending';
       	 order[0].REPStatus__c         		= ordRespArray[0].OrderStatus;
         order[0].REPOrderSubStatus__c		= ordRespArray[0].OrderSubStatus;
       
       }
        
        
        update order;
   //setOrder(name,ordRespArray[0].OrderId, ordRespArray[0].OrderStatus);
   
        }else{
        List<order__c> order = [select id,name , reporderid__c, repstatus__c, order_status__c from order__c where id =:orderid];
        
        order[0].Order_Status__c   = 'System not Available';
        update order;
        
        
        }
  return null;
    
    
    }
}