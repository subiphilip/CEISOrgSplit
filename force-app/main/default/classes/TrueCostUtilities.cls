/*
1/24/2012   Shane McLaughlin    Added Method 'markBetaInviteComplete' used by trigger 'NewAccount'.  No test written.
1/26/2012   Hemanth Chandra     Fixed List bound exception in getThePremices method
1/26/2012   Shane McLaughlin    Added published__c to the where clause on methods that query rep_ratings__c
1/29/2012   Hemanth Chandra     Fixed List bound exception in getMyInvite method 
2/4/2012    Shane McLaughlin    Moved ResultsContainer Class from Shoppping to TrueCostUtilities
2/6/2012    Shane McLaughlin    Added additional round of search for Address-ESID match; Code to remove 'TEMP' addresses from results
2/8/2012    Shane McLaughlin    Added commission calculation method
2/10/2012   Shane McLaughlin    Added method to check for orders in progress (functionality from the MyAccount class)
2/14/2012   Shane McLaughlin    Fixed defect in beta invite completion method (missing a ! operator)
2/15/2012   Shane McLaughlin    Alternate version of PullTheMontthlyUsage now takes APA as arguments.
2/22/2012   Shane McLaughlin    Added pricekWh variable to the resultsContainer class
2/23/2012   Barry Glasco        Added convert lead method called from NewOrder.trigger
3/1/2012    Shane McLaughlin    Added list<string> rewardsText to ResultsContainer class
3/1/2012    Hemanth Chandra     Added Confirmed for Order Status
3/2/2012    Shane McLaughlin    Removed Confirmed from query for Order In Progress
3/5/2012    Shane McLaughlin    Added PersonEmailToBadEmail method
3/5/2012    Shane McLaughlin    Added toProperCase method
3/13/2012   Shane McLaughlin    Added method to expire older orders when a new order is placed
3/14/2012   Shane McLaughlin    Added SavePlan (customers can save plan they like for future shopping)
3/23/2012   Shane McLaughlin    Changes to Address lookup to note and find apartment numbers
3/26/2012   Shane McLaughlin    Added filter on REPRating to prevent ratings from coming back that aren't linked to a participant.
6/26/2012                       changed markbeta query to include correct data
7/18/2012     Shane McLaughlin   commented out the test for beta invite.
7/18/2012     Shane McLaughlin   Commented out the pull the monthly usage by premise (we use APA for that now). 
8/7/2012     Shane McLaughlin    Added dedupe for monthly Usage query results.
9/24/2012    Shane McLaughlin    Commented out shopping methods (moved to other classes) and added new status codes to the GetOrderInProgress method
12/5/2012    Shane McLaughlin    Removed commented out methods (months of safety had passed).
12/5/2012   Shane McLaughlin     Added logic for cases where the usage data is incomplete of contains zeros
1/9/2013    Shane McLaughlin  GrabRewardsText2 uses maps to fix a "Applies to a All plans" omission and keep everything lighter
*/ 

public class  TrueCostUtilities {
        public static Integer resultSize {get;set;}
        
        public static id getTheAccount(id theuser){ //takes a userid and returns the account for that portal user
        list<user> theuserlist=[select contact.account.id from user where id =: theuser];
        if(!(theuserlist.isEmpty()))
        {
         id theaccount=theuserlist[0].contact.account.id;
        return theaccount;
        }
        else
        return null;
    }
    
    public static id lookuptheAdmin(){
        //list<user> alladmins = [select id from user where profile.Name = 'System Administrator' and IsActive= true and userrole.name = 'Business Manager'];         
        //return alladmins[0].id;
        return '00530000005wfQm';
    }
    
    @future
    public static void incrementLoginCounterTimestamp(string e){
        list<account> a = new list<account>();
        a = [select id, isPersonAccount, Last_Login_Time_Stamp__c, TrueCost_login_count__c from account 
                        where personEmail like :e ];
        if (a.size()==1){
            a[0].Last_Login_Time_Stamp__c =system.now();
            if (a[0].TrueCost_login_count__c == null) {a[0].TrueCost_login_count__c = 0;}
            a[0].TrueCost_login_count__c ++;
            try{
                update a;
            } catch (DMLException dml){
                //just want to make sure login happens.  OK if counter is not perfect
              }
            
        }
    }

    public static void incrementLoginCounterTimestampNow(string e){
        list<account> a = new list<account>();
        a = [select id, isPersonAccount, Last_Login_Time_Stamp__c, TrueCost_login_count__c from account 
                        where personEmail like :e ];
        if (a.size()==1){
            a[0].Last_Login_Time_Stamp__c =system.now();
            if (a[0].TrueCost_login_count__c == null) {a[0].TrueCost_login_count__c = 0;}
            a[0].TrueCost_login_count__c ++;
            try{
                update a;
            } catch (DMLException dml){
                //just want to make sure login happens.  OK if counter is not perfect
              }
            
        }
    }
    
    public static id getThePremise(id user){
        list<AccountPremiseAssociation__c> thepremiselist=[select premise__c from AccountPremiseAssociation__c where account__c =: getTheAccount(user)];
        if(thepremiselist.isEmpty())
            return null;
        return thepremiselist[0].premise__c;
    }
        
    public static id getTheAPAs(id user){
        list<AccountPremiseAssociation__c> thelist=[select id, premise__c from AccountPremiseAssociation__c where account__c =: getTheAccount(user)];
        return thelist[0].id;
    }   
    
     public static list<monthly_usage__C> pullGuestMonthlyUsage(){
        list<monthly_usage__c> usagelist = new list<monthly_usage__c>();
            //temporary hack to apply the CEHE 1000 kWh usage.  TODO--query the premise's TDSP and get the right curve for that TDSP
            list<tdsp__c> cnp=[select id from TDSP__c where name!='None' and name like '%centerpoint%' and recordtypeid='012300000019FSK' LIMIT 1];
            usagelist=pullAverageUsage(cnp[0].id, '1000 kWh');
        return usagelist;   
    }
    
