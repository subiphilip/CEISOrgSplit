public with sharing class ControllerforReadReviews {
        
    public rep_profile__c therep{get;set;}
    public list<TrueCostUtilities.ratingwrapper> thelist{get;set;}
    
    public list<TrueCostUtilities.ratingwrapper> getratings(){        
        thelist=TrueCostUtilities.getRatingWrapperForREP(ApexPages.currentPage().getParameters().get('Id'));
        if (ApexPages.currentPage().getParameters().get('Id')==null) thelist=TrueCostUtilities.getRatingWrapperForREP();
        return thelist;
    }
    
    public list<rep_profile__c> getRepList(){
        return ControllerForElectricCompanies.getreplist();
    }
    
    public integer getRepPlanCount(){
        return [select id from rate__c where
                active__c = true AND plan__r.active__c = true AND suspended__c = false AND plan__r.suspended__c = false and plan__r.rep_profile__r.active__c =: true
                           AND plan__r.plan_start_date__c <= today AND plan__r.plan_end_date__c >today 
                           and plan__r.rate_class_del__c =: 'Residential'  //and the rate class matches                
                and plan__r.rep_profile__r.id =:ApexPages.currentPage().getParameters().get('Id')].size();
    }
        
    public rep_profile__c getrep(){
        therep=[select id, createdby.firstname, name, about_us__c, star_rating_avg__c, total_reviews__c, logo_url__c, 
        Legal_Name__c, PUCT_License_Number__c, Customer_Service_Phone_Number__c, Mailing_Street_Address__c,
        snapshot_id__c, Friendly_URL__c, Mailing_City__c, Mailing_State__c, Mailing_Zip__c
                from rep_profile__c where id =: ApexPages.currentPage().getParameters().get('Id') limit 1];
        return therep;
    }
    
    public list<rate__c> getRates(){
        list<rate__C> theRates = [select id, plan__r.name from rate__c 
                                  where plan__r.rep_profile__r.id =: ApexPages.currentPage().getParameters().get('Id') 
                                  and active__c = true AND plan__r.active__c = true AND suspended__c = false 
                                  AND plan__r.suspended__c = false AND plan__r.plan_start_date__c <= today AND plan__r.plan_end_date__c >today ];
        return theRates;
    }

    //pass it a rep id
    public static rep_rating__c getRandomReview(string repid){

        if (repid==null) {return getRandomReview();}
        
        list<rep_rating__c> repratinglist =[select id, rating__c, REP_Profile__r.name, Review__c, REP_Profile__r.logo_url__c, createddate, 
        author__r.firstname, Plan__r.name, Site_Comments__c ,REP_Profile__c
        from rep_rating__c where rep_profile__r.id =:repid and published__c=true];   
        
        return PickOneAtRandom(repratinglist);
    }

    //has no rep id
    public static rep_rating__c getRandomReview(){
        list<rep_rating__c> repratinglist =[select id, rating__c, REP_Profile__r.name, Review__c, REP_Profile__r.logo_url__c, createddate, 
        author__r.firstname, Plan__r.name, Site_Comments__c,REP_Profile__c
        from rep_rating__c where published__c=true and REP_Profile__r.active__c=true];   

        return PickOneAtRandom(repratinglist);
    }

    public static rep_rating__c PickOneAtRandom(list<rep_rating__c> incoming){
        integer itemcount = incoming.size();
        system.debug(itemcount);  
        integer whichOne;

        do {             
            whichOne = math.min(itemcount-1, math.round((math.random()*itemcount)));
        } while (incoming[whichOne].Review__c==null);       

        return incoming[whichOne];
    }

 }