public  class TriEagleAPI {

	public static void TriEagleAsyncCall (string orderid){
		list<logger__c> log = new list<logger__c>();

		order__c o = [select id, ownerid,Authorized_Representative__c,Parent_Account__c,reporderid__c,record_type_name__c, rate__c,SSN__c,rep_profile__r.name,order_status__c, premise__r.id, premise__c,Plan_ID__c,  order_expiration_date__c, createddate, name,First_Name__c,Last_Name__c,Customer_date_of_birth__c,Critical_Care__c,Mailing_Street_Address__c,Mailing_City__c,Mailing_State__c,Mailing_Zip_Code__c,Service_Address__c,Service_State__c,Service_City__c,Service_Zip__c,InitialDateofService__c,Enrollment_Type__c,PMVI_Flag__c,ESIID_Number__c,Customer_Email__c, Customer_Phone_Number__c ,REP_email__c ,Fixed_Energy_Rate__c,
			exception__c, repstatus__c, Rate__r.Name, Language_Preference__c

			from order__c where id =: orderid];

		PartnerAPI__c Papi = PartnerAPI__c.getInstance(o.REP_Profile__r.Name);

		string phone = NewLeafAPImrg.stripPhoneCharacters(o.Customer_Phone_Number__c);
		string ssn = NewLeafAPImrg.stripPhoneCharacters(o.SSN__c);
		integer ratename = Integer.valueof(o.Rate__r.Name);
		
		string ServiceDate = '';
		string SwitchType = 'Switching Service';

		if (o.Enrollment_Type__c =='Move-In'){
			ServiceDate = string.valueof(BusinessHoursDate(o.InitialDateofService__c));
			SwitchType = 'Move-In';
		} else if (o.Enrollment_Type__c == 'Self-Selected Switch'){
			ServiceDate = string.valueof(BusinessHoursDate(o.InitialDateofService__c));
		}


		ServiceDate = string.valueof(o.InitialDateofService__c);

		if (o.Mailing_Street_Address__c == null){
			o.Mailing_Street_Address__c = o.Service_Address__c;
			o.Mailing_City__c = o.Service_City__c;
			o.Mailing_State__c = o.Service_State__c;
			o.Mailing_Zip_Code__c = o.Service_Zip__c;
		}


		Trieagleenergy.TRUSTSoap req = new  Trieagleenergy.TRUSTSoap(); 

		String resp = req.CreateCustomer(
			ratename, //rate number
			o.ESIID_Number__c, 
			Papi.Partner_code__c, //partner name ("web code")
			o.First_Name__c, 
			o.Last_Name__c, 
			phone, 
			phone, 
			o.Customer_Email__c, 
			ssn, 
			o.Language_Preference__c, 
			o.Authorized_Representative__c, 
			SwitchType, //"Move-In" or "Switching Service"
			ServiceDate, //"Initial Date Of Service (req for move-in)"
			o.Mailing_Street_Address__c, 
			'', //address line 2
			o.Mailing_City__c , 
			o.Mailing_State__c, 
			o.Mailing_Zip_Code__c, 
			Papi.Username__c //api key);
		);

		//handle response
		logger__c log1 = new logger__c();		
		log1.name       = 'trieagle response :';
		
		log1.message__c = resp;
		log1.order__c    = o.id;
		log.add(log1);
		
		Dom.Document docRes = new Dom.Document();		
		docRes.load(resp);
		
		//Retrieve the root element for this document.
		Dom.XMLNode s = docRes.getRootElement();
		Dom.XMLNode EnvelopeRes = docRes.getRootElement();
		Dom.XMLNode BodyRes= EnvelopeRes.getChildElements()[0];	
	 
		String results = '';
		string statusCode = '';
		string successCode = '';
		String SuccessMessage = '';
		String CustomerId = '';
		String  ErrorCode = '';
		String  ErrorMessage = '';

		
		for(Dom.XMLNode childRes : s.getChildElements()) {
			
			if (childres.getName() == 'statusCode')
				statusCode = childRes .getText();
			if (childres.getName() == 'SuccessCode')
				successCode = childRes .getText(); 
			if (childres.getName() == 'SuccessMessage')
				SuccessMessage = childRes .getText();
			if (childres.getName() == 'CustomerID')
				CustomerId = childRes .getText();
			if (childres.getName() == 'ErrorCode')
				ErrorCode = childRes .getText();
			if (childres.getName() == 'ErrorMessage')
				ErrorMessage = childRes .getText();
		}

		system.debug('statuscode:'+ statuscode);
		system.debug('successcode:'+ successcode);
		//1 is succcess 0 is error
		system.debug('success message;' +successmessage);
		system.debug('customer id;' + customerID);
		system.debug('error code;' + errorCode);
		system.debug('error message;' + errormessage); 

		if (statuscode=='1'){
			o.REPStatus__c         		= successcode;
			o.REPOrderSubStatus__c		= successmessage;
			o.REPOrderId__c             = customerID;

			if ('200'.equals(successcode)){
				o.Order_Status__c           = 'Approved Pending Confirmation';		
			}
			if ('201'.equals(successcode)){
				o.Order_Status__c           = 'Approved Pending Deposit';			
			}	   
			if ('202'.equals(successcode)){
				o.Order_Status__c           = 'Pending';	
			}
		}
	   
		if (statuscode == '0' ){
			o.Order_Status__c = 'API Exception';
			o.REPStatus__c         		= errorcode;
			o.REPOrderSubStatus__c		= errormessage;
		}

		logger__c log3 = new logger__c();
		log3.name       = 'trieagle customerid :';
		
		log3.message__c = customerid +':'+ successcode +':' +successmessage;
		log3.order__c    = o.id;
		log.add(log3);
		
	   
		if (customerID.length()>0){
			insert new AsyncRequest__c(type__c = 'TriEagleOrderCheck', params__c = o.id);
		}
		
		update o;
		insert log;
	}

