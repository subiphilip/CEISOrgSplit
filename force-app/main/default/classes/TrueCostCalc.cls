/*
1/9/2013  Shane McLaughlin  Uses the new GrabRewardsText2 from TrueCostUtilities
*/

public class TrueCostCalc { 
    
    
   public static Integer resultSize {get;set;}
    
   public static list<rate__C> getactivePlans2(AccountPremiseAssociation__c APA, id tdsp, string premiseType){//generates the plan list (really a list of rates)
        system.debug('TDSP is ' + tdsp);
        string rateType = PremiseType; 
        string loadprofile;
        boolean morethan50;
        decimal TotalUsage=1; 
        boolean noTOU;
        string repofrecordid;
        
        if (APA!=null){
            repofrecordid = APA.REP_of_Record__c;
            tdsp=APA.Premise__r.tdsp_lookup__r.id;
            if (APA.Meter_Data_Daily_Status__c != 'Complete'){
                noTOU = true;
            }   else noTOU = false;
            if (APA.premise__r.premise_type__c.contains('Non')){
                    rateType = 'Commercial';
                    loadprofile = APA.premise__r.Load_Profile__c;
                    morethan50 = APA.X50KVA__c;
                }  else rateType = 'Residential';           
            try{
                if (APA.meter_data_request_status__c == 'Complete') TotalUsage = totaltheUsage(TrueCostUtilities.pulltheMonthlyusage(APA));
            } catch (exception e){}
        } else { //guest commercial
            if (rateType == 'Commercial'){
                TotalUsage = totaltheusage(TrueCostUtilities.pullAverageUsage(tdsp, 'Less Than 50 KVA'));
                loadprofile = 'BUSLO';
                morethan50 = false;
            }
        }
        
        system.debug('rateType is ' + rateType);     
        list<rate__C> tempplanlist = SharedRateQuery(Tdsp, RateType, TotalUsage, REPofRecordID); //via shared query
        //if commercial, then remove the ones that don't match the premise load_profile__c (if it exists; if not, assume low!)
        if (ratetype=='Commercial' && !tempplanlist.isempty()){
            tempplanlist=CleanCommercialPlans(loadprofile, morethan50, tempplanlist);           
        }
        if (APA!=null && noTOU == true && !tempplanlist.isempty() ){
                tempplanlist=StripTOU(tempplanlist);
         }   
        if (APA==null && !tempplanlist.isempty() ){
            tempplanlist=StripTOU(tempplanlist);
        }
        return tempplanlist;
   } 

    public static list<rate__c> CleanCommercialPlans(string profile, boolean over50kva, list<rate__c> incomingRates){
        

        string LoadFactorString; //temp variable for matching the right string

        try{
            if(profile.contains('BUSHI')){
                LoadFactorString = 'High';
            }
            else if(profile.contains('BUSMED')){
                LoadFactorString = 'Medium';
            }
            else if(profile.contains('BUSLO') && over50kva){
                LoadFactorString = 'Low';
            }
            else if((profile.contains('BUSLO') && !over50kva)   ||  (profile ==null)    ||  (profile.contains('BUSNOD'))    ){
                LoadFactorString = 'Less Than 50 KVA';
            }
        } catch(exception e){
            LoadFactorString = 'Less Than 50 KVA';
        } //handles nulls explicitly

        list<rate__c> oklist = new list<rate__C>();
        for (rate__c r:incomingRates){
            if(r.Load_Factor__c.contains(LoadFactorString)||r.Load_Factor__c==null){
                oklist.add(r);
            } else {
                system.debug('This does not belong: '+  profile + ' with '+ r.Load_Factor__c);
            }
        }

        return oklist;
    }

    public static list<rate__c> StripTOU(list<rate__c> incomingRates){
        list<rate__c> oklist = new list<rate__C>();

        for (rate__c r:incomingRates){
            if(r.Record_Type_Name__c!='Residential TOU'){
                oklist.add(r);
            } 
        }

        return oklist;
    }
    