    public static list<monthly_usage__C> pullGuestMonthlyUsage(id tdsp){
        list<monthly_usage__c> usagelist = new list<monthly_usage__c>();            
        usagelist=pullAverageUsage(tdsp, '1000 kWh');
        return usagelist;   
    }
    
    public static list<monthly_usage__C> pullTheMonthlyUsage(AccountPremiseAssociation__c APA){
        list<monthly_usage__c> usagelist = new list<monthly_usage__c>();        //see if usage data permission exists
        try{
            if(APA.id==null){return TrueCostUtilities.pullGuestMonthlyUsage();}  //nulls never get past this line.  Allows for shopping without premise.
        } catch(exception e){
            system.debug(e); return TrueCostUtilities.pullGuestMonthlyUsage();
        }
        if (APA.Meter_Data_Permission__c){ //if so, then get the real data
            usagelist= [select id, usage__c, month_number__c, premise__r.tdsp_lookup__r.id from monthly_usage__c where APA__r.id =: APA.id and estimated__c = false order by month_number__c ];        
            system.debug('========================================================================================Real Data Found.  size==' + usagelist.size());            
            if(!usagelist.isempty() ) return scrubForDupes(usagelist);
        } 
        if ( !APA.Meter_Data_Permission__c || usagelist.isempty()  ){ //if no permission, or if no data is found, is there estimated data?
            usagelist= [select id, usage__c, month_number__c from monthly_usage__c where APA__r.id =: APA.id and estimated__c = true order by month_number__c ];
            if (usagelist.isempty()  ){  //if there's no estimated data, let's see if the user has selected a profile
            system.debug('========================================================================================No Estimated Data Found');
                if (APA.Premise__r.tdsp_lookup__r == null){ //default the customer to Houston Electric for now
                    APA.Premise__r.tdsp_lookup__r = [select id from tdsp__c where name like '%centerpoint%' limit 1];
                    system.debug('========================================================================================No TDSP Found');
                    usagelist = TrueCostUtilities.pullAverageUsage(APA.Premise__r.tdsp_lookup__r.id, '1000 kWh');
                    return usagelist;
                }               
                //let's get a load curve for the customer
                
                if ( APA.Customer_Selected_Profile__c == 'Small'){
                    usagelist = TrueCostUtilities.pullAverageUsage(APA.Premise__r.tdsp_lookup__r.id, '500 kWh');
                    system.debug('========================================================================================Small Profile')   ;
                } else {
                    if ( APA.Customer_Selected_Profile__c == 'Medium' || APA.Customer_Selected_Profile__c == null ){
                        usagelist = TrueCostUtilities.pullAverageUsage(APA.Premise__r.tdsp_lookup__r.id, '1000 kWh');
                    system.debug('========================================================================================Medium Profile')  ;
                    } else {
                        if ( APA.Customer_Selected_Profile__c == 'Large'){
                        usagelist = TrueCostUtilities.pullAverageUsage(APA.Premise__r.tdsp_lookup__r.id, '2000 kWh');   
                    system.debug('========================================================================================Large Profile')   ;
                        }
                    }
                }
                
            }
        }
        if(usagelist.isempty() ){return TrueCostUtilities.pullGuestMonthlyUsage();} //just in case.
        return scrubForDupes(usagelist);   
    }
    
    public static list<monthly_usage__C> scrubForDupes(list<monthly_usage__C> original){
        
        list<monthly_usage__C> scrubbed = new list<monthly_usage__C>();
        if(original.size()>12){            
                for (monthly_usage__C o:original){ //walk through each item
                    if (o.month_number__c > scrubbed.size()) { //if the scrubbed list doesn't have that month yet, we're going to add it.                        
                        scrubbed.add(o);
                    } else{ //then we assume that month was already represented.  If so, then let's take the minimum
                        if (o.usage__c < scrubbed[math.round(o.month_number__c-1)].usage__c){
                            monthly_usage__C changedvalue = scrubbed.get(math.round(o.month_number__c-1));
                            scrubbed.remove(math.round(o.month_number__c-1));
                            scrubbed.add(changedvalue);                            
                        }
                    }
                }    
            
            return CorrectNullsAndZeros(scrubbed);
            
        }                        
        return CorrectNullsAndZeros(original);
    }
    
    public static list<monthly_usage__C> CorrectNullsAndZeros(list<monthly_usage__C> original){
        list<monthly_usage__C> completed = new list<monthly_usage__C>();        
        list<monthly_usage__C> stuffToFix = new list<monthly_usage__C>();        
        boolean NotComplete=false;
        
        //check for zeros
        for (monthly_usage__C o:original){
            if (o.usage__c == null || o.usage__c == 0){
                //stuffToFix.add(o);  //if it's a null/zero, lets fix it   
                NotComplete = true;
            }
        }
        
        //check for missing months
        if (original.size()<12){
            list<decimal> monthsFound = new list<decimal>();
            for (integer x=1; x<13; x++){
                boolean found=false;
                for (monthly_usage__C o:original){
                    if (o.month_number__c == x){found = true;}
                }
                if (found==false){
                    NotComplete = true;
                    //stuffToFix.add(new monthly_usage__c(month_number__c=x, usage__c=0));
                }
            }
        }
        
        /*
            if (stuffToFix.size()>0){
            return FillGaps(pullAverageUsage(original[0].premise__r.tdsp_lookup__r.id, '1000 kWh'), original, StuffToFix);              
        }
        */
        if (NotComplete){
            system.debug('=====================================================Data Incomplete; starting FillGaps()');
            return FillGaps(pullAverageUsage(original[0].premise__r.tdsp_lookup__r.id, '1000 kWh'), original);            
        } 
        
        return original;
        
    }
    
