public with sharing class NewLeafAPImrg {

   public static HttpRequest BuildTokenRequest(string repname){
   		HttpRequest req = new HttpRequest(); 
  		PartnerAPI__c Papi = PartnerAPI__c.getInstance(repname);

  		string repstring= Papi.brand_string__c;

	    req.setEndPoint(Papi.Endpoint__c);
	    req.setMethod('POST');

        String body =repstring+'_xml='+
        //+'<?xml version=\"1.0\"?>'
        +'<'+repstring+'_api>' 
        +'<request>'
        +'<type>login</type>'
        +'<username>'+Papi.Username__c+'</username>' 
        +'<password>'+Papi.Password__c+'</password>'
        +'</request>'
        +'</'+repstring+'_api>';
        req.setbody(body);
        system.debug(req.getbody());
        return req;
   }

   public class TokenException extends exception {}

   //common language for getting the token out of the response.  Can be used from an @future callout
   public static string parseToken(HTTPResponse res){
		List<String> orgInfo=new List<String>();        
        Dom.Document doc = new Dom.Document();        
        doc.load(res.getBody());
        
        //Retrieve the root element for this document.        
        Dom.XMLNode Envelope = doc.getRootElement();        
        Dom.XMLNode Body1= Envelope.getChildElements()[0];        

        for(Dom.XMLNode child : Body1.getChildElements()) {        
        	orgInfo.add(child.getText());
        }
        system.debug(orginfo);             
        return orginfo[2];   	
   }

    //gets the token.  Do NOT use from an @future callout.  It won't work.
  	public String gettoken(string repname){

  		HttpRequest req = BuildTokenRequest(repname);
     	Http http = new Http();

     	HTTPResponse res = http.send(req); //sends the request
     	System.debug(res.getBody()); //what did we get back?
 		return parseToken(res);
  }
  	
  	//formatting for SSN and phone numbers.  Why repeat code in every method?  
  	public static string stripPhoneCharacters(string input){
  		return input.replace(' ', '').replace('(', '').replace(')', '').replace('-', '');
  	}



   	@Future(callout=true)
   	public static void newOrderFuture(string orderid){
   		neworder(orderid);
   	}

   	public static void neworder(String orderid){
   		
  		order__c order = [select id, rate__r.name, Reward__r.Reward_Product_ID__c, exception__c, rate__r.Plan__r.Plan_ID__c, Deposit__c, Deposit_Requested__c, repstatus__c, ownerid,Authorized_Representative__c,Parent_Account__c,reporderid__c,record_type_name__c, rate__c,SSN__c,rep_profile__r.name,order_status__c, premise__r.id, premise__c,Plan_ID__c,  order_expiration_date__c, createddate, name,First_Name__c,Last_Name__c,Customer_date_of_birth__c,Critical_Care__c,Mailing_Street_Address__c,Mailing_City__c,Mailing_State__c,Mailing_Zip_Code__c,Service_Address__c,Service_State__c,Service_City__c,Service_Zip__c,InitialDateofService__c,Enrollment_Type__c,PMVI_Flag__c,ESIID_Number__c,Customer_Email__c, Customer_Phone_Number__c ,REP_email__c ,Fixed_Energy_Rate__c from Order__c where id =: orderid limit 1 ];
  		//status checking
  		if (order.Order_Status__c!='New/Successfully Submitted') return;  		

  		PartnerAPI__c Papi = PartnerAPI__c.getInstance(order.REP_Profile__r.Name);
		string repstring= Papi.brand_string__c;


   		List<logger__c> log = new List<logger__c>(); 
    	ProcessorControl.inFutureContext = true;
		system.debug('order:' + order);

		//do some prep
		String phone = stripPhoneCharacters(order.Customer_Phone_Number__c);
		String ssn   = stripPhoneCharacters(order.ssn__c);

		//get rateid__c for rate id passed		 
		//system.debug('rateId.........................'+ rateRes.name);

   		if (order.InitialDateofService__c == null){
     		order.InitialDateofService__c = system.today()+3;
     	}
    	
    	//logging
    	logger__c logs = new logger__c(); 
    	logs.Order__c = order.id;
    	logs.message__c = 'inital date of service:'+order.InitialDateofService__c;
    	log.add(logs); 
    
	    list<BusinessHours> REPhours = [select id from BusinessHours where name = 'REP SLA']; //Finds the REP business hours 
	     system.debug('=============initial date of service =========  ' + order.InitialDateofService__c);
	        //Datetime newdate = BusinessHours.add(REPhours[0].id, order.InitialDateofService__c, 18*60*60*1000L); 
	      //1 * 24 * 60 * 60 * 1000L
	      Datetime newdate = BusinessHours.add(REPhours[0].id, order.InitialDateofService__c, 1*24*60*1000L); 
	    
	    logger__c logs1 = new logger__c(); 
	    logs1.Order__c = order.id;
	    logs1.message__c = 'business  date of service:'+newdate;
	    log.add(logs1); 
	     
	  
	   	system.debug('=============created=========  ' + newdate);
	    integer month1                       = newdate.month();
	    integer day1                         = newdate.day();
        String dayS1                          = string.valueof(newdate.day());
        String monthS1                        = string.valueof(newdate.month());

        if (order.InitialDateofService__c != null){   //it's not first available
        	system.debug('service start date' + newdate);
        	String zero1                         = '0';
        	if (string.valueof(month1).length() == 1){
        		monthS1 = zero1 + string.valueof(month1);
        	}
        	if (string.valueof(day1).length() == 1){
        		dayS1 = zero1 + string.valueof(day1);
	        }  
        	system.debug('initdateofservice' +monthS1+dayS1+newdate.year());
        }
        
        string typeSwitch = 'switch';
       	date now = System.today();
        date bet =  date.newInstance(newdate.year(),  newdate.month(),newdate.day());
      	date start = date.newInstance(now.year(),  now.month(),now.day());
      	System.debug('start date:'+ start);
        system.debug('end date:'+ bet);
       
       integer numberDaysDue =     start.daysBetween(bet);
        integer test =     start.daysBetween(date.valueof(newdate));
       system.debug('days due:'+numberDaysDue);
       system.debug('test'+test);
         if ( numberDaysDue > 6)
         {
         
          typeSwitch = 'forward_switch';
          
         }
         if (order.Enrollment_Type__c == 'Move-In')
         { 
         
         typeSwitch = 'move';
         
         }
        logger__c logs2 = new logger__c(); 
	    logs2.Order__c = order.id;
	    logs2.message__c = 'switch type:'+typeSwitch;
	    log.add(logs2);
		logger__c logs3 = new logger__c(); 
	    logs3.Order__c = order.id;
	    logs3.message__c = 'days between: '+numberDaysDue;
	    log.add(logs3);

	    //let's get that lovely token
        HttpRequest req = BuildTokenRequest(order.REP_Profile__r.Name);
        String token = '';
	    Http http = new Http();
	    HTTPResponse res = http.send(req);
	    System.debug(res.getBody());
	    token = parseToken(res);
         //End get token call


     	if ((order.Mailing_Street_Address__c == '') || (order.Mailing_Street_Address__c == null)){
	       order.Mailing_Street_Address__c = order.Service_Address__c;
	       order.Mailing_City__c           = order.Service_City__c;
	       order.Mailing_State__c          = order.Service_State__c;
	       order.Mailing_Zip_Code__c       = order.Service_Zip__c;
     	}
			
     	string previousAddressSection = '';
     	//required fields for FCP.  Not sure if they're required to be non-null
     	if (order.rep_profile__r.name=='First Choice Power'){
     		previousAddressSection =
     				  '<previous_addr1></previous_addr1>'
	                 +'<previous_addr2></previous_addr2>'
	                 +'<previous_city></previous_city>'
	                 +'<previous_state></previous_state>'
	                 +'<previous_zip></previous_zip>';
     	}
     	string rewardProduct = '';
     	if (order.Reward__c != null){
     		rewardProduct = 
     			'<product>'
                      +'<product_id>'+order.Reward__r.Reward_Product_ID__c+'</product_id>'
                +'</product>';
     	}
     	string StartDateSection = '';
     	
     	if (order.Enrollment_Type__c == 'Move-In' || order.Enrollment_Type__c == 'Self-Selected Switch'){
     		//all that awful date logic here
     		StartDateSection = 
     			'<service_start_day>'+newdate.day()+'</service_start_day>'
	           +'<service_start_month>'+newdate.month()+'</service_start_month>'
	           +'<service_start_year>'+newdate.year()+'</service_start_year>';
     		
     	}


	    string body =repstring+'_xml='+  
	        +'<?xml version=\"1.0\"?>'
            +'<'+repstring+'_api>' 
                +'<request>'
                +'<type>create_order</type>'
                +'<token>'+token+'</token>'
                +'</request>'
                +'<order>'
	                +'<esiid>'+order.ESIID_Number__c+'</esiid>'
	                +'<service_addr1>'+order.Service_Address__c+'</service_addr1>'
	                +'<service_addr2></service_addr2>'
	                +'<service_city>'+order.Service_City__c+'</service_city>'
	                 +'<service_state>'+order.Service_State__c+'</service_state>'
	                 +'<service_zip>'+order.Service_Zip__c+'</service_zip>'
	                 //stop here, branch if move and not Direct Energy?  Or use little "insert sections"
	                 + previousAddressSection
	                 //only if not a standard switch?
	                 + StartDateSection
	                 +'<customer_type>'+typeswitch+'</customer_type>'
	                 +'<plan_id>'+order.rate__r.Plan__r.Plan_ID__c+'</plan_id>'
	                 +'<products>'
	                        +'<product>'
	                              +'<product_id>'+order.Rate__r.Name+'</product_id>'
	                        +'</product>'
	                        + rewardProduct
	                 +'</products>'
	                 +'<language>english</language>'
	                 +'<f_name>'+order.First_Name__c+'</f_name>'
	                 +'<l_name>'+order.Last_Name__c+'</l_name>'
	                 +'<email>'+order.Customer_Email__c+'</email>'
	                 +'<day_phone>'+phone+'</day_phone>'
	                 +'<day_phone_ext></day_phone_ext>'
	                 +'<alt_phone></alt_phone>'
	                 +'<alt_phone_ext></alt_phone_ext>'
	                 +'<ssn>'+ssn+'</ssn>'
	                 +'<bill_addr1>'+order.Mailing_Street_Address__c+'</bill_addr1>'
					 +'<bill_addr2></bill_addr2>'
					 +'<bill_city>'+order.Mailing_City__c+'</bill_city>'
					 +'<bill_state>'+order.Mailing_State__c+'</bill_state>'
					 +'<bill_zip>'+order.Mailing_Zip_Code__c+'</bill_zip>'
	                 +'<market_source_id>'+Papi.Partner_code__c+'</market_source_id>'
           		+'</order>'
    		+'</'+repstring+'_api>';
    
	    	logger__c logs4 = new logger__c(); 
		    logs4.Order__c = order.id;
		    logs4.message__c = 'order body sent: '+body;
		    log.add(logs4);
	    
		    req.setbody(body);

		    Http http1 = new Http();
		    req.setTimeOut(90000);
		    res = http1.send(req);
		    System.debug(res.getBody());
 

		    //Handle response
		    List<String> orderResponse =new List<String>();
		        List<String> orderResponse1 =new List<String>();
		        Dom.Document docRes = new Dom.Document();
		        
		        docRes.load(res.getBody());
		        
		        //Retrieve the root element for this document.
		        
		        Dom.XMLNode EnvelopeRes = docRes.getRootElement();
		        
		        Dom.XMLNode BodyRes= EnvelopeRes.getChildElements()[0];
		        
		        system.debug('raw response' +res.getBody());
		        logger__c logs5 = new logger__c(); 
			    logs5.Order__c = order.id;
			    logs5.message__c = 'response: '+res.getBody();
			    log.add(logs5);
		        
		        system.debug('raw response' +BodyRes);
		        String order_result = '';
		        string id_validated = '';
		        String order_created = '';
		        String order_id = '';
		        String deposit_required = '';
		        String deposit_due = '';
		        String payment_required = '';
		        String payment_due = '';
		        String error_msg = '';
		        String order_valid = '';
		        
		        for(Dom.XMLNode childRes : BodyRes.getChildElements()) {
		            
			        if (childres.getName() == 'order_result')
			            order_result = childRes.getText();
			        if (childres.getName() == 'id_validated')
			            id_validated = childRes.getText(); 
			        if (childres.getName() == 'order_created')
			            order_created = childRes.getText();
			        if (childres.getName() == 'order_id')
			            order_id = childRes.getText(); 
			        if (childres.getName() == 'deposit_required')
			            deposit_required = childRes.getText(); 
			        if (childres.getName() == 'deposit_due')
			            deposit_due = childRes.getText();  
			        if (childres.getName() == 'payment_required')
			            payment_required = childRes.getText();
			        if (childres.getName() == 'payment_due')
			            payment_due = childRes.getText();  
			        if (childres.getName() == 'active_order_id')
			           order_id = childres.getText();
		            if (childres.getName() == 'error_msg')
			           error_msg = error_msg+', '+childres.getText();
			        if (childres.getName() == 'order_valid')
			           order_valid = childres.getText();                 
			                
			        orderResponse1.add(childres.getName());
			        orderResponse.add(childRes.getText());
		        }

		        system.debug( order_result );
		        system.debug(id_validated );
		        system.debug(order_created );
		        system.debug(order_id );
		        system.debug(deposit_required );
		        system.debug(deposit_due );
		        system.debug(payment_required );
		        system.debug(payment_due  );
		        system.debug(error_msg  );
		        system.debug(order_valid  );
		        

		        //case 1--order not created, error message
		        if ( order_id == ''){
		        	System.debug('order Error');		         
			        order.Exception__c = error_msg;			        
			        order.order_status__c = 'API Error';
			        
		        } else { //the order was created and there is an order ID
		        	order.reporderid__c = order_id; //we have an id so let's put it on the order
		        	if (order_valid == '0'){
		        		System.debug('Invalid order');	
		        		order.Exception__c = error_msg;	
		        		order.order_status__c = 'API Error';
		        	}

		        	if( id_validated == 'nomatch'){ //case 2--bad ssn match
			            System.debug('order Error ssn not match');		         
			        	order.Exception__c = 'SSN did not match';		         
			        	order.order_status__c = 'Approved Pending Deposit';
			        	order.Deposit_Requested__c=true;
			        	order.Deposit__c=Decimal.valueof(deposit_due);

		        	} else if( deposit_required=='0'){ //case 3 good ssn with no deposit
				        order.Order_Status__c =  'Approved Pending Confirmation';
				        order.REPStatus__c = id_validated;

		        	} else if (deposit_required=='1'){
		        		order.Exception__c = 'SSN was found, but required deposit';	
		        		order.Order_Status__c =  'Approved Pending Deposit';
				        order.REPStatus__c = id_validated;
				        order.Deposit_Requested__c=true;
			        	order.Deposit__c=Decimal.valueof(deposit_due);
		        	}

		        }
		        
		        list<BusinessHours> REPhours2 = [select id from BusinessHours where name = 'REP SLA']; //Finds the REP business hours 		        
		        if (REPhours2.size() == 0) REPhours2 = [select id from BusinessHours where isDefault = true];  //just in case, uses our org's default hours.
		        	order.Order_Expiration_Date__c = BusinessHours.add(REPhours2[0].id, system.today(), 18*60*60*1000L); 		       
		        update order;
	       
		  
		    upsert log;
		  
	}

	public static map<String, Plan__c> getExistingPlans(String repName){
		list<plan__c> plans = new list<plan__c>();
        map<String, plan__c> planMap = new map<String, plan__c>();

        //get existing plans
		plans = [select id, name, Renewable_Content__c, Contract_Length__c, REP_Profile__c, REP_Profile__r.Name, Rate_Type__c, Plan_ID__c, RecordTypeID, 
				Record_Type_Name__c from Plan__c where REP_Profile__r.Name =: repName];

		//make planMap for later use
        if (plans.size()>0){
        	for(Plan__c p:plans){
        		planMap.put(p.Plan_ID__c, p);
        	}
        	return planMap;
        }else{return null;}
	}

	 @Future(callout=true)
	 public static void getPlans(String repName){
	 	//system.debug(repName);
        PartnerAPI__c Papi = PartnerAPI__c.getInstance(repName);
        string repstring= Papi.brand_string__c;

        // get rep profile
        REP_Profile__c profile = [select id, name from REP_Profile__c where name =:repName];
        //system.debug('****Rep Profile ID: '+profile.Id);

        list<rate__c> rates = new list<rate__c>();
        map<String, rate__c> rateMap = new map<String, rate__c>();

        map<String, plan__c> planMap = new map<String, plan__c>();

        list<TDSP__c> tdsps = new list<TDSP__c>();
        map<String, TDSP__c> tdspMap = new map<String, TDSP__c>();

        //get existing rates
        rates = [select id, name, msid__c, plan__r.renewable_content__c ,
		        plan__r.contract_length__c, plan__r.REP_Profile__r.name, plan__r.REP_Profile__r.id, 
		        plan__r.rate_type__c, plan__r.plan_id__c, TDSP__r.TDSP_API_name__c, 
		        energy_base_rate_cents__c, X500_kWh_rate_cents__c, 
		        X1000_kWh_rate__c, X2000_kWh_rate_cents__c,  
		        Cancellation_Fee__c, minimum_usage_charge__c, Link_for_EFL__c, Link_for_TOS__c, 
		        Link_for_YRAC__c
		        from rate__c
		        where plan__r.REP_Profile__r.name =: repName];
        
        // for new TNMP rates, default to TNMP North for TDSP, and then clone it for TNMP coast (api name TNMP-C)
        // for new **plans** set record type "Electric Plan"
        // for new **rates** set record type "Residential"
        // for terms_and_conditions_url, map this to rate fields "link_for_TOS" and "link_for_YRAC"
        // energy types: renewable = 100%, non-renewable = 9%

        // new fields created: rate__c.msid__c (TrueCost's unique id as a Direct Energy partner)
        // TDSP__c.TDSP_API_Name__c (text nameo f utility we will use to map to TDSP records.
        // Logger__c.Rate__c (lookup on logger so we can show API responses as a rate related list.)

        //make rateMap for later use
        if (rates.size()>0) {
            for(rate__c r:rates) {
                rateMap.put(r.name, r);
            }
        }

		//get existing plan map
        planMap = getExistingPlans(repName);        

        //get tdsp list
        tdsps = [select id, name, TDSP_API_Name__c from TDSP__c where RecordTypeID = '012300000019FSK'];

        //make map of tdsps by api tdsp name
        if (tdsps.size()>0){
        	for(TDSP__c t:tdsps){
        		tdspMap.put(t.TDSP_API_Name__c, t);
        	}
        }

        //let's get that lovely token
        HttpRequest req = BuildTokenRequest(repName);
        String token = '';
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug(res.getBody());
        token = parseToken(res);
         //End get token call


        string body =repstring+'_xml='+  
            +'<?xml version=\"1.0\"?>'
            +'<'+repstring+'_api>' 
                +'<request>'
                +'<type>get_partner_plans</type>'
                +'<token>'+token+'</token>'
                +'</request>'
            +'</'+repstring+'_api>';

        req.setbody(body);

        Http http1 = new Http();
        res = http1.send(req);
        System.debug(res.getBody());

        //Handle response
        //List<String> planResponse =new List<String>();
        //List<String> planResponse1 =new List<String>();
        Dom.Document docRes = new Dom.Document();
        
        docRes.load(res.getBody());
        
        //Retrieve the root element for this document.
        
        Dom.XMLNode EnvelopeRes = docRes.getRootElement();
        
        Dom.XMLNode BodyRes= EnvelopeRes.getChildElements()[1];
        
        //system.debug('raw response' +res.getBody());       
        //system.debug('raw response' +BodyRes);
        String msid = '';
        string planName = '';
        String type = '';
        String plan_id = '';
        String product_id = '';
        String tdsp_name = '';
        String term_length ='';
        String rate = '';
        String display_rate='';
        String energy_type='';
        String cancellation_fee='';
        String service_fee='';
        String electricity_facts_label = '';
        String terms_and_conditions_url = '';
        String terms_and_conditions_text = '';
        
        list<plan__c> plansToInsert = new list<plan__c>();
        Integer i = 0;

      	//*** first, run through the xml and look for new plans to create
      	system.debug('***** first run through for plans **********');
		for(Dom.XMLNode planRes : bodyRes.getChildElements()) {
            for(Dom.XMLNode childRes : planRes.getChildElements()) {

                if (childres.getName() == 'msid')
                    msid = childRes.getText();
                if (childres.getName() == 'name')
                    planName = childRes.getText(); 
                if (childres.getName() == 'type')
                    type = childRes.getText();
                if (childres.getName() == 'plan_id')
                    plan_id = childRes.getText(); 
                if (childres.getName() == 'product_id')
                    product_id = childRes.getText(); 
                if (childres.getName() == 'tdsp_name')
                    tdsp_name = childRes.getText();  
                if (childres.getName() == 'term_length')
                    term_length = childRes.getText();
                if (childres.getName() == 'rate')
                    rate = childRes.getText();
                if (childres.getName() == 'display_rate')
                    display_rate = childRes.getText();
                if (childres.getName() == 'energy_type')
                   energy_type = childres.getText();
                if (childres.getName() == 'cancellation_fee')
                   cancellation_fee = childres.getText();
                if (childres.getName() == 'service_fee')
                   service_fee = childres.getText(); 
                if (childres.getName() == 'electricity_facts_label')
                   electricity_facts_label = childres.getText();   
                if (childres.getName() == 'terms_and_conditions_url')
                   terms_and_conditions_url = childres.getText();   
                if (childres.getName() == 'terms_and_conditions_text')
                   terms_and_conditions_text = childres.getText();                   
            }
            /*
            system.debug('***api rate fields');
            system.debug('msid: '+msid);
            system.debug('name: '+planName);
            system.debug('type: '+type);
            system.debug('plan id: '+plan_id);
            system.debug('product id: '+product_id);
            system.debug('tdsp: '+tdsp_name);
            system.debug('term length: '+term_length);
            system.debug('rate: '+rate);
            system.debug('display rate: '+display_rate);
            system.debug('energy type: '+energy_type);
            system.debug('cancellation fee: '+cancellation_fee);
            system.debug('service fee: '+service_fee);
            system.debug('electricity facts label: '+electricity_facts_label);
            system.debug('terms and conditions url: '+terms_and_conditions_url);
            system.debug('terms and conditions text: '+terms_and_conditions_text);
			*/
    		plan__c existPlan;
    		try{
    			existPlan = planMap.get(plan_id);
    		} catch (exception e){
    			existPlan = null;
    		}

    		if (existPlan == null){//create new plan
    			system.debug('***plan does not exist');
    			//do the plan creation logic here
    			Plan__c newPlan = new Plan__c(name=planName, REP_Profile__c=profile.Id, Plan_ID__c=plan_id, Rate_Class_del__c='Residential', Rate_Type__c=type,
    										  Contract_Length__c= Decimal.valueOf(term_length.trim()), RecordTypeID='012300000018T0g',
    										  Plan_Start_Date__c=Date.today(), Plan_End_Date__c= Date.today().addYears(1));
    			
    			if (energy_type == 'renewable'){
    				newPlan.Renewable_Content__c=100;
    				newPlan.Green_ranking__c=100.00;
    			} else {
    				//set to 9% renewable if not green
    				newPlan.Renewable_Content__c=9;
    				newPlan.Green_ranking__c=9.00;
    			}
    			
    			//add plan to list to insert
    			if (plansToInsert.size()==0){
    				//first plan so add to the list
    				plansToInsert.add(newPlan);
				} else {
					//check to see if this plan is already in the list to be added
					boolean okToAdd = true;
					for (Plan__c p:plansToInsert){
						if (p.Plan_ID__c == newPlan.Plan_ID__c){
							okToAdd = false;
						}
					}
					if (okToAdd){
						plansToInsert.add(newPlan);
					}
				}
    		}

    		//re-initialize variables
    		msid = '';
	        planName = '';
	        type = '';
	        plan_id = '';
	        product_id = '';
	        tdsp_name = '';
	        term_length ='';
	        rate = '';
	        display_rate='';
	        energy_type='';
	        cancellation_fee='';
	        service_fee='';
	        electricity_facts_label = '';
	        terms_and_conditions_url = '';
	        terms_and_conditions_text = '';
	        i++;
        }

        //insert any new plans
        system.debug('**** plans to insert: '+plansToInsert.size());
        if (plansToInsert.size()>0){
        	insert plansToInsert;

        	//refresh existing plan map after insert
        	planMap = getExistingPlans(repName);
        }


        list<rate__c> ratesToUpdate = new list<rate__c>();
      	list<rate__c> ratesToInsert = new list<rate__c>();

        //*** now, run through the xml again for rates
        system.debug('**** Second run through for rates');
        for(Dom.XMLNode planRes : bodyRes.getChildElements()) {
            for(Dom.XMLNode childRes : planRes.getChildElements()) {

                if (childres.getName() == 'msid')
                    msid = childRes.getText();
                if (childres.getName() == 'name')
                    planName = childRes.getText(); 
                if (childres.getName() == 'type')
                    type = childRes.getText();
                if (childres.getName() == 'plan_id')
                    plan_id = childRes.getText(); 
                if (childres.getName() == 'product_id')
                    product_id = childRes.getText(); 
                if (childres.getName() == 'tdsp_name')
                    tdsp_name = childRes.getText();  
                if (childres.getName() == 'term_length')
                    term_length = childRes.getText();
                if (childres.getName() == 'rate')
                    rate = childRes.getText();
                if (childres.getName() == 'display_rate')
                    display_rate = childRes.getText();
                if (childres.getName() == 'energy_type')
                   energy_type = childres.getText();
                if (childres.getName() == 'cancellation_fee')
                   cancellation_fee = childres.getText();
                if (childres.getName() == 'service_fee')
                   service_fee = childres.getText(); 
                if (childres.getName() == 'electricity_facts_label')
                   electricity_facts_label = childres.getText();   
                if (childres.getName() == 'terms_and_conditions_url')
                   terms_and_conditions_url = childres.getText();   
                if (childres.getName() == 'terms_and_conditions_text')
                   terms_and_conditions_text = childres.getText();                   
                        
                //planResponse1.add(childres.getName());
                //planResponse.add(childRes.getText());
            }
            /*
            system.debug('***api rate fields');
            system.debug('msid: '+msid);
            system.debug('name: '+planName);
            system.debug('type: '+type);
            system.debug('plan id: '+plan_id);
            system.debug('product id: '+product_id);
            system.debug('tdsp: '+tdsp_name);
            system.debug('term length: '+term_length);
            system.debug('rate: '+rate);
            system.debug('display rate: '+display_rate);
            system.debug('energy type: '+energy_type);
            system.debug('cancellation fee: '+cancellation_fee);
            system.debug('service fee: '+service_fee);
            system.debug('electricity facts label: '+electricity_facts_label);
            system.debug('terms and conditions url: '+terms_and_conditions_url);
            system.debug('terms and conditions text: '+terms_and_conditions_text);
			*/

            rate__c existRate;
            try {
                existRate = rateMap.get(product_id);
            }
            catch (exception e) { 
                existRate = null;
            }

            if (existRate != null){//rate already exists so update it
            	system.debug('***rate is pre-existing');
            	//system.debug('***pre-existing rate fields');
            	system.debug('msid: '+existRate.msid__c);
	            system.debug('product id: '+existRate.name);
	            system.debug('tdsp: '+existRate.TDSP__r.TDSP_API_Name__c);
	            system.debug('base rate: '+existRate.energy_base_rate_cents__c);
	            system.debug('display rate: '+existRate.X500_kWh_rate_cents__c);
	            system.debug('electricity facts label: '+existRate.Link_for_EFL__c);
	            system.debug('terms and conditions url: '+existRate.Link_for_TOS__c);

	            existRate.msid__c = msid;
	            existRate.Link_for_EFL__c=electricity_facts_label;
	            existRate.Link_for_TOS__c=terms_and_conditions_url;
	            existRate.Link_for_YRAC__c=terms_and_conditions_url;
	            existRate.energy_base_rate_cents__c=decimal.valueof(rate.trim());

	            if (display_rate != '' && display_rate != null){
		            existRate.X500_kWh_rate_cents__c=decimal.valueof(display_rate.trim());
		            existRate.X1000_kWh_rate__c=decimal.valueof(display_rate.trim());
		            existRate.X2000_kWh_rate_cents__c=decimal.valueof(display_rate.trim());
	        	} else {
	        		existRate.X500_kWh_rate_cents__c=decimal.valueof(rate.trim());
		            existRate.X1000_kWh_rate__c=decimal.valueof(rate.trim());
		            existRate.X2000_kWh_rate_cents__c=decimal.valueof(rate.trim());
	        	}

	            ratesToUpdate.add(existRate);
        	} else {//rate does not exist so create it
        		system.debug('***rate does not exist');
        		//check to see if plan exists
        		plan__c existPlan;
        		try{
        			existPlan = planMap.get(plan_id);
        		} catch (exception e){
        			existPlan = null;
        		}

        		if (existPlan == null){//create new plan and assign to existPlan
        			system.debug('*** plan does not exist, skipping this rate ****');
        		} else {
	        		//create new rate only if there is an actual rate value defined
	        		if (rate != ''){
		        		Rate__c newRate = new Rate__c(name=product_id, msid__c=msid, plan__c=existPlan.id,
		        										Link_for_EFL__c=electricity_facts_label, link_for_TOS__c=terms_and_conditions_url,
		        										link_for_YRAC__c=terms_and_conditions_url, RecordTypeID='012300000017ceA');
						
						//system.debug('*****rate is below*****');
						//system.debug(rate);
						newRate.energy_base_rate_cents__c=decimal.valueof(rate.trim()); 
						newRate.cancellation_fee__c=decimal.valueof(cancellation_fee); 
						newRate.minimum_usage_charge__c=decimal.valueof(service_fee);
						if (newRate.minimum_usage_charge__c != null && newRate.minimum_usage_charge__c != 0){
							newRate.Minimum_Usage_Charge_Threshold_kWh__c=100;
						}
						//set diplay rate if available, otherwise use base rate
						if (display_rate != '' && display_rate != null){
							newRate.X500_kWh_rate_cents__c=decimal.valueof(display_rate.trim());
			        		newRate.X1000_kWh_rate__c=decimal.valueof(display_rate.trim());
			        		newRate.X2000_kWh_rate_cents__c=decimal.valueof(display_rate.trim());
						} else{
							newRate.X500_kWh_rate_cents__c=decimal.valueof(rate.trim());
			        		newRate.X1000_kWh_rate__c=decimal.valueof(rate.trim());
			        		newRate.X2000_kWh_rate_cents__c=decimal.valueof(rate.trim());
						}
		        		
		        		//get tdsp by api name
		        		TDSP__c theTDSP;
		        		try{
		        			theTDSP = tdspMap.get(tdsp_name);
		        		} catch (exception e){
		        			theTDSP = null;
		        		}
		        		
		        		if (theTDSP != null){
		        			if (tdsp_name == 'TNMP'){
		        				//TNMP needs to be cloned and added to TNMP-C as well
		        				TDSP__c tnmpc;
		        				try {
		        					tnmpc = tdspMap.get('TNMP-C');
		        				} catch (exception e){
		        					tnmpc = null;
		        				}

		        				if (tnmpc != null){
		        					Rate__c cloneRate = newRate.clone();
		        					cloneRate.TDSP__c = tnmpc.id;
		        					ratesToInsert.add(cloneRate);
		        				}
		        			}
		        			newRate.TDSP__c = theTDSP.id;
		        			ratesToInsert.add(newRate);
		        		} else {
		        			system.debug('*** TDSP API Name not found: '+tdsp_name);
		        		}
	        		}
        		}

        	}

        	//re-initialize variables
    		msid = '';
	        planName = '';
	        type = '';
	        plan_id = '';
	        product_id = '';
	        tdsp_name = '';
	        term_length ='';
	        rate = '';
	        display_rate='';
	        energy_type='';
	        cancellation_fee='';
	        service_fee='';
	        electricity_facts_label = '';
	        terms_and_conditions_url = '';
	        terms_and_conditions_text = '';
        }

        if (ratesToUpdate.size()>0) {
            update ratesToUpdate;
        }

        if (ratesToInsert.size()>0){
        	insert ratesToInsert;
        	//for (Rate__c r:ratesToInsert){
        	//	system.debug(r);
        	//}
        }
 
    }
   		

 /*
  
  
  public String makePayment(Order__c order)
  {
     
     
     Order__c orderId = [select reporderid__c,Deposit__c, REP_Profile__r.Name from order__c where Id = :order.id limit 1];
      
     HttpRequest req = new HttpRequest();
     String token = gettoken(order);
     System.debug('Token' + token);
             
     String body1 ='newleaf_xml='+   
        +'<?xml version=\"1.0\"?>'
            +'<newleaf_api>' 
            +'<request>'
           +'<type>make_payment</type>'
            +'<token>'+token+'</token>'
            +'</request>'
            +'<payment>'
            +'<order_id>'+orderId.reporderid__c+'</order_id>'
            +'<auto_pay>0</auto_pay>'
            +'<payment_type>creditcard</payment_type>'
            +'<cc_num>'+order.Payment_Card_Number__c+'</cc_num>'
            +'<cc_type>'+order.Payment_Card_Type__c+'</cc_type>'
            +'<cc_exp_month>'+order.Payment_Card_Month__c+'</cc_exp_month>'
            +'<cc_exp_year>'+order.Payment_Card_Year__c+'</cc_exp_year>'
            +'<cc_sec_code>'+order.Payment_Card_3_digit_code__c+'</cc_sec_code>'
            +'<cc_holder_name>'+order.Name_as_it_appears_on_Payment_Card__c+'</cc_holder_name>'
            +'<payment_addr1>'+order.Payment_Card_Address_Line_1__c+'</payment_addr1>'
            +'<payment_addr2></payment_addr2>'
            +'<payment_city>'+order.Payment_Card_Address_City__c+'</payment_city>'
            +'<payment_state>'+order.Payment_Card_Address_State__c+'</payment_state>'
            +'<payment_zip>'+order.Payment_Card_Address_Zip__c+'</payment_zip>'
            +'<deposit_amount>'+orderId.Deposit__c+'</deposit_amount>'
            +'</payment>'
    +'</newleaf_api>';
    
    System.debug('req'+body1);
    
     req.setbody(body1);

     Http http1 = new Http();
    
     HTTPResponse res1 = http1.send(req);
     System.debug(res1.getBody());
  

    List<String> orderResponse =new List<String>();
        List<String> orderResponse1 =new List<String>();
    Dom.Document docRes = new Dom.Document();
        
        docRes.load(res1.getBody());
        
        //Retrieve the root element for this document.
        
        Dom.XMLNode EnvelopeRes = docRes.getRootElement();
        
        Dom.XMLNode BodyRes= EnvelopeRes.getChildElements()[0];
        
        system.debug('raw response' +res1.getBody());
        system.debug('raw response' +BodyRes);
        String order_result = '';
        string id_validated = '';
        String order_created = '';
        String order_id = '';
        String deposit_required = '';
        String deposit_due = '';
        String payment_required = '';
        String payment_due = '';
        String authCode = '';
        String result   = '';
        for(Dom.XMLNode childRes : BodyRes.getChildElements()) {
            
        if (childres.getName() == 'auth_code')
            authcode = childRes .getText();
        if (childres.getName() == 'result')
            result = childRes .getText();   
        
                
        orderResponse1.add(childres.getName());
        orderResponse.add(childRes .getText());
        }
        system.debug('orderresponse'+ orderresponse);
        system.debug( 'authcode'+ authcode );
        system.debug( 'result'+ result );
    
        if ( result == '1')
           order.Order_Status__c = 'Confirmed';
        
    
        update order;
        return 'order';

  
  
  }

*/
}