    //<rateid, <month_number, cost>>
    public static map<id, decimal> MakeMonthEstimateMap(list<month_estimate__c> MEs){
        map<id, decimal> output = new  map<id, decimal>();

        for (month_estimate__c me: Mes){
            if (output.get(me.Rate__c)==null){
                output.put(me.Rate__c, me.Total__c); //if it doesn't exist
            } else { //there was already a value, so we'll just add to it
                output.put(me.Rate__c, output.get(me.Rate__c) + me.Total__c);
            }
        }

        return output;

    }
   
   public static list<month_estimate__c> makeTempMonthEstimates(AccountPremiseAssociation__c theAPA, list<Rate__c> ratelist){
      //are we doing resi or commercial?  This will control a few flow elements.
        string ratetype = 'Resi'; 
        try {
            if (ratelist[0].plan__r.rate_class_del__c == 'Commercial') ratetype = 'Comm';
        }catch (exception e){} //switch to comm if appropriate
        
        list<month_estimate__c> tempmonthEstimateList= new list<month_estimate__c>();
        
        decimal PUCA = TrueCostUtilities.getPUCA();
        decimal MGRT =TrueCostUtilities.getMGRT();
        decimal LocalSalesTaxRate;
        decimal commFixedMonthly =0;
        decimal commVarRate = 0;
        list<decimal> commMonthlyVar = new list<decimal>();
        list<monthly_usage__c> usage = new list<monthly_usage__c>();

        map<id, map<string, map<string, map<string, decimal>>>> TOURateMaps = new map<id, map<string, map<string, map<string, decimal>>>>();    
        map<string, map<string, map<string, decimal>>> APAUsageProfile = new map<string, map<string, map<string, decimal>>>();      
        map<id, map<integer, decimal>> TOUCostMaps = new map<id, map<integer, decimal>>();  //place to store cost maps, if they exist
        
        try{
            LocalSalesTaxRate=TrueCostUtilities.getLocalSalesTax(theAPA.premise__r.Electric_Service_Address_Zip__c);
        } catch(exception e) {LocalSalesTaxRate=TrueCostUtilities.getLocalSalesTax('77002');} //default zip code for tax estimate
        
        for (Rate__c rate:ratelist){ //do a quick pass to see if any are TOU.  If not, this saves a lot of time!
            system.debug('Looking through rates.  Rate ' +rate.id+ ' record type is ' +rate.Record_Type_Name__c);
            if(rate.Record_Type_Name__c == 'Residential TOU') {
                TOURateMaps = TimeOfUseEngine.GrabAnnualRateProfile(rateList);
                APAUsageProfile = TimeOfUseEngine.GrabAnnualLoadProfile(theAPA.id);
                system.debug('TOU found');
                break; //if there's at least one, there's no point finishing that loop! 
            }
        }
        
        if (theAPA!=null){
            usage = TrueCostUtilities.pullTheMonthlyUsage(theAPA); //for that APA
        } else {
            system.debug('ratelist[0].TDSP__c: '+ratelist[0].TDSP__c);
            system.debug('ratelist: '+ratelist);
            usage = TrueCostUtilities.pullGuestMonthlyUsage(ratelist[0].TDSP__c); //for the tdsp that these rates are for
        }
        
        list<Maintained_Fees__c> allfeelist = new List<Maintained_fees__c>();
        
        if( rateType== 'Resi'){//this is for residential rates associated with a rate plan. Otherwise, it'll be blank.  Logic to skip unnecessary soql            
                allfeelist = [select id, Basis__c, Fee__r.id, Rate__r.id, Value__c from Maintained_Fees__c 
                 where rate__c in: ratelist and Additional_Charge__c=true];
        } else{
            list<Fee__c> commfees = new List<Fee__c>([select id, Basis__c, Value__c from Fee__c //get the commerical tariffs for that TDSP
                 where tdsp__r.id =: ratelist[0].TDSP__c and rate_class__c = 'Secondary Service <= 10 kVa']);
            for(Fee__c mf:commfees){
                if (mf.basis__c=='Volumetric'){
                        commVarRate += mf.value__c; //system.debug('===========found volumetric fee ' + mf.value__c); system.debug('===========new volumetric fee total' + volumetric_total);
                }
                if (mf.basis__c=='Monthly'){
                        commFixedMonthly += mf.value__c; //system.debug('===========found monthly fee ' + mf.value__c); system.debug('===========new monthly fee total' + monthly_fixed_total);      
                }
            }
            //build the monthly tariff stuff once for all rates
            for (monthly_usage__C mu:usage){
                commMonthlyVar.add(mu.usage__c*commVarRate);
            }
        }
        
        for (Rate__c rate:ratelist){ //populate ALL the plan estimates
            if(rate.Record_Type_Name__c == 'Residential TOU') {//if the rate is TOU, get the cost map for this rate so we'll have it ready later            
                TOUCostMaps.put(rate.id, TimeOfUseEngine.GetCostsFromUsageAndRateProfiles(APAUsageProfile, TOURateMaps.get(rate.id)));
            }       
                        
            system.debug('++++++++++++++++++++++++starting rate+++++++++++++++++++           ' + rate.id);
            //decimal plantotalcost=0;
            decimal volumetric_total = 0;
            decimal monthly_fixed_total = 0;
            if(rateType=='Resi'){
                list<Maintained_Fees__c> planfees = new List<Maintained_fees__c>();
                for(Maintained_Fees__c mf:allfeelist){
                    if (mf.rate__r.id==rate.id){
                            planfees.add(mf); //find all the fees for the rate/plan that we're currently iterating on
                    }
                }
                system.debug('====Planfees====' + planfees);
                
                for(Maintained_Fees__c mf:planfees){
                    if (mf.basis__c=='Volumetric'){
                            volumetric_total += mf.value__c; //system.debug('===========found volumetric fee ' + mf.value__c); system.debug('===========new volumetric fee total' + volumetric_total);
                    }
                    if (mf.basis__c=='Monthly'){
                            monthly_fixed_total += mf.value__c; //system.debug('===========found monthly fee ' + mf.value__c); system.debug('===========new monthly fee total' + monthly_fixed_total);      
                    }
                }
            }
            
            for (integer i=1; i<13; i++){ //create each month estimate
                
                Month_Estimate__c y=new Month_Estimate__c();
                y.rate__c=rate.id;
                y.month_number__c=i;
                    
                if(rate.Energy_Base_Rate_cents__c!=null){                   
                    if(rate.Record_Type_Name__c == 'Residential TOU') {                     
                        //use the total energy charge for that month
                        y.Energy_Charge__c = TOUCostMaps.get(rate.id).get(i);
                        system.debug('Using TOUCostMap for month '+ i + '.   Value is '+TOUCostMaps.get(rate.id).get(i) +' instead of ' + rate.Energy_Base_Rate_cents__c*usage[i-1].usage__c/100);
                    } else {
                        y.Energy_Charge__c=rate.Energy_Base_Rate_cents__c*usage[i-1].usage__c/100; //calculates cost of the energy charge
                    }
                } else y.Energy_Charge__c=0;    
                system.debug('=============energy charge=============   ' + y.Energy_Charge__c);                          
                if(rate.Monthly_Base_Charge__c !=null){
                    y.Customer_Charge__c=rate.Monthly_Base_Charge__c;                  
                    }else y.Customer_Charge__c=0;
                    system.debug('=============monthly base=============   ' + y.Customer_Charge__c);  
                y.Minimum_Usage_Charge__c=0; 
                if(rate.Minimum_Usage_Charge_Threshold_kWh__c !=null){
                    if(usage[i-1].usage__c < rate.Minimum_Usage_Charge_Threshold_kWh__c){
                        y.Minimum_Usage_Charge__c=rate.Minimum_Usage_Charge__c;    
                    }
                    else if (rate.Minimum_Usage_Charge_Threshold2__c !=null){
                        if(usage[i-1].usage__c < rate.Minimum_Usage_Charge_Threshold2__c){
                            y.Minimum_Usage_Charge__c=rate.Minimum_Usage_Charge2__c;    
                        } else if (rate.Minimum_Usage_Charge_Threshold3__c !=null){
                            if(usage[i-1].usage__c < rate.Minimum_Usage_Charge_Threshold3__c){
                                y.Minimum_Usage_Charge__c=rate.Minimum_Usage_Charge3__c;    
                            }
                        } 
                    }
                    
                }else if (rate.Usage_Discount_Minimum__c != null){ 
                    if (rate.Usage_Discount_Minimum__c < usage[i-1].usage__c) {
                        y.Minimum_Usage_Charge__c=0-rate.Usage_Discount_Amount__c; 
                    }
                }
                 system.debug('=============minimum usage=============   ' + y.Minimum_Usage_Charge__c); 
                
                if (rateType=='Comm') {y.TDSP_per_Month__c = commFixedMonthly;} else { y.TDSP_per_Month__c=monthly_fixed_total;}
                system.debug('=============volmetric total is =============   ' + volumetric_total);
                system.debug('=============usage is =============   ' + usage[i-1].usage__c);
                if (RateType=='Comm'){
                    y.TDSP_per_kWh__c = commMonthlyVar[i-1]; //get the one we precalculated before starting the rate loop
                } else {
                    if( (volumetric_total!=null) && (usage[i-1].usage__c!=null) ){
                            y.TDSP_per_kWh__c= volumetric_total*usage[i-1].usage__c; system.debug('=============if is false=============   ');
                    } else{
                        y.TDSP_per_kWh__c= 0; system.debug('=============if is true=============   ');
                    }       
                    system.debug('=============if is complete=============   ');
                }
                y.total__c=y.Energy_Charge__c+y.Customer_Charge__c+y.Minimum_Usage_Charge__c+y.TDSP_per_kWh__c+y.TDSP_per_Month__c;   system.debug('=============pretax is complete=============   ');             

                if(rate.plan__r.Miscellaneous_Gross_Receipts_Tax__c) y.PUCA__c=y.total__c*PUCA; else y.PUCA__c=0;

                if(rate.plan__r.PUC_Gross_Receipts_Assessment__c   ) y.MGRT__c=y.total__c*MGRT; else y.MGRT__c=0;

                y.total__c = y.total__c + y.PUCA__c + y.MGRT__c; system.debug('everything done but sales taxes ');  
                y.Local_Sales_Tax__c = y.total__c * LocalSalesTaxRate;
                y.total__c = y.total__c + y.Local_Sales_Tax__c; system.debug('sales tax calculated for month');  
                //plantotalcost=plantotalcost+y.total__c; system.debug('total is complete');
                system.debug('=============all math is done=============   ');
                tempmonthEstimateList.add(y);
                //y.clear();
            }
            }
                return tempmonthEstimateList;    
   }
   

