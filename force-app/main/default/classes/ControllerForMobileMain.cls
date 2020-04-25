global virtual class ControllerForMobileMain { 
  
    //Login related stuff--register part only!
    public string loginpassword{get;set;}
    public string loginemail{get;set;}


    @RemoteAction
    global static string getdetailscostlist(string userid, id planId){
        list<month_estimate__c> monthEstimateList= new list<month_estimate__c>{};
        AccountPremiseAssociation__C theAPA = APAUtilities.GetActiveAPA(TrueCostUtilities.GetTheAccount(userid));
        monthestimateList = TrueCostCalc.makeTempMonthEstimates(theAPA, getActivePlansById( planId ) );
        decimal[] thelist = new decimal[12];
        return JSON.serialize(monthestimateList);
    }
    
      
    global pageReference login(){
        system.debug('password is ' + loginpassword);
        system.debug('username is ' + loginemail);
        return Site.login(loginemail, loginpassword, '/MobileAddressSetup');
    }
    public static list<rate__c> getActivePlansById(id therate){
      //return [select id from rate__c where active__c=true and plan__r.active__c=true and plan__r.rep_profile__r.active__c=true and suspended__c = false];
      list<rate__C> tempplanlist=new list<rate__C>();
        tempplanlist=[select id, plan__r.id, plan__r.renewable_content__c, plan__r.contract_length__c, plan__r.REP_profile__r.logo_url__c, cancellation_fee__c, Record_Type_Name__c, load_factor__c,
                        plan__r.green_ranking__c, plan__r.REP_profile__r.star_ranking__c, plan__r.REP_profile__r.star_rating_avg__c, plan__r.REP_profile__r.total_reviews__c, plan__r.REP_profile__r.PUC_Scorecard_Ranking__c,
                        plan__r.REP_profile__r.years_in_business_score__c, plan__r.rep_profile__r.id, plan__r.REP_profile__r.name, 
                        Minimum_Usage_Charge__c, Minimum_Usage_Charge_Threshold_kWh__c,
                        Minimum_Usage_Charge2__c, Minimum_Usage_Charge_Threshold2__c,
                        Minimum_Usage_Charge3__c, Minimum_Usage_Charge_Threshold3__c,
                        Usage_Discount_Amount__c, Usage_Discount_Minimum__c,
                        plan__r.Link_Off__c,
                        Energy_Base_Rate_cents__c, Monthly_Base_Charge__c,plan__r.Miscellaneous_Gross_Receipts_Tax__c,plan__r.PUC_Gross_Receipts_Assessment__c,plan__r.rate_class_del__c, tdsp__r.id
                    from rate__c
                    where id=:therate];
         return tempplanlist;
    }

    //used to generate a sitemap for plandetails pages, NOT for shopping purposes anymore
    public static list<rate__c> getActivePlans(){
      return [select id from rate__c where active__c=true and plan__r.active__c=true and plan__r.rep_profile__r.active__c=true and suspended__c = false];
    }
    
    public static list<content_item__c> getAllFeeTerms(){
      return [select id, name, Definition__c, lastmodifieddate from content_item__c where Published__c = true and (fee__c=true or Glossary_Term__c=true)];
    }
    
    public static list<faq__c> getAllFAQ(){
      return [select id, lastmodifieddate from faq__c where Public__c = true and recordtypeid='012300000018tOF'];
    }
    
    public static list<ValidZipCode__c> getAllTCZips(){
      return [select id, name, lastmodifieddate from ValidZipCode__c where served_by_truecost__c = true];
    }
    
    public static list<REP_Profile__c> getREPs(){
        return [select id, name, about_us__c, Logo_URL__c, friendly_url__c, lastmodifieddate, Star_Rating_Avg__c from REP_Profile__c where active__c=true order by random_number_for_sorting__c, lastmodifieddate DESC];
    }
    
    @RemoteAction
    global static list<string> GetTDSPsByZip(string zip){          
        //list<aggregateResult> ARs= [select TDSP_Lookup__r.name Utility from premises__c where Electric_Service_Address_Zip__c =: zip and ESI_ID_Status__c='Active' and recordtypeid =: '012300000018rXq' group by TDSP_Lookup__r.name];        
        list<aggregateResult> ARs= [select TDSP_Lookup__r.name Utility from premises__c where Electric_Service_Address_Zip__c =: zip and ESI_ID_Status__c='Active' and recordtype.Name = 'Electric Premise' group by TDSP_Lookup__r.name];        
      list<string> output = new list<string>();
        for (aggregateResult AR:ARs){
          output.add(string.valueof(AR.get('Utility')));
        }
        return output;
    }
    
    @RemoteAction
    global static list<string> GetCitiesByZip(string zip){          
        //list<aggregateResult> ARs= [select Electric_Service_Address_City__c from premises__c where Electric_Service_Address_Zip__c =: zip and ESI_ID_Status__c='Active' and recordtypeid =: '012300000018rXq' group by Electric_Service_Address_City__c];        
        list<aggregateResult> ARs= [select Electric_Service_Address_City__c from premises__c where Electric_Service_Address_Zip__c =: zip and ESI_ID_Status__c='Active' and recordtype.Name = 'Electric Premise' group by Electric_Service_Address_City__c];        
      list<string> output = new list<string>();
        for (aggregateResult AR:ARs){
            string recordString = '';
            for(string s:string.valueof(AR.get('Electric_Service_Address_City__c')).split(' ')){
              recordString = recordString + s.tolowercase().capitalize()+' ';
            }
            output.add(RecordString.trim());
        }
        return output;
    }
    
    @RemoteAction
    global static list<rep_rating__c> pullRatings(){          
        return [select id, rep_profile__r.name, rating__c, author__r.firstname, review__c, createddate from rep_rating__c where published__c=true and rep_profile__c!=null and rep_profile__r.active__C = true and author__c !=null and author__r.firstname != null  order by createddate DESC];        
    }
        
    @RemoteAction
    global static list<daily_usage__c> pullRawDailies(string userid){
      AccountPremiseAssociation__C theAPA2 = APAUtilities.GetActiveAPA(TrueCostUtilities.GetTheAccount(userid));        
        return MeterDataUtilities.QueryAll(theAPA2);         
    }
    
    @RemoteAction
        global static string FetchAddress(string premiseId){
          return [select id, Electric_Service_Address__c from premises__c where id=:PremiseId].Electric_Service_Address__c;
        }
        
    
    @RemoteAction 
    global static list<monthly_usage__c> pullRawMonthlies(string premiseId){
      list<monthly_usage__c> mus = new   list<monthly_usage__c>();
        list<AccountPremiseAssociation__C> theAPAs = [select id, Premise__r.Premise_Type__c, premise__r.TDSP_Lookup__r.name, premise__r.Electric_Service_Address__c, Customer_Selected_Profile__c, premise__r.id, Meter_Data_Permission__c  from AccountPremiseAssociation__C 
                                                      where premise__r.id =: premiseId and public_data__c = true
                                                      order by lastmodifieddate DESC limit 1 ];
        if (theAPAs.isempty() ){
            return null;
        } else
        return TrueCostUtilities.pullTheMonthlyUsage(theAPAs[0]);
    }
    
    @RemoteAction   //used by the publicDataViewer page
    global static list<decimal> PullMonthlyCost(string premiseId){
      list<monthly_usage__c> mus = new   list<monthly_usage__c>();
        list<AccountPremiseAssociation__C> theAPAs = [select id, Premise__r.Premise_Type__c, premise__r.TDSP_Lookup__r.id, premise__r.TDSP_Lookup__r.name, premise__r.Electric_Service_Address__c, Customer_Selected_Profile__c, premise__r.id, REP_of_Record__c, Meter_Data_Daily_Status__c, Meter_Data_Permission__c  from AccountPremiseAssociation__C 
                                                      where premise__r.id =: premiseId and public_data__c = true
                                                      order by lastmodifieddate DESC limit 1 ];
        if (theAPAs.isempty() ){
            return null;
        } else  {
            //find the cheapest 1-year rate? public static list<rate__C> getactivePlans(premises__c prem, AccountPremiseAssociation__c APA, id tdsp)
      list<rate__c>ActivePlans= TrueCostCalc.getActivePlans2(theAPAs[0], theAPAs[0].premise__r.TDSP_Lookup__r.id, 'Residential');
            
            list<rate__c> SelectedPlans = new list<rate__c>();
            for (rate__c r:ActivePlans){
              if (r.plan__r.contract_length__c == 12 && SelectedPlans.size()==0) SelectedPlans.add(r);
            }
            
            //   public static list<month_estimate__c> makeTempMonthEstimates(AccountPremiseAssociation__c theAPA, list<Rate__c> ratelist){

        return getDetailsCostList(TrueCostCalc.makeTempMonthEstimates(theAPAs[0], SelectedPlans)); 
        }
    }
    
    public static decimal[] getdetailscostlist(list<month_estimate__C> MonthEstimateList){
                decimal[] thelist = new decimal[12];
                for (month_estimate__C me:MonthEstimateList){
                    thelist.add((me.total__C).setscale(2));
                }
                return thelist;
        }
    
    global static list<daily_usage__c> pullRawDailiesForward(string userid, date lastDate){
      AccountPremiseAssociation__C theAPA2 = APAUtilities.GetActiveAPA(TrueCostUtilities.GetTheAccount(userid));        
        return [select id, Date__c, Total_for_the_day__c, Intervals__c from daily_usage__c where Account_Premise_Association__c =: theAPA2.id and Date__c>:lastdate order by date__c ASC];        
    }
    
    @RemoteAction
    global static void SetPreferences(string userid, boolean choice, string field){
        account a = [select id, Meter_Data_Email_Daily__c, Meter_Data_Email_Weekly__c from account where id=:TrueCostUtilities.GetTheAccount(userid)];  
        if (field == 'Meter_Data_Email_Daily__c') a.Meter_Data_Email_Daily__c=choice; 
        if (field == 'Meter_Data_Email_Weekly__c') a.Meter_Data_Email_Weekly__c=choice; 
        update a;
    }
    
    @RemoteAction   
    global static boolean GetPreferences(string userid, string field){
        account a = [select id, Meter_Data_Email_Daily__c, Meter_Data_Email_Weekly__c from account where id=:TrueCostUtilities.GetTheAccount(userid)];  
        if (field == 'Meter_Data_Email_Daily__c') return a.Meter_Data_Email_Daily__c; 
        else if (field == 'Meter_Data_Email_Weekly__c') return a.Meter_Data_Email_Weekly__c; 
        else return false; 
    }
    

    
    /*
    @RemoteAction
    global static list<IntervalDataExplorer.ChartDataObject> pullDataRemote(string userid, string unit){
      AccountPremiseAssociation__C theAPA2 = APAUtilities.GetActiveAPA(TrueCostUtilities.GetTheAccount(userid));
        if (unit == 'day') return IntervalDataExplorer.getTheDayWrapper(theAPA2);
        if (unit == 'hour') return IntervalDataExplorer.getTheHourWrapper(theAPA2);
        if (unit == '15') return IntervalDataExplorer.getTheIntervalWrapper(theAPA2);
        return null;        
    }
    */
    
     @RemoteAction
     global static content_item__c getRemoteContent(string contentid){
       ControllerforContentItems C = new ControllerforContentItems();
         c.whichcontent = contentid;
         C.getmyContent();
         if (c.thecontent.Definition__c!=null){
             return c.thecontent;
         } else return null;
     }  
    
    @RemoteAction
        global static list<content_blogentry__c> getBlogsRemote(){
        list<content_blogentry__c> blogposts = [select ID, Title__c, body__c, above_the_fold__c, author__c, publish_date__c, deck__c
            from content_blogentry__c
            where publish_date__c <:system.now() and published__c = true
            order by publish_date__c DESC limit 50];         
        return ContentRewriter.Rewrite(blogposts);
    }
    
    @RemoteAction
            global static list<faq__c> getFAQ(){               
               return [select id, question__c, answer__c from FAQ__c where Public__c = true and Record_Type_Name__c='TrueCost FAQ'];
            }
    
    @RemoteAction
        global static list<premises__c> sendPremise(string MobileAddress, string MobileZip){
          return TrueCostUtilities.exactMatchServiceAddress(MobileAddress, MobileZip);
        }
    
    @RemoteAction
        global static string checkZip (string zip){
          return TrueCostUtilities.checkZipCode(zip);
        }
    
    @RemoteAction
        global static string getMeterData (string userid, string meterNumber){
          try{
                AccountPremiseAssociation__C theAPA2 = APAUtilities.GetActiveAPA(TrueCostUtilities.GetTheAccount(userid));
            
                premises__c theprem = [select id, meter_number__c
                           from premises__c where id=: theAPA2.premise__r.id];
                theprem.meter_number__c = meterNumber;
                update theprem;  
                
                theAPA2.meter_data_permission__c = true;
                //UsageRequestManager mgr = new UsageRequestManager();
                //mgr.sendRequest(theprem, theAPA2, 'Summary Billing Data') ; 
                theAPA2.Meter_Data_Request_Status__c = 'In Progress';    
                theAPA2.Meter_Data_Permission__c = true;
                UhitAsync.UHITSummaryCalloutFuture(theAPA2.id);
                update theAPA2; 
                         
                return 'Success';
            } catch(exception e){return string.valueof(e);}
        }
    
    @RemoteAction
        global static string setPremiseSize (string userid, string size){
          try{
                AccountPremiseAssociation__C theAPA2 = APAUtilities.GetActiveAPA(TrueCostUtilities.GetTheAccount(userid));                
                theAPA2.Customer_Selected_Profile__c = size;
                update theAPA2;            
                return 'Success';
            } catch(exception e){return string.valueof(e);}
        }
    
    @RemoteAction
        global static string RemoteCreateAPA (string userid, string premiseid){
          try{
                account a = [select id from account where id=:TrueCostUtilities.GetTheAccount(userid)];
                APAUtilities.MakeAPA(a.id, premiseid);
                return 'Success';
            } catch (exception e){return string.valueof(e);}
        }
    
    @RemoteAction
            global static string Register(string first, string last, string email, string password, string promo){
                //check for existing user by email
                list<user> ulist = [select id from user where username =: email];
                if (ulist.size()!=0) {return 'That email address has already been used.';}
                integer x=1;
                string trynickname = first+last;
                ulist = [select id from user where communitynickname =: trynickname];
                if (ulist.size()>0){
                  do{
                        x++;
                      trynickname = first+last+x;
                      ulist = [select id from user where communitynickname =: trynickname];
                    } while (ulist.size()>0);
                }
                user u = new user();
                u.communitynickname = trynickname.substring(0,math.min(trynickname.length(), 38));
                u.firstname=first;
                u.lastname=last;
                u.email=email;
                u.username=email;


        id userId;
                
                try{
                  userId = Site.createPersonAccountPortalUser(u, string.valueof(TrueCostUtilities.lookuptheadmin()), password); 
                }catch (exception e){return 'There was an error with your registration.'; } 
                
                //update promo on account
                /*if (promo!=null){
                    try{
                        updateAccountWithPromoCode(userID, promo);
                    }catch(exception e){}
                }
                */
                return 'Success';
            }
    
    @RemoteAction
            global static string RegisterWithGA(string first, string last, string email, string password, string promo, GAContainer GAC){
                //check for existing user by email
                list<user> ulist = [select id from user where username =: email];
                if (ulist.size()!=0) {return 'That email address has already been used.';}
                integer x=1;
                string trynickname = first+last;
                ulist = [select id from user where communitynickname =: trynickname];
                if (ulist.size()>0){
                  do{
                        x++;
                      trynickname = first+last+x;
                      ulist = [select id from user where communitynickname =: trynickname];
                    } while (ulist.size()>0);
                }
                user u = new user();
                u.communitynickname = trynickname.substring(0,math.min(trynickname.length(), 38));
                u.firstname=first;
                u.lastname=last;
                u.email=email;
                u.username=email;
                id userId;
                
                try{
                  userId = Site.createPersonAccountPortalUser(u, string.valueof(TrueCostUtilities.lookuptheadmin()), password); 
                }catch (exception e){return 'There was an error with your registration.'; } 
                
                try{//update promo/analytics tracking on account                    
                    if (GAC!=null || promo!=null){                    
                        updateAccountGA(userID, GAC.campaign, GAC.medium, GAC.source, GAC.term, GAC.content, promo);
                    }
                }catch(exception e){system.debug(e.getmessage());}
                
                return 'Success';
            }
    
    global class GAContainer {
        public string campaign{get;set;}
        public string medium{get;set;}
        public string source{get;set;}
        public string term{get;set;}
        public string content{get;set;}
    }
    
    @future
    global static void updateAccountGA(id userid, string c, string m, string s, string t, string n, string promo){
      if (userId != null) { 
            try{
                account newaccount = [select id, Web_Source__c ,GA_Campaign__c, GA_Content__c, GA_Medium__c, GA_Term__c from account where id=: TrueCostUtilities.gettheAccount(userid)];
                newAccount.GA_Source__c = s; 
                newAccount.GA_Campaign__c = c; 
                newAccount.GA_Content__c = n; 
                newAccount.GA_Medium__c = m; 
                newAccount.GA_Term__c = t; 
                newAccount.Web_Source__c = promo;
                update newaccount; 
            }catch(exception e){}
      }
    }
    
    @RemoteAction
    public static Lead getLead(id leadid){
        try{ return [select id,
                FirstName, LastName, Email, Phone, Street, City, State, PostalCode, SessionStore__c
                from Lead where id=:leadid order by lastmodifieddate limit 1];
           }catch (exception e){return null;}
     
    }


    @RemoteAction
    public static List<Lead> createLead(string s, string status, string email){
        try {
            //List<Lead> leads = [select id, email from Lead where email = :email];
            //insert new Lead( Email = email, LastName = 'unknown');
            //List<Lead> leads = [select id, email from Lead where email = :email order by lastmodifieddate limit 1];
            //return leads;
            if(String.isEmpty(email)){
                insert new Lead( LastName = s, LeadSource = status);
            } else {
                insert new Lead( LastName = s, LeadSource = status, Email = email);
            }
            List<Lead> leads = [select id, LastName, Email, LeadSource, workflow_timer__c from Lead where LastName = :s order by lastmodifieddate limit 1];
            return leads;    
        } catch(exception e) {
            return null;
        }      
     
    }

    @RemoteAction
    public static List<Lead> updateLead(
        id leadid,
        string email,
        string zip,
        string firstName,
        string lastName,
        string phone,
        string street,
        string company,
        string dob,
        boolean meterDataPermission,
        string session,
        string language,
        string switchDate){

        Date dateOfBirth = Date.parse(dob);
        //Date dateOfSwitch = Date.parse(switchDate);
        Date dateOfSwitch = Date.parse(switchDate);
        DateTime triggerDateTime = DateTime.now() - .041;

        List<Lead> leads = [select id,
        Email,
        Zip__c,
        FirstName,
        LastName,
        Phone,
        Street,
        Company,
        Birth_Date__c,
        Language__c,
        Switch_Date__c,
        LeadSource,
        Description,
        dm_timestamp__c,
        workflow_timer__c
        from Lead where Id = :leadid order by lastmodifieddate limit 1];

        if(!String.isEmpty(lastName)){
            leads[0].LastName = lastName;
        }
        if(!String.isEmpty(email)){
            leads[0].Email = email;
        }
        if(!String.isEmpty(firstName)){
            leads[0].FirstName = firstName;
        }
        if(!String.isEmpty(zip)){
            leads[0].Zip__c = zip;
        }
        if(leads[0].LeadSource == 'switch-reminder'){
            //leads[0].Description = 'switch-reminder-update';  
        }
        
        leads[0].workflow_timer__c = triggerDateTime;
        leads[0].Phone = phone;
        leads[0].Street = street;
        leads[0].Company = company;
        leads[0].Birth_Date__c = dateOfBirth;
        leads[0].SessionStore__c = session;
        leads[0].Meter_Data_Permission__c = meterDataPermission;
        leads[0].Language__c = language;
        //leads[0].Switch_Date__c = dateOfSwitch;
        leads[0].Switch_Date__c = dateOfSwitch;
        update leads;
        return leads;     
    }







    
    @RemoteAction
        global static string RemoteLogin(string email, string password, string url){
            PageReference result = new PageReference('temp');
            try {
                result = Site.login(email, password, url);
              system.debug(result);
            }catch (exception e){
              return e.getMessage();
            }
            if (result!=null) {
                insert new AsyncRequest__c(type__c='TrueCostLoginTracking', params__c=email);
                return result.getURL(); 
            } else {
                return 'login error';
            }
        }

    
    @RemoteAction 
    global static string CheckDataStatusRemote(string userid){
      string x = [select id, Meter_Data_Request_Status__c from AccountPremiseAssociation__c 
            where account__r.id=:TrueCostUtilities.getTheAccount(userid) and selected__c=:true order by lastmodifieddate limit 1].Meter_Data_Request_Status__c;
      if (x.contains('Error')) x='Error';
        return x;
    }
    
    @RemoteAction 
    global static string CheckDataStatusRemoteDetails(string userid){
      string x = [select id, Meter_Data_Request_Status__c from AccountPremiseAssociation__c 
            where account__r.id=:TrueCostUtilities.getTheAccount(userid) and selected__c=:true order by lastmodifieddate limit 1].Meter_Data_Request_Status__c;
        return x;
    }
    
    @RemoteAction 
    global static account getAddressDetails(string userid){
      account x = [select id, firstname, lastname, personemail, phone,
                     PersonMailingStreet, PersonMailingCity, PersonMailingPostalCode, PersonMailingState
                     from account where id=:TrueCostUtilities.getTheAccount(userid)];
        return x;
    }
    
    @RemoteAction 
    global static string putAddressDetails(string userid, string first,string last,string email,string phone,string street,string city,string state,string zip){
      account x = [select id, firstname, lastname, personemail, phone,
                     PersonMailingStreet, PersonMailingCity, PersonMailingPostalCode, PersonMailingState
                     from account where id=:TrueCostUtilities.getTheAccount(userid)];
        x.firstname=first; x.lastname=last; x.personemail=email; x.phone=phone; 
        x.PersonMailingStreet=street; x.PersonMailingCity=city; x.PersonMailingPostalCode=zip; x.PersonMailingState=state;
        try{ 
            update x;
          return 'Success';
        }catch(exception e){return e.getMessage();}
    }
    
    @RemoteAction 
    global static string CreateRemoteCase(string userid, string name, string email, string phone, string description, boolean wantsContact, string userAgent){
        system.debug(userAgent);
        id rt = [select id from recordtype where name='TrueCost Customer Case'].id;
        truecost_case__c tcc;
        try{
            account a = [select id from account where id=:TrueCostUtilities.getTheAccount(userid)][0];
            tcc = new truecost_case__c(Contact_Person__c=name, Non_Account_Email__c=email, internal_comments__c='browser is '+userAgent, Non_Account_Phone__c=phone, recordtypeid=rt, account__c=a.id, description__c=description, wants_contact__c=wantsContact, origin__c='Web');
          
        } catch(exception e){
            system.debug(e);
          tcc = new truecost_case__c(Non_Account_Email__c=email, Non_Account_Phone__c=phone, internal_comments__c='browser is '+userAgent, recordtypeid=rt, description__c=description, wants_contact__c=wantsContact, origin__c='Web');
        } 
        try{insert tcc;}catch(exception e){system.debug(e);return e.getMessage();}    
        return tcc.id;
    }
    
    @RemoteAction 
    global static string CreateRemoteCaseAnyType(string userid, string name, string email, string phone, string description, boolean wantsContact, string userAgent, string rt){
        system.debug(userAgent);
        id rtid;
        if (rt!=null) {
            rtid= [select id from recordtype where name=:rt].id;
        } else{
            rtid= [select id from recordtype where name='TrueCost Customer Case'].id;

        }
        truecost_case__c tcc;
        try{
            account a = [select id from account where id=:TrueCostUtilities.getTheAccount(userid)][0];
            tcc = new truecost_case__c(Contact_Person__c=name, Non_Account_Email__c=email, internal_comments__c='browser is '+userAgent, Non_Account_Phone__c=phone, recordtypeid=rtid, account__c=a.id, description__c=description, wants_contact__c=wantsContact, origin__c='Web');
          
        } catch(exception e){
            system.debug(e);
          tcc = new truecost_case__c(Non_Account_Email__c=email, Non_Account_Phone__c=phone, internal_comments__c='browser is '+userAgent, recordtypeid=rtid, description__c=description, wants_contact__c=wantsContact, origin__c='Web');
        } 
        try{insert tcc;}catch(exception e){system.debug(e);return e.getMessage();}    
        return tcc.id;
    }
    
    
    
    
    @RemoteAction
        global static string SetPremiseStuff(string userid, integer sqft, string year, integer occupants, string heating, boolean pool, boolean estimate){
          AccountPremiseAssociation__C theAPA = APAUtilities.GetActiveAPA(TrueCostUtilities.GetTheAccount(userid));
            premises__c p = [select id, Square_Feet__c, Year_Built__c, Heating_System__c, Occupants__c, Pool__c from premises__c where id=:theAPA.premise__r.id];
            p.Square_Feet__c=sqft;
            p.Year_Built__c=year;
            p.Heating_System__c=heating;
            p.Occupants__c=occupants;
            p.Pool__c=pool;
            try{
              update p;
            }catch(exception e) {return e.getMessage();}
            if (estimate){
                system.debug('doing an estimate');
                TrueCostEstimator.MakeEstimateThenSave(theAPA);
                theAPA.Meter_Data_Estimated__c = true;
                try {                       
                    update theAPA;
                } catch(DmlException d) {
                    return d.getMessage();
                }
            }
            return 'Success';
        }

    @RemoteAction
        global static AccountPremiseAssociation__c getAPAsafe(id userid){
            try{ return [select id, 
                    premise__r.id, premise__c, premise__r.premise_type__c, 
                    premise__r.Electric_Service_Address_Zip__c, 
                    premise__r.ESID__c, premise__r.Electric_Service_Address__c, premise__r.Electric_Service_Address_City__c, 
                    premise__r.Electric_Service_Address_State2__c, 
                    premise__r.Occupants__c, premise__r.Square_Feet__c, premise__r.Heating_System__c, premise__r.Year_Built__c, premise__r.Pool__c,

                    premise__r.TDSP_Lookup__r.Meter_Data_Method__c, premise__r.TDSP_Lookup__r.Name,

                    account__r.Billing_Adrs_Line_1__c,account__r.Billing_Adrs_Line_2__c, 
                    account__r.Billing_City__c, account__r.Billing_zip_code__c, account__r.State__c,
                    account__r.FirstName, account__r.LastName, account__r.Phone,                     
                    account__r.DBA_Name__c ,  account__r.DUNS_Number__c, account__r.Id, 
                    account__r.Meter_Data_Email_Daily__c, account__r.Meter_Data_Email_Weekly__c, 
                    account__r.isPersonAccount, account__r.PersonEmail, account__r.Language_Preference__c,

                    Meter_Data_Permission__c, Meter_Data_Request_Status__c, Public_data__c, Customer_Selected_Profile__c                            

                    from AccountPremiseAssociation__c 
                    where selected__c=true and account__r.id=:TrueCostUtilities.getTheAccount(userid) order by lastmodifieddate limit 1];
               }catch (exception e){return null;}
            
        }


    // EDITS FOR TRUECOST V2 
    @RemoteAction
        global static string RemoteCreateTC2 (string userid, string premiseid){
          try{
                account a = [select id from account where id=:TrueCostUtilities.GetTheAccount(userid)];
                APAUtilities.MakeAPA(a.id, premiseid);
                return '{"status":"success","account":"'+a.id+'"}';
            } catch (exception e){return string.valueof(e);}
        }
    @RemoteAction
            global static string RegisterTC2(string first, string last, string email, string password, string promo, GAContainer GAC){
                //check for existing user by email
                list<user> ulist = [select id from user where username =: email];
                if (ulist.size()!=0) {return 'That email address has already been used.';}
                integer x=1;
                string trynickname = first+last;
                ulist = [select id from user where communitynickname =: trynickname];
                if (ulist.size()>0){
                  do{
                        x++;
                      trynickname = first+last+x;
                      ulist = [select id from user where communitynickname =: trynickname];
                    } while (ulist.size()>0);
                }
                user u = new user();
                u.communitynickname = trynickname.substring(0,math.min(trynickname.length(), 38));
                u.firstname=first;
                u.lastname=last;
                u.email=email;
                u.username=email;
                id userId;
                
                try{
                  userId = Site.createPersonAccountPortalUser(u, string.valueof(TrueCostUtilities.lookuptheadmin()), password); 
                }catch (exception e){return 'There was an error with your registration.'; } 
                
                try{//update promo/analytics tracking on account                    
                    if (GAC!=null || promo!=null){                    
                        updateAccountGA(userID, GAC.campaign, GAC.medium, GAC.source, GAC.term, GAC.content, promo);
                    }
                }catch(exception e){system.debug(e.getmessage());}
                
                return '{"status":"success","user":"'+userId+'"}';
            }
    @RemoteAction
            global static string CheckExistingEmail(string email){
                list<user> ulist = [select id from user where username =: email];
                if (ulist.size()!=0) { 
                    return 'That email address has already been used.';
                }
                return 'Success';
            }

    @RemoteAction 
    global static string changePasswordTC2(string newPassword, string verifyNewPassword, string oldpassword) {

        try{
            Site.changePassword(newPassword, verifyNewPassword, oldpassword);
        }catch (exception e){
            return 'There was an error with your registration.'; 
        } 
         
        return '{"status":"success"}';
    }    
    @RemoteAction 
    global static string forgotPasswordTC2(string email) {

        boolean success = Site.forgotPassword(email);
        
        if (success) {              
            return '{"status":"success"}';
        } else {
            return '{"status":"error"}';
        }
        
    }     
    @RemoteAction
            global static string getTheRewardsTC2(id therateid){
                
            Rate__c rate;
            id program;

            //first get the REP offering the rate in the URL parameter.  We'll check for universal plans
            list<rewards__c> rewardlist = new list<rewards__c>();
            try{
                rate = [select id, plan__r.REP_Profile__r.id from Rate__c where id=:therateid]; //match the rate with an REP and get its ID
            } catch(exception e){
                return JSON.serialize(rewardlist);
            }
                    
            list<RateRewardAssociation__c> RRAlist = [select id, reward__r.program__c, rate__r.plan__r.REP_Profile__r.id, reward__r.id from RateRewardAssociation__c 
                where rate__r.id=:therateid];
            list<id> rewardIDlist = new list<id>();
            for (RateRewardAssociation__c RRA:RRAlist){
                rewardIDlist.add(RRA.reward__r.id);
            }
                    
            rewardlist=[select id, Choice__c, Program__c, name, Percentage_Value__c, Reward_Value__c, Reward_Program__c,reward_program__r.id,  Reward_Description__c, 
                                Time_from_start_of_contract_in_months__c, New_Customer_Only__c 
                                from rewards__c 
                                where ((id in: rewardIDlist or reward_program__r.id in:rewardIDlist) or (Applies_to_all_plans__c=:true and rep_profile__r.id =: rate.plan__r.rep_profile__r.id)) and ((Reward_Start_Date__c<=:System.today() and Reward_End_Date__c>=:System.today()) or (Reward_Start_Date__c=:null and Reward_End_Date__c=:null))
                                order by Program__c, Reward_Program__c, Time_from_start_of_contract_in_months__c ASC, choice__c
                        ];
            system.debug('==================rewardslist contains' + rewardlist);
            list<rewards__c> rewardlist2 = new list<rewards__c>();
            for (Rewards__c reward :rewardlist){
                if (reward.program__c){ //if it's a program
                    rewardlist2.add(reward);//gather each program into your list    
                    system.debug('==================added program' + reward.name);
                    for (Rewards__c subreward :rewardlist){ //look through all the rewards again
                        system.debug('====================checking reward + subreward' + subreward.name);
                        if (subreward.Reward_Program__r.id == reward.id){ //find all the rewards that are part of that program
                            rewardlist2.add(subreward); // add them so that the display order to the customer makes sense
                            system.debug('==================added subreward + subreward.name');
                        }   else {system.debug('==================did not add subreward + subreward.name');}
                    }
                }         
            }
            for (Rewards__c reward:rewardlist){ //now grab the rewars taht are not part of a program and list them.
                        if (!reward.program__c && reward.reward_Program__c ==null){
                            rewardlist2.add(reward);
                        }
                            
                    }
            
            return JSON.serialize(rewardlist2);
                
            }
}