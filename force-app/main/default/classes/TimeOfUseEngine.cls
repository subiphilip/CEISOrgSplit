public class TimeOfUseEngine {

	public static map<integer, decimal> GetCostsFromUsageAndRateProfiles(map<string, map<string, map<string, decimal>>> Usage, map<string, map<string, map<string, decimal>>> Rate){
		//system.debug('Usage: '  + Usage);
		//system.debug('Rate: '  + Rate);

		map<integer, decimal> output = new map<integer, decimal>();

		for (integer m=1; m<13;m++){ //months
			decimal runningMonthlyCostTotal = 0;

			for (integer d=1; d<8;d++){ //days
				for (integer h=0; h<24;h++){ //hours
					system.debug('Time is ' + m + '/' + d + ':' +h);
					system.debug('Usage is ' + Usage.get(string.valueof(m)).get(string.valueof(d)).get(string.valueof(h)) );
					system.debug('Rate is ' + Rate.get(string.valueof(m)).get(string.valueof(d)).get(string.valueof(h)) );

					runningMonthlyCostTotal = runningMonthlyCostTotal 
						+ 
						(	
							Usage.get(string.valueof(m)).get(string.valueof(d)).get(string.valueof(h)) 
							* 
							Rate.get(string.valueof(m)).get(string.valueof(d)).get(string.valueof(h))
							*
							.01 //since energy charges are always in cents
						)
					;
				}
			}

			output.put(m, (runningMonthlyCostTotal*(DaysInMonth(m)/7)).setscale(2)); //assuming kind of normal distribution of Mondays, Tuesday, etc in each month
		}
		return output;
	}

	public static integer DaysInMonth(integer monthNumber){
		if (monthNumber == 2) return 28;
		else if (monthNumber==1 || monthNumber==12 || monthNumber==3 || monthNumber==5|| monthNumber==7 || monthNumber==8 || monthNumber==10) return 31;
		else return 30;
	}

	//serializes into a attachment on the APA
	public static map<string, map<string, map<string, decimal>>> GrabAnnualLoadProfile(string APAid){
		attachment A = [select id, body from attachment where parentID =: APAid and Name = 'UsageProfileMap.txt'];
		map<string, map<string, map<string, decimal>>> output = (map<string, map<string, map<string, decimal>>>)Json.deserialize(a.body.toString(), map<string, map<string, map<string, decimal>>>.class);
		return output;
	}

	//takes an APA, queries the daily usages, and builds a map of month, day, hour, average usage
	public static void BuildAnnualLoadProfile(string APAid){
		//get the aPA
		AccountPremiseAssociation__c APA = [select Account__c, Id, TOU_Profile_Complete__c, Meter_Data_Estimated__c,Meter_Data_Permission__c,Meter_Data_Request_Status__c,Premise__c, lastdaily__c 
        FROM AccountPremiseAssociation__c
        where id=:APAid];

        //Get the daily usages
		list<daily_usage__c> DUs= MeterDataUtilities.QueryAll(APA);

		map<string, map<string, map<string, decimal>>> UsageTotalMap = initializeEmptyMap(); //how much happened in each month, day, hour?
		map<string, map<string, map<string, decimal>>> UsageCountMap = initializeEmptyMap(); //how many of them are there?

		for (daily_usage__c DU:DUs){	//for each daily usage
			integer intervalCounter=0;
			decimal hourlyTotal=0;
			decimal WhatHour=0;
			string Month = string.valueof(DU.Date__c.month());
			string dayOfWeek = DayAbbreviationToString(DayOfWeekFromDate(DU.Date__c));
			system.debug('month is ' + Month + ' and day of week is ' + dayOfWeek);
			for (string s:DU.Intervals__c.split(',')){				
				hourlyTotal = hourlyTotal + decimal.valueOf(s);
				intervalCounter = intervalCounter + 15;
				if (intervalCounter==60){ //we've finished an hour
					system.debug('Hour is ' + WhatHour);
					//increment the hourly total
					UsageTotalMap.get(Month).get(dayOfWeek).put(string.valueof(WhatHour), UsageTotalMap.get(Month).get(dayOfWeek).get(string.valueof(WhatHour)) + hourlyTotal);
					//increment the count of readings for that hour
					UsageCountMap.get(Month).get(dayOfWeek).put(string.valueof(WhatHour), UsageCountMap.get(Month).get(dayOfWeek).get(string.valueof(WhatHour)) + 1);
					intervalCounter=0; //reset it for the next hour					
					hourlyTotal=0; //reset for next hour.

					if (WhatHour<23) WhatHour=WhatHour+1; //saves operation if we're done for the day--and handles fall DST. We'll just average that extra hour into the 11pm again.  Kludgy!

				}
			}
		}		

		map<string, map<string, map<string, decimal>>> UsageProfileMap = AverageTheMaps(UsageTotalMap, UsageCountMap); 

		attachment A = new attachment();
		A.body = blob.valueof(Json.serialize(UsageProfileMap));
		
		a.Name = 'UsageProfileMap.txt';
		a.parentID = APAid;
		delete [select id from attachment where parentID =: APAid and Name = 'UsageProfileMap.txt']; //clean up any old ones
		insert a;

		APA.TOU_Profile_Complete__c=true;
		update APA;



	}

	public static map<string, map<string, map<string, decimal>>> initializeEmptyMap(){
		map<string, map<string, map<string, decimal>>> output = new map<string, map<string, map<string, decimal>>>();

		for (integer m=1; m<13;m++){ //months
			output.put(string.valueof(m), new map<string, map<string, decimal>>());
			for (integer d=1; d<8;d++){ //days
				output.get(string.valueof(m)).put(string.valueof(d), new map<string, decimal>());
				for (integer h=0; h<24;h++){ //hours
					output.get(string.valueof(m)).get(string.valueof(d)).put(string.valueof(h),0);
				}
			}
		}
		return output;
	}

	public static map<string, map<string, map<string, decimal>>> AverageTheMaps(map<string, map<string, map<string, decimal>>> Readings, map<string, map<string, map<string, decimal>>> ReadingQuantities){
		
		map<string, map<string, map<string, decimal>>> output = new map<string, map<string, map<string, decimal>>>();

		for (integer m=1; m<13;m++){ //months
			output.put(string.valueof(m), new map<string, map<string, decimal>>());
			for (integer d=1; d<8;d++){ //days
				output.get(string.valueof(m)).put(string.valueof(d), new map<string, decimal>());
				for (integer h=0; h<24;h++){ //hours
					//check for div 0
					if (ReadingQuantities.get(string.valueof(m)).get(string.valueof(d)).get(string.valueof(h))==0){
						system.debug('no reading quantity for '+ m+'/'+d+':'+h);
						output.get(string.valueof(m)).get(string.valueof(d)).put(
							string.valueof(h),
							0
						);
					} else{
						output.get(string.valueof(m)).get(string.valueof(d)).put(
							string.valueof(h),
							(
								Readings.get(string.valueof(m)).get(string.valueof(d)).get(string.valueof(h)) 
								/ 
								ReadingQuantities.get(string.valueof(m)).get(string.valueof(d)).get(string.valueof(h))  
							).setscale(3)
						);
					}
				}
			}
		}
		return output;

	}


	public static string DayOfWeekFromDate(date d){
		datetime dt = datetime.newInstance(d, time.newInstance(0,0,0,0));
		system.debug('incoming date is ' + d);
		return dt.format('E');
	}


	//Should be run as an async once a TOU rate is created/edited.  We'll handle that with a trigger separately
	public static map<id, map<string, map<string, map<string, decimal>>>> GrabAnnualRateProfile(list<string> RateIds){
		map<id, map<string, map<string, map<string, decimal>>>> RateMap = new map<id, map<string, map<string, map<string, decimal>>>>();

		list<attachment> Attachments = [select id, parentID, body from attachment where parentID in: RateIds and Name = 'HourCostProfile.txt'];

		for (attachment a:Attachments){
			RateMap.put(a.parentID, (map<string, map<string, map<string, decimal>>>)Json.deserialize(a.body.toString(), map<string, map<string, map<string, decimal>>>.class));
		}

		return RateMap;
	}

	public static map<string, map<string, map<string, decimal>>> GrabAnnualRateProfile(string RateId){
		attachment A = [select id, body from attachment where parentID =: RateId and Name = 'HourCostProfile.txt'];
		map<string, map<string, map<string, decimal>>> output = (map<string, map<string, map<string, decimal>>>)Json.deserialize(a.body.toString(), map<string, map<string, map<string, decimal>>>.class);
		return output;
		//            list<daily_usage__c> output = (List<daily_usage__c>) Json.deserialize(a.body.toString(), list<daily_usage__c>.class);   
	}

	public static map<id, map<string, map<string, map<string, decimal>>>> GrabAnnualRateProfile(list<rate__c> Rates){
		list<id> rateIds = new list<id>();
		for (Rate__c r:Rates){
			rateIds.add(r.id);
		}
		return GrabAnnualRateProfile(rateIds);
	}





	public static void BuildAnnualRateProfile(string RateId){
		
		//map<datetime, decimal> costMap= new map<datetime, decimal>() ;
		//a map of month (1-12), day (1=Sun, 7= Saturday), hour (0=12am, 23=11pm);
		map<string, map<string, map<string, decimal>>> CostMap = new map<string, map<string, map<string, decimal>>>();

		rate__c rate = [select id, Energy_Base_Rate_cents__c from rate__c where id =: RateId];
		list<rate_exception__c> REs = [select id, rate__c, start_day__c, Start_hour__c, end_hour__c, energy_charge_cents__c
										from rate_exception__c where rate__c =: RateId];

		for (integer m=1; m<13;m++){ //months
			CostMap.put(string.valueof(m), new map<string, map<string, decimal>>());
			for (integer d=1; d<8;d++){ //days
				CostMap.get(string.valueof(m)).put(string.valueof(d), new map<string, decimal>());
				for (integer h=0; h<24;h++){ //hours
					CostMap.get(string.valueof(m)).get(string.valueof(d)).put(string.valueof(h),rate.Energy_Base_Rate_cents__c);
				}
			}
		}

		system.debug(CostMap);

		for (rate_exception__c re:REs){ //let's go through the rate exceptions
			integer day = DayToInteger(re.Start_Day__c); //what day are we dealing with?
			integer startHour = integer.valueof(re.Start_Hour__c); //convert to integers so we only have to do this once per RE
			integer endHour = integer.valueof(re.End_Hour__c);

			for (integer m=1; m<13;m++){ //months
				for (integer h=0; h<24;h++){ //hours
					if (h>=startHour && h<=endHour){
						CostMap.get(string.valueof(m)).get(string.valueof(day)).put(string.valueof(h),re.energy_charge_cents__c); //replace the energy charge with the exception version
					}					
				}
			}

		}
		attachment A = new attachment();
		A.body = blob.valueof(Json.serialize(costMap));
		
		a.Name = 'HourCostProfile.txt';
		a.parentID = RateId;
		delete [select id from attachment where parentID =: RateId and Name = 'HourCostProfile.txt']; //clean up any old ones
		insert a;
	}


	public static integer DayToInteger(string day){
		if (day == 'Sunday') return 1;
		if (day == 'Monday') return 2;
		if (day == 'Tuesday') return 3;
		if (day == 'Wednesday') return 4;
		if (day == 'Thursday') return 5;
		if (day == 'Friday') return 6;
		if (day == 'Saturday') return 7;
		return null;
	}

	public static string DayAbbreviationToString(string day){
		if (day == 'Sun') return '1';
		if (day == 'Mon') return '2';
		if (day == 'Tue') return '3';
		if (day == 'Wed') return '4';
		if (day == 'Thu') return '5';
		if (day == 'Fri') return '6';
		if (day == 'Sat') return '7';
		return null;
	}


	public static void RateExceptionChangeASR(string rateID){
		//suspend the rate
		Rate__c r = [select id, suspended__c from Rate__c where id =: RateId];
		r.Suspended__c = true;
		update r;

		//redo the profile
		BuildAnnualRateProfile(rateID);

	}
}