   //called from plandetails
   public static list<resultscontainer> scoreMyEstimatesSimpler(list<Month_Estimate__c> estimates, list<Rate__c> planlist, list<Monthly_Usage__c> usage){
        list<resultscontainer> scoringresults = new list<resultscontainer> ();
        
        map<id, string> rewardmap = TrueCostUtilities.GrabRewardsText2(planlist);      
        decimal totalusage = TrueCostCalc.totaltheusage(usage);

        for (rate__c pi:planlist){
            resultscontainer rc=new resultscontainer(pi); //TrueCostUtilities.resultscontainer rc=new TrueCostUtilities.resultscontainer(pi);           
            rc.rewardstext=rewardmap.get(pi.id);
            
            for (month_estimate__c me:estimates){ //scroll through the monthestimtes
                if(me.rate__c==pi.id){ //find the one that matches that rate
                    rc.price=rc.price+me.total__c; //add that month's price to the total                   
                }
            }
            rc.pricekWh=rc.price/totalusage;      //calculate cents per kWh    
            scoringresults.add(rc);            
        }
        
        return scoringresults;                            
    }


    public static decimal totaltheusage (list<monthly_usage__c> mul){
            decimal usagetotal=0;
            if (mul != null){
                
                for (monthly_usage__c mu:mul){
                    usagetotal=usagetotal+mu.Usage__c; 
                }
            }
            return usagetotal;
        }   
    
