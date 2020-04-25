/*
1/26/2012   Shane McLaughlin    Added scale factor >0.5 as exit condition to avoid SQL query limit.
2/16/2012   Shane Mclaughlin    Removed the year of construction from the comp criteria.

*/
public class  TrueCostEstimator {

    //the good version
    public static void MakeEstimateThenSave(AccountPremiseAssociation__c APA){        
        system.debug('==============================================APA id is' + APA.id);
        list<monthly_usage__c> mulist = [select id from monthly_usage__c where APA__c =: APA.id];
        if ( ! mulist.isempty() ) {
            try{
                delete mulist;
            } catch (dmlexception e){}
        }
        mulist = makeUsageEstimateList(APA);
        insert mulist;
    }
    
    public static list<monthly_usage__c> makeUsageEstimateList(AccountPremiseAssociation__c APA){        
        system.debug('==============================================APA id is' + APA.id);
        AccountPremiseAssociation__c APA2 = [select id, premise__c, premise__r.id,  premise__r.Pool__c, premise__r.Square_Feet__c, premise__r.Year_Built__c, premise__r.Heating_System__c, premise__r.Occupants__c
                            from AccountPremiseAssociation__c where id =: APA.id];
        system.debug('==============================================APA2 id is' + APA2.id);
        list<Monthly_Usage__c> mulist = new list<Monthly_Usage__c>();
        mulist=averageComps(APA2);
        for (monthly_usage__C mu:mulist){
            mu.estimated__c = true;
            system.debug('===========starting iteration=========            ');            
            system.debug('===========month number=========            ' );            
            system.debug('===========mulist is=========            ' + mulist);            
        }
        system.debug('===========mulist complete=========            ' + mulist);
        system.debug('===========mulist size is=========            ' + mulist.size());
        return mulist;
    }
    
    public static list<monthly_usage__C> averageComps(AccountPremiseAssociation__c APA){
        decimal scalefactor = 0.1; //starting entry for sample size...Increase if not getting enough data for estimate
        decimal squarefoothigh = (1+scalefactor)*APA.premise__r.Square_Feet__c;
        decimal squarefootlow = (1-scalefactor)*APA.premise__r.Square_Feet__c;
        integer yearfactor = 5;
        decimal startyear = integer.valueof(APA.premise__r.Year_Built__c)-yearfactor;
        decimal endyear = integer.valueof(APA.premise__r.Year_Built__c)+yearfactor;
        list<monthly_usage__c> mucomplist = new list<monthly_usage__c>(); //list used to create estimate
        do {
            mucomplist = [select id, month_number__c, usage__c from monthly_usage__c 
                          where premise__r.square_feet__c>: squarefootlow
                             and premise__r.square_feet__c <: squarefoothigh 
                             and premise__r.Year_of_Construction__c >=: startyear
                             and premise__r.Year_of_Construction__c <=: endyear                            
                            limit 600];                       
            scalefactor = scalefactor+0.1;
            yearfactor++;
        } while (mucomplist.size()<360&&scalefactor<0.5);
                    
        system.debug('================================mu comp list size is ' + mucomplist.size());      
        
        list<monthly_usage__c> muestimate = new list<monthly_usage__c>();  //list that is the returned estimate
        
        if (!mucomplist.isempty() ){
            for (integer k =1; k<13; k++){
            
                AggregateResult x = [select avg(usage__c) Avg from monthly_usage__c where id in: mucomplist and month_number__c =: k];
            
                monthly_usage__c muitem = new monthly_usage__C();
                muitem.month_number__c=k;
                muitem.Usage__c = (decimal)x.get('Avg');
                if (muitem.Usage__C == null) {muitem.Usage__c = 0;}
                muitem.usage__c = math.round(muitem.usage__c);
                muitem.Premise__c=APA.premise__r.id;
                muitem.APA__c = APA.id;
                muestimate.add(muitem);
            }
        } else { //it's empty
            system.debug('we did not get any comps.  Switching to guest usage');
            muestimate = TrueCostUtilities.pullGuestMonthlyUsage();
            for (monthly_usage__c muitem:muestimate){
                muitem.Premise__c=APA.premise__r.id;
                muitem.APA__c = APA.id;
            }
        }
        return muestimate;
    }
    //deprecating everything below this point for an APA-based estimator
    public static void MakeEstimateThenSave(premises__c prem){
        
        list<monthly_usage__c> mulist = [select id from monthly_usage__c where premise__c =: prem.id];
        if ( ! mulist.isempty() ) {
            try{
                delete mulist;
            } catch (dmlexception e){}
        }
        mulist = makeUsageEstimateList(prem);
        insert mulist;
    }
    
    
    
    public static list<monthly_usage__c> makeUsageEstimateList(premises__c prem){
        
        list<Monthly_Usage__c> mulist = averageComps(prem);
        
                            
        for (monthly_usage__C mu:mulist){
            mu.estimated__c = true;
        
        
            system.debug('===========starting iteration=========            ');
            
            system.debug('===========month number=========            ' );
            
            system.debug('===========mulist is=========            ' + mulist);
            
        }
        system.debug('===========mulist complete=========            ' + mulist);
        system.debug('===========mulist size is=========            ' + mulist.size());
        return mulist;
    }
    
    
    
    public static list<monthly_usage__C> averageComps(premises__c prem){
        decimal scalefactor = 0.1; //starting entry for sample size...Increase if not getting enough data for estimate
        decimal squarefoothigh = (1+scalefactor)*prem.Square_Feet__c;
        decimal squarefootlow = (1-scalefactor)*prem.Square_Feet__c;
        integer yearfactor = 5;
        //decimal startyear = prem.Year_of_Construction__c-yearfactor;
        //decimal endyear = prem.Year_of_Construction__c+yearfactor;
        list<monthly_usage__c> mucomplist = new list<monthly_usage__c>(); //list used to create estimate
        do {
            mucomplist = [select id, month_number__c, usage__c from monthly_usage__c 
                          where premise__r.square_feet__c>: squarefootlow
                             and premise__r.square_feet__c <: squarefoothigh 
                             //and premise__r.Year_of_Construction__c >: startyear
                             //and premise__r.Year_of_Construction__c <: endyear                            
                            limit 600];                       
            scalefactor = scalefactor+0.1;
            yearfactor++;
        } while (mucomplist.size()<360&&scalefactor<0.5);
                    
        system.debug('================================mu comp list size is ' + mucomplist.size());      
        
        list<monthly_usage__c> muestimate = new list<monthly_usage__c>();  //list that is the returned estimate
        
        if (!mucomplist.isempty() ){
            for (integer k =1; k<13; k++){
            
                AggregateResult x = [select avg(usage__c) Avg from monthly_usage__c where id in: mucomplist and month_number__c =: k];
            
                monthly_usage__c muitem = new monthly_usage__C();
                muitem.month_number__c=k;
                muitem.Usage__c = (decimal)x.get('Avg');
                if (muitem.Usage__C == null) {muitem.Usage__c = 0;}
                muitem.usage__c = math.round(muitem.usage__c);
                muitem.Premise__c=prem.id;
                muestimate.add(muitem);
            }
        }
        
        
        
        
        return muestimate;
    }
}