	public static void TriEagleOrderCheck (string orderid){

		order__c order = [select id,name , REP_Profile__r.Name, reporderid__c, exception__c, repstatus__c,repordersubstatus__c, order_status__c ,ESIID_Number__c from order__c where id  =:  orderid];
		if (order.reporderid__c.length()==0) return;

		PartnerAPI__c Papi = PartnerAPI__c.getInstance(order.REP_Profile__r.Name);

		Trieagleenergy.TRUSTSoap req = new  Trieagleenergy.TRUSTSoap(); 
		String resp = '';
    
		
		resp = req.ConfirmCustomer(integer.valueof(order.reporderid__c), string.valueof(order.ESIID_Number__c), Papi.Username__c);
		system.debug('response   '+ resp);
		
		Dom.Document docRes = new Dom.Document();
		
		docRes.load(resp);
		
		//Retrieve the root element for this document.
		
		Dom.XMLNode s = docRes.getRootElement();
		Dom.XMLNode EnvelopeRes = docRes.getRootElement();
		Dom.XMLNode BodyRes= EnvelopeRes.getChildElements()[0];
		
		system.debug('bodyres!!!!!!!!!!: '+ bodyRes);
	 
		String results = '';
		string statusCode = '';
		string successCode = '';
		String SuccessMessage = '';
		String CustomerId = '';
		String  ErrorCode = '';
		String  ErrorMessage = '';

		
		for(Dom.XMLNode childRes : s.getChildElements()) {
			
		if (childres.getName() == 'statusCode')
			statusCode = childRes .getText();
		if (childres.getName() == 'SuccessCode')
		   successCode = childRes .getText(); 
		if (childres.getName() == 'SuccessMessage')
			SuccessMessage = childRes .getText();
		if (childres.getName() == 'CustomerID')
			CustomerId = childRes .getText();
		if (childres.getName() == 'ErrorCode')
			ErrorCode = childRes .getText();
		if (childres.getName() == 'ErrorMessage')
			ErrorMessage = childRes .getText();
		}

		system.debug('statuscode:'+ statuscode);
		system.debug('successcode:'+ successcode);
		//1 is succcess 0 is error
		system.debug('success message;' +successmessage);
		system.debug('customer id;' + customerID);
		system.debug('error code;' + errorCode);
		system.debug('error message;' + errormessage); 
	   
		if (statuscode == '1'){
	   		order.REPStatus__c         		= successcode;
			order.REPOrderSubStatus__c		= successmessage;
			if ('200'.equals(successcode)) {  order.Order_Status__c = 'Approved Pending Confirmation'; } 
	   		else if ('201'.equals(successcode)) {  order.Order_Status__c = 'Approved Pending Deposit'; }
			else if ('202'.equals(successcode)) {  order.Order_Status__c = 'Pending'; }
		} else if (statuscode == '0' ) {
			order.Order_Status__c           = 'API Exception';
			order.REPStatus__c         		= errorcode;
			order.REPOrderSubStatus__c		= errormessage;		 
		}
		
		
		update order;
		
	}