   public static string getHowCalculated(AccountPremiseAssociation__c theAPA){
            try{
                //using data            
                if (theAPA.Meter_Data_Request_Status__c == 'Complete' && theAPA.Meter_Data_Permission__c) return 'Real Data';                       
                //estimated usage
                if (theAPA.Meter_Data_Request_Status__c != 'Complete' && theAPA.Meter_Data_Estimated__c  == true) return 'Estimated Data';          
                //size profile
                if ( (theAPA.Meter_Data_Request_Status__c != 'Complete' || !theAPA.Meter_Data_Permission__c) && theAPA.Customer_Selected_Profile__c == 'Small') return 'Small';
                if ( (theAPA.Meter_Data_Request_Status__c != 'Complete' || !theAPA.Meter_Data_Permission__c)&& theAPA.Customer_Selected_Profile__c == 'Medium') return 'Medium';
                if ( (theAPA.Meter_Data_Request_Status__c != 'Complete' || !theAPA.Meter_Data_Permission__c)&& theAPA.Customer_Selected_Profile__c == 'Large') return 'Large';
                //average for area
                return 'Default Load';
            } catch(exception e){return 'No Premise';}
        }
   
    public static string getMeterDataStatus(AccountPremiseAssociation__c theAPA){
            try{
                if (theAPA.Meter_Data_Permission__c){
                    //complete
                    if (theAPA.Meter_Data_Request_Status__c == 'Complete') return 'Complete';                               
                    //loading
                    if (theAPA.Meter_Data_Request_Status__c == 'In Progress') return 'Pending';
                    //error
                    if (theAPA.Meter_Data_Request_Status__c.contains('Error')) return 'Error';
                }   else {
                    return 'Not requested';
                }   
            } catch (exception e){
            return 'No Premise';
        } return 'No Premise';
    }
    
