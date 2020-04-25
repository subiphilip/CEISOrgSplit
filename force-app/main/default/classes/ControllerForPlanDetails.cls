/*
7/18/2012   Shane McLaughlin   Moved getMeterDataStatus() and getHowCalculated() logic to TrueCostCalc
*/
public with sharing class ControllerForPlanDetails {
    // edited by bodie
    public String planIdDetails;
    
    public rate__c detailrate {get;set;}
    //public id selectedPlan {get;set;}
    public id enrollplan {get;set;}
    //public string lightboxmessage {get;set;}
    
    public boolean badID {get;set;} //turns true if the id in the url parameter is not found.
    
    //public boolean lightboxflag { get; set; } //for the lightbox control
    //some stuff based on the user    
   
    private AccountPremiseAssociation__c theAPA {get;set;}                    
    /* Stuff for the sliders and filters*/
    public list<decimal> costlist{get;set;}//for the usage chart in the plan details page
    public list<month_estimate__c> DetailEstimates{get;set;}//for the sample bill table on details page 
    public string selectedmonth{get;set;}//for the sample bill month selector 
    //public list<Rate__c> planlist {get;set;}              
              
    public string streetaddress {Get;set;}
    //public string meterdatastatus {get;set;}{meterdatastatus=premise.Meter_Data_Status__c;}

    private list<month_estimate__c> monthEstimateList= new list<month_estimate__c>{};
    private list<plan_estimate__c> planestimatelist = new list<plan_estimate__c>{};
    
        
    /*private list<TrueCostUtilities.ResultsContainer> scoringresults = new list<TrueCostUtilities.ResultsContainer>{};
    public list<TrueCostUtilities.ResultsContainer> top4= new list<TrueCostUtilities.ResultsContainer>{};
    */
    private list<ResultsContainer> scoringresults = new list<ResultsContainer>{};
    public list<ResultsContainer> top4= new list<ResultsContainer>{};
    public id blacklistplan {get; set;}  //this is the plan the user wants to remove
    private set<id> blacklist = new set<id>{}; //set of plans a customer doesn't want to show up in the top 4
    
    public ResultsContainer GetTileStuff(){    
    //public TrueCostUtilities.ResultsContainer GetTileStuff(){
        return scoringresults[0];
    }
    

    public void setPlanIdDetails (String s) {
        planIdDetails = s;
    }
    
    public String getPlanIdDetails() {
      return planIdDetails;
    } 
    
    public ControllerForPlanDetails() {
        selectedmonth = string.valueof(date.today().addDays(15).month()); //either this month, or if we're close to the end of the month, next month
        try{
            theAPA=APAUtilities.GetActiveAPA(TrueCostUtilities.getTheAccount(UserInfo.getUserId()));                
        } catch(exception e){
            theAPA=new AccountPremiseAssociation__c();//if there's no APA, usage and stuff will be based off the default for that rate's TDSP.
        }
        streetaddress=theAPA.premise__r.Electric_Service_Address__c;
        try{
            // edited by Bodie
            planIdDetails = ApexPages.currentPage().getParameters().get('Id');
            
            monthestimateList = TrueCostCalc.makeTempMonthEstimates(theAPA, getactivePlans( planIdDetails ) );
            list<Monthly_Usage__c> usage=TrueCostUtilities.pullTheMonthlyUsage(theAPA); //grabs the usage also needed for the calc method
            scoringresults=TrueCostCalc.scoreMyEstimatesSimpler(monthEstimateList, getactivePlans( planIdDetails ), usage);

            system.debug(scoringresults[0]);
        } catch (exception e) {BadID=true;}
    }
    
    public rate__c<ResultsContainer> getDetailPlanById(string planId){
        
        detailRate=[
            select id,
            X1000_kWh_rate__c,
            plan__r.name,
            recordtypeid,
            plan__r.rate_class_del__c,
            tdsp__r.name,
            RUC_Nodal_Fees__c,
            Basis_Charge_Included__c,
            Bandwidth_Swing_Allowed__c,
            plan__r.plan_description__c,
            plan__r.contract_length__c,
            plan__r.REP_profile__r.logo_url__c,
            plan__r.REP_Profile__r.About_Us__c,
            load_factor__c,
            TOS_Url__c,
            YRAC_Url__c,
            EFL_Url__c,
            plan__r.REP_profile__r.star_rating_avg__c,
            plan__r.REP_profile__r.total_reviews__c,
            Record_Type_Name__c,
            plan__r.REP_Profile__r.id,
            plan__r.REP_Profile__r.name,
            Link_for_EFL__c,
            Link_for_TOS__c,
            Link_for_YRAC__c,
            plan__r.REP_profile__r.PUC_Scorecard_Ranking__c
            from rate__c
            where id =: planIdDetails
        ];                
        
        return detailRate;
    }
    
    public rate__c getDetailPlan() { //feeds the plan details page
                
                detailRate=[select id, X1000_kWh_rate__c, plan__r.name, recordtypeid, plan__r.rate_class_del__c, tdsp__r.name,
                            RUC_Nodal_Fees__c, Basis_Charge_Included__c, Bandwidth_Swing_Allowed__c,
                            plan__r.plan_description__c, plan__r.contract_length__c, plan__r.REP_profile__r.logo_url__c, plan__r.REP_Profile__r.About_Us__c, load_factor__c,
                            TOS_Url__c, YRAC_Url__c, EFL_Url__c, plan__r.REP_profile__r.star_rating_avg__c, plan__r.REP_profile__r.total_reviews__c,
                            Record_Type_Name__c, plan__r.REP_Profile__r.id, plan__r.REP_Profile__r.name, Link_for_EFL__c, Link_for_TOS__c, Link_for_YRAC__c, plan__r.REP_profile__r.PUC_Scorecard_Ranking__c
                    from rate__c
                    where id =: planIdDetails];                
        return detailRate;
    }
        
   
   public static list<rate__C> getactivePlans(id therate){//generates the plan list (really a list of rates)
        list<rate__C> tempplanlist=new list<rate__C>();
        tempplanlist=[select id, X1000_kWh_rate__c , plan__r.name, plan__r.id, plan__r.renewable_content__c, plan__r.contract_length__c, plan__r.REP_profile__r.logo_url__c, cancellation_fee__c, Record_Type_Name__c, load_factor__c,
                        plan__r.green_ranking__c, plan__r.REP_profile__r.star_ranking__c, plan__r.REP_profile__r.star_rating_avg__c, plan__r.REP_profile__r.total_reviews__c, plan__r.REP_profile__r.PUC_Scorecard_Ranking__c,
                        plan__r.REP_profile__r.years_in_business_score__c, plan__r.rep_profile__r.id, plan__r.REP_profile__r.name, 
                        Minimum_Usage_Charge__c, Minimum_Usage_Charge_Threshold_kWh__c,
                        Minimum_Usage_Charge2__c, Minimum_Usage_Charge_Threshold2__c,
                        Minimum_Usage_Charge3__c, Minimum_Usage_Charge_Threshold3__c,
                        Usage_Discount_Amount__c, Usage_Discount_Minimum__c,
                        Energy_Base_Rate_cents__c, Monthly_Base_Charge__c,plan__r.Miscellaneous_Gross_Receipts_Tax__c,plan__r.PUC_Gross_Receipts_Assessment__c,plan__r.rate_class_del__c, tdsp__r.id
                    from rate__c
                    where id=:therate];
         return tempplanlist;
   }
   
   public pageReference grantMeterDataPermission(){
                
                pageReference pageref = page.Calculation_Choice;
            pageref.getParameters().put('mode', 'MeterData');
            return pageref;
        }
    
    public pageReference requestUsageEstimate(){ 
            pageReference pageref = page.Calculation_Choice;
            pageref.getParameters().put('mode', 'Estimate');
            return pageref;
    }
        
    public PageReference pickAProfile(){
            pageReference pageref = page.Calculation_Choice;
            pageref.getParameters().put('mode', 'Profile');
            return pageref;        
    }    
        
        public decimal[] getdetailscostlist(){
                decimal[] thelist = new decimal[12];
                for (month_estimate__C me:MonthEstimateList){
                    thelist.add(me.total__C);
                }
                return thelist;
        }

        public List<SelectOption> getMonthNames() {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('1','January'));
            options.add(new SelectOption('2','February'));
            options.add(new SelectOption('3','March'));
            options.add(new SelectOption('4','April'));
            options.add(new SelectOption('5','May'));
            options.add(new SelectOption('6','June'));
            options.add(new SelectOption('7','July'));
            options.add(new SelectOption('8','August'));
            options.add(new SelectOption('9','September'));
            options.add(new SelectOption('10','October'));
            options.add(new SelectOption('11','November'));
            options.add(new SelectOption('12','December'));
            return options;
        }
        
        public month_estimate__C getEstimateForSelectedMonth(){         
                integer x;
                string y=selectedMonth;
                x = integer.valueof(y);
                return monthEstimateList[x-1];
        }
        
        public void changetheSelectedMonth(){
        }
        
        public boolean hasOrderInProgress(){
            return TrueCostutilities.orderinprogress(TrueCostUtilities.getTheAccount(UserInfo.getUserId()), theAPA.premise__r.id).name!=null;
        }
        
        public string getMeterDataStatus(){
            try{return TrueCostCalc.getMeterDataStatus(theAPA);}catch(exception e){return 'No Premise';}
        }        
        
        public string getHowCalculated(){
            try{return TrueCostCalc.getHowCalculated(theAPA);}catch(exception e){return 'No Premise';}
        }
        
        public decimal totaltheusage (list<monthly_usage__c> mul){
            decimal usagetotal=0;
            for (monthly_usage__c mu:mul){
                usagetotal=usagetotal+mu.Usage__c;
            }
            return usagetotal;
        }
        
}