    public static list<monthly_usage__C> FillGaps(list<monthly_usage__C> defaults, list<monthly_usage__C> actuals){
        map<decimal, decimal> MapActuals = new map<decimal, decimal>();
        map<decimal, decimal> MaptoFix = new map<decimal, decimal>();
        map<decimal, decimal> MapDefaults = new map<decimal, decimal>();
        list<monthly_usage__C> output = new list<monthly_usage__C>();
        
        //make our maps
        for (monthly_usage__C mu:defaults){
            MapDefaults.put(mu.month_number__c, mu.usage__c);
        }
        for (monthly_usage__C mu:actuals){
            MapActuals.put(mu.month_number__c, mu.usage__c);
        }        
        
        //get scaling factor
        decimal defaultTotal=0;
        decimal ActualTotal=0;
        decimal scalingFactor;
        
        for (decimal d:MapActuals.keyset()){
            if (MapActuals.get(d)!=0){
                defaultTotal=defaultTotal+MapDefaults.get(d);
                ActualTotal=ActualTotal+MapActuals.get(d);
            }
        }
        
        try{
            scalingFactor = ActualTotal/defaultTotal;
        }catch (exception e){scalingFactor=1;} //for div 0 in case there's absolutely no data at all or all 0
        
        for (integer x=1; x<13; x++){           
            if (MapActuals.get(x)!=null && MapActuals.get(x)!=0 ){
                    output.add(new monthly_usage__c(month_number__c=x, usage__c=MapActuals.get(x)));
                }else{
                    output.add(new monthly_usage__c(month_number__c=x, usage__c=(MapDefaults.get(x)*scalingFactor).setscale(0)));
                }            
        }        
        system.debug('=====================================================Returning the Corrected Output');
        system.debug(output);
        return output;
        
    }
    
    
    public static list<monthly_usage__C> pullAverageUsage(id TDSP, string usageprofile){
        system.debug('tdsp id is '+ tdsp);
        system.debug('usageprofile is '+ usageprofile);
        load_curve__c loadcurve = [select January__c, February__c,  March__c, April__c, May__c, June__c, July__c, August__c, September__c, October__c, November__c, December__c 
                                   //from load_curve__c where Usage_Profile__c=:usageprofile and TDSP__c=:TDSP and tdsp__r.recordtypeid='012300000019FSK'];
                                   from load_curve__c where Usage_Profile__c=:usageprofile and TDSP__c=:TDSP and tdsp__r.recordtype.name ='TDSP'];
        list<monthly_usage__c> fakeusagelist= new list<monthly_usage__c>();
        
        list <decimal> eachmonth = new list<decimal>();
        eachmonth.add(loadcurve.January__c);
        eachmonth.add(loadcurve.February__c);
        eachmonth.add(loadcurve.March__c);
        eachmonth.add(loadcurve.April__c);
        eachmonth.add(loadcurve.May__c);
        eachmonth.add(loadcurve.June__c);
        eachmonth.add(loadcurve.July__c);
        eachmonth.add(loadcurve.August__c);
        eachmonth.add(loadcurve.September__c);
        eachmonth.add(loadcurve.October__c);
        eachmonth.add(loadcurve.November__c);
        eachmonth.add(loadcurve.December__c);
        system.debug('Stuff added to eachmonth list: jan is ' + eachmonth[0]);
        system.debug('Stuff added to eachmonth list: jun is ' + eachmonth[5]);
        
        for (integer i=0; i<12; i++){           
            monthly_usage__C mu = new monthly_usage__C();               system.debug('starting iteration' + i);
            mu.Month_Number__c=i+1; system.debug ('month number assigned' + (i+1) );
            mu.usage__c=eachmonth[i]; system.debug ('usage assigned' + eachmonth[i] );
            fakeusagelist.add(mu);       system.debug ('added a row' + mu );     system.debug('Here is complete usagelist ' + fakeusagelist);
                        
        }   
        system.debug('Here is complete usagelist ' + fakeusagelist);
        system.debug('=============usagelist is of size ' + fakeusagelist.size());
        return fakeusagelist;
    }
    
    public static string checkZipCode(string zip2check){ //checks to see if the entered zip code is served by TrueCost or in our expansion plans
        list<validzipcode__c> ziplist = new list<validzipcode__c>();
        ziplist= [select id, name, tdsp__c, served_by_TrueCost__c from ValidZipCode__c where name =: zip2check];
        
        if ((ziplist.size()==1)&&(ziplist[0].Served_by_TrueCost__c==true)) {return 'Now';}
            else{if ((ziplist.size()==1)&&(ziplist[0].Served_by_TrueCost__c==false)) {return 'Later';} 
                else{if (ziplist.size()==0) {return 'No';} 
                    else{if (ziplist.size()>1) {return 'Maybe';}
                        else {return 'Error';}
                    }
                }
            }
        }
    
    public static string TDSPfromZipCode(string zip2check){ //checks to see if the entered zip code is served by TrueCost or in our expansion plans
        list<validzipcode__c> ziplist = new list<validzipcode__c>();
        ziplist= [select id, name, tdsp_lookup__r.name, served_by_TrueCost__c from ValidZipCode__c where name =: zip2check];        
        if (ziplist.size()==1) return ziplist[0].tdsp_lookup__r.name;
        if (ziplist.size()==0) return 'None';
        if (ziplist.size()>1) return 'Multiple';
        
        return null; //won't happen but it's required
    }
    
    public static list<rep_rating__c> getRatingsForREP (id repid){ //retrieves the data for populating the REP review list
        list<rep_rating__c> repratinglist = new list<rep_rating__C>();
        repratinglist=[select id, rating__c, REP_Profile__r.name, Review__c, REP_Profile__r.logo_url__c, createddate, 
        author__r.firstname, Plan__r.name, Site_Comments__c
        from rep_rating__c where rep_profile__r.id =:repid and published__c=true order by createddate DESC limit 50];             
        return repratinglist;
    }
    