    public static string getMeterDataError(AccountPremiseAssociation__c theAPA){
        try{
            AccountPremiseAssociation__c localAPA = [select id, RequestId__c from AccountPremiseAssociation__c where id=:theAPA.id];
            UHITRequest__c theRequest = [select id, StatusCode__c from UHITRequest__c where RequestId__c =: localAPA.RequestId__c];
            if (theRequest.StatusCode__c=='21'){return 'Meter Number Validation';}
            if (theRequest.StatusCode__c=='7'){return 'No REP';}
            if (theRequest.StatusCode__c=='9'){return 'Incorrect Service Address';}
            return 'Other';
        } catch(exception e) {return 'Other';}     
    }
    
    public static string isMyDataReadyYet(AccountPremiseAssociation__c theAPA){ //refreshes APA before calling...used for shopplans poller. 
        AccountPremiseAssociation__c tempAPA = [select id, Meter_Data_Request_Status__c, Meter_Data_Permission__c from AccountPremiseAssociation__c where id=:theAPA.id];
        return getMeterDataStatus(tempAPA);
    }
    
    public static decimal MakeCustomerSatRanking(decimal stars, decimal PUC){
        Calculation_Inputs__c CI = Calculation_Inputs__c.getOrgDefaults();        
        if (CI.PUC_Complaint_Scorecard_weighting__c==null) {return stars;}
        if (PUC==null ) {PUC=3;}
        if (stars==null) {stars=4;} //give them a moderate score
        else{
            decimal PUCtranslated;
            if (PUC == 5) PUCtranslated=20;
                else if (PUC == 4) PUCtranslated=40;
                else if (PUC== 3) PUCtranslated=60;
                else if (PUC == 2) PUCtranslated=80;
                else if (PUC == 1) PUCtranslated=100;   
            return (CI.PUC_Complaint_Scorecard_weighting__c/100)*PUCtranslated + (1-(CI.PUC_Complaint_Scorecard_weighting__c/100))*stars;
            }
        return stars; //shouldn't happen, but it might
    }
   