	public static date BusinessHoursDate(date d){
		list<BusinessHours> REPhours = [select id from BusinessHours where name = 'REP SLA']; //Finds the REP business hours  
		Datetime newdate;
		If (!REPhours.isEmpty()){
			newdate = BusinessHours.add(REPhours[0].id, d, 1); //if we're out of business hours, roll to the next day
		} else { newdate = Date.newInstance(2020,5,1);}
		Date dateTemp = Date.newInstance(newdate.year(),newdate.month(),newdate.day()); //now back from datetime to date
		return dateTemp;
	}

	
	public boolean enabled = false;
	public order__C[] orderlist;
	
	public void placeOrder(order__C[] orderlist){
		//, String rep, String rateId
		
		System.debug('api list'+ orderlist[0]);
		System.debug('name' +orderlist[0].rep_profile__r.name );
		
		system.debug('pmvi flag!!!!!!!!!!!!!!!!!!!!!!!!!!'+  orderlist[0]);
		system.debug('name sent!!!!!!!!!!!!!!!!!!!!!!!!!!'+  orderlist[0].name);
		system.debug('rateid !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'+ orderlist[0].Rate__c);
		
	 
		if (orderlist[0].rep_profile__r.name == 'TriEagle Energy' ){
			system.debug('orderid passes'+orderlist[0].name);
		
			callTriEagle(orderlist[0].Authorized_Representative__c,orderlist[0].ssn__c,orderlist[0].Critical_Care__c, orderlist[0].name, orderlist[0].id, orderlist[0].First_Name__c,orderlist[0].Last_Name__c,orderlist[0].Customer_Date_of_Birth__c,orderlist[0].Mailing_City__c,orderlist[0].Mailing_State__c,orderlist[0].Mailing_Street_Address__c,orderlist[0].Mailing_Zip_Code__c,orderlist[0].Service_Address__c,orderlist[0].Service_City__c,orderlist[0].Service_State__c,orderlist[0].Service_Zip__c,orderlist[0].InitialDateofService__c,orderlist[0].Enrollment_Type__c, orderlist[0].Plan_ID__c,orderlist[0].ESIID_Number__c,orderlist[0].Customer_Email__c, orderlist[0].Customer_Phone_Number__c,orderlist[0].rate__c);
   
		}else{
		
		
		// set system not available code
		
		}
	}

   