    public static list<ratingwrapper> getRatingWrapperForREP (id repid){ //retrieves the data for populating the REP review list
        list<rep_rating__c> repratinglist = new list<rep_rating__C>();
        repratinglist=[select id, rating__c, REP_Profile__r.name, Review__c, REP_Profile__r.logo_url__c, createddate, 
        author__r.firstname, Plan__r.name, Site_Comments__c
        from rep_rating__c where rep_profile__r.id =:repid and published__c=true 
                       order by createddate DESC limit 50];
        list<ratingwrapper> theoutput = new list<ratingwrapper>();
        for (rep_rating__c i:repratinglist){
            ratingwrapper x = new ratingwrapper();
            x.firstname=i.author__r.firstname;
            x.rating=i.rating__c;
            x.REP=i.REP_Profile__r.name;
            x.review=i.Review__c;
            x.whenmade=i.createddate.format('MM/dd/yyyy');
            x.plan=i.Plan__r.name;
            x.sitecomments=i.Site_Comments__c;
            theoutput.add(x);
        }           
        return theoutput;
    }
    
    public static list<ratingwrapper> getRatingWrapperForREP (){ //If no REP is specified
        list<rep_rating__c> repratinglist = new list<rep_rating__C>();
        repratinglist=[select id, rating__c, REP_Profile__r.name, Review__c, REP_Profile__r.logo_url__c, createddate, 
        author__r.firstname, Plan__r.name, rep_profile__r.id, Site_Comments__c
        from rep_rating__c 
                       where rep_profile__c != null and rep_profile__r.active__c = true and published__c=true
                       order by createddate DESC limit 50];
        list<ratingwrapper> theoutput = new list<ratingwrapper>();
        for (rep_rating__c i:repratinglist){
            ratingwrapper x = new ratingwrapper();
            x.firstname=i.author__r.firstname;
            x.rating=i.rating__c;
            x.REP=i.REP_Profile__r.name;
            x.review=i.Review__c;
            x.sitecomments=i.Site_Comments__c;
            x.whenmade=i.createddate.format('MM/dd/yyyy');
            x.plan=i.Plan__r.name;
            x.logourl=i.REP_Profile__r.logo_url__C;
            x.repid=i.rep_profile__r.id;
            theoutput.add(x);
        }           
        return theoutput;
    }
    
    public class ratingwrapper {
        public string firstname{get;set;}
        public decimal rating{get;set;}
        public string REP{get;set;}
        public string review{get;set;}
        public string whenmade{get;set;}
        public string plan{get;set;}
        public string logourl{Get;set;}
        public string sitecomments{get;set;}
        public id repid{get;set;}
    }
    
public static list<premises__C> exactMatchServiceAddress(string address, string zip){
        list<string> strings =address.split(' ', 0);
        //Let's see if we have an apartment number.        
          if ((strings[strings.size()-1].contains('0') ||            strings[strings.size()-1].contains('1') ||            strings[strings.size()-1].contains('2') ||
                strings[strings.size()-1].contains('3') ||             strings[strings.size()-1].contains('4') ||             strings[strings.size()-1].contains('5') ||
                strings[strings.size()-1].contains('6') ||            strings[strings.size()-1].contains('7') ||            strings[strings.size()-1].contains('8') ||
                strings[strings.size()-1].contains('9') ||            strings[strings.size()-1].contains('0') ) && strings.size()>2){
            
                    string APTsearchquery='FIND\'' + strings[0] + ' ' + strings[1] + ' ' + strings[strings.size()-1]+'*\' IN ALL FIELDS  RETURNING Premises__c (Premise_Type__c,id,ESID__c, Electric_Service_Address__c, Electric_Service_Address_City__c, Electric_Service_Address_Zip__c, Electric_Service_Address_State2__c Where (ESI_ID_Status__c = \'Active\' or ESI_ID_Status__c = \'De-Energized\') and Electric_Service_Address_Zip__c like  \'' + zip + '%\' limit 25)';
                    List<List<SObject>> APTsearchList=search.query(APTsearchquery);
                    premises__c[] theAPTlist = ((List<premises__c>)APTsearchlist[0]);        
                    return noTemps(theAPTlist);
          }
                                 
        //if you're this far, there was no apartment number OR no matching address was found.    
        string searchquery='FIND\'' + address + '*\' IN ALL FIELDS  RETURNING Premises__c (Premise_Type__c,id,ESID__c, Electric_Service_Address__c, Electric_Service_Address_City__c, Electric_Service_Address_State2__c, Electric_Service_Address_Zip__c Where (ESI_ID_Status__c = \'Active\' or ESI_ID_Status__c = \'De-Energized\') and Electric_Service_Address_Zip__c like  \'' + zip + '%\' limit 25)';
        system.debug('searchquery'+searchquery);
        List<List<SObject>>searchList=search.query(searchquery);
        premises__c[] thelist = ((List<premises__c>)searchlist[0]);
        if (thelist.size()==0){ //if no matches, broaden the query to
            list<string> streetnumber=address.split(' ', 0); //strip off the street number and first string at the front of the address and pull all the matches for given zip
            if(streetnumber.size()>1){
                searchquery='FIND\'' + streetnumber[0] + ' ' + streetnumber[1] + '*\' IN ALL FIELDS  RETURNING Premises__c (Premise_Type__c,id,ESID__c, Electric_Service_Address__c, Electric_Service_Address_City__c, Electric_Service_Address_State2__c, Electric_Service_Address_Zip__c Where (ESI_ID_Status__c = \'Active\' or ESI_ID_Status__c = \'De-Energized\') and Electric_Service_Address_Zip__c like  \'' + zip + '%\' limit 25)';
                searchList=search.query(searchquery);
                thelist = ((List<premises__c>)searchlist[0]);
                if (thelist.size()==0){ //if no matches, broaden the query to
                    System.Debug('address'+address);
                    streetnumber=address.split(' ', 0); //strip off the street number at the front of the address and pull all the matches for given zip
                    System.Debug('streetnumber'+streetnumber);
                    if (streetnumber[0].length()>1){ //to prevent the dreaded 1-character SOSL error
                        searchquery='FIND\'' + streetnumber[0] + '*\' IN ALL FIELDS  RETURNING Premises__c (Premise_Type__c,id,ESID__c, Electric_Service_Address__c, Electric_Service_Address_City__c, Electric_Service_Address_Zip__c, Electric_Service_Address_State2__c Where (ESI_ID_Status__c = \'Active\' or ESI_ID_Status__c = \'De-Energized\') and Electric_Service_Address_Zip__c like  \'' + zip + '%\' limit 25)';
                        searchList=search.query(searchquery);
                        thelist = ((List<premises__c>)searchlist[0]);
                    }
                }
            }
        }
        return NoTemps(thelist);
        
    }
    