    public static void UpdateREPSatRanking(){
        list<REP_Profile__c> allREPs= [select id, name, star_ranking__c,
                                        (select Rating__c, REP_Profile__c from REP_Ratings__r where published__c=true) 
                                        from REP_Profile__c where active__c=true]; 
        list<REP_Rating__c> allRatings = new list<REP_Rating__c>(); 
        for (REP_Profile__c r:allREPs){
            allRatings.addAll(r.REP_Ratings__r);
        }
        decimal totalRatingsValue=0;
        for (REP_Rating__c r:allRatings){
            totalRatingsValue+=r.rating__c;
        }
        decimal averageRatingsCount=allRatings.size()/math.max(1, allREPs.size());
        decimal averageRatingsValue=Calculation_Inputs__c.getInstance().REP_Rating_Reference__c;
        if (averageRatingsValue==null){averageRatingsValue =4;}
        
        map<REP_Profile__c, decimal> REPTotalPointsMap = new map<REP_Profile__c, decimal>();
        decimal pointCounter;
        //for each REP, add up the difference between the scores and the average rating score
        for (REP_Profile__c p:allREPs){
            pointCounter=0;
            for(REP_Rating__c r:p.REP_Ratings__r){
                system.debug(p.name + 'has a score of ' + r.rating__c + ' full review of ' + r);
                pointCounter=pointCounter+(r.rating__c-averageRatingsValue);
                system.debug(p.name + 'has ' + pointCounter);
            }
            REPTotalPointsMap.put(p, pointCounter);
            system.debug(REPTotalPointsMap);
        }
        system.debug(REPTotalPointsMap);
        //now, let's scale the points by getting the min/max and normalizing to 100
        list<decimal> scores = REPTotalPointsMap.values();
        scores.sort();               
        if (!scores.isEmpty()){
            decimal minPoints = scores[0];
            decimal maxPoints = scores[scores.size()-1];
            
            for (REP_Profile__c p:allREPs){
                p.star_ranking__c = (REPTotalPointsMap.get(p)-minPoints)/(maxPoints-minPoints)*100;
            }        
            update allREPs;
        }
    }

