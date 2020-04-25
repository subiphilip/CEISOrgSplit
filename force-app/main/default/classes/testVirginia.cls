public with sharing class testVirginia {
	
	public testVirginia()
	{
	   
	   
    	
	
	
	
	}
	
	public void createOrder()
	{
	
	VirginiaPowerEnroll.RetailOrderAutomationServiceSoap status = new VirginiaPowerEnroll.RetailOrderAutomationServiceSoap();
    	VirginiaPowerEnroll.CheckSystemStatus   newStat = new VirginiaPowerEnroll.CheckSystemStatus();
    	VirginiaPowerEnroll.CheckSystemStatusResponse resp = new VirginiaPowerEnroll.CheckSystemStatusResponse();
    	VirginiaPowerEnroll.CreateOrderResponse orderResp = new VirginiaPowerEnroll.CreateOrderResponse();
    	
    	
    	resp = status.CheckSystemStatus(newStat);
    	system.debug('response!!!!!!!!!!!!!!!!!!!!!!!!!!'+ resp);
    	
    	String resp1 = null;
    	cirro.BasicHttpBinding_IService1 svc = new cirro.BasicHttpBinding_IService1();
		resp1 =  svc.getData(991597994);
		system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'+ resp1.substring(13,resp1.length()));
    	
    	
    	VirginiaPowerEnroll.CreateOrderRequest req = new VirginiaPowerEnroll.CreateOrderRequest();
    	//System Information
    	req.ClientSystem 						= 'TCOST';
    	req.UserId       						= '10000663';
    	req.Token        						= 'myTokenId';
    	req.AgentId      						= '161';
    	req.LeadSource   						= 'AGT'; 
    	req.UdcNameCode  						= 'CNP1';
    	req.CreditCheckInd                      = 'Y';
    	req.ValidationInd                       = 'N'; 
    	// Customer Information
    	VirginiaPowerEnroll.CustomerInfo customerInfo = new VirginiaPowerEnroll.CustomerInfo();
    	customerInfo.CustomerType   		= 'Residential';
    	customerInfo.CustomerFirstName		= 'FirstName';
    	customerInfo.CustomerLastName		= 'LastName';
    	customerInfo.Birthdate				= '0214';
    	customerInfo.SocialSecurityNum		=  resp1.substring(13,resp1.length());
    	customerInfo.BillingLanguage		= 'English';
    	customerInfo.LifeSupportIndicator	= 'N';
    	req.CustomerInfo = customerInfo;
    	//Address Information
    	
    	VirginiaPowerEnroll.ArrayOfAddressInfo  aiArray = new VirginiaPowerEnroll.ArrayOfAddressInfo();
    	//VirginiaPowerEnroll.AddressInfo arAddreInfo = new VirginiaPowerEnroll.AddressInfo();
    	VirginiaPowerEnroll.AddressInfo ai    = new VirginiaPowerEnroll.AddressInfo();
    	List<VirginiaPowerEnroll.AddressInfo> bi    = new List<VirginiaPowerEnroll.AddressInfo>();
    	ai.PrimaryResidenceInd     				= 'Y';
    	ai.AddressType             				= 'Billing';
    	ai.AddressLine1            				= '308 Harborside Cir';
    	ai.AddressLine2            				= 'Line2';
    	ai.City                    				= 'Kemah';
    	ai.StateCode               				= 'TX';
    	ai.Zip                     				= '77565';
    	
    	
 
    	system.debug('address1    '+ ai);
    	bi.add(ai);
    	VirginiaPowerEnroll.AddressInfo ais    = new VirginiaPowerEnroll.AddressInfo();
    	ais.PrimaryResidenceInd     				= 'Y';
    	ais.AddressType             				= 'Service';
    	ais.AddressLine1            				= '308 Harborside Cir';
    	ais.AddressLine2            				= 'Line2';
    	ais.City                    				= 'Kemah';
    	ais.StateCode               				= 'TX';
    	ais.Zip                     				= '77565';
    	bi.add(ais);
    	aiArray.AddressInfo = bi;
    	
    	
    	system.debug('address2    '+ aiArray);
    	//system.debug('address3    '+ arAddreInfo);
    
    	req.AddressInfoArray = aiArray;
    	system.debug('address3    '+ req.AddressInfoArray);
    	/*
    	
    	//Contact Info
    	system.debug('contact1    '+ req.ContactInfo.);
    	req.ContactInfo.AllowEmailUsageInd      = 'Y';
    	req.ContactInfo.ContactEmailAddr        = 'bglasco@gmail.com';
    	req.ContactInfo.ContactType             = 'CS';
    	req.ContactInfo.OnlineAccess            = 'Y';
    	
    	VirginiaPowerEnroll.ArrayOfPhoneInfo phoneArray = new VirginiaPowerEnroll.ArrayOfPhoneInfo();
    	
    	VirginiaPowerEnroll.PhoneInfo phone = new VirginiaPowerEnroll.PhoneInfo();
    	
    	List<VirginiaPowerEnroll.PhoneInfo> pi    = new List<VirginiaPowerEnroll.PhoneInfo>();
    	
    	phone.PhoneNumber               = '9999999999';
    	phone.PhoneType                 = 'HM';
    	
    	pi.add(phone);
    	system.debug('phone pre___________________-                  ' + pi);
    	phoneArray.PhoneInfo = pi;
    	system.debug('phone pre2___________________-                  ' + phoneArray);
    	req.ContactInfo.PhoneInfoArray.PhoneInfo = pi;
    	
    	system.debug('phone post');
    	
    	*/
    	
    	
    	//Order info
    	
//<ret:CampaignOfferId>ECNP1ELEC031202/3453/12/M</ret:CampaignOfferId>
//<ret:CampaignOfferId>ECNP1ELEC031202/3453/12/M</ret:CampaignOfferId>
    	
    	VirginiaPowerEnroll.ArrayOfOrderInfo orderArray = new VirginiaPowerEnroll.ArrayOfOrderInfo();
    	VirginiaPowerEnroll.OrderInfo orderInfo = new VirginiaPowerEnroll.OrderInfo();
    	List<VirginiaPowerEnroll.OrderInfo> orderLst = new List<VirginiaPowerEnroll.OrderInfo>();
    	orderInfo.ProductType     			= 'E';
    	orderInfo.OrderType                 = 'MI';
    	orderInfo.CampaignOfferId           = 'ECNP1ELEC031202/3453/12/M';
    	orderInfo.MoveInType                = 'MP';
    	orderInfo.ServiceStartDate          = '07302012';
    	//orderInfo.LocationInfoArray.LocationInfo.
    	
    	orderLst.add(orderInfo);
    	system.debug('order list                            ' + orderLst);
    	orderArray.OrderInfo = orderLst;
    	req.OrderInfoArray = orderArray;
    	// not calling order yet
    	orderResp = status.CreateOrder(req);
    	
    	system.debug('Response: ______________' + orderResp);
    	
    	
	   //}
	  // catch(exception e){
	  // system.debug('exception' + e);
	   //}
    	
    	
    	
    	
    	
    	
    	
    	
    	
	
	
	}
	
	public void checkStatus()
	{
	
		VirginiaPowerEnroll.RetailOrderAutomationServiceSoap status = new VirginiaPowerEnroll.RetailOrderAutomationServiceSoap();
    	VirginiaPowerEnroll.CheckSystemStatus   newStat = new VirginiaPowerEnroll.CheckSystemStatus();
    	VirginiaPowerEnroll.CheckSystemStatusResponse resp = new VirginiaPowerEnroll.CheckSystemStatusResponse();
    	VirginiaPowerEnroll.CreateOrderResponse orderResp = new VirginiaPowerEnroll.CreateOrderResponse();
    	VirginiaPowerEnroll.CheckOrderStatusResponse checkResp = new VirginiaPowerEnroll.CheckOrderStatusResponse();
    	
    	
    	resp = status.CheckSystemStatus(newStat);
    	system.debug('response!!!!!!!!!!!!!!!!!!!!!!!!!!'+ resp);
    	
    	//String resp1 = null;
    	//cirro.BasicHttpBinding_IService1 svc = new cirro.BasicHttpBinding_IService1();
		//resp1 =  svc.getData(991597994);
		//system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'+ resp1.substring(13,resp1.length()));
    	
    	/*
    	Approved Order Ids
1769406726042012
1759473526032012
1759247426032012

Cancelled Order Ids
1783116907062012
1783209207062012
1783353507062012

Pending Order Ids
1778745519052012
1781810831052012
1783355807062012

    	
    	
    	
    	*/
    	
    	VirginiaPowerEnroll.CheckOrderStatus	req = new VirginiaPowerEnroll.CheckOrderStatus();
    	
    	//System Information
    	req.ClientSystem 						= 'TCOST';
    	req.UserId       						= '10000663';
    	req.Token        						= 'myTokenId';
    	req.Type_x		    					= 'ORDERID';
    	req.Id									= '1759247426032012';
    	req.ProductType							= 'E';
    	
    checkResp = status.CheckOrderStatus(req);
    system.debug('status' +checkresp);
	
	
	}

}