    public static list<premises__c> NoTemps(list<premises__c> results){
        list<premises__c> finallist = new list<premises__c>();
        try{        
            for (premises__c prem:results){
                if (!prem.Electric_Service_Address__c.endswith('TEMP')){
                    finallist.add(prem);
                }
            }
        } catch(exception e){}
        return finallist;
    }
        
        
    
    public static list<premises__C> searchByESID (string ESID){
        if (ESID==null) {premises__c[] thelist = new list<premises__C>(); return thelist;}
        string searchquery='FIND\'' + ESID + '*\' IN ALL FIELDS  RETURNING Premises__c (Premise_Type__c,id,ESID__c, Electric_Service_Address__c, Electric_Service_Address_City__c, Electric_Service_Address_State2__c, Electric_Service_Address_Zip__c limit 25)';
        List<List<SObject>>searchList=search.query(searchquery);
        premises__c[] thelist = ((List<premises__c>)searchlist[0]);
        
        
        return thelist;
        
    }
    
    public static void grantMeterDataPermission(id premiseid){
        premises__c thepremise=[select id, Meter_Data_Permission__c from premises__c where id =: premiseid];
        thepremise.Meter_Data_Permission__c=true;
        update thepremise;
    }
    
    public static boolean checkMeterDataPermission(id APAid){
        AccountPremiseAssociation__c theAPA=[select id, Meter_Data_Permission__c from AccountPremiseAssociation__c where id =: APAid];
        return theAPA.Meter_Data_Permission__c;
    }
    public static string checkMeterDataStatus(id APAid){
        AccountPremiseAssociation__c theAPA=[select id, Meter_Data_Request_Status__c from AccountPremiseAssociation__c where id =: APAid];
        return theAPA.Meter_Data_Request_Status__c;
    }
    
    public static list<decimal> getcostchart(id rateid, id premiseid){
        decimal[] costlist = new decimal[11]; 
        month_estimate__C[] myME = [select Month_Number__c, Total__c  from month_estimate__C 
                                    where plan_estimate__r.rate__r.id =: rateid and plan_estimate__r.premise__r.id =: premiseid
                                    order by month_number__C];
        if(!myME.isempty() ){
            for (integer k=0; k<12; k++){
                costlist.add(myME[k].total__c);
            }
        }                                    
        return costlist;
    }
    
    public static integer countALLtheplans(){           
        return [select count() from rate__c where active__c =: true ];
    }
    
    public static integer countALLtheREPs(){                    
        return [select count() from REP_Profile__c];    
    }
    
    public static list<month_estimate__c> fetchMonthEstimates(id premiseid, id rateid, id accountid){
        month_estimate__c[] ListofME = new list<month_estimate__c>();
        ListofME = [select Customer_Charge__c, Energy_Charge__c, Minimum_Usage_Charge__c, TDSP_per_kWh__c, TDSP_per_Month__c, Total__c, Month_Number__c,
                            PUCA__c, MGRT__c, Local_Sales_Tax__c
                    from month_estimate__c 
                    where plan_estimate__r.premise__r.id =: premiseid and plan_estimate__r.rate__r.id =: rateid and plan_estimate__r.account__r.id =: accountid order by Month_number__C];
        
        return ListofMe;
    }
    
    /*public static integer CountMyInvites(id myaccount){
        integer invitecount=[select count() from beta_invite__c where status__c='new' and sender__c =: myaccount];
        return invitecount;
    }
    
    public static beta_invite__c GetMyInvite(id myaccount){
        beta_invite__c invite;
        if(myaccount != null){
            List<beta_invite__c> lstInvite = [select id, Invitee_Email__c, Message__c, Code__c, Sender__c, Status__c from beta_invite__c where status__c='New' and sender__c =: myaccount limit 1];
            if(!lstInvite.isEmpty())
                invite = lstInvite[0];
            //system.debug('=========invite is=============' + invite);
        }
        return invite;
    }*/
    
    public static string HashThis(string input){
        blob someinput = blob.valueof(input + Crypto.getRandomInteger());
        blob mess = crypto.generateDigest('MD5', someinput);        
        //system.debug(EncodingUtil.convertToHex(mess));
        return EncodingUtil.convertToHex(mess);
        
    }
    
    public static user GrabAUser(){
        user u = [select id from user where ContactId != null order by lastname limit 1 ];
        return u;
    }
    
    public static decimal getPUCA(){
        TaxesAndFees__c tf = TaxesAndFees__c.getOrgDefaults();
        return tf.PUCA__c;      
    }
    public static decimal getMGRT(){
        TaxesAndFees__c tf = TaxesAndFees__c.getOrgDefaults();
        return tf.MGRT__c;      
    }
    public static decimal getLocalSalesTax(string zip){     
        return 0.0125;
    }
    
    
    