	@Future(callout=true)
   private static void callTriEagle(string authrep, String ssn, boolean criticalcare, String name, String orderid, String FirstName, String LastName,Date CustomerDateofBirth, String MailingCity,String MailingState, String MailingStreetAddress,String MailingZipCode,String ServiceAddress,String ServiceCity,String ServiceState, String ServiceZip,Date InitialDateofService,String enrollmenttype,String plan,String esiid,String email, String phone, String rate)
   {
	ProcessorControl.inFutureContext = true;
	system.debug('order id: ' + orderid);
	List<order__c> orderName = [select id,name , reporderid__c, repstatus__c, order_status__c from order__c where id =:orderid];
	name = orderName[0].name;



if(MailingStreetAddress == null)
{
MailingStreetAddress = ServiceAddress;
MailingCity          = ServiceCity;
MailingState         = ServiceState;
MailingZipCode       = ServiceZip;
}

phone = phone.replace('(','');
phone = phone.replace(')','');
phone = phone.replace('-','');
ssn   = ssn.replace('-','');
ssn   = ssn.replace(' ','');
System.debug('ssn '+ ssn); 

rate__c rateName = [SELECT Name FROM Rate__c WHERE Id =: rate limit 1];
		List<logger__c> log = new List<logger__c>();
		List<Exceptions__c> ex = new List<Exceptions__c>();
		
		logger__c logStart = new logger__c();
		logStart.name       = 'trieagle start:';
		
		logStart.message__c = enrollmenttype +' : '+ InitialDateofService;
		logStart.order__c    = orderid;
		log.add(logStart);


	   if (InitialDateofService == null || InitialDateofService == date.today())
		 {
		 InitialDateofService = date.today();
		 InitialDateofService.addDays(3);
		 }
   
	
	  /*
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
		
		}*/
		

		list<BusinessHours> REPhours = [select id from BusinessHours where name = 'REP SLA']; //Finds the REP business hours 
   
		Datetime newdate = BusinessHours.add(REPhours[0].id, InitialDateofService, 1); 
			
	
		
	 
	 
	 
	 
		List<order__c> order = [select id,name , reporderid__c, exception__c, repstatus__c, order_status__c, InitialDateofService__c from order__c where id =:orderid];
		
	   Trieagleenergy.TRUSTSoap req = new  Trieagleenergy.TRUSTSoap(); 
	   String resp = '';
	  
		Date dateTemp = Date.newInstance(newdate.year(),newdate.month(),newdate.day());
   
		try{
		// Integer ratee = 3647; 
		Integer ratee = Integer.valueof(rateName.name); 	
		  //       CreateCustomer(Integer rateID,String esiid,String webCode,String firstName,String lastName,String phone,String altPhone,String email,String ssn,String language,String authRep,String signUpType,String requestedDate,String billingAddress,String billingAddress2,String billingCity,String billingState,String billingZipCode,String APIKey)
		//API Key: 8419827582276416762857489  prod
		//URL: http://www.trieagleenergy.com/webservices/trust.asmx?WSDL prod
		// qa 7845748957489574895734574
		system.debug('move in date:       '+string.valueof(dateTemp));
		if( enrollmenttype  == 'Move-In')
		{
		
		resp = req.CreateCustomer(ratee, esiid, 'CENTERPOINT', FirstName, LastName, phone, phone, email, ssn, 'English', authrep, 'Move-In', string.valueof(dateTemp), MailingStreetAddress, '', MailingCity, MailingState, MailingZipCode, '8419827582276416762857489');
		 order[0].InitialDateofService__c = dateTemp;
		 }else if(enrollmenttype == 'Self-Selected Switch'){
		resp = req.CreateCustomer(ratee, esiid, 'CENTERPOINT', FirstName, LastName, phone, phone, email, ssn, 'English', authrep, 'Switching Service', string.valueof(dateTemp), MailingStreetAddress, '', MailingCity, MailingState, MailingZipCode, '8419827582276416762857489');
	  order[0].InitialDateofService__c = dateTemp;
		} else{
		
		 resp = req.CreateCustomer(ratee, esiid, 'CENTERPOINT', FirstName, LastName, phone, phone, email, ssn, 'English', authrep, 'Switching Service', '', MailingStreetAddress, '', MailingCity, MailingState, MailingZipCode, '8419827582276416762857489');
	  
		} 
		
		//system.debug(resp);
		logger__c log1 = new logger__c();
		log1.name       = 'trieagle response :';
		
		log1.message__c = resp;
		log1.order__c    = orderid;
		log.add(log1);
		
		 Dom.Document docRes = new Dom.Document();
		
		docRes.load(resp);
		
		//Retrieve the root element for this document.
		
		Dom.XMLNode s = docRes.getRootElement();
		Dom.XMLNode EnvelopeRes = docRes.getRootElement();
		Dom.XMLNode BodyRes= EnvelopeRes.getChildElements()[0];
		
	
	 
		String results = '';
		string statusCode = '';
		string successCode = '';
		String SuccessMessage = '';
		String CustomerId = '';
		String  ErrorCode = '';
		String  ErrorMessage = '';

		
		for(Dom.XMLNode childRes : s.getChildElements()) {
			
		if (childres.getName() == 'statusCode')
			statusCode = childRes .getText();
		if (childres.getName() == 'SuccessCode')
		   successCode = childRes .getText(); 
		if (childres.getName() == 'SuccessMessage')
			SuccessMessage = childRes .getText();
		if (childres.getName() == 'CustomerID')
			CustomerId = childRes .getText();
		if (childres.getName() == 'ErrorCode')
			ErrorCode = childRes .getText();
		if (childres.getName() == 'ErrorMessage')
			ErrorMessage = childRes .getText();
		}

system.debug('statuscode:'+ statuscode);
system.debug('successcode:'+ successcode);
//1 is succcess 0 is error
system.debug('success message;' +successmessage);
system.debug('customer id;' + customerID);
system.debug('error code;' + errorCode);
system.debug('error message;' + errormessage); 

if (errormessage != null){

  Exceptions__c error = new Exceptions__c(
			  
			   Name = 'Apex Exception - Trieagle',
			   Error__c = errormessage,
			   Error_Type__c = 'tri eagle response'
			  );
			ex.add(error);   
			  //insert error;
}
	   
	   if (statuscode == '1' && '200'.equals(successcode))
	   {
		 order[0].Order_Status__c           = 'Approved Pending Confirmation';
		 order[0].REPStatus__c         		= successcode;
		 order[0].REPOrderSubStatus__c		= successmessage;
		 order[0].REPOrderId__c             = customerID;
	   
	   }
	   if (statuscode == '1' && '201'.equals(successcode))
	   {
		 order[0].Order_Status__c           = 'Approved Pending Deposit';
		 order[0].REPStatus__c         		= successcode;
		 order[0].REPOrderSubStatus__c		= successmessage;
		 order[0].REPOrderId__c             = customerID;
	   }
	   
		if (statuscode == '1' && '202'.equals(successcode))
	   {
		 order[0].Order_Status__c           = 'Pending';
		 order[0].REPStatus__c         		= successcode;
		 order[0].REPOrderSubStatus__c		= successmessage;
		 order[0].REPOrderId__c             = customerID;
	   }
	   
	  if (statuscode == '0' )
	   {
		 order[0].Order_Status__c           = 'Pending';
		 order[0].REPStatus__c         		= errorcode;
		 order[0].REPOrderSubStatus__c		= errormessage;
		 
	   }
		
		String respConfirm = '';
		
		logger__c log3 = new logger__c();
		log3.name       = 'trieagle customerid :';
		
		log3.message__c = customerid +':'+ successcode +':' +successmessage;
		log3.order__c    = orderid;
		log.add(log3);
		
	   if (customerID != null){
		logger__c log5 = new logger__c();
		log5.name       = 'trieagle confirm start:';
		
		log5.message__c = customerid +':'+ esiid+':' +successmessage;
		log5.order__c    = orderid;
		log.add(log5);
		//Trieagleenergy.TRUSTSoap req = new  Trieagleenergy.TRUSTSoap();
		respConfirm = req.ConfirmCustomer(integer.valueof(customerID), esiid, '8419827582276416762857489');
		
		logger__c log4 = new logger__c();
		log4.name       = 'trieagle confirm resp:';
		
		log4.message__c = respConfirm;
		log4.order__c    = orderid;
		log.add(log4);
	   
		
		//confirm
		Dom.Document docResConfirm = new Dom.Document();
		
		docResConfirm.load(respConfirm);
		
		//Retrieve the root element for this document.
		
		Dom.XMLNode sConfirm = docResConfirm.getRootElement();
		Dom.XMLNode EnvelopeResConfirm = docResConfirm.getRootElement();
		Dom.XMLNode BodyResConfirm= EnvelopeResConfirm.getChildElements()[0];
		
		system.debug('bodyres!!!!!!!!!!: '+ bodyResconfirm);
	 
		String resultsConfirm = '';
		string statusCodeConfirm = '';
		string successCodeConfirm = '';
		String SuccessMessageConfirm = '';
		String CustomerIdConfirm = '';
		String  ErrorCodeConfirm = '';
		String  ErrorMessageConfirm = '';

		
		for(Dom.XMLNode childRes : sConfirm.getChildElements()) {
			
		if (childres.getName() == 'statusCode')
			statusCodeConfirm = childRes .getText();
		if (childres.getName() == 'SuccessCode')
		   successCodeConfirm = childRes .getText(); 
		if (childres.getName() == 'SuccessMessage')
			SuccessMessageConfirm = childRes .getText();
		if (childres.getName() == 'CustomerID')
			CustomerIdConfirm = childRes .getText();
		if (childres.getName() == 'ErrorCode')
			ErrorCodeConfirm = childRes .getText();
		if (childres.getName() == 'ErrorMessage')
			ErrorMessageConfirm = childRes .getText();
		}
		order[0].REPOrderSubStatus__c = SuccessMessageConfirm;
		
		//confirm
	   }
		
		
		
		
		
		}
		catch (CalloutException ce)
		{
		system.debug('callout exception ' +ce);
		  Exceptions__c error = new Exceptions__c(
			  
			   Name = 'Apex Exception - ' + System.now(),
			   Error__c = ce.getMessage(),
			   Error_Type__c = ce.getTypeName()
			  );
			   
			  insert error;
		  
		}
		catch (Exception e)
		{
		system.debug('callout exception ' +e);
		  Exceptions__c error = new Exceptions__c(
			  
			   Name = 'Apex Exception trieagle order ' + order[0].name,
			   Error__c = e.getMessage(),
			   Error_Type__c = e.getTypeName()
			  );
			   
			  insert error;
		  
		}
		finally{
		//insert ex;
		update order;
		insert log;
		
   
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
public  void checkEagleStatus(){
	
	
	  
	 
	 
	 
		order__c order = [select id,name , reporderid__c, exception__c, repstatus__c,repordersubstatus__c, order_status__c ,ESIID_Number__c from order__c where repordersubstatus__c = 'Customer was accepted but is still unconfirmed' limit 1];
		
	   Trieagleenergy.TRUSTSoap req = new  Trieagleenergy.TRUSTSoap(); 
	   String resp = '';
	  
		
   
		try{
	   
		  //       CreateCustomer(Integer rateID,String esiid,String webCode,String firstName,String lastName,String phone,String altPhone,String email,String ssn,String language,String authRep,String signUpType,String requestedDate,String billingAddress,String billingAddress2,String billingCity,String billingState,String billingZipCode,String APIKey)
		//API Key: 8419827582276416762857489  prod
		//URL: http://www.trieagleenergy.com/webservices/trust.asmx?WSDL prod
		// qa 7845748957489574895734574
		//resp = req.ConfirmCustomer(customerID, esiid, APIKey)
	  
		resp = req.ConfirmCustomer(integer.valueof(order.reporderid__c), string.valueof(order.ESIID_Number__c), '8419827582276416762857489');
		 system.debug('response   '+ resp);
	   
		}
		catch (CalloutException e)
		{
		system.debug('callout exception ' +e);
		  Exceptions__c error = new Exceptions__c(
			  
			   Name = 'Apex Exception - ' + System.now(),
			   Error__c = e.getMessage(),
			   Error_Type__c = e.getTypeName()
			  );
			   
			  insert error;
		  
		}
		
		//
		
		 Dom.Document docRes = new Dom.Document();
		
		docRes.load(resp);
		
		//Retrieve the root element for this document.
		
		Dom.XMLNode s = docRes.getRootElement();
		Dom.XMLNode EnvelopeRes = docRes.getRootElement();
		Dom.XMLNode BodyRes= EnvelopeRes.getChildElements()[0];
		
		system.debug('bodyres!!!!!!!!!!: '+ bodyRes);
	 
		String results = '';
		string statusCode = '';
		string successCode = '';
		String SuccessMessage = '';
		String CustomerId = '';
		String  ErrorCode = '';
		String  ErrorMessage = '';

		
		for(Dom.XMLNode childRes : s.getChildElements()) {
			
		if (childres.getName() == 'statusCode')
			statusCode = childRes .getText();
		if (childres.getName() == 'SuccessCode')
		   successCode = childRes .getText(); 
		if (childres.getName() == 'SuccessMessage')
			SuccessMessage = childRes .getText();
		if (childres.getName() == 'CustomerID')
			CustomerId = childRes .getText();
		if (childres.getName() == 'ErrorCode')
			ErrorCode = childRes .getText();
		if (childres.getName() == 'ErrorMessage')
			ErrorMessage = childRes .getText();
		}

system.debug('statuscode:'+ statuscode);
system.debug('successcode:'+ successcode);
//1 is succcess 0 is error
system.debug('success message;' +successmessage);
system.debug('customer id;' + customerID);
system.debug('error code;' + errorCode);
system.debug('error message;' + errormessage); 
	   
	   if (statuscode == '1' && '200'.equals(successcode))
	   {
		 order.Order_Status__c           = 'Approved Pending Confirmation';
		 order.REPStatus__c         		= successcode;
		 order.REPOrderSubStatus__c		= successmessage;
		 order.REPOrderId__c             = customerID;
	   
	   }
	   if (statuscode == '1' && '201'.equals(successcode))
	   {
		 order.Order_Status__c           = 'Approved Pending Deposit';
		 order.REPStatus__c         		= successcode;
		 order.REPOrderSubStatus__c		= successmessage;
		 order.REPOrderId__c             = customerID;
	   }
	   
		if (statuscode == '1' && '202'.equals(successcode))
	   {
		 order.Order_Status__c           = 'Pending';
		 order.REPStatus__c         		= successcode;
		 order.REPOrderSubStatus__c		= successmessage;
		 order.REPOrderId__c             = customerID;
	   }
	   
	  if (statuscode == '0' )
	   {
		 order.Order_Status__c           = 'Failed';
		 order.REPStatus__c         		= errorcode;
		 order.REPOrderSubStatus__c		= errormessage;
		 
	   }
		
		update order;
   
  
 
   
}

public static void getProviders()
{

		Trieagleenergy.TRUSTSoap soap = new  Trieagleenergy.TRUSTSoap();
		String providers = soap.GetProviders('77565', '7845748957489574895734574');
		system.debug('providers'+ providers);
//Centerpoint 4
}

public static void getRates()
{

		Trieagleenergy.TRUSTSoap soap = new  Trieagleenergy.TRUSTSoap();
		String rates = soap.GetRates(4, 'CENTERPOINT', '8419827582276416762857489');
		
		system.debug('providers'+ rates);
		
		/*
		roviders<?xml version="1.0"?><Rates><rate><rateID>3173</rateID><energyRate>9.4</energyRate><rate_500>10.4</rate_500><rate_1000>9.9</rate_1000><rate_2000>9.6</rate_2000><planName>TEFIX12</planName><displayName>Eagle 12</displayName><tagLine> <![CDATA[Great rate with no gimmicks!]]></tagLine><tagLine2>12 Month Fixed Price Plan</tagLine2><term>12</term><earlyCancellationFee> <![CDATA[$20.00 for each month remaining in contract]]></earlyCancellationFee><renewableContent>4</renewableContent><stateAverageRenewableContent>9</stateAverageRenewableContent><monthly>4.95</monthly></rate>
		<rate><rateID>3245</rateID><energyRate>9.7</energyRate><rate_500>10.7</rate_500><rate_1000>10.2</rate_1000><rate_2000>9.9</rate_2000><planName>GEFIX12</planName><displayName>Green Eagle 12</displayName><tagLine> <![CDATA[Do what's right for the environment with 100% renewable]]></tagLine><tagLine2> <![CDATA[100% Renewable Energy]]></tagLine2><term>12</term><earlyCancellationFee> <![CDATA[$20.00 for each month remaining in contract]]></earlyCancellationFee><renewableContent>100</renewableContent><stateAverageRenewableContent>9</stateAverageRenewableContent><monthly>4.95</monthly></rate>
		<rate><rateID>3647</rateID><energyRate>9.1</energyRate><rate_500>10.1</rate_500><rate_1000>9.6</rate_1000><rate_2000>9.3</rate_2000><planName>TEFIX16</planName><displayName>Eagle 16</displayName><tagLine> <![CDATA[Avoid potential price spikes until 2014!]]></tagLine><tagLine2>16 Month Fixed Price Plan</tagLine2><term>16</term><earlyCancellationFee> <![CDATA[$20.00 for each month remaining in contract]]></earlyCancellationFee><renewableContent>4</renewableContent><stateAverageRenewableContent>9</stateAverageRenewableContent><monthly>4.95</monthly></rate>
		<rate><rateID>3686</rateID><energyRate>9.4</energyRate><rate_500>10.4</rate_500><rate_1000>9.9</rate_1000><rate_2000>9.6</rate_2000><planName>GEFIX16</planName><displayName>Green Eagle 16</displayName><tagLine> <![CDATA[Do what's right for the environment with 100% renewable]]></tagLine><tagLine2> <![CDATA[100% Renewable Energy]]></tagLine2><term>16</term><earlyCancellationFee> <![CDATA[$20.00 for each month remaining in contract]]></earlyCancellationFee><renewableContent>100</renewableContent><stateAverageRenewableContent>9</stateAverageRenewableContent><monthly>4.95</monthly></rate>
		<rate><rateID>3221</rateID><energyRate>9.6</energyRate><rate_500>10.6</rate_500><rate_1000>10.1</rate_1000><rate_2000>9.8</rate_2000><planName>TEFIX24</planName><displayName>Eagle 24</displayName><tagLine> <![CDATA[Avoid potential price spikes for 2 years!]]></tagLine><tagLine2>24 Month Fixed Price Plan</tagLine2><term>24</term><earlyCancellationFee> <![CDATA[$20.00 for each month remaining in contract]]></earlyCancellationFee><renewableContent>4</renewableContent><stateAverageRenewableContent>9</stateAverageRenewableContent><monthly>4.95</monthly></rate>
		<rate><rateID>3293</rateID><energyRate>9.9</energyRate><rate_500>10.9</rate_500><rate_1000>10.4</rate_1000><rate_2000>10.1</rate_2000><planName>GEFIX24</planName><displayName>Green Eagle 24</displayName><tagLine> <![CDATA[Do what's right for the environment with 100% renewable]]></tagLine><tagLine2> <![CDATA[100% Renewable Energy]]></tagLine2><term>24</term><earlyCancellationFee> <![CDATA[$20.00 for each month remaining in contract]]></earlyCancellationFee><renewableContent>100</renewableContent><stateAverageRenewableContent>9</stateAverageRenewableContent><monthly>4.95</monthly></rate></Rates>
		
		*/
//Centerpoint 4
}
 
}