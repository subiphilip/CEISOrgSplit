@RestResource(urlMapping='/plan-details/*')
global class TC2_Plan_Details {

    static string selectedmonth{get;set;}
    static AccountPremiseAssociation__c theAPA {get;set;}
    static list<ResultsContainer> scoringresults = new list<ResultsContainer>{};
    static list<month_estimate__c> monthEstimateList= new list<month_estimate__c>{};
    
    @HttpGet
    global static rate__c getPlanDetails(){
        
        RestRequest request = RestContext.request;
        String planId = request.params.get('planId');
        
        //selectedmonth = string.valueof(date.today().addDays(15).month());
        theAPA=new AccountPremiseAssociation__c();
        
        TrueCostCalc tcc = new TrueCostCalc();
        list<Monthly_Usage__c> usage = TrueCostUtilities.pullTheMonthlyUsage(theAPA);
        // monthestimateList = tcc.makeTempMonthEstimates(theAPA, getPlanById( planId ) );
        // scoringresults = tcc.scoreMyEstimatesSimpler(monthEstimateList, getPlanById( planId ), usage);
        
        return getPlanById(planId);
    }
    
    global static List<Monthly_Usage__c> getPlanUsages(){
        
        theAPA=new AccountPremiseAssociation__c();
        list<Monthly_Usage__c> usage = TrueCostUtilities.pullTheMonthlyUsage(theAPA);
        return usage;
    }
    
    global static rate__c getPlanById(string planId) {        
        try {
            rate__c detailRate = [select id, plan__r.name, recordtypeid, plan__r.rate_class_del__c, tdsp__r.name,
                            RUC_Nodal_Fees__c, Basis_Charge_Included__c, Bandwidth_Swing_Allowed__c,
                            plan__r.plan_description__c, plan__r.contract_length__c, plan__r.REP_profile__r.logo_url__c, plan__r.REP_Profile__r.About_Us__c, load_factor__c,
                            TOS_Url__c, YRAC_Url__c, EFL_Url__c, plan__r.REP_profile__r.star_rating_avg__c, plan__r.REP_profile__r.total_reviews__c,
                            Record_Type_Name__c, plan__r.REP_Profile__r.id, plan__r.REP_Profile__r.name, Link_for_EFL__c, Link_for_TOS__c, Link_for_YRAC__c, plan__r.REP_profile__r.PUC_Scorecard_Ranking__c
                    from rate__c
                    where id =: planId];                
            return detailRate;
        } catch (Exception e) {
            System.debug(e);
        }
        
        return null;
    }
}