    public static list<RateRewardAssociation__c> GrabRewardsText(list<rate__c> rates){
        list<RateRewardAssociation__c> RT = [select id, rate__r.id, reward__r.id, reward__r.name, reward__r.program__c, reward__r.REP_Profile__r.id, reward__r.Applies_To_All_Plans__c from RateRewardAssociation__c 
                                             where (rate__r.id in:rates or reward__r.Applies_to_All_Plans__c=true)  order by reward__r.program__c DESC];
        /*
        //get all the All Plans rewards
        //list<rewards__c> rewards = [select id, name, program__c, REP_Profile__r.id from rewards__c where  Applies_to_All_Plans__c=true order by program__c DESC];
        //for each "All Plans" reward, create a RRA for that rates that it applies to
        //for (rate__c r:rates){
            RateRewardAssociation__c
        }
        */
        return RT;      
    }
    
    public static map<id, string> GrabRewardsText2 (list<rate__c> rates){
        map<id, string> output = new map<id, string>();
        //rewards for the plans by rate id
        for (RateRewardAssociation__c RRA: [select id, rate__r.id, reward__r.id, reward__r.name, reward__r.program__c, reward__r.REP_Profile__r.id from RateRewardAssociation__c 
                                             where (rate__r.id in:rates)  order by reward__r.program__c DESC]){
           if (output.get(RRA.rate__r.id)==null) {
                output.put(RRA.rate__r.id, RRA.reward__r.name);
           } else {
                output.put(RRA.rate__r.id, output.get(RRA.rate__r.id) + ', ' + RRA.reward__r.name);
           }
        }
        //All Plans rewards by REP Profile
        for (Rewards__c Rew:[select id, name, REP_PRofile__r.id from rewards__c where Applies_To_All_Plans__c = true order by program__c DESC]){
            for (rate__c r:rates){
                if (r.plan__r.REP_PRofile__r.id == REW.REP_PRofile__r.id){
                   if (output.get(r.id)==null) {
                        output.put(r.id, Rew.name);
                   } else {
                       if (!output.get(r.id).contains(Rew.name)){//if it's not null, check to avoid duplicate text!
                           output.put(r.id, output.get(r.id) + ', ' + Rew.name);
                       }
                    } 
                }
            }
            
        } 
        
        return output;
    }
    
    
    public static boolean isSwitchHold(id premiseID){
        premises__c myprem = [select id, SWITCH_HOLD_INDICTOR__c from premises__C where id=:premiseID]; 
        return myprem.SWITCH_HOLD_INDICTOR__c=='Y';
    }
    
    public static void setOrderExpiration(list<Order__c> orders){
        
        list<BusinessHours> REPhours = [select id from BusinessHours where name = 'REP SLA']; //Finds the REP business hours 
        if (REPhours.size() == 0) REPhours = [select id from BusinessHours where isDefault = true];  //just in case, uses our org's default hours.
        
        for (Order__c o:orders){
            o.Order_Expiration_Date__c = BusinessHours.add(REPhours[0].id, o.createddate, 18*60*60*1000L); 
            system.debug('=============created=========  ' + o.createddate);    
            system.debug('=============will expire=========  ' + o.Order_Expiration_Date__c)    ;
        }
        update orders;
    
    }
    
    /*public static void markBetaInviteComplete(list<account> incominglist){  //Shane McLaughlin on 1/24/2012        
    }*/
    
    public static boolean showOnlyPublished(){ //checks a system variable (custom setting) to determine display rules
        TrueCostSystemVariables__c tcsv = TrueCostSystemVariables__c.getOrgDefaults();
        if(tcsv!=null)
        {
        return tcsv.Show_only_Published_content__c;
        }
        else
        {
          return false;
        }
    
    }
    
    public static decimal calculateCommission(decimal contractmonths){
        decimal monthsToUse = math.min(math.max(contractmonths, 3), 18);
        commission__c c = commission__c.getOrgDefaults();
        decimal comm = c.residential_per_month__c;
        return comm*monthstoUse;    
    }
    
    public static order__c CurrentOrder(AccountPremiseAssociation__C theAPA){
        order__c CurrentOrder = new order__c();
        list<order__c> orderlist = [select id, order_status__c, Plan_Expiration__c, REP_Profile__r.name 
                                 from order__c where Plan_Expiration__c>:system.today().addDays(14) and premise__c=:theAPA.premise__r.id and Parent_Account__r.id =: theAPA.account__r.id and order_status__c=: 'Confirmed' ];
        if (orderlist.size()>0) {           
            return orderlist[0];
            
        } else return null;
        
    }
    
    public static order__c orderinprogressNoDML(id acc, id prem){
        order__c orderinprogress = new order__c(); 
        list<order__c> orderlist = [select id, order_status__c, Plan_Expiration__c, REP_Profile__r.name, Contract_Length__c, plan__r.name, name, InitialDateofService__c 
                                 from order__c where premise__c=:prem and Parent_Account__r.id =: acc and (order_status__c = 'New' or order_status__c = 'New/Successfully Submitted' or order_status__c = 'Approved Pending Deposit' or  order_status__c = 'Approved Pending Confirmation' or order_status__c = 'Approved Pending Deposit' or  order_status__c = 'Pending Information' or order_status__c = 'Pending Switch Hold')];
        if (orderlist.size()>0) {           
            orderinprogress=orderlist[0];
        }        
        return orderinprogress;
    }
    
