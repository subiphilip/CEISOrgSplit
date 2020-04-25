global class MeterDataUtilities {    

    global static void CompactMeterDataMonthly(string APAid){
        AccountPremiseAssociation__c APA = [select Account__c, Id, Meter_Data_Estimated__c,Meter_Data_Permission__c,Meter_Data_Request_Status__c,Premise__c,lastdaily__c 
        FROM AccountPremiseAssociation__c
        where id=:APAid];

        MeterDataUtilities.DailiesToMonthlies(apa);
        MeterDataUtilities.AppendDailies(apa);
    }

    global static void DailiesToMonthlies(AccountPremiseAssociation__c APA){
        id premise;
        if (APA.premise__c ==null){ //only query if we have to.
        	premise = [select id, premise__c from AccountPremiseAssociation__c where id =: APA.id].premise__c;
        } else premise = APA.Premise__c;
        
        list<daily_usage__c> data = QueryAll(APA);
        if (!data.isempty()){
            //SOMETHING ABOUT DEDUPLICATION!
            data = DedupeByDateAndSortAscending(data);

            system.debug('first record is ' + data[0] + ' and last record is ' + data[data.size()-1]);        
            map<integer, decimal> monthvalues = new map<integer, decimal>{1=>0, 2=>0, 3=>0, 4=>0, 5=>0, 6=>0, 7=>0, 8=>0, 9=>0, 10=>0, 11=>0, 12=>0};
            
            system.debug('first record is ' + data[0] + ' and last record is ' + data[data.size()-1]);
            for (daily_usage__c d:data){
                if (d.Date__c > data[data.size()-1].Date__c.addyears(-1) ){
            		monthvalues.put(d.Date__c.month(), monthvalues.get(d.Date__c.month()) + d.Total_for_the_day__c);
                }
            }
            
            list<Monthly_Usage__c> replacementMonths = new list<Monthly_Usage__c>();
            
            for (integer x=1; x<13; x++){
                replacementMonths.add(new Monthly_Usage__c(Month_Number__c=x, APA__c = APA.id, Usage__c=monthvalues.get(x), Premise__c=premise, Estimated__c=false));
            }
            
            try{delete [select id from Monthly_Usage__c where APA__c =: APA.id];}catch(exception e){}
            insert replacementMonths;
        }
        
    }

    global static list<daily_usage__c> DedupeByDateAndSortAscending(list<daily_usage__c> incoming){
        map<date, daily_usage__c> DateMap = new map<date, daily_usage__c>();
        for (daily_usage__c du:incoming){
            DateMap.put(du.date__c, du); //will eliminate duplicate dates
        }
        list<date> DateList = new list<date>(DateMap.keyset());
        DateList.sort(); //ascending order
        list<daily_usage__c> output = new list<daily_usage__c>();
        for (date d:DateList){
            output.add(DateMap.get(d));
        }
        return output;
    }
        
    global static void AppendDailies(AccountPremiseAssociation__c APA){
    	list<daily_usage__c> toPut = getExistingJSONfromAttachment(APA);
        toPut.addAll(getOlderDailies(APA));

        if (!toPut.isEmpty()){
            IntervalsToJSONAttachment(toPut, APA.id);
            CleanDailies(APA);
        }
    }
    
    global static void CleanDailies (AccountPremiseAssociation__c APA){
    	list<daily_usage__c> Intervals = [select id, Date__c, Total_for_the_day__c, Intervals__c from daily_usage__c where date__c < LAST_N_DAYS:30 and Account_Premise_Association__c =: APA.id order by date__c ASC];      
        delete Intervals;
    }    
    
    global static list<daily_usage__c> getDailies (AccountPremiseAssociation__c APA){
    	list<daily_usage__c> Intervals = [select Date__c, Total_for_the_day__c, Intervals__c from daily_usage__c where Account_Premise_Association__c =: APA.id order by date__c ASC];      
        return Intervals;
    }
    
    global static list<daily_usage__c> getOlderDailies (AccountPremiseAssociation__c APA){
    	list<daily_usage__c> Intervals = [select Date__c, Total_for_the_day__c, Intervals__c from daily_usage__c where date__c < LAST_N_DAYS:30 and Account_Premise_Association__c =: APA.id order by date__c ASC];      
        return Intervals;
    }
    
    global static list<daily_usage__c> getExistingJSONfromAttachment (AccountPremiseAssociation__c APA){    	
        try{
            attachment a = [select id, body from attachment where name = 'IntervalDataAsJSON.txt' and parentID=:APA.id order by createddate DESC limit 1];
        	system.debug(string.valueof(a.body));
            list<daily_usage__c> output = (List<daily_usage__c>) Json.deserialize(a.body.toString(), list<daily_usage__c>.class);   
        	delete a;
            return output;
        }catch(exception e){
            system.debug(e); 
            list<daily_usage__c> output = new list<daily_usage__c>();
            return output;}
        return null;
    }
    
    global static void IntervalsToJSONAttachment(list<daily_usage__c> input, id parentid){
        input = DedupeByDateAndSortAscending(input); //first, dedupe

		string JSONString = Json.serialize(input);
        attachment a = new attachment();
        a.body = blob.valueof(JSONString);
        a.Name = 'IntervalDataAsJSON.txt';
        a.parentID=parentid;
        insert a;
    }
    
    global static list<daily_usage__c> QueryAll(AccountPremiseAssociation__c APA){
    	list<daily_usage__c> output = new list<daily_usage__c>();
        try{
            attachment a = [select id, body from attachment where name = 'IntervalDataAsJSON.txt' and parentID=:APA.id order by createddate DESC limit 1];
        	system.debug(string.valueof(a.body));
            output = (List<daily_usage__c>) Json.deserialize(a.body.toString(), list<daily_usage__c>.class);   
        }catch(exception e){system.debug(e); }
        output.addAll(getDailies(APA));
        //would you want to verify that there are no overlaps? 
        return output;        
    }
    
    
}