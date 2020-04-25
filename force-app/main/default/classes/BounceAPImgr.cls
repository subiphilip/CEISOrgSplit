public class BounceAPImgr {
    
    public List<String> XMLData{get;set;}
    public order__c[] orderlist;
    
    public void placeOrder(order__c[] orderlist)
    {
        String enrollmenttype = '';
        if  (orderlist[0].PMVI_Flag__c)     
        {
            enrollmenttype = 'MI';
        }else
        {
            enrollmenttype = 'NB';
        }
        //String token = getToken();    
        system.debug('place order'+ orderlist[0]);
        neworder(orderlist[0].name);
        // order(orderlist[0].ssn__c,orderlist[0].Critical_Care__c, orderlist[0].name, orderlist[0].id, orderlist[0].First_Name__c,orderlist[0].Last_Name__c,orderlist[0].Customer_Date_of_Birth__c,orderlist[0].Mailing_City__c,orderlist[0].Mailing_State__c,orderlist[0].Mailing_Street_Address__c,orderlist[0].Mailing_Zip_Code__c,orderlist[0].Service_Address__c,orderlist[0].Service_City__c,orderlist[0].Service_State__c,orderlist[0].Service_Zip__c,orderlist[0].InitialDateofService__c,enrollmenttype, orderlist[0].Plan_ID__c,orderlist[0].ESIID_Number__c,orderlist[0].Customer_Email__c, orderlist[0].Customer_Phone_Number__c,orderlist[0].rate__c);
        
    }
    
    
    
    
    public String gettoken(){
        if(!Test.isRunningTest()){
            //RC Added to prevent web callouts from test class
            system.debug('Inside');
            HttpRequest req = new HttpRequest();
            String token = '';
            
            trueCostSystemVariables__c tcsv = TrueCostSystemVariables__c.getOrgDefaults();
            
            req.setEndPoint(tcsv.bounce__c);
            
            req.setMethod('POST');
            String username = 'centerpoint';
            String password = '7kbzlhSw';
            Blob headerValue = Blob.valueOf(username + ':' + password);
            String authorizationHeader = 'BASIC ' +
                EncodingUtil.base64Encode(headerValue);
            req.setHeader('Authorization', authorizationHeader);
            String body ='bounce_xml='+
                +'<?xml version=\"1.0\"?>'
                +'<bounce_api>' 
                +'<request>'
                +'<type>login</type>'
                +'<username>centerpoint</username>' 
                +'<password>7kbzlhSw</password> '
                +'</request> '
                +'</bounce_api> ';
            
            
            
            req.setbody(body);
            
            
            Http http = new Http();
            HTTPResponse res = http.send(req);
            System.debug(res.getBody());
            
            
            List<String> orgInfo=new List<String>();
            
            Dom.Document doc = new Dom.Document();
            
            doc.load(res.getBody());
            
            //Retrieve the root element for this document.
            
            Dom.XMLNode Envelope = doc.getRootElement();
            
            Dom.XMLNode Body1= Envelope.getChildElements()[0];
            
            string user_createResult = '';
            
            
            
            for(Dom.XMLNode child : Body1.getChildElements()) {
                
                orgInfo.add(child .getText());
            }
            system.debug(orginfo);
            
            return orginfo[2];
            
        }
        else{
            String Token = 'Token';
            return Token;
        }
    }
    
    
    @Future(callout=true)
    private static void neworder(String name)
    {
        if(!Test.isRunningTest()){
        order__c order = [select id,   exception__c, repstatus__c, ownerid,Authorized_Representative__c,Parent_Account__c,reporderid__c,record_type_name__c, rate__c,SSN__c,rep_profile__r.name,order_status__c, premise__r.id, premise__c,Plan_ID__c,  order_expiration_date__c, createddate, name,First_Name__c,Last_Name__c,Customer_date_of_birth__c,Critical_Care__c,Mailing_Street_Address__c,Mailing_City__c,Mailing_State__c,Mailing_Zip_Code__c,Service_Address__c,Service_State__c,Service_City__c,Service_Zip__c,InitialDateofService__c,Enrollment_Type__c,PMVI_Flag__c,ESIID_Number__c,Customer_Email__c, Customer_Phone_Number__c ,REP_email__c ,Fixed_Energy_Rate__c from Order__c where name =: name limit 1 ];
        List<logger__c> log = new List<logger__c>(); 
        ProcessorControl.inFutureContext = true;
        system.debug('order:' + order);
        String phone = '';
        phone = order.Customer_Phone_Number__c;
        phone = phone.replace(' ','');
        phone = phone.replace('(','');
        phone = phone.replace(')','');
        phone = phone.replace('-','');
        String ssn   = order.ssn__c.replace('-','');
        
        //
        
        //get rateid__c for rate id passed
        
        Rate__c rateRes = [ select name from rate__c where id =: order.rate__c limit 1];
        system.debug('rateId.........................'+ rateRes.name);
        if (order.InitialDateofService__c == null)
        {
            order.InitialDateofService__c = system.today()+3;
        }
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
        if (order.InitialDateofService__c != null)
        {
            
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
        logger__c logs2 = new logger__c(); 
        logs2.Order__c = order.id;
        logs2.message__c = 'switch type:'+typeSwitch;
        log.add(logs2);
        logger__c logs3 = new logger__c(); 
        logs3.Order__c = order.id;
        logs3.message__c = 'days between: '+numberDaysDue;
        log.add(logs3);
        
        HttpRequest req = new HttpRequest();
        String token = '';
        //req.setEndpoint('http://174.36.54.131/test-api/api-ng/place-order.php');
        //req.setEndpoint('http://199.168.175.28/test-api/api-ng/place-order.php');
        //req.setEndpoint('https://www.bounceenergy.com/api-ng/place-order.php');
        //req.setEndpoint('https://www.bounceenergy.com/test-api/api-ng/place-order.php');
        TrueCostSystemVariables__c tcsv = TrueCostSystemVariables__c.getOrgDefaults();
        
        System.debug(tcsv);
        req.setEndPoint(tcsv.bounce__c);
        req.setMethod('POST');
        String username = 'testuser';
        String password = '@p1T3st';
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'BASIC ' +
            EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);
        String body ='bounce_xml='+
            +'<?xml version=\"1.0\"?>'
            +'<bounce_api>' 
            +'<request>'
            +'<type>login</type>'
            +'<username>centerpoint</username>' 
            +'<password>7kbzlhSw</password> '
            +'</request> '
            +'</bounce_api> ';
        
        
        
        req.setbody(body);
        
        
        Http http = new Http();
        
        HTTPResponse res = http.send(req);
        
        System.debug(res.getBody());
        
        
        List<String> orgInfo=new List<String>();
        
        Dom.Document doc = new Dom.Document();
        
        doc.load(res.getBody());
        
        //Retrieve the root element for this document.
        
        Dom.XMLNode Envelope = doc.getRootElement();
        
        Dom.XMLNode Body1= Envelope.getChildElements()[0];
        
        string user_createResult = '';
        
        
        
        for(Dom.XMLNode child : Body1.getChildElements()) {
            
            orgInfo.add(child .getText());
        }
        system.debug(orginfo);
        
        token = orginfo[2];
        
        System.debug('Token' + token);
        //End get token call
        if ((order.Mailing_Street_Address__c == '') || (order.Mailing_Street_Address__c == null))
        {
            order.Mailing_Street_Address__c = order.Service_Address__c;
            order.Mailing_City__c           = order.Service_City__c;
            order.Mailing_State__c          = order.Service_State__c;
            order.Mailing_Zip_Code__c       = order.Service_Zip__c;
            
            
        }
        
        body ='bounce_xml='+  
            +'<?xml version=\"1.0\"?>'
            +'<bounce_api>' 
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
            +'<previous_addr1></previous_addr1>'
            +'<previous_addr2></previous_addr2>'
            +'<previous_city></previous_city>'
            +'<previous_state></previous_state>'
            +'<previous_zip></previous_zip>'
            +'<service_start_day>'+newdate.day()+'</service_start_day>'
            +'<service_start_month>'+newdate.month()+'</service_start_month>'
            +'<service_start_year>'+newdate.year()+'</service_start_year>'
            +'<customer_type>'+typeswitch+'</customer_type>'
            +'<plan_id>'+order.Plan_ID__c+'</plan_id>'
            +'<products>'
            +'<product>'
            +'<product_id>'+rateRes.name+'</product_id>'
            +'</product>'
            +'</products>'
            +'<language>english</language>'
            +'<f_name>'+order.First_Name__c+'</f_name>'
            +'<l_name>'+order.Last_Name__c+'</l_name>'
            +'<email>'+order.Customer_Email__c+'</email>'
            +'<day_phone>'+phone+'</day_phone>'
            +'<day_phone_ext></day_phone_ext>'
            +'<alt_phone></alt_phone>'
            +'<alt_phone_ext></alt_phone_ext>'
            +'<bill_addr1>'+order.Mailing_Street_Address__c+'</bill_addr1>'
            +'<bill_addr2></bill_addr2>'
            +'<bill_city>'+order.Mailing_City__c+'</bill_city>'
            +'<bill_state>'+order.Mailing_City__c+'</bill_state>'
            +'<bill_zip>'+order.Mailing_Zip_Code__c+'</bill_zip>'
            +'<ssn>'+ssn+'</ssn>'
            +'<market_source_id>448</market_source_id>'
            
            +'</order>'
            +'</bounce_api>';
        
        logger__c logs4 = new logger__c(); 
        logs4.Order__c = order.id;
        logs4.message__c = 'order body sent: '+body;
        log.add(logs4);
        
        req.setbody(body);
        
        Http http1 = new Http();
        res = http1.send(req);
        System.debug(res.getBody());
        /*
<bounce_api>
<response>
<type>order_result</type>
<order_valid>0</order_valid>
<error_msg>Esid is active</error_msg>
<active_order_id>374249</active_order_id>
</response>
</bounce_api>
*/
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
        
        for(Dom.XMLNode childRes : BodyRes.getChildElements()) {
            
            if (childres.getName() == 'order_result')
                order_result = childRes .getText();
            if (childres.getName() == 'id_validated')
                id_validated = childRes .getText(); 
            if (childres.getName() == 'order_created')
                order_created = childRes .getText();
            if (childres.getName() == 'order_id')
                order_id = childRes .getText(); 
            if (childres.getName() == 'deposit_required')
                deposit_required = childRes .getText(); 
            if (childres.getName() == 'deposit_due')
                deposit_due = childRes .getText();  
            if (childres.getName() == 'payment_required')
                payment_required = childRes .getText();
            if (childres.getName() == 'payment_due')
                payment_due = childRes .getText();  
            if (childres.getName() == 'active_order_id')
                order_id = childres.getText();        
            
            orderResponse1.add(childres.getName());
            orderResponse.add(childRes .getText());
        }
        system.debug( order_result );
        system.debug(id_validated );
        system.debug(order_created );
        system.debug(order_id );
        system.debug(deposit_required );
        system.debug(deposit_due );
        system.debug(payment_required );
        system.debug(payment_due  );
        
        /*
<type>order_result</type>
<id_validated>validated</id_validated>
<order_created>1</order_created>
<order_id>502920</order_id>
<deposit_required>0</deposit_required>
<deposit_due>0.00</deposit_due>
<payment_required>0</payment_required>
<payment_due>0.00</payment_due>
*/
        if( id_validated == 'nomatch')
        {
            System.debug('order Error ssn not match');
            
            order.failure_reason__c = 'nomatch';
            
            order.order_status__c = 'Pending';
            update order;
            
        }
        
        
        // if (orderResponse[1] == '0' && order_id == '')
        if ( order_id == '')
        {
            System.debug('order Error');
            
            order.failure_reason__c = orderResponse[2];
            
            order.order_status__c = 'Pending';
            update order;
            
            //}else if(orderResponse[1] == '0' && order_id != ''){
        }else if( order_id != ''){	
            
            order.reporderid__c = order_id; 
            
            if( id_validated == 'validated' || order_id != '')
            {
                order.Order_Status__c =  'Approved Pending Confirmation';
                order.REPStatus__c = id_validated;
            }
            if(  deposit_required == '1' && id_validated != 'nomatch')
            {
                order.Order_status__c =  'Approved Pending Deposit';
                order.Deposit_Requested__c = true;
                order.Deposit__c = Decimal.valueof(deposit_due);
            }
            list<BusinessHours> REPhours2 = [select id from BusinessHours where name = 'REP SLA']; //Finds the REP business hours 
            if (REPhours2.size() == 0) REPhours2 = [select id from BusinessHours where isDefault = true];  //just in case, uses our org's default hours.
            order.Order_Expiration_Date__c = BusinessHours.add(REPhours2[0].id, system.today(), 18*60*60*1000L); 
            
            update order;
        }
        
        upsert log;
        }
    }
    
    public void manualOrder(String name)
    {
        order__c order = [select id,   exception__c, repstatus__c, ownerid,Authorized_Representative__c,Parent_Account__c,reporderid__c,record_type_name__c, rate__c,SSN__c,rep_profile__r.name,order_status__c, premise__r.id, premise__c,Plan_ID__c,  order_expiration_date__c, createddate, name,First_Name__c,Last_Name__c,Customer_date_of_birth__c,Critical_Care__c,Mailing_Street_Address__c,Mailing_City__c,Mailing_State__c,Mailing_Zip_Code__c,Service_Address__c,Service_State__c,Service_City__c,Service_Zip__c,InitialDateofService__c,Enrollment_Type__c,PMVI_Flag__c,ESIID_Number__c,Customer_Email__c, Customer_Phone_Number__c ,REP_email__c ,Fixed_Energy_Rate__c from Order__c where name =: name limit 1 ];
        List<logger__c> log = new List<logger__c>(); 
        ProcessorControl.inFutureContext = true;
        system.debug('order:' + order);
        String phone = '';
        phone = order.Customer_Phone_Number__c;
        phone = phone.replace(' ','');
        phone = phone.replace('(','');
        phone = phone.replace(')','');
        phone = phone.replace('-','');
        String ssn   = order.ssn__c.replace('-','');
        
        //
        
        //get rateid__c for rate id passed
        
        Rate__c rateRes = [ select name from rate__c where id =: order.rate__c limit 1];
        system.debug('rateId.........................'+ rateRes.name);
        if (order.InitialDateofService__c == null)
        {
            order.InitialDateofService__c = system.today()+3;
        }
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
        if (order.InitialDateofService__c != null)
        {
            
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
        logger__c logs2 = new logger__c(); 
        logs2.Order__c = order.id;
        logs2.message__c = 'switch type:'+typeSwitch;
        log.add(logs2);
        logger__c logs3 = new logger__c(); 
        logs3.Order__c = order.id;
        logs3.message__c = 'days between: '+numberDaysDue;
        log.add(logs3);
        
        HttpRequest req = new HttpRequest();
        String token = '';
        //req.setEndpoint('http://174.36.54.131/test-api/api-ng/place-order.php');
        //req.setEndpoint('http://199.168.175.28/test-api/api-ng/place-order.php');
        //req.setEndpoint('https://www.bounceenergy.com/api-ng/place-order.php');
        //req.setEndpoint('https://www.bounceenergy.com/test-api/api-ng/place-order.php');
        trueCostSystemVariables__c tcsv = TrueCostSystemVariables__c.getOrgDefaults();
        
        req.setEndPoint(tcsv.bounce__c);
        req.setMethod('POST');
        String username = 'testuser';
        String password = '@p1T3st';
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'BASIC ' +
            EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);
        String body ='bounce_xml='+
            +'<?xml version=\"1.0\"?>'
            +'<bounce_api>' 
            +'<request>'
            +'<type>login</type>'
            +'<username>centerpoint</username>' 
            +'<password>7kbzlhSw</password> '
            +'</request> '
            +'</bounce_api> ';
        
        
        
        req.setbody(body);
        
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug(res.getBody());
        
        
        List<String> orgInfo=new List<String>();
        
        Dom.Document doc = new Dom.Document();
        
        doc.load(res.getBody());
        
        //Retrieve the root element for this document.
        
        Dom.XMLNode Envelope = doc.getRootElement();
        
        Dom.XMLNode Body1= Envelope.getChildElements()[0];
        
        string user_createResult = '';
        
        
        
        for(Dom.XMLNode child : Body1.getChildElements()) {
            
            orgInfo.add(child .getText());
        }
        system.debug(orginfo);
        
        token = orginfo[2];
        
        System.debug('Token' + token);
        //End get token call
        if ((order.Mailing_Street_Address__c == '') || (order.Mailing_Street_Address__c == null))
        {
            order.Mailing_Street_Address__c = order.Service_Address__c;
            order.Mailing_City__c           = order.Service_City__c;
            order.Mailing_State__c          = order.Service_State__c;
            order.Mailing_Zip_Code__c       = order.Service_Zip__c;
            
            
        }
        
        body ='bounce_xml='+  
            +'<?xml version=\"1.0\"?>'
            +'<bounce_api>' 
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
            +'<previous_addr1></previous_addr1>'
            +'<previous_addr2></previous_addr2>'
            +'<previous_city></previous_city>'
            +'<previous_state></previous_state>'
            +'<previous_zip></previous_zip>'
            +'<service_start_day>'+newdate.day()+'</service_start_day>'
            +'<service_start_month>'+newdate.month()+'</service_start_month>'
            +'<service_start_year>'+newdate.year()+'</service_start_year>'
            +'<customer_type>'+typeswitch+'</customer_type>'
            +'<plan_id>'+order.Plan_ID__c+'</plan_id>'
            +'<products>'
            +'<product>'
            +'<product_id>'+rateRes.name+'</product_id>'
            +'</product>'
            +'</products>'
            +'<language>english</language>'
            +'<f_name>'+order.First_Name__c+'</f_name>'
            +'<l_name>'+order.Last_Name__c+'</l_name>'
            +'<email>'+order.Customer_Email__c+'</email>'
            +'<day_phone>'+phone+'</day_phone>'
            +'<day_phone_ext></day_phone_ext>'
            +'<alt_phone></alt_phone>'
            +'<alt_phone_ext></alt_phone_ext>'
            +'<bill_addr1>'+order.Mailing_Street_Address__c+'</bill_addr1>'
            +'<bill_addr2></bill_addr2>'
            +'<bill_city>'+order.Mailing_City__c+'</bill_city>'
            +'<bill_state>'+order.Mailing_City__c+'</bill_state>'
            +'<bill_zip>'+order.Mailing_Zip_Code__c+'</bill_zip>'
            +'<ssn>'+ssn+'</ssn>'
            +'<market_source_id>448</market_source_id>'
            
            +'</order>'
            +'</bounce_api>';
        
        logger__c logs4 = new logger__c(); 
        logs4.Order__c = order.id;
        logs4.message__c = 'order body sent: '+body;
        log.add(logs4);
        
        req.setbody(body);
        
        Http http1 = new Http();
        res = http1.send(req);
        System.debug(res.getBody());
        /*
<bounce_api>
<response>
<type>order_result</type>
<order_valid>0</order_valid>
<error_msg>Esid is active</error_msg>
<active_order_id>374249</active_order_id>
</response>
</bounce_api>
*/
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
        
        for(Dom.XMLNode childRes : BodyRes.getChildElements()) {
            
            if (childres.getName() == 'order_result')
                order_result = childRes .getText();
            if (childres.getName() == 'id_validated')
                id_validated = childRes .getText(); 
            if (childres.getName() == 'order_created')
                order_created = childRes .getText();
            if (childres.getName() == 'order_id')
                order_id = childRes .getText(); 
            if (childres.getName() == 'deposit_required')
                deposit_required = childRes .getText(); 
            if (childres.getName() == 'deposit_due')
                deposit_due = childRes .getText();  
            if (childres.getName() == 'payment_required')
                payment_required = childRes .getText();
            if (childres.getName() == 'payment_due')
                payment_due = childRes .getText();  
            if (childres.getName() == 'active_order_id')
                order_id = childres.getText();        
            
            orderResponse1.add(childres.getName());
            orderResponse.add(childRes .getText());
        }
        system.debug( order_result );
        system.debug(id_validated );
        system.debug(order_created );
        system.debug(order_id );
        system.debug(deposit_required );
        system.debug(deposit_due );
        system.debug(payment_required );
        system.debug(payment_due  );
        
        /*
<type>order_result</type>
<id_validated>validated</id_validated>
<order_created>1</order_created>
<order_id>502920</order_id>
<deposit_required>0</deposit_required>
<deposit_due>0.00</deposit_due>
<payment_required>0</payment_required>
<payment_due>0.00</payment_due>
*/
        if( id_validated == 'nomatch')
        {
            System.debug('order Error ssn not match');
            
            order.failure_reason__c = 'nomatch';
            
            order.order_status__c = 'Pending';
            update order;
            
        }
        
        
        // if (orderResponse[1] == '0' && order_id == '')
        if ( order_id == '')
        {
            System.debug('order Error');
            
            order.failure_reason__c = orderResponse[2];
            
            order.order_status__c = 'Pending';
            update order;
            
            //}else if(orderResponse[1] == '0' && order_id != ''){
        }else if( order_id != ''){	
            
            order.reporderid__c = order_id; 
            
            if( id_validated == 'validated' || order_id != '')
            {
                order.Order_Status__c =  'Approved Pending Confirmation';
                order.REPStatus__c = id_validated;
            }
            if(  deposit_required == '1' && id_validated != 'nomatch')
            {
                order.Order_status__c =  'Approved Pending Deposit';
                order.Deposit_Requested__c = true;
                order.Deposit__c = Decimal.valueof(deposit_due);
            }
            list<BusinessHours> REPhours2 = [select id from BusinessHours where name = 'REP SLA']; //Finds the REP business hours 
            if (REPhours2.size() == 0) REPhours2 = [select id from BusinessHours where isDefault = true];  //just in case, uses our org's default hours.
            order.Order_Expiration_Date__c = BusinessHours.add(REPhours2[0].id, system.today(), 18*60*60*1000L); 
            
            update order;
        }
        
        upsert log;
        
    }
    
    
    public String makePayment(Order__c order)
    {
        
        
        Order__c orderId = [select reporderid__c,Deposit__c from order__c where Id = :order.id limit 1];
        
        HttpRequest req = new HttpRequest();
        String token;
        if(!Test.isRunningTest()){
            //RC Added to prevent web callouts from test class
            system.debug('Inside');
            token = gettoken();
        }
        
        //req.setEndpoint('http://174.36.54.131/test-api/api-ng/place-order.php');
        //req.setEndpoint('http://199.168.175.28/test-api/api-ng/place-order.php');
        // req.setEndpoint('https://www.bounceenergy.com/api-ng/place-order.php');
        trueCostSystemVariables__c tcsv = TrueCostSystemVariables__c.getOrgDefaults();
        
        req.setEndPoint(tcsv.bounce__c);
        req.setMethod('POST');
        String username = 'testuser';
        String password = '@p1T3st';
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'BASIC ' +
            EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);
        String body ='bounce_xml='+
            +'<?xml version=\"1.0\"?>'
            +'<bounce_api>' 
            +'<request>'
            +'<type>login</type>'
            +'<username>centerpoint</username>' 
            +'<password>7kbzlhSw</password> '
            +'</request> '
            +'</bounce_api> ';
        
        
        
        
        
        
        String body1 ='bounce_xml='+   
            +'<?xml version=\"1.0\"?>'
            +'<bounce_api>' 
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
            +'</bounce_api>';
        
        System.debug('req'+body1);
        
        req.setbody(body1);
        
        Http http1 = new Http();
        
        HTTPResponse res1 = http1.send(req);
        System.debug(res1.getBody());
        /*
<bounce_api>
<response>
<type>order_result</type>
<order_valid>0</order_valid>
<error_msg>Esid is active</error_msg>
<active_order_id>374249</active_order_id>
</response>
</bounce_api>
*/
        //Handle response
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
    @Future(callout=true)
    public static void getOrderStatus()
    {
        //token
        String token = '';
        try{
            HttpRequest req = new HttpRequest();
            
            
            trueCostSystemVariables__c tcsv = TrueCostSystemVariables__c.getOrgDefaults();
            
            req.setEndPoint(tcsv.bounce__c);
            
            req.setMethod('POST');
            String username = 'centerpoint';
            String password = '7kbzlhSw';
            Blob headerValue = Blob.valueOf(username + ':' + password);
            String authorizationHeader = 'BASIC ' +
                EncodingUtil.base64Encode(headerValue);
            req.setHeader('Authorization', authorizationHeader);
            String body ='bounce_xml='+
                +'<?xml version=\"1.0\"?>'
                +'<bounce_api>' 
                +'<request>'
                +'<type>login</type>'
                +'<username>centerpoint</username>' 
                +'<password>7kbzlhSw</password> '
                +'</request> '
                +'</bounce_api> ';
            
            
            
            req.setbody(body);
            
            
            Http http = new Http();
            HTTPResponse res = http.send(req);
            System.debug(res.getBody());
            
            
            List<String> orgInfo=new List<String>();
            
            Dom.Document doc = new Dom.Document();
            
            doc.load(res.getBody());
            
            //Retrieve the root element for this document.
            
            Dom.XMLNode Envelope = doc.getRootElement();
            
            Dom.XMLNode Body1= Envelope.getChildElements()[0];
            
            string user_createResult = '';
            
            
            
            for(Dom.XMLNode child : Body1.getChildElements()) {
                
                orgInfo.add(child .getText());
            }
            system.debug(orginfo);
            
            token =  orginfo[2];
        }
        catch(exception e)
        {
            system.debug(e);
        }
        //end token
        List<Order__c> order = [select a.id,a.order_status__c,a.reporderid__c from order__c a where a.order_status__c = 'Approved Pending Confirmation' and a.rep_profile__r.name = 'Bounce Energy' limit 4 ];
        system.debug('order'+order);
        List<order__c> updateOrder = new List<order__c>();
        for (Order__c ord : order){
            HttpRequest req = new HttpRequest();
            
            //req.setEndpoint('http://174.36.54.131/test-api/api-ng/place-order.php');
            //req.setEndpoint('http://199.168.175.28/test-api/api-ng/place-order.php');
            //req.setEndpoint('https://www.bounceenergy.com/api-ng/place-order.php');
            trueCostSystemVariables__c tcsv = TrueCostSystemVariables__c.getOrgDefaults();
            
            req.setEndPoint(tcsv.bounce__c);
            req.setMethod('POST');
            String username = 'testuser';
            String password = '@p1T3st';
            Blob headerValue = Blob.valueOf(username + ':' + password);
            String authorizationHeader = 'BASIC ' +
                EncodingUtil.base64Encode(headerValue);
            req.setHeader('Authorization', authorizationHeader);
            String body ='bounce_xml='+
                +'<?xml version=\"1.0\"?>'
                +'<bounce_api>' 
                +'<request>'
                +'<type>login</type>'
                +'<username>centerpoint</username>' 
                +'<password>7kbzlhSw</password> '
                +'</request> '
                +'</bounce_api> ';
            
            
            
            
            System.debug('Token' + token);
            /*
<bounce_api>
<request>
<type>get_order_status</type>
<token>3409adfjm34rlaedflk34r45</token>
<order_id>123456</order_id>
</request>
</bounce_api>       
*/        
            
            
            
            String body1 ='bounce_xml='+   
                +'<?xml version=\"1.0\"?>'
                +'<bounce_api>' 
                +'<request>'
                +'<type>get_order_status</type>'
                +'<token>'+token+'</token>'
                +'<order_id>'+ord.reporderid__c+'</order_id>'
                +'</request>'
                +'</bounce_api>';
            
            System.debug('req'+body1);
            
            req.setbody(body1);
            
            Http http1 = new Http();
            
            HTTPResponse res1 = http1.send(req);
            System.debug(res1.getBody());
            /*
<bounce_api>
<response>
<type>order_result</type>
<order_valid>0</order_valid>
<error_msg>Esid is active</error_msg>
<active_order_id>374249</active_order_id>
</response>
</bounce_api>
<bounce_api>
<response>
<type>order_status</type>
<order_id>123456</order_id>
<order_status_id>17</order_status_id>
<order_status_description>accepted</order_status_description>
</response>
</bounce_api>
*/
            //Handle response
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
            String orderStatus = '';
            String orderStatusDescription = '';
            for(Dom.XMLNode childRes : BodyRes.getChildElements()) {
                
                if (childres.getName() == 'order_status_id')
                    orderStatus = childRes .getText();
                if (childres.getName() == 'order_status_description')
                    orderStatusDescription = childRes .getText();   
                
                
                orderResponse1.add(childres.getName());
                orderResponse.add(childRes .getText());
            }
            system.debug('orderresponse'+ orderresponse);
            system.debug( 'authcode'+ authcode );
            system.debug( 'result'+ result );
            
            if ( orderStatusDescription == 'accepted') 
                ord.Order_Status__c = 'Confirmed';
            
            if ( orderStatusDescription == 'declined') 
                ord.Order_Status__c = 'Rejected';
            
            if ( orderStatusDescription == 'pending') 
                ord.Order_Status__c = 'Pending';  
            
            updateOrder.add(ord);
            //update ord;
            
        }  	
        update updateOrder;
        /*
Get Order Status
Request:
Response:


<bounce_api>
<request>
<type>get_order_status</type>
<token>3409adfjm34rlaedflk34r45</token>
<order_id>123456</order_id>
</request>
</bounce_api>



<bounce_api>
<response>
<type>order_status</type>
<order_id>123456</order_id>
<order_status_id>3</order_status_id>
<order_status_description>pending</order_status_description>
</response>
</bounce_api>



<bounce_api>
<response>
<type>order_status</type>
<order_id>123456</order_id>
<order_status_id>17</order_status_id>
<order_status_description>accepted</order_status_description>
</response>
</bounce_api>



<bounce_api>
<response>
<type>order_status</type>
<order_id>123456</order_id>
<order_status_id>9</order_status_id>
<order_status_description>declined</order_status_description>
</response>
</bounce_api>
*/
        
    }
    
    public  void orderstat(string name){  	
        Order__c order = [select a.id,a.order_status__c,a.reporderid__c from order__c a where a.name =: name and a.rep_profile__r.name = 'Bounce Energy'  limit 1];
        system.debug('order'+order);
        HttpRequest req = new HttpRequest();
        String token;
        if(!Test.isRunningTest()){
            //RC Added to prevent web callouts from test class
            //system.debug('Inside');
            token = gettoken();
        }
        //req.setEndpoint('http://174.36.54.131/test-api/api-ng/place-order.php');
        //req.setEndpoint('http://199.168.175.28/test-api/api-ng/place-order.php');
        //req.setEndpoint('https://www.bounceenergy.com/api-ng/place-order.php');
        trueCostSystemVariables__c tcsv = TrueCostSystemVariables__c.getOrgDefaults();
        
        req.setEndPoint(tcsv.bounce__c);
        req.setMethod('POST');
        String username = 'testuser';
        String password = '@p1T3st';
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'BASIC ' +
            EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);
        String body ='bounce_xml='+
            +'<?xml version=\"1.0\"?>'
            +'<bounce_api>' 
            +'<request>'
            +'<type>login</type>'
            +'<username>centerpoint</username>' 
            +'<password>7kbzlhSw</password> '
            +'</request> '
            +'</bounce_api> ';
        
        
        
        
        System.debug('Token' + token);
        
        
        
        String body1 ='bounce_xml='+   
            +'<?xml version=\"1.0\"?>'
            +'<bounce_api>' 
            +'<request>'
            +'<type>get_order_status</type>'
            +'<token>'+token+'</token>'
            +'<order_id>'+order.reporderid__c+'</order_id>'
            +'</request>'
            +'</bounce_api>';
        
        System.debug('req'+body1);
        
        req.setbody(body1);
        
        Http http1 = new Http();
        
        HTTPResponse res1 = http1.send(req);
        System.debug(res1.getBody());
        
        //Handle response
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
        String orderStatus = '';
        String orderStatusDescription = '';
        for(Dom.XMLNode childRes : BodyRes.getChildElements()) {
            
            if (childres.getName() == 'order_status_id')
                orderStatus = childRes .getText();
            if (childres.getName() == 'order_status_description')
                orderStatusDescription = childRes .getText();   
            
            
            orderResponse1.add(childres.getName());
            orderResponse.add(childRes .getText());
        }
        system.debug('orderresponse'+ orderresponse);
        system.debug( 'authcode'+ authcode );
        system.debug( 'result'+ result );
        
        if ( orderStatusDescription == 'accepted') 
            order.Order_Status__c = 'Confirmed';
        
        if ( orderStatusDescription == 'declinded') 
            order.Order_Status__c = 'Rejected';
        
        //  update order;
        
        
        
        
        
        
        
    }
}