    public static order__c orderinprogress(id acc, id prem){
        order__c orderinprogress = new order__c(); 
        system.debug('Account: ' + acc + ' and premise: ' + prem);
                     
        list<order__c> orderlist = [select id, order_status__c, Plan_Expiration__c, REP_Profile__r.name, Contract_Length__c, plan__r.name, name, InitialDateofService__c 
                                 from order__c where premise__c=:prem and Parent_Account__r.id =: acc and (order_status__c = 'New' or order_status__c = 'New/Successfully Submitted' or order_status__c = 'Approved Pending Deposit' or order_status__c = 'Approved Pending Deposit' or  order_status__c = 'Approved Pending Confirmation' or  order_status__c = 'Pending Information' or order_status__c = 'Pending Switch Hold')];
        list<order__c> orderOld = [select id, order_status__c, Plan_Expiration__c, REP_Profile__r.name, Contract_Length__c, plan__r.name, name, InitialDateofService__c 
                                 from order__c where premise__c=:prem and Parent_Account__r.id =: acc and (order_status__c = 'Enroll Page - Started' or order_status__c = 'Enroll Page - Complete' or order_status__c = 'Plan Disclosures Page - Complete')];
        
       
        
        if (orderlist.size()>0) {           
            orderinprogress=orderlist[0];
        }
        
        if (orderOld.size()>0) {           
            delete orderOld;
        }
        return orderinprogress;
    }
    
        public static order__c orderinprogress( id prem){
        order__c orderinprogress = new order__c(); 
        system.debug('premise: ' + prem);
                     
        list<order__c> orderlist = [select id, order_status__c, Plan_Expiration__c, REP_Profile__r.name, Contract_Length__c, plan__r.name, name, InitialDateofService__c 
                                 from order__c where premise__c=:prem and (order_status__c = 'New' or order_status__c = 'New/Successfully Submitted' or order_status__c = 'Approved Pending Deposit' or order_status__c = 'Approved Pending Deposit' or  order_status__c = 'Approved Pending Confirmation' or  order_status__c = 'Pending Information' or order_status__c = 'Pending Switch Hold')];
        list<order__c> orderOld = [select id, order_status__c, Plan_Expiration__c, REP_Profile__r.name, Contract_Length__c, plan__r.name, name, InitialDateofService__c 
                                 from order__c where premise__c=:prem  and (order_status__c = 'Enroll Page - Started' or order_status__c = 'Enroll Page - Complete' or order_status__c = 'Plan Disclosures Page - Complete')];
        
       
        
        if (orderlist.size()>0) {           
            orderinprogress=orderlist[0];
        }
        
        if (orderOld.size()>0) {           
            delete orderOld;
        }
        return orderinprogress;
    }
    
    @future
    public static void convertLeadFromAcctId(id incoming){
        account a = [select id, personemail from account where id=:incoming];
        convertLead(a);
    }
    
    public static void convertLead(Account id){
     
      try {
        Account convert = id;
        
        list<Lead> leads =  [select id, isconverted, ownerid from Lead where email = :convert.personemail and email != null];
          for (lead lead:leads){  
        if (!lead.IsConverted)
        {
            Database.LeadConvert lc = new database.LeadConvert();
            lc.setLeadId(lead.id);
            system.debug('leadId:' + lead.id);
            lc.setAccountId(convert.id);
            lc.setOverwriteLeadSource(true);
            lc.setDoNotCreateOpportunity(true);
           // lc.setOwnerId(lead.ownerid);

            LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
            lc.setConvertedStatus(convertStatus.MasterLabel);
            
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            System.assert(lcr.isSuccess());
        }
      }
        
      }catch(exception e){
         system.debug('error' + e);
      }
    
    }

    public static void convertLeadAsync(string accountid){
      
        Account convert = [select id, personemail from account where id =:accountid order by createddate DESC limit 1];
        
        list<Lead> leads =  [select id, isconverted, ownerid from Lead where email = :convert.personemail and email != null];
          for (lead lead:leads){  
        if (!lead.IsConverted)
        {
            Database.LeadConvert lc = new database.LeadConvert();
            lc.setLeadId(lead.id);
            system.debug('leadId:' + lead.id);
            lc.setAccountId(convert.id);
            lc.setOverwriteLeadSource(true);
            lc.setDoNotCreateOpportunity(true);
           // lc.setOwnerId(lead.ownerid);

            LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
            lc.setConvertedStatus(convertStatus.MasterLabel);
            
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            System.assert(lcr.isSuccess());
        }
      }
    
    }
    
    public static string toProperCase(string txt){
        list<string> sl = txt.split(' ', 0);
                string x='';
                for (string s:sl){
                    s.trim();
                    if (s!=''){                     
                        s=s.substring(0,1).toUpperCase()+s.substring(1).toLowerCase();
                        x = x+s+' ';
                    }
                }
                
                return x.trim();
    }
    
    public static void expireOlderOrders(id prem){
        list<Order__c> orders = [select id, name, active__c, createddate from Order__c where premise__c =: prem order by createddate ASC];
        if (orders.size() > 1 ){                 //if there are previous orders
            for (Order__C anOrder:orders){
                anOrder.active__c = false;          //mark them all false (inactive)
                system.debug('marking false order number ================================' + anOrder.name);
            }
            orders[orders.size()-1].active__c = true;  //mark the newest one as active
            system.debug('marking true order number ================================' + orders[orders.size()-1].name);
            update orders;
        }
    }

///stuff for saving plans    
    public static void SavePlan(AccountPremiseAssociation__c APA, id rate){
        Saved_Plan__c SP = new Saved_Plan__c();
        sp.AccountPremiseAssociation__c = APA.id;
        sp.rate__c = rate;
        try{
            insert sp;
        } catch (dmlException e){}    
    }
    
    public static void UnsavePlan(AccountPremiseAssociation__c APA, id rate){
        Saved_Plan__c SP = new Saved_Plan__c();
        SP = [select id from saved_plan__c where AccountPremiseAssociation__c =: APA.id and rate__c =: rate];
        try{
            delete sp;
        } catch (dmlException e){} 

    }
    
    public static list<saved_plan__c> fetchSavedPlans(AccountPremiseAssociation__c APA){
        list<saved_plan__c> sps = [select id, rate__r.id, rate__r.plan__r.name, rate__r.plan__r.REP_PRofile__r.name
                                     from saved_plan__c where AccountPremiseAssociation__c =: APA.id];          
        return sps;
    }
    