    public static list<rate__c> SharedRateQuery(id tdsp, string rateType, decimal totalUsage, string repofrecordid){
        if (RateType==null) RateType = 'Residential';
        return [select id,
                Record_Type_Name__c,
                plan__r.name,
                plan__r.id,
                plan__r.renewable_content__c,
                plan__r.contract_length__c,
                plan__r.REP_profile__r.logo_url__c,
                cancellation_fee__c,
                plan__r.Online_Payment_Bill_Stements__c,
                plan__r.green_ranking__c,
                plan__r.Link_Off__c,
                plan__r.REP_profile__r.star_ranking__c,
                plan__r.REP_profile__r.star_rating_avg__c,
                plan__r.REP_profile__r.PUC_scorecard_ranking__c,
                plan__r.REP_profile__r.total_reviews__c,plan__r.rate_class_del__c,
                tdsp__r.id,
                plan__r.REP_profile__r.years_in_business_score__c,
                plan__r.rep_profile__r.id,
                plan__r.REP_profile__r.name,
                plan__r.REP_profile__r.Renewal_Program_Participant__c,
                plan__r.REP_profile__r.Residential_Commission_Rate__c,
                plan__r.REP_profile__r.Commercial_Commission_Rate__c,plan__r.REP_profile__r.Residential_Renewal_Commission_Rate__c,
                Renewal_Offer__c,
                Minimum_Usage_Charge__c,
                Minimum_Usage_Charge_Threshold_kWh__c,
                Minimum_Usage_Charge_Threshold2__c,
                Minimum_Usage_Charge3__c,
                Minimum_Usage_Charge_Threshold3__c,
                Usage_Discount_Amount__c,
                Usage_Discount_Minimum__c,
                Energy_Base_Rate_cents__c,
                Monthly_Base_Charge__c,plan__r.Miscellaneous_Gross_Receipts_Tax__c,plan__r.PUC_Gross_Receipts_Assessment__c,
                plan__r.rep_profile__r.Earliest_Date_of_Service__c,
                Load_Factor__c,
                X1000_kWh_rate__c,
                X2000_kWh_rate_cents__c,
                X500_kWh_rate_cents__c,
                non_demand_1500_kWh_rate_cents__c,
                non_demand_2500_kWh_rate_cents__c,
                non_demand_3500_kWh_rate_cents__c,
                Advertised_Rate__c,
                
                Standard_Move_In_for_New_Meters__c,
                plan__r.plan_id__c,
                plan__r.REP_Profile__r.REP_Account__c,
                plan__r.REP_profile__r.Fax_Number__c,
                plan__r.REP_Profile__r.ownerid,
                plan__r.REP_profile__r.Customer_Service_Email__c,
                plan__r.REP_profile__r.Home_Page__c,
                plan__r.REP_profile__r.Mailing_City__c,
                plan__r.REP_profile__r.Mailing_State__c,
                plan__r.REP_profile__r.Mailing_Street_Address__c,
                plan__r.REP_profile__r.Mailing_Zip__c,
                plan__r.REP_profile__r.PUCT_License_Number__c,
                plan__r.REP_profile__r.Legal_Name__c,
                plan__r.REP_profile__r.Allow_credit_card_for_autopay__c,
                plan__r.REP_profile__r.Accept_American_Express__c,
                plan__r.REP_profile__r.Accept_Discover__c,
                plan__r.REP_profile__r.Accept_MasterCard__c,
                plan__r.REP_profile__r.Accept_Visa__c,
                plan__r.REP_profile__r.Customer_Service_Phone_Number__c,
                plan__r.REP_profile__r.Soonest_Switch_Date__c,
                plan__r.REP_profile__r.Soonest_Move_Date__c,
                plan__r.REP_profile__r.Maximum_Switch_Days__c,
                plan__r.Card_Required_For_Payment__c,
                
                plan__r.REP_profile__r.About_Us__c,
                plan__r.Plan_Description__c,
                
                Same_Day_Move_In_Fee__c,
                Changed_Start_Date_Fee__c,
                Self_Selected_Switch_Fee__c,
                Disconnect_Fee__c,
                Reconnect_Fee__c,
                Third_Party_Payment_Fee__c,
                Reminder_Fee__c,
                Insufficient_Funds_Cancelled_Checks__c,
                Excessive_Payments_Fee__c,
                Paper_Bill_Request_Fee__c,
                Manual_Assistance_Fee__c,
                Move_in_Fee__c,
                Late_Payment_Fee__c,
                Minimum_Usage_Charge2__c,
                Cancellation_Fee_Description__c,
                Cancellation_Fee_Type__c
                    
                    from rate__c
                    where (active__c = true AND plan__r.active__c = true AND suspended__c = false AND plan__r.suspended__c = false and plan__r.rep_profile__r.active__c =: true
                            AND plan__r.plan_start_date__c <= today AND plan__r.plan_end_date__c >today 
                            and tdsp__r.id =: tdsp  //and the tdsp matches
                            and ((Renewal_Offer__c = true and plan__r.REP_profile__r.Renewal_Program_Participant__c  = true and plan__r.REP_profile__c =: repofrecordid)  
                                                or
                                                    (Renewal_Offer__c = false and plan__r.REP_profile__r.Renewal_Program_Participant__c = false) //APAs without REP_of_Record__c see normal plans
                                                or
                                                (Renewal_Offer__c = false and plan__r.REP_profile__r.Renewal_Program_Participant__c = true and plan__r.REP_profile__c !=: repofrecordid))
                            and plan__r.rate_class_del__c =: rateType  //and the rate class matches
                            and ( //usage data is ok for that plan
                                (minimum_annual_usage__c <: totalUsage and maximum_annual_usage__c>=:totalUsage) //specified min/max, it fits
                                or 
                                (minimum_annual_usage__c = null and maximum_annual_usage__c = null) // or min/max are null
                                
                            )                          
                            ) order by X1000_kWh_rate__c ASC
                    ];
    }
}