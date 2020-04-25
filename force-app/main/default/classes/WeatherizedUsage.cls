public class WeatherizedUsage {
    
    public map<date,decimal> usage {get;set;}
    public map<string,decimal> usageBaseLoad {get;set;}
    public map<date,decimal> usageWeatherDependent {get;set;}
    public map<date,decimal> usageWeatherAdjusted {get;set;}
    public map<integer, decimal> NormalizedUsage {get;set;}
    public map<integer, decimal> Swing{get;set;}
    public map<date, decimal> weatherFactors {get;set;}
    date minDate;
    date maxDate;
    
    public WeatherizedUsage(string fuel, map<date,decimal> providedUsage, premises__c weatherPremise){
    	usageWeatherAdjusted = new map<date,decimal>();
        usageWeatherDependent = new map<date,decimal>();
        usageBaseLoad = new map<string, decimal>();
        weatherFactors = new map<date, decimal>();
        if (fuel==null) fuel='gas';  //for future use if this ever does electric        
        usage=providedUsage; 
        BuildBaseLoad();
        MakeWeatherDependentMap();
        LoadWeatherFactor(weatherPremise);
        WeatherAdjust();
        NormalizedUsage = MakeNormalized2(usageWeatherAdjusted, maxDate, minDate); //MakeNormalized(map<date, decimal> usage, date maxDate, date minDate)        
    }
    
    public WeatherizedUsage(premises__c premise, string fuel){
        usageWeatherAdjusted = new map<date,decimal>();
        usageWeatherDependent = new map<date,decimal>();
        usageBaseLoad = new map<string, decimal>();
        weatherFactors = new map<date, decimal>();
        
        if (fuel==null) fuel='gas';  //for future use if this ever does electric        
        LoadUsageSeries(premise);        
        if (premise.premise_type__c != 'AGR'){
            BuildBaseLoad();
            MakeWeatherDependentMap();
            LoadWeatherFactor(premise);
            WeatherAdjust();
            NormalizedUsage = MakeNormalized(usageWeatherAdjusted, maxDate, minDate); //MakeNormalized(map<date, decimal> usage, date maxDate, date minDate)
        } else{
            // it's Ag so we don't do any weather adjusting
            NormalizedUsage = MakeNormalized(usage, maxDate, minDate);
        }
        if (GasChoiceUtilities.getTotalUsage(NormalizedUsage)==0){
            NormalizedUsage = (GasChoiceUtilities.getDefaultUsage(premise));
        }
    }
    
    
    
    public void MakeWeatherDependentMap(){
        try{
            for (date d:usage.keyset()){
                try{
                    usageWeatherDependent.put(d, math.max(0, usage.get(d)-usageBaseload.get(string.valueOf(d.year()))));
                }catch(exception e){
                	system.debug('Could not calculate weather dependent usage for ' + d + '.  Using non-adjusted' );
                    usageWeatherDependent.put(d, usage.get(d));
                }
            }
        } catch (exception e){
            system.debug('Could not calculate weather dependent usage');
        }
    }
    
    
    
    public static map<date, decimal> AUsToMap (list<annual_usage__c> usages){
        map<date, decimal> usage = new map<date, decimal>();
        
        for (annual_usage__c u:usages){
            if(u.January__c!=null) usage.put(date.parse('1/1/'+u.year__c), u.January__c/10); else usage.put(date.parse('1/1/'+u.year__c), 0);// we /10 to get from the usage unit (therms) to the pricing unit (Dth)
            if(u.February__c!=null)usage.put(date.parse('2/1/'+u.year__c), u.February__c/10); else usage.put(date.parse('2/1/'+u.year__c), 0);
            if(u.March__c!=null)usage.put(date.parse('3/1/'+u.year__c), u.March__c/10); else usage.put(date.parse('3/1/'+u.year__c), 0);
            if(u.April__c!=null)usage.put(date.parse('4/1/'+u.year__c), u.April__c/10); else usage.put(date.parse('4/1/'+u.year__c), 0);
            if(u.May__c!=null) usage.put(date.parse('5/1/'+u.year__c), u.May__c/10); else usage.put(date.parse('5/1/'+u.year__c), 0);
            if(u.June__c!=null)usage.put(date.parse('6/1/'+u.year__c), u.June__c/10); else usage.put(date.parse('6/1/'+u.year__c), 0);
            if(u.July__c!=null)usage.put(date.parse('7/1/'+u.year__c), u.July__c/10); else usage.put(date.parse('7/1/'+u.year__c), 0);
            if(u.August__c!=null)usage.put(date.parse('8/1/'+u.year__c), u.August__c/10); else usage.put(date.parse('8/1/'+u.year__c), 0);
            if(u.September__c!=null)usage.put(date.parse('9/1/'+u.year__c), u.September__c/10); else usage.put(date.parse('9/1/'+u.year__c), 0);
            if(u.October__c!=null)usage.put(date.parse('10/1/'+u.year__c), u.October__c/10); else usage.put(date.parse('10/1/'+u.year__c), 0);
            if(u.November__c!=null)usage.put(date.parse('11/1/'+u.year__c), u.November__c/10); else usage.put(date.parse('11/1/'+u.year__c), 0);
            if(u.December__c!=null)usage.put(date.parse('12/1/'+u.year__c), u.December__c/10); else usage.put(date.parse('12/1/'+u.year__c), 0);
        }        
        return usage;
    }
    
    public void WeatherAdjust(){
        try{
            for (date d:usage.keyset()){
                //handling null weatherFactor and baseload
                if (weatherFactors.get(d)==null || weatherFactors.get(d)==0 ){weatherFactors.put(d, 1);}
                if (UsageBaseload.get(string.valueof(d.year()))==null){UsageBaseload.put(string.valueof(d.year()), 0 );}
                try{
                	usageWeatherAdjusted.put(d, (usageWeatherDependent.get(d)/math.max(0.5, math.min(2, weatherFactors.get(d)))+UsageBaseload.get(string.valueof(d.year()))).setscale(1));
                }catch (exception e){
                    
                    system.debug('Could not weather adjust date:' + d+' because of error '+ e);
                    system.debug('weather factor is ' + weatherFactors.get(d));
                    
                	usageWeatherAdjusted.put(d, usageWeatherDependent.get(d)/math.max(0.5, math.min(2, weatherFactors.get(d))));
                }
            }
        }catch(exception e){system.debug('Could not weather adjust :' + e);}
    }
                                      
    public void LoadUsageSeries (premises__c premise){
        //get the usage for that premise
            list<annual_usage__c> usages = [select id, Account__c,April__c, August__c, December__c, Estimated__c, February__c, 
                                     January__c,July__c,  June__c, March__c,May__c,November__c,  October__c, Premise_Usage_Sum__c ,September__c, Year__c
                                     from annual_usage__c 
                                     where ignore__c!=true and Year__c!=null and Year__c !='0'
                                     and Premise__r.id =: premise.id order by year__c desc limit 4];
        
        if (usages.isempty()){   //if there is no usage!
            system.debug('No usage found');
            }
        if (usages.isempty() && premise.premise_type__C == 'AGR'){
            system.debug('Loading Ag defaults');
            GasChoiceCalcInputs__c GCCI = GasChoiceCalcInputs__c.getOrgDefaults();
            load_curve__c LC = [select id, January__c,February__c,March__c,April__c,
                                May__c, June__c, July__c, August__c, September__c, October__c, November__c, December__c
                                 from load_curve__c 
                                 where Name = 'Nebraska Ag'];
            if (LC!=null){
                annual_usage__c FakeAU = new annual_usage__c(
                    January__c=LC.January__c/10, 
                    February__c=LC.February__c/10, 
                    March__c=LC.March__c/10, 
                    April__c=LC.April__c/10, 
                    May__c=LC.May__c/10, 
                    June__c=LC.June__c/10, 
                    July__c=LC.July__c/10, 
                    August__c=LC.August__c/10, 
                    September__c=LC.September__c/10, 
                    November__c=LC.November__c/10, 
                    December__c=LC.December__c/10, 
                    October__c=LC.October__c/10,
                    year__c = GCCI.Current_Program_Year__c
                    );
                usages.add(FakeAU);
                }
                
        }
        if (!usages.isempty()) { 
            usage = AUsToMap(usages);
            set<date> dateSet = usage.keyset();
            list<date> dateList = new list<date>();
            dateList.addall(dateSet);
            dateList.sort();        
            minDate = dateList[0];
            maxDate = dateList[datelist.size()-1];
        }
    }
    
    public void buildBaseload(){
        
        set<string> years= new set<string>();
        try{
            for (date d:usage.keyset()){
                years.add(string.valueof(d.year()));
            }
        
            system.debug(years);
            for (string y:years){
                system.debug('date 1 is ' + date.parse('7/1/'+y));
                system.debug('date 1 has usage ' + usage.get(date.parse('7/1/'+y)));
                system.debug('date 2 is ' + date.parse('8/1/'+y));
                system.debug('date 2 has usage ' + usage.get(date.parse('8/1/'+y)));
                try{
                	usageBaseLoad.put(y, (usage.get(date.parse('7/1/'+y))+usage.get(date.parse('8/1/'+y)))/2);
                    system.debug('set basedload for year ' + y + ' of ' + usageBaseLoad.get(y));
                }catch (exception e){
                    system.debug('Could not get baseload for year' + y);
                	usageBaseLoad.put(y,0);
                }
            }
        }catch (exception e){system.debug('Could not get baseload');}
    }
    
    public void LoadWeatherFactor(premises__c premise){
        premises__c WS = new premises__c();
        annual_usage__C Norm = new annual_usage__C();
        list<annual_usage__c> actuals = new list<annual_usage__c>();        
        
        if (premise.Location__Latitude__s == null || premise.Location__Longitude__s==null){ //if the premise has no coordinates 
            //if we don't know where the premise is, let's at least base on it Scottsbluff, NE
            premise.Location__Latitude__s = 41.8667;
            premise.Location__Longitude__s = -103.6667;
        } 
        
        WS = WSLookup(premise.Location__Latitude__s, premise.Location__Longitude__s);          
        try{
            Norm = [select id, Account__c,April__c, August__c, December__c, Estimated__c, February__c, 
                                         January__c,July__c,  June__c, March__c,May__c,November__c,  October__c, Premise_Usage_Sum__c ,September__c  
                    from annual_usage__c where isNorm__c = true and premise__r.id =: WS.id limit 1][0];
            
            actuals = [select id, Account__c,April__c, August__c, December__c, Estimated__c, February__c, 
                                         January__c,July__c,  June__c, March__c,May__c,November__c,  October__c, Premise_Usage_Sum__c ,September__c, Year__c
                       from annual_usage__c where isNorm__c = false and premise__r.id =: WS.id order by Year__c DESC limit 4 ];
            
            for (annual_usage__c u:actuals){
                if(u.January__c!=null && Norm.January__c!=0) weatherFactors.put(date.parse('1/1/'+u.year__c), ( u.January__c/Norm.January__c )); else weatherFactors.put(date.parse('1/1/'+u.year__c), 1);
                if(u.February__c!=null && Norm.February__c!=0)weatherFactors.put(date.parse('2/1/'+u.year__c), ( u.February__c/Norm.February__c )); else weatherFactors.put(date.parse('2/1/'+u.year__c), 1);
                if(u.March__c!=null && Norm.March__c!=0)weatherFactors.put(date.parse('3/1/'+u.year__c), (u.March__c/Norm.March__c )); else weatherFactors.put(date.parse('3/1/'+u.year__c), 1);
                if(u.April__c!=null && Norm.April__c!=0)weatherFactors.put(date.parse('4/1/'+u.year__c), (u.April__c/Norm.April__c )); else weatherFactors.put(date.parse('4/1/'+u.year__c), 1);
                if(u.May__c!=null && Norm.May__c!=0) weatherFactors.put(date.parse('5/1/'+u.year__c), (u.May__c/Norm.May__c )); else weatherFactors.put(date.parse('5/1/'+u.year__c), 1);
                if(u.June__c!=null && Norm.June__c!=0)weatherFactors.put(date.parse('6/1/'+u.year__c), (u.June__c/Norm.June__c )); else weatherFactors.put(date.parse('6/1/'+u.year__c), 1);
                if(u.July__c!=null && Norm.July__c!=0)weatherFactors.put(date.parse('7/1/'+u.year__c), (u.July__c/Norm.July__c )); else weatherFactors.put(date.parse('7/1/'+u.year__c), 1);
                if(u.August__c!=null && Norm.August__c!=0)weatherFactors.put(date.parse('8/1/'+u.year__c), (u.August__c/Norm.August__c )); else weatherFactors.put(date.parse('8/1/'+u.year__c), 1);
                if(u.September__c!=null && Norm.September__c!=0)weatherFactors.put(date.parse('9/1/'+u.year__c), (u.September__c/Norm.September__c )); else weatherFactors.put(date.parse('9/1/'+u.year__c), 1);
                if(u.October__c!=null && Norm.October__c!=0)weatherFactors.put(date.parse('10/1/'+u.year__c), (u.October__c/Norm.October__c )); else weatherFactors.put(date.parse('10/1/'+u.year__c), 1);
                if(u.November__c!=null && Norm.November__c!=0)weatherFactors.put(date.parse('11/1/'+u.year__c), (u.November__c/Norm.November__c )); else weatherFactors.put(date.parse('11/1/'+u.year__c), 1);
                if(u.December__c!=null && Norm.December__c!=0)weatherFactors.put(date.parse('12/1/'+u.year__c), (u.December__c/Norm.December__c )); else weatherFactors.put(date.parse('12/1/'+u.year__c), 1);
            }
            for (date x:weatherFactors.keyset()){
                system.debug('Weather Factor for ' + x + ' is ' + weatherFactors.get(x));
                
            }
            }catch(exception e){
                DiagnosticEntry.RecordCrash(e);
                throw new WeatherizationException('Weather data error', e);
            }
    }
    
    public class WeatherizationException extends Exception {}
    
    public static map<integer, decimal> MakeNormalized2(map<date, decimal> usage, date maxDate, date minDate){
        system.debug('in makeNormzlied with startdate '+minDate+' and endDate '+maxDate);
         if (usage.isempty()) {system.debug('usage is empty'); return null;}
        
        map<integer, decimal> output = new map<integer, decimal>();
        for (integer i=1; i<13; i++){
            output.put(i, 0);
        }
        
        set<date> Dateset = usage.keyset();
        list<date> Datelist = new list<date>();
        datelist.addall(dateset);
        datelist.sort();
        
        integer dateCounter = 1;
        
        for (date d:datelist){
            if (datelist.size()>=dateCounter+24){ //there's three years' worth of this month
                system.debug('there are 3 years of data');
            	output.put(d.month(), usage.get(d)*0.2 + usage.get(d.addmonths(12))*0.3+usage.get(d.addmonths(24))*0.5);	
            } else if (datelist.size()>=dateCounter+12){
                system.debug('there are 2 years of data');
            	output.put(d.month(), usage.get(d)*0.4 + usage.get(d.addmonths(12))*0.6);
            } else{
                system.debug('there is just 1 year of data');
            	output.put(d.month(), usage.get(d)); //it's all that month's usage
            }
            dateCounter=dateCounter+1;
            if (dateCounter>12) continue;
        }
        return output;
    }
    
    public static map<integer, decimal> MakeNormalized(map<date, decimal> usage, date maxDate, date minDate){
        system.debug('in makeNormzlied with startdate '+minDate+' and endDate '+maxDate);
                      
        if (usage.isempty()) {system.debug('usage is empty'); return null;}
        
        map<integer, decimal> output = new map<integer, decimal>();
        for (integer i=1; i<13; i++){
            output.put(i, 0);
        }
        
        if (usage.size()==12){ //that's easy--use the usage as the usage
            for (date d:usage.keyset()){
                output.put(d.month(), usage.get(d)); 
            }
        }
        else if (usage.size()==24){
                //get the date keyset into a sorted list ASC; split into 3 groups of 12.
            set<date> Dateset = usage.keyset();
            list<date> Datelist = new list<date>();
            datelist.addall(dateset);
            datelist.sort();
            
            integer dateCounter = 1;
            for (date d:datelist){
                if (dateCounter>12) {
                    output.put(d.month(), output.get(d.month()) + usage.get(d)*0.6);
                    system.debug('On dateCounter ' + DateCounter + ' We gave weighting of 60% to date ' + d + ' of usage ' + usage.get(d));
                } else {
                    output.put(d.month(), output.get(d.month()) + usage.get(d)*0.4);
                    system.debug('On dateCounter ' + DateCounter + ' We gave weighting of 40% to date ' + d + ' of usage ' + usage.get(d));
                }
                dateCounter=dateCounter+1;
            }
        }
        else if (usage.size()>=36){
            //get the date keyset into a sorted list ASC; split into 3 groups of 12.
            set<date> Dateset = usage.keyset();
            list<date> Datelist = new list<date>();
            datelist.addall(dateset);
            datelist.sort();
            //now shrink it down to 36 items
            integer countToKill=math.max(0, datelist.size()-36);
            for (integer i=0; i<countToKill; i++){
                datelist.remove(0);
            }
            
            integer dateCounter = 1;
            for (date d:datelist){
                
                if (dateCounter>24){
                    output.put(d.month(), output.get(d.month()) + usage.get(d)*0.5); 
                    system.debug('On dateCounter ' + DateCounter + ' We gave weighting of 50% to date ' + d + ' of usage ' + usage.get(d));
                } else if (dateCounter>12) {
                    output.put(d.month(), output.get(d.month()) + usage.get(d)*0.3);
                    system.debug('On dateCounter ' + DateCounter + ' We gave weighting of 30% to date ' + d + ' of usage ' + usage.get(d));
                } else {
                    output.put(d.month(), output.get(d.month()) + usage.get(d)*0.2);
                    system.debug('On dateCounter ' + DateCounter + ' We gave weighting of 20% to date ' + d + ' of usage ' + usage.get(d));
                }
                dateCounter=dateCounter+1;
            }
        }
        
        return output;
    }
    
    public static void calculateSwing(map<date, decimal> usage){
        
    }
    
    public static premises__c WSLookup(decimal clat, decimal clong){
        id WSID = [select id from recordtype where name='Weather Station'].id;
        string q = 'select id from Premises__c where recordtypeid = \'' + WSID + '\' order by distance(location__c, geolocation('+string.valueof(clat)+', '+string.valueof(clong)+'), \'mi\') ASC limit 3';
        system.debug(q);
        list<premises__c> plist = database.query(q);
        if (plist.isempty()) return null; else return plist[0];
    }                                                                     

    public static Premises__c WSLookupForOffice(decimal clat, decimal clong, id offId){
        list<Weather_Office__c> wOffs = new list<Weather_Office__c>();
        set<Id> stationSet = new set<Id>();

        //get weather stations for the specific office
        wOffs = [select id, name, Weather_Station__c from Weather_Office__c where CES_Office__c =:offId];

        if (wOffs.size()>0){
            for (Weather_Office__c wo:wOffs){
                stationSet.add(wo.Weather_Station__c);
            }
        } else { return null;}// if no stations, return null

        //get closest weather station to provided utility coordinates
        id WSID = [select id from recordtype where name='Weather Station'].id;
        
        string q = 'select id from Premises__c where recordtypeid = \'' + WSID + '\' and id in:stationSet order by distance(location__c, geolocation('+string.valueof(clat)+', '+string.valueof(clong)+'), \'mi\') ASC limit 3';
        system.debug(q);
        list<premises__c> plist = database.query(q);
        if (plist.isempty()) return null; else return plist[0];
    }
                                                                     
                                                                     
}