    public static void RemoveExpirationDatesFromPreviousOrders(id orderid){
        order__c o = [select Parent_Account__c, createddate, premise__c from order__c where id=:orderid];
        //change 352
        Account acct = [select id, Current_Plan_Expiration__c from account where id =: o.Parent_Account__c limit 1];
        acct.Current_Plan_Expiration__c = null;
        update acct;

        //change 353 for 
        list<order__c> OrdersForUpdate = [SELECT Id,Order_Status__c,Plan_Expiration__c, Order_Renewal_Status__c, premise__c 
            FROM Order__c 
            WHERE order_status__c = 'Confirmed' and premise__c =: o.premise__c 
                    and createddate <: o.createddate 
                    and Order_Renewal_Status__c!='Won' and Order_Renewal_Status__c!='Lost' ];
        for (order__c a:OrdersForUpdate){
            a.Plan_Expiration__c = null;
            a.Order_Renewal_Status__c='Won';
        }
        update OrdersForUpdate;
        
    }

    public static void SetTrueCostOrderRecordType(string orderid){
        order__c o = [select id, rate__r.record_type_name__c, recordtypeid from order__c where id=:orderid];
        if (o.rate__r.record_type_name__c=='Commercial'){
            o.recordtypeid = [select id from recordtype where name='Commercial Electric Order'].id;
            update o;
        } else if (o.rate__r.record_type_name__c.contains('Residential')){
            
        }

    }
    
////////////Test methods below//////////////////////////////////////////////////////////
    
    
    static testmethod void testGetPUCA(){ getPUCA(); }
    static testmethod void testgetMGRT(){ getMGRT(); }
    static testmethod void getLocalSalesTax(){      getLocalSalesTax('77066');      }
    static testmethod void testGrabAUser(){ 
        // stage data
        Contact c = new Contact(LastName = 'Test Class test', FirstName = 'Test Test Test');
        insert c;
        
        GrabAUser(); 
    }
    
    /*static testmethod void testgetmyinvite(){
        user u = (GrabAUser());
        TrueCostTestUtilities.giveInvites(u);
        GetMyInvite(gettheaccount(u.id)); 
        
        }
    */
    
    
    static testmethod void testsetOrderExpiration(){
            TestControllerforREPOrderProcessing.setupthedata();
            list<order__c> olist = [select id, Order_Expiration_Date__c, createddate from order__c limit 5];                 
            setOrderExpiration(olist);
        }
    
    static testmethod void testhashthis(){        hashthis('string');    }
    
    static testmethod void testtheutilities(){
        TrueCostTestUtilities.createTestPremisewithUsage();
        TrueCostTestUtilities.createTestZipCodes();
        list<premises__c> thepremiseid=[select id from premises__c limit 1];
        //pullTheMonthlyUsage(thepremiseid[0].id);
        checkZipCode('00001');
        checkZipCode('00002');
        checkZipCode('00003');
    }
    
    static testmethod void testDataCreation(){
        TrueCostTestUtilities.createAlltheData();
    }
    
    
    public static void updateRatingsForREP(string repid){
        list<REP_rating__c> ratings = [select id, ownerid, rating__c, published__c, REP_Profile__c from REP_Rating__c where REP_Profile__c =: repid and REP_Profile__C != null];
        if (ratings.size()>0){
            decimal total=0;
            integer count=0;
            for (REP_rating__c rating:ratings) {
                if (rating.published__c){
                    total+=rating.rating__c;
                    count++;
                }
            }
            decimal average;
            if (count>0) average=total/count;

            REP_Profile__c RepToUpdate = [select id from REP_Profile__c where id=: repid];            
            RepToUpdate.Star_Rating_Avg__c=average;
            REPToUpdate.Total_Reviews__c=count;
            update RepToUpdate;            
        }
    }

    public static void UpdateAccountPIIfromOrder(string orderid){
        //get order
        order__c o = [select id, Parent_Account__r.id, Customer_Phone_Number__c, Parent_Account__r.SSN__c, Parent_Account__r.Birthday__c, SSN__c, Customer_Date_of_Birth__c
        from order__c
        where id=:orderid];
        

        //check account details, update nulls if they exist
        if (o.Parent_Account__r.SSN__c==null || o.Parent_Account__r.Birthday__c ==null){
            account a = [select id, Birthday__c, SSN__c from account where id=:o.Parent_Account__r.id];
            if (a.Birthday__c==null) a.Birthday__c=o.Customer_Date_of_Birth__c;
            if (a.SSN__c==null) a.SSN__c=o.SSN__c;
            if (a.Phone==null) a.Phone=o.Customer_Phone_Number__c;
            if (a.PersonHomePhone==null) a.PersonHomePhone=o.Customer_Phone_Number__c;

            update a;
        }
    }
    
    public static void SetREPofRecordAsync(string orderid){
        //get order
        order__c o = [select id, Parent_Account__r.id, REP_Profile__r.id, Premise__r.id 
        from order__c
        where id=:orderid];
        
        //get apa
        list<AccountPremiseAssociation__c> apa = [select id, REP_of_Record__c, Account__r.id, Premise__r.id, Selected__c, Attention__c  
        from AccountPremiseAssociation__c 
        where Selected__c = TRUE and Account__r.id =: o.Parent_Account__r.id and Premise__r.id =: o.Premise__r.id ];
            if (apa.size() == 0){
                return;}
                    else {

                        if (apa.size() > 1){
                        //do error stuff
                        for (AccountPremiseAssociation__c a:apa){
                        a.Attention__c = true;
                         }
                        } 
                        else {
                        apa[0].Rep_of_Record__c = o.Rep_Profile__r.id;
                        }
                    }
               
                update apa;          
      
    }
}