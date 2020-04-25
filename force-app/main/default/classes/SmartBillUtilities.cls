public class SmartBillUtilities{
    
    public static boolean SmartBillTests3(map<integer, decimal> usage, premises__c thepremise){        
        //is the usage real or estimated?
        list<annual_usage__c> AUs = [select id, year__c, estimated__c, Premise_Usage_Sum__c from annual_usage__c where ignore__c != true and premise__r.id=:thepremise.id];
        if (AUs.isempty()) {system.debug('Estimated Usage Only'); return false;}
        boolean ok=false;
        GasChoiceCalcInputs__c GCCI = GasChoiceCalcInputs__c.getinstance();
        for (annual_usage__C AU:AUS){
            if (integer.valueof(au.Year__c)>=integer.valueof(GCCI.Current_Program_Year__c)-1 && au.Premise_Usage_Sum__c/10 < (GCCI.Maximum_Annual_Dth_SmartBill__c) && au.estimated__c == false) ok=true;
        }
        if (!ok) return false;
        //Verify usage via tests 1-7.
        decimal totalusage = 0;
        for (decimal d:usage.values()){
            totalusage=totalusage+d;
        }
    //Test 2--below maximum annual usage
        if (totalusage > GCCI.Maximum_Annual_Dth_SmartBill__c) {system.debug('Test 2 Failed'); return false;}
    //Test 3--maximum "zero usage" months allowed is 4
        decimal zerocounter=0;
        for (decimal d:usage.values()){
            if (d==0) zerocounter++;
        }        
        if (zerocounter>4) {system.debug('Test 3 Failed'); return false;}       
        return true;
    }
    
    public static boolean SmartBillTests2(map<integer, decimal> usage, premises__c thepremise, SmartBill_Index__c SBI){        
        //is the usage real or estimated?
        list<annual_usage__c> AUs = [select id, year__c, estimated__c, Premise_Usage_Sum__c from annual_usage__c where ignore__c != true and premise__r.id=:thepremise.id];
        if (AUs.isempty()) {system.debug('Estimated Usage Only'); return false;}
        boolean ok=false;
        GasChoiceCalcInputs__c GCCI = GasChoiceCalcInputs__c.getinstance();
        for (annual_usage__C AU:AUS){
            if (integer.valueof(au.Year__c)>=integer.valueof(GCCI.Current_Program_Year__c)-1 && au.Premise_Usage_Sum__c < (SBI.Maximum_Annual_Usage__c) && au.estimated__c == false) ok=true;
        }
        if (!ok) return false;
        //Verify usage via tests 1-7.
        decimal totalusage = 0;
        
        for (decimal d:usage.values()){
            totalusage=totalusage+d;
        }
        
    //Test 1--meets minimum annual usage    
       // why have a minimum?	 if (totalusage < SBI.Minimum_Annual_Usage__c/10) {system.debug('Test 1 Failed'); return false;}
    //Test 2--below maximum annual usage
        if (totalusage > GCCI.Maximum_Annual_Dth_SmartBill__c/10) {system.debug('Test 2 Failed'); return false;}
    //Test 3--maximum "zero usage" months allowed is 4
        
        decimal zerocounter=0;
        for (decimal d:usage.values()){
            if (d==0) zerocounter++;
        }        
        if (zerocounter>4) {system.debug('Test 3 Failed'); return false;}       
    /*
//Test 4--Oct to Mar must be greater than sum of the other months
        decimal OctToMar = usage.get(10)+usage.get(11)+usage.get(12)+usage.get(1)+usage.get(2)+usage.get(3);
        decimal AprSept = totalusage - OctToMar;
        if (AprSept > OctToMar) {system.debug('Test 4 Failed'); return false;}
        
    //Test 5--Average of Dec-Feb must be greater than average of Oct to Mar
        decimal DecFeb = usage.get(12)+usage.get(1)+usage.get(2);
        if (DecFeb/3 < OctToMar/6) {system.debug('Test 5 Failed'); return false;}
    //Test 6--Jan to April must be greater than May to August
        decimal MayAug = usage.get(5)+usage.get(6)+usage.get(7)+usage.get(8);
        if (usage.get(1) + usage.get(2) + usage.get(3) + usage.get(4) < MayAug) {system.debug('Test 6 Failed'); return false;}
    //Test 7 --SeptDec must be greater than May-Aug 
        if (MayAug > usage.get(9)+usage.get(10)+usage.get(11)+usage.get(12) ) {system.debug('Test 7 Failed'); return false;}
    //if you made it this far, you must be quotable
        */
        return true;
    }
    
    public static boolean SmartBillTests(annual_usage__c AU, premises__c thepremise, SmartBill_Index__c SBI){        
    //Verify usage via tests 1-7.
    
    //Test 1--meets minimum annual usage    
        if (AU.Premise_Usage_Sum__c < SBI.Minimum_Annual_Usage__c) {system.debug('Test 1 Failed'); return false;}
    //Test 2--below maximum annual usage
        if (AU.Premise_Usage_Sum__c > SBI.Maximum_Annual_Usage__c) {system.debug('Test 2 Failed'); return false;}
    //Test 3--maximum "zero usage" months allowed is 4
        decimal zerocounter=0;
        if (AU.January__c == 0) zerocounter ++;
        if (AU.February__c == 0) zerocounter ++;
        if (AU.March__c == 0) zerocounter ++;
        if (AU.April__c == 0) zerocounter ++;
        if (AU.May__c == 0) zerocounter ++;
        if (AU.June__c == 0) zerocounter ++;
        if (AU.July__c == 0) zerocounter ++;
        if (AU.August__c == 0) zerocounter ++;
        if (AU.September__c == 0) zerocounter ++;
        if (AU.October__c == 0) zerocounter ++;
        if (AU.November__c == 0) zerocounter ++;
        if (AU.December__c == 0) zerocounter ++;
        if (zerocounter>4) {system.debug('Test 3 Failed'); return false;}       
    //Test 4--Oct to Mar must be greater than sum of the other months
        decimal OctToMar = AU.October__c+AU.November__c+AU.December__c+AU.January__c+AU.February__c+AU.March__c;
        decimal AprSept = AU.Premise_Usage_Sum__c - OctToMar;
        if (AprSept > OctToMar) {system.debug('Test 4 Failed'); return false;}
    //Test 5--Average of Dec-Feb must be greater than average of Oct to Mar
        decimal DecFeb = AU.December__c+AU.January__c+AU.February__c;
        if (DecFeb/3 < OctToMar/6) {system.debug('Test 5 Failed'); return false;}
    //Test 6--Jan to April must be greater than May to August
        decimal MayAug = AU.May__c+AU.June__c+AU.July__c+AU.August__c;
        if (AU.January__c +AU.February__c+AU.March__c+AU.April__c < MayAug) {system.debug('Test 6 Failed'); return false;}
    //Test 7 --SeptDec must be greater than May-Aug 
        if (MayAug > AU.October__c+AU.November__c+AU.December__c+AU.September__c) {system.debug('Test 7 Failed'); return false;}
    //if you made it this far, you must be quotable
        return true;
    }
    
    public static decimal getNormalizedUsage(annual_usage__c AU, premises__c thepremise, SmartBill_Index__c SBI){
        decimal weatherFactor = 1; ////////////////////////////////////////////////////////////temporary stub.
        decimal baseload = (AU.July__c+AU.August__c)/2;
        decimal weatherAffectedUsage = AU.Premise_Usage_Sum__c - baseload*12;
        decimal normalizedWeatherAffectedUsage= weatherAffectedUsage * weatherFactor;
        system.debug('================================================Usage for the year is ' + normalizedWeatherAffectedUsage + baseload*12);        
        return normalizedWeatherAffectedUsage + baseload*12;        
    }
    
    public static decimal getDistributionCosts(premises__c premise, annual_usage__c usage, SmartBill_Index__c SBI){
        decimal VariableCost =0; 
        decimal FixedCost =0; 
        
        if (premise.premise_type__c == 'RES'){
            map<integer, decimal>usagemap = GasChoiceUtilities.NormalizeUsage(premise);            
            for (integer i:usagemap.keyset()){
                system.debug('===================RES: month is ' + i + ' and usage for that month is ' + usagemap.get(i));
                VariableCost = VariableCost + math.max(0, usagemap.get(i)*10-SBI.Nebraska_Distribution_Threshhold__c)*SBI.Above_threshold_cost__c;
                VariableCost = VariableCost + math.min(SBI.Nebraska_Distribution_Threshhold__c, usagemap.get(i)*10)*SBI.Below_threshold_distribution_cost__c;
            }
            system.debug('============================Variable distribution cost for the year is ' + VariableCost);
            FixedCost = 12*SBI.Nebraska_Dist_Fixed__c;  
            system.debug('Fixed cost for the year is '+     FixedCost );     
        }
        if (premise.premise_type__c == 'COM'){
            map<integer, decimal>usagemap = GasChoiceUtilities.NormalizeUsage(premise);
            for (integer i:usagemap.keyset()){
                system.debug('===================COM: month is ' + i + ' and usage for that month is ' + usagemap.get(i));
                VariableCost = VariableCost + math.max(0, usagemap.get(i)*10-SBI.Nebraska_COM_Distribution_Threshhold__c)*SBI.Above_threshold_cost_COM__c;
                system.debug('===================COM: Variable cost is now ' + VariableCost);
                VariableCost = VariableCost + math.min(SBI.Nebraska_COM_Distribution_Threshhold__c, usagemap.get(i)*10)*SBI.Below_threshold_distribution_cost_COM__c;
                system.debug('===================COM: Variable cost is now ' + VariableCost);
            }
            system.debug('============================Variable distribution cost for the year is ' + VariableCost);
            FixedCost = 12*SBI.Nebraska_COM_Dist_Fixed__c;       
            system.debug('Fixed cost for the year is '+     FixedCost );  
        }
        system.debug('Fixed cost for the year is '+     FixedCost );   
        system.debug('VariableCost for the year is '+     VariableCost);   
        return FixedCost+VariableCost;
    }
    
    public static decimal getCommodity(decimal TotalUsage, SmartBill_Index__c SBI, integer YearNumber){        
        if(YearNumber ==1) {
            system.debug('Year1 Commodity is  ' +     SBI.year_1_cost__c*TotalUsage + math.max(SBI.Margin_year_1__c*TotalUsage, SBI.Minimum_Aggregate_Margin_Year_1__c));
            return SBI.year_1_cost__c*TotalUsage + math.max(SBI.Margin_year_1__c*TotalUsage, SBI.Minimum_Aggregate_Margin_Year_1__c);
        }else{
            system.debug('Year2 Commodity is  ' +     SBI.year_2_cost__c*TotalUsage + math.max(SBI.Margin_Year_2_per_therm__c*TotalUsage, SBI.Minimum_Aggregate_Margin_Year_2__c));

            return SBI.year_2_cost__c*TotalUsage + math.max(SBI.Margin_Year_2_per_therm__c*TotalUsage, SBI.Minimum_Aggregate_Margin_Year_2__c);
        }
        return null;    
    }
    
    public static decimal getSmartBill(premises__c premise, rate__c Rate){
        try{
            decimal SmartBill;
            //get the SmartBillIndex information
            SmartBill_Index__c SBI = [select id,
                                      Dist_Fixed_Monthly_30000__c, Dist_Fixed_Monthly_5000_or_less__c, Dist_Fixed_Monthly_5001_to_30000__c,
                                      Dist_per_Therm_30000__c, Dist_per_Therm_5000_or_less__c, Dist_per_Therm_5001_to_30000__c,
                                      Margin_year_1__c, Margin_Year_2_per_therm__c, Maximum_Annual_Usage__c, Minimum_Annual_Usage__c,
                                      Minimum_Aggregate_Margin_Year_1__c, Minimum_Aggregate_Margin_Year_2__c, Tax_Factor__c, 
                                      year_1_cost__c, year_2_cost__c,       
                                      Above_threshold_cost__c, Below_threshold_distribution_cost__c, Nebraska_Dist_Fixed__c, Nebraska_Distribution_Threshhold__c, 
                                      Above_threshold_cost_COM__c, Below_threshold_distribution_cost_COM__c, Nebraska_COM_Dist_Fixed__c, Nebraska_COM_Distribution_Threshhold__c,
                                      Program__c
                                                                 
                                      from SmartBill_Index__c where Division__c =: premise.division__c and program__c =:premise.program__c];
            //get usage history (the most recent one)        
            annual_usage__c usage = [select id, Account__c,April__c, August__c, December__c, Estimated__c, February__c, 
                                     January__c,July__c,  June__c, March__c,May__c,November__c,   October__c, Premise_Usage_Sum__c ,September__c, Year__c
                                     from annual_usage__c where Premise__r.id =: premise.id order by year__c desc limit 1];
            //Run the Tests to see if it's quotable
            if (!SmartBillUtilities.SmartBillTests(usage, premise, SBI)){return null;}
            //weather normalize--need HDD/CDD tables?
            decimal TotalUsage = getNormalizedUsage(usage, premise, SBI);
            decimal DistributionCosts = SmartBillUtilities.getDistributionCosts(premise, usage, SBI);
            system.debug('================================DistributionCosts per year are ' + DistributionCosts);
            decimal Year1Commodity = SmartBillUtilities.getCommodity(TotalUsage, SBI, 1);
            decimal Year2Commodity = SmartBillUtilities.getCommodity(TotalUsage, SBI, 2);
            decimal Year1Quote = ((Year1Commodity + DistributionCosts)/12)*SBI.tax_factor__c;
            decimal Year2Quote = ((Year2Commodity + DistributionCosts)/12)*SBI.tax_factor__c;
            decimal CombinedQuote = (Year1Quote + Year2Quote)/2;        
            //now which one were you looking for?
            if (Rate.plan__r.contract_length__c == 12){return Year1Quote.setscale(2);}
            if (Rate.plan__r.contract_length__c == 24){return CombinedQuote.setscale(2);}
        } catch(exception e){return null;}
        return null;
    }
    
    
    public static decimal getDistributionCosts2(premises__c premise, decimal usage, SmartBill_Index__c SBI){        
        decimal VariableCost =0; 
        decimal FixedCost =0; 
        
        if (premise.premise_type__c == 'RES'){
                VariableCost = VariableCost + math.max(0, usage*10-SBI.Nebraska_Distribution_Threshhold__c)*SBI.Above_threshold_cost__c;
                VariableCost = VariableCost + math.min(SBI.Nebraska_Distribution_Threshhold__c, usage*10)*SBI.Below_threshold_distribution_cost__c;
            system.debug('============================Variable distribution cost is ' + VariableCost);
            FixedCost = SBI.Nebraska_Dist_Fixed__c;  
        }
        if (premise.premise_type__c == 'COM'){
                VariableCost = VariableCost + math.max(0, usage*10-SBI.Nebraska_COM_Distribution_Threshhold__c)*SBI.Above_threshold_cost_COM__c;
                VariableCost = VariableCost + math.min(SBI.Nebraska_COM_Distribution_Threshhold__c, usage*10)*SBI.Below_threshold_distribution_cost_COM__c;
            system.debug('============================Variable distribution cost is ' + VariableCost);
            FixedCost = SBI.Nebraska_COM_Dist_Fixed__c; 
        }
        system.debug('distribution cost is ' + (FixedCost+VariableCost));
        return FixedCost+VariableCost;
    }
    
    public static list<plan__c> RemoveSmartBills(list<plan__c> incoming){
        list<plan__c> output = new list<plan__c>();
        for (plan__c p:incoming){
            if (p.rate_type__c != 'SmartBill'){
                output.add(p);
            }        
        }
        return output;
    }
    
    public static decimal getSmartBillImpliedCustomerCost(SmartBill_Index__c SBI, date startdate, date enddate, map<string, map<date, decimal>> Costs, map<integer, decimal> usage, decimal margin, decimal Discount){
        date datecounter=startdate;
        decimal totalCost =0;
        decimal totalUsage = 0;
        
        while (datecounter<=enddate){
            totalCost = totalCost + SBI.Monthly_Supplier_Fee__c + (Costs.get('Fixed Supply').get(datecounter)+ margin + discount)*usage.get(datecounter.month());
            totalUsage = totalUsage + usage.get(datecounter.month());
            datecounter=datecounter.addmonths(1);
        }
        
        if (TotalUsage>0)        return TotalCost/TotalUsage ;
        else return TotalCost;
    }  
        
    
    
}