public class GasChoiceUtilities{
	
	@future public static void MakeUsageKeys(){
			list<annual_usage__c> AUList=[select id, premise__r.gas_premise_number__c, year__c from annual_usage__c where key__c =null limit 9999 for update];
			for (annual_usage__c au:AUList){
				au.key__c=au.premise__r.gas_premise_number__c + '--' + au.year__c;
			}
			update AUList;        
		}
	
	public static decimal getTotalUsage(map<integer, decimal> usage){
		decimal output=0;
		try{
			for (integer i:usage.keyset()){
			output+=usage.get(i);
			}
		}catch(exception e){system.debug('Usage total error: ' + e); return 0;}
		return output;
	}

	public static decimal getBlendFix(map<integer, decimal> usage){
		decimal output=0;
		for (integer i:usage.keyset()){
			if(i<6 || i>10) output+=usage.get(i);
		}
		return output;
	}

	public static decimal getBlendIndex(map<integer, decimal> usage){
		decimal output=0;
		for (integer i:usage.keyset()){
			if(i>5 && i<11) output+=usage.get(i);
		}
		return output;
	}
	
	public static decimal CalculateMarginVolumeDiscount(map<integer,decimal> usage){
		//gets the discount factor for the customer's normalized usage.  For example, 1 is no discount, .98 is a 2% discount, etc.
		try{GasChoiceCalcInputs__c gcci = GasChoiceCalcInputs__c.getOrgDefaults();        
			system.debug(usage);
			decimal AnnualUsage = 0;
			for (integer u:usage.keyset()){
				AnnualUsage+=usage.get(u); system.debug('============  Annual usage running total is now ' +AnnualUsage);
			}
			//the custom calc section
			if (AnnualUsage<gcci.Volume_price_break_threshhold__c){
				return 1;
			} else{
				decimal increments=(AnnualUsage-gcci.Volume_price_break_threshhold__c)/gcci.Price_break_increment__c;
				return math.max(1-gcci.Maximum_discount__c, 1-(increments*gcci.Volume_Discount__c));
			}
		   }catch(exception e){return 0;}
	}
	
	public static map<integer, decimal> getDefaultUsage(premises__c premise){
		integer counter=0;
		map<integer, decimal> output = new map<integer, decimal>();
		map<integer, decimal> totals = new map<integer, decimal>{1=>0, 2=>0, 3=>0, 4=>0, 5=>0, 6=>0, 7=>0, 8=>0, 9=>0, 10=>0, 11=>0, 12=>0 }; 
		for (annual_usage__c AU: [select January__c, February__c, March__c, April__c, May__c, June__c, 
									July__c, August__c, September__c, October__c, November__c, December__c
									from annual_usage__c 
									where 
									premise__r.record_type_name__c = 'Gas Choice Premise' 
									and premise__r.program__c =: premise.program__c
									and premise__r.division__c =: premise.division__c
									and premise__r.Electric_Service_Address_City__c =: premise.Electric_Service_Address_City__c                                     
									and premise__r.premise_type__c =: premise.premise_type__c
									and ignore__c!=true
									 order by lastmodifiedDate DESC limit 5000]){
			if (AU.January__c!=null) totals.put(1, totals.get(1)+AU.January__c);
			if (AU.February__c!=null)totals.put(2, totals.get(2)+AU.February__c);
			if (AU.March__c!=null) totals.put(3, totals.get(3)+AU.March__c);            
			if (AU.April__c!=null) totals.put(4, totals.get(4)+AU.April__c);
			if (AU.May__c!=null) totals.put(5, totals.get(5)+AU.May__c);
			if (AU.June__c!=null) totals.put(6, totals.get(6)+AU.June__c);
			if (AU.July__c !=null) totals.put(7, totals.get(7)+AU.July__c );
			if (AU.August__c!=null) totals.put(8, totals.get(8)+AU.August__c);
			if (AU.September__c!=null) totals.put(9, totals.get(9)+AU.September__c);
			if (AU.October__c!=null) totals.put(10, totals.get(10)+AU.October__c);
			if (AU.November__c!=null) totals.put(11, totals.get(11)+AU.November__c);
			if (AU.December__c!=null) totals.put(12, totals.get(12)+AU.December__c);
			counter= counter+1;
		}
		if (counter==0) counter=1;
		
		//take the average and also convert to Dth from therms
		return new map<integer, decimal>{
			1=>totals.get(1)/counter/10,
			2=>totals.get(2)/counter/10,
			3=>totals.get(3)/counter/10,
			4=>totals.get(4)/counter/10,
			5=>totals.get(5)/counter/10,
			6=>totals.get(6)/counter/10,
			7=>totals.get(7)/counter/10,
			8=>totals.get(8)/counter/10,
			9=>totals.get(9)/counter/10,
			10=>totals.get(10)/counter/10,
			11=>totals.get(11)/counter/10,
			12=>totals.get(12)/counter/10
		};
	}
	
	public static map<integer,decimal> NormalizeUsage(premises__c premise){
		WeatherizedUsage WU = new WeatherizedUsage(premise, 'gas');
		if (!WU.NormalizedUsage.isempty()){
			return WU.NormalizedUsage;
		}
		else{
			system.debug('No usage found');
			return getDefaultUsage(premise);  //grab all the usages in that city and property type and add it to the list
		}
	} 
	
	public static map<integer,decimal> NormalizeThisUsage(premises__c premise){
		WeatherizedUsage WU = new WeatherizedUsage(premise, 'gas');
		if (!WU.NormalizedUsage.isempty()){
			return WU.NormalizedUsage;
		}
		else{
			system.debug('No usage found');
			return getDefaultUsage(premise);  //grab all the usages in that city and property type and add it to the list
		}
	}
	
	public static list<premises__C> exactMatchServiceAddressGas(string address){
		list<string> strings =address.split(' ', 0);
		//Let's see if we have an apartment number.        
		  if ((strings[strings.size()-1].contains('0') ||            strings[strings.size()-1].contains('1') ||            strings[strings.size()-1].contains('2') ||
				strings[strings.size()-1].contains('3') ||             strings[strings.size()-1].contains('4') ||             strings[strings.size()-1].contains('5') ||
				strings[strings.size()-1].contains('6') ||            strings[strings.size()-1].contains('7') ||            strings[strings.size()-1].contains('8') ||
				strings[strings.size()-1].contains('9') ||            strings[strings.size()-1].contains('0') ) && strings.size()>2){
					
					string APTsearchquery='FIND\'' + strings[0] + ' ' + strings[1] + ' ' + strings[strings.size()-1]+'*\' IN ALL FIELDS  RETURNING Premises__c (Division__c, Program__c, SG_First_Name__c, SG_Last_Name__c, Premise_Type__c,id,Account_Number__c, Electric_Service_Address__c, Electric_Service_Address_City__c, Electric_Service_Address_Zip__c Where Record_Type_Name__c = \'Gas Choice Premise\' limit 25)';
					List<List<SObject>> APTsearchList=search.query(APTsearchquery);
					premises__c[] theAPTlist = ((List<premises__c>)APTsearchlist[0]);        
					return theAPTlist;
		  }
								 
		//if you're this far, there was no apartment number OR no matching address was found.    
		string searchquery='FIND\'' + address + '*\' IN ALL FIELDS  RETURNING Premises__c (Division__c, Program__c, SG_First_Name__c, SG_Last_Name__c, Premise_Type__c,id,Account_Number__c, Electric_Service_Address__c, Electric_Service_Address_City__c, Electric_Service_Address_State2__c, Electric_Service_Address_Zip__c Where Record_Type_Name__c = \'Gas Choice Premise\' limit 25)';
		system.debug('searchquery'+searchquery);
		List<List<SObject>>searchList=search.query(searchquery);
		premises__c[] thelist = ((List<premises__c>)searchlist[0]);
		if (thelist.size()==0){ //if no matches, broaden the query to
			list<string> streetnumber=address.split(' ', 0); //strip off the street number and first string at the front of the address and pull all the matches for given zip
			if(streetnumber.size()>1){
				searchquery='FIND\'' + streetnumber[0] + ' ' + streetnumber[1] + '*\' IN ALL FIELDS  RETURNING Premises__c (Division__c, Program__c, SG_First_Name__c, SG_Last_Name__c, Premise_Type__c,id,Account_Number__c, Electric_Service_Address__c, Electric_Service_Address_City__c, Electric_Service_Address_Zip__c Where Record_Type_Name__c = \'Gas Choice Premise\' limit 25)';
				searchList=search.query(searchquery);
				thelist = ((List<premises__c>)searchlist[0]);
				if (thelist.size()==0){ //if no matches, broaden the query to
					System.Debug('address'+address);
					streetnumber=address.split(' ', 0); //strip off the street number at the front of the address and pull all the matches for given zip
					System.Debug('streetnumber'+streetnumber);
					if (streetnumber[0].length()>1){ //to prevent the dreaded 1-character SOSL error
						searchquery='FIND\'' + streetnumber[0] + '*\' IN ALL FIELDS  RETURNING Premises__c (Division__c, Program__c, SG_First_Name__c, SG_Last_Name__c, Premise_Type__c,id,Account_Number__c, Electric_Service_Address__c, Electric_Service_Address_City__c, Electric_Service_Address_Zip__c Where Record_Type_Name__c = \'Gas Choice Premise\' limit 25)';
						searchList=search.query(searchquery);
						thelist = ((List<premises__c>)searchlist[0]);
					}
				}
			}
		}
		return thelist;
	}
		
	public static decimal getDiscount(premises__c thepremise, map<integer, decimal> usage){      
		boolean usageIsNotValid=false;
		if (thepremise.program__c == 'Ag') return 0; //no transportation reservation fee for Ag
			else system.debug(' it aint AG ');
		//check for empty usage, which would normally produce no capacity charges
		if (GasChoiceUtilities.getTotalUsage(usage) == 0 ){
			usageIsNotValid = true;
		}

		
		GasChoiceCalcInputs__c GCCI = GasChoiceCalcInputs__c.getOrgDefaults();
		
		//division-based capacity pricing
		if (GCCI.Capacity_pricing_methodology__c=='division') return getDiscount(thepremise);
		
		//otherwise, it's either premise or pin pricing.  Let's get the capacity cost table
		
		list<Pipeline_Point__c> PP= [select id,  Commercial_Peak_Month_Capacity_Cost_Dth__c, Residential_Capacity_Cost_per_Dth__c,
									 Total_demand_charge_for_Pin__c, Commercial_Peak_Day__c, Residential_Peak_Day__c, Industrial_Peak_Day_Capacity__c, Per_Dth_Allocated_Cost__c, Total_Use__c
							 from pipeline_point__c 
							 where SourceGas_Consolidated_Pin__c =: thepremise.pin__c];
		//null handling 
			if (GCCI.Peak_Month_1__c== null) GCCI.Peak_Month_1__c = 1;
			if (GCCI.Peak_Month_2__c== null) GCCI.Peak_Month_2__c = 2;
		
		if (usageIsNotValid || PP.isempty()){
			//fallback to the old version of the method with static pin costs
			return (getDiscount(thepremise));
		}
		//version 1 of pin-based capacity pricing...return the straight-up value off the PP table.
		if    (GCCI.Capacity_pricing_methodology__c=='pin' && thepremise.program__c=='Nebraska'){
			try{
				return pp[0].Per_Dth_Allocated_Cost__c;
			} catch (exception e){return 2;}
		} else if (GCCI.Capacity_pricing_methodology__c=='pin' && thepremise.program__c=='Wyoming'){
			try{return getDiscount(thepremise);}catch(exception e){system.debug('No Capacity cost found; returning 2'); return 2;}
		}
		
		
		//get most recent program year usage (no weatherizing, normalizing, etc since capacity is based off of most recent actuals!)
		list<annual_usage__c> AU = [select actual_mdq__c, January__c, February__c, March__c, April__c, May__c, June__c, 
									July__c, August__c, September__c, October__c, November__c, December__c, Premise_Usage_Sum__c
									from annual_usage__c 
									where 
									ignore__c != true
									and premise__r.id =: thepremise.id order by year__c DESC limit 1];

		decimal PeakMonthSumUsage=0;
		if (!AU.isempty()){
			if (GCCI.Peak_Month_1__c == 1 || GCCI.Peak_Month_2__c ==1) PeakMonthSumUsage = PeakMonthSumUsage+AU[0].January__c;
			if (GCCI.Peak_Month_1__c == 2 || GCCI.Peak_Month_2__c ==2) PeakMonthSumUsage = PeakMonthSumUsage+AU[0].February__c;
			if (GCCI.Peak_Month_1__c == 3 || GCCI.Peak_Month_2__c ==3) PeakMonthSumUsage = PeakMonthSumUsage+AU[0].March__c;
			if (GCCI.Peak_Month_1__c == 10 || GCCI.Peak_Month_2__c ==10) PeakMonthSumUsage = PeakMonthSumUsage+AU[0].October__c;        
			if (GCCI.Peak_Month_1__c == 11 || GCCI.Peak_Month_2__c ==11) PeakMonthSumUsage = PeakMonthSumUsage+AU[0].November__c;
			if (GCCI.Peak_Month_1__c == 12 || GCCI.Peak_Month_2__c ==12) PeakMonthSumUsage = PeakMonthSumUsage+AU[0].December__c;
		} else {
			PeakMonthSumUsage = usage.get(integer.valueof(GCCI.Peak_Month_1__c))*10 + usage.get(integer.valueof(GCCI.Peak_Month_1__c)*10); 
		}
		decimal peakMonthUsage=(PeakMonthSumUsage/2)/10;
		system.debug(LoggingLevel.ERROR, 'Peak Month Usage is  + ' + peakMonthUsage);

		decimal peakMonthCapacityCostTotal;
		if (thepremise.premise_type__c == 'RES'){
			if (peakMonthUsage==0 && !AU.isempty())  peakMonthUsage = AU[0].Premise_Usage_Sum__c/12; //kludge if there's usage but not in those months
			peakMonthCapacityCostTotal = peakMonthUsage*PP[0].Residential_Capacity_Cost_per_Dth__c;

		} else if (thepremise.premise_type__c == 'COM'){
			peakMonthCapacityCostTotal =  peakMonthUsage*PP[0].Commercial_Peak_Month_Capacity_Cost_Dth__c;        
		} else if (thepremise.premise_type__c == 'IND'){
			if (AU[0].actual_mdq__c == null) throw new CapacityCostException('Please add the MDQ to the most recent annual usage');
			peakMonthCapacityCostTotal = PP[0].Total_demand_charge_for_Pin__c*(AU[0].actual_mdq__c/(PP[0].Industrial_Peak_Day_Capacity__c+PP[0].Residential_Peak_Day__c+PP[0].Commercial_Peak_Day__c));
			//throw new CapacityCostException('We don\'t calculate dynamic prices for Industrial premises.  Please refer to CES administrator for quoting this customer');
		} else if(thepremise.premise_type__c == 'AGR' && thepremise.division__c =='Torrington'){
			//yes, there really is Torringon Ag.
			peakMonthCapacityCostTotal =  peakMonthUsage*PP[0].Commercial_Peak_Month_Capacity_Cost_Dth__c;
		} 

		else throw new CapacityCostException('The premise type is not valid (AGR, RES, COM or IND)');
		//spread the capacity cost total over the entire premise usage to get a per dec charge
		system.debug(LoggingLevel.ERROR, 'Total  Capacity Cost is + ' + peakMonthCapacityCostTotal);
		system.debug(LoggingLevel.ERROR, 'Total  Usage is ' + GasChoiceUtilities.getTotalUsage(usage));
		return (peakMonthCapacityCostTotal/GasChoiceUtilities.getTotalUsage(usage)) ;   
		
		system.debug('returning 2 because everything failed to complete');
		return 2;
	}
	
	public class CapacityCostException extends Exception {}
	
	public static decimal getDiscount(premises__c thepremise){      
		if (thepremise.program__c == 'Ag') return 0; //no transportation reservation fee for Ag
		system.debug(' it aint AG ');
		try{
			system.debug('returning actual pin cost');            
			return [select cost__c from PinCosts__c where name =: thepremise.pin__c][0].cost__c;
		}catch (exception e){ system.debug('########################################### Pin ' + thepremise.pin__c + ' not found');}
		try{
			system.debug('returning division pin cost');
			return [select cost__c from PinCosts__c where name =: thepremise.division__c][0].cost__c;
		}catch (exception e){}
		try{
			system.debug('returning program pin cost');
			return [select cost__c from PinCosts__c where name =: thepremise.program__c][0].cost__c;
		}catch (exception e){}
		try{
			system.debug('returning fallback');
			return [select cost__c from PinCosts__c where name =: 'Fallback'][0].cost__c;
		}catch (exception e){}
		system.debug('returning 2 because everything failed to complete');
		return 2;
	}
	
	public static decimal getDiscount(string division){
		system.debug('The division requested is ' + division);      
		if (division == 'Ag') return 0; //no transportation reservation fee for Ag
		system.debug(' it aint AG ');
		map<string, pinCosts__c> CapacityPricing =  pinCosts__c.getAll();
		try{
			//system.debug('returning division pin cost ' + [select cost__c from PinCosts__c where name =: division][0].cost__c);
			
			
			return CapacityPricing.get(division).cost__c;
		}catch (exception e){}        
		try{
			system.debug('returning fallback');
			return CapacityPricing.get('Fallback').cost__c;
		}catch (exception e){}
		system.debug('returning 2 because everything failed to complete');
		return 2;
	}
	
	public static date WhenDoesItStart(premises__c thepremise, string ProgramYear){
		date startdate;
		if (thepremise.program__c=='Ag'){
			startdate = date.parse('4/1/'+programYear);
			system.debug('Changed startdate to '+startdate);
		}
		else{
			startdate = date.parse('6/1/'+programYear);
			system.debug('Changed startdate to '+startdate);
		}
		if ( system.today().toStartOfMonth().addmonths(1) > startdate){
			startdate = system.today().toStartOfMonth().addmonths(1);
			system.debug('Changed startdate to '+startdate);
		}        
		return startdate;        
	}

	public static date WhenDoesItStart(boolean Ag, string ProgramYear){
		date startdate;
		if (Ag){
			startdate = date.parse('4/1/'+programYear);
			system.debug('Changed startdate to '+startdate);
		}
		else{
			startdate = date.parse('6/1/'+programYear);
			system.debug('Changed startdate to '+startdate);
		}
		if ( system.today().toStartOfMonth().addmonths(1) > startdate){
			startdate = system.today().toStartOfMonth().addmonths(1);
			system.debug('Changed startdate to '+startdate);
		}        
		return startdate;        
	}
	
	public static void CreatePositions(order__c oIn){        
		order__c o = [select id, program__c, rate__r.plan__r.Full_Requirements_Premium__c, confirmation_code_year__c, rate__r.fixed_rate__c, position_status__c, Smart_Bill_Quote__c,Choice_Multiyear_Continuation__c, Order_Status__c, 
				   premise__r.Location__Latitude__s, premise__r.Location__Longitude__s, premise__r.pin__c, rate__r.plan__r.rate_type__c, rate__r.plan__r.contract_length__c, rate__r.plan__r.margin_per_dth__c, rate__r.plan__r.id, rate__r.plan__r.name,  
				   rate__r.Index_reference__c, rate__r.name, rate__r.id, rate__r.confirmation_code__c, rate__r.Index_Rate_Percentage__c, rate__r.Fixed_Rate_Percentage__c,
				   premise__r.Consultant_Margin__c, Contract_Length__c, Premise__c,Account_Number__c, Confirmation_Code__c,
				   premise__r.id, premise__r.program__c, premise__r.division__c, premise__r.Electric_Service_Address_City__c, premise__r.Premise_Type__c,
					  rate__r.Index_Adder__c
				   from order__c
				   where id =: oIn.id];
		//continuation of previous order
			//get all orders for the same premise for previous confirmation code year.
		list<order__c> o1 = [select id, Choice_Multiyear_Continuation__c, Confirmation_Code__c
			from Order__c 
			where Premise__c=:o.Premise__c and confirmation_code_year__c = : string.valueof(integer.valueof(o.confirmation_code_year__c)-1)
			and confirmation_code__c =: o.confirmation_code__c and Account_Number__c =: o.Account_Number__c
			and rate__r.plan__r.contract_length__c >12 and id!=:o.id];
		if (!o1.isEmpty()){
			for (order__c thiso:o1){
				thiso.Choice_Multiyear_Continuation__c = true; //mark the continuation.  Not sure why there's be more than 1.
			}      
			update o1;    
			o.Position_Status__c = 'Created'; //or else it'll stay in pending status
			update o;
			return; //don't create any positions!
		} 
		//replacement
			//get all orders for the same premise for the same confirmation code year.
		list<order__c> o2 = [select id, Order_Status__c, Confirmation_Code__c
			from Order__c 
			where Premise__c=:o.Premise__c and confirmation_code_year__c = : o.confirmation_code_year__c and id!=:o.id];
		if (!o2.isEmpty()){
			for (order__c thiso:o2){
				thiso.Order_Status__c = 'Terminated Early'; //mark the termination
			}      
			update o2;    
		} 

		date startdate;
		startdate=GasChoiceUtilities.WhenDoesItStart(o.premise__r, o.confirmation_code_year__c);
		date enddate=startdate.addMonths(integer.valueof(o.Contract_Length__c)-1);
		system.debug('=============================================================== startdate is ' + startdate + ' and enddate is' + enddate);
		map<integer,decimal> usage = GasChoiceUtilities.NormalizeUsage(o.premise__r);  

		//if we're only doing the move-ins, this will blank the capacity charge portion of the costs!
		GasChoiceCalcInputs__c gcci = GasChoiceCalcInputs__c.getOrgDefaults();
		boolean IncludeCapacity = true;
		if (o.confirmation_code_year__c==gcci.Current_Program_Year__c){
			IncludeCapacity = false; system.debug('current program year.  will not include capacity costs');
		}
		
		map<string, map<date, decimal>> Costs = GasChoiceCalc2.getCosts2(o.premise__r, startdate, enddate); //gets everything including distrubtion       
		//query the pricing scenario, grab the "main financial basis"
		Pipeline_Scenario__c ps=GasChoiceCalc2.GetPS(o.premise__r);
		ID BasisOptionID = ps.Main_Financial_Basis__r.id;

		list<position__c> plist = new list<position__c>();

		for (date d:costs.get('NYMEX').keySet()){
			if (d > system.today()){
				system.debug('doing date  ======================================================================' + d);      
				system.debug('Adder: '+ Costs.get('TotalAdder').get(d));
				system.debug('DT_Basis__c: '+ Costs.get('Basis').get(d));
				system.debug('PhysicalPremiumToIndex: '+ Costs.get('PhysicalPremiumToIndex').get(d));
				system.debug('PLCommodity: '+ Costs.get('PLCommodity').get(d));
				system.debug('Capacity: '+ Costs.get('Capacity').get(d));
				system.debug('Fuel: '+ Costs.get('Fuel').get(d));
				system.debug('index adder: '+ o.rate__r.Index_Adder__c);
				system.debug('index ref: '+ o.rate__r.Index_reference__c);
				system.debug('volume: '+ Usage.get(d.Month()));


				position__c p = new position__c(NYMEX_lock__c=false, Basis_Lock__c=false, Customer_Price__c = (o.rate__r.Index_Adder__c*10).setscale(4), 
						Contract_Month__c = d, Order__c=o.id, Volume__c=Usage.get(d.Month()), Weatherized_Volume__c=Usage.get(d.Month()), Basis_Option__c=BasisOptionID, 
						Adder__c = Costs.get('TotalAdder').get(d), Balancing__c=0, Closed__c=false, Swing_Cost__c=0, 
						DT_Basis__c = Costs.get('Basis').get(d), DT_Basis_Physical__c = Costs.get('PhysicalPremiumToIndex').get(d),
						DT_NYMEX__c = 0, Fuel_Cost__c=Costs.get('Fuel').get(d), PL_Commodity__c = Costs.get('PLCommodity').get(d),
						PL_Demand__c = Costs.get('Capacity').get(d), Other_Charges__c=0
						);      
				//handling for adders, etc on cost for zero-usage months
				if (p.Volume__c==0) p.Volume__c=0.1;

				if (o.rate__r.plan__r.rate_type__c=='IndexNoSpread'){
				   plist.add(p);
				}
				if (o.rate__r.plan__r.rate_type__c=='Index' || o.rate__r.plan__r.rate_type__c=='SmartBlended' && (d.month()>5 && d.month()<11) ){
				   p.Other_Charges__c = p.Other_Charges__c + Costs.get('WholesaleAdjustment').get(d);
				   p.Adder__c = p.Adder__c + Costs.get('WholesaleAdjustment').get(d);
				   plist.add(p);
				}
				if (o.rate__r.plan__r.rate_type__c=='SmartBill'){
					list<decimal> taxFactor = GasChoiceUtilities.GetTaxFactor(o.Premise__r);
					p.NYMEX_lock__c=true;
					p.Basis_Lock__c=true;
					p.DT_NYMEX__c = Costs.get('NYMEX').get(d);
					p.Customer_Price__c = o.Smart_Bill_Quote__c/math.max(.1, usage.get(d.month()));  //you just lumped in distribution costs and taxes with the customer charge
					p.Adder__c = o.rate__r.plan__r.Full_Requirements_Premium__c + p.Adder__c + taxFactor[0]*Costs.get('TotalFixedCosts').get(d) + Costs.get('DistributionCosts').get(d); //so now we put those in the adder so that net is still margin
					plist.add(p);                    
				}
				if (o.rate__r.plan__r.rate_type__c=='SmartCap'){
					//p.Other_Charges__c = p.Other_Charges__c + Costs.get('WholesaleAdjustment').get(d);
					//p.Adder__c = p.Adder__c + Costs.get('WholesaleAdjustment').get(d);
					//plist.add(p);
					//do something about those caps!
				}
				if (o.rate__r.plan__r.rate_type__c=='SmartFixed' || o.rate__r.plan__r.rate_type__c=='Fixed'){
					p.NYMEX_lock__c=true;
					p.Basis_Lock__c=true;
					p.DT_NYMEX__c = Costs.get('NYMEX').get(d);
					p.Customer_Price__c = (o.rate__r.Fixed_Rate__c*10).setscale(4);
					if (o.rate__r.plan__r.rate_type__c=='SmartFixed'){
						p.Adder__c = p.Adder__c + Costs.get('DPAperDth').get(d)*o.Rate__r.Index_Rate_Percentage__c/100; //putting the DPA cost into the adder
					}
					plist.add(p);
				}
				if (o.rate__r.plan__r.rate_type__c=='SmartBlended' && !(d.month()>5 && d.month()<11)){
					p.NYMEX_lock__c=true;
					p.Basis_Lock__c=true;
					p.DT_NYMEX__c = Costs.get('NYMEX').get(d);
					p.Customer_Price__c = (o.rate__r.Fixed_Rate__c*10).setscale(4);
					plist.add(p);
				}
				if (o.rate__r.plan__r.rate_type__c=='Blended'){
					//make two positions for the 2nd segment;
					
					position__c pFixed = p.clone(false, true, false, false);
					position__c pIndex = p.clone(false, true, false, false);

					pIndex.Volume__c = p.Volume__c*o.Rate__r.Index_Rate_Percentage__c/100; //Index
					p.Other_Charges__c = p.Other_Charges__c + Costs.get('WholesaleAdjustment').get(d);
					p.Adder__c = p.Adder__c + Costs.get('WholesaleAdjustment').get(d);
					plist.add(pIndex);

					pFixed.NYMEX_lock__c=true;
					pFixed.Basis_Lock__c=true;
					p.DT_NYMEX__c = Costs.get('NYMEX').get(d);
					pFixed.Customer_Price__c = (o.rate__r.Fixed_Rate__c*10).setscale(4);
					pFixed.Volume__c=p.Volume__c*o.Rate__r.Fixed_Rate_Percentage__c/100;
					plist.add(pFixed);

				}
				
				
			}
			
		}
		//now, all the WACGO stuff
		position__c WACOGPosition = makeWACOGPosition(plist);
		for (position__c p:plist){
			p.Nymex_Wacog__c = WACOGPosition.DT_NYMEX__c;
			p.Basis_F_Wacog__c = WACOGPosition.DT_Basis__c;
			p.Basis_P_Wacog__c = WACOGPosition.DT_Basis_Physical__c;
			p.Customer_PriceWACOG__c = WACOGPosition.Customer_Price__c;
			p.AdderWACOG__c = WACOGPosition.Adder__c;
			p.BalancingWACOG__c = WACOGPosition.Balancing__c;
			p.Fuel_Cost_Wacog__c = WACOGPosition.Fuel_Cost__c;
			p.PL_Commodity_Wacog__c = WACOGPosition.PL_Commodity__c;
			p.PL_Demand_Wacog__c = WACOGPosition.PL_Demand__c;
			p.Swing_Cost_Wacog__c = WACOGPosition.Swing_Cost__c;

		}

		//now, get the total volume for the sale and the first/last fixed positions
		decimal totalVolume=0;
		date FirstFixedDate; date LastFixedDate;

		for (position__c p:plist){
			if (p.NYMEX_lock__c && p.Basis_Lock__c) totalVolume=totalVolume+p.Volume__c;
			if (FirstFixedDate==null || p.Contract_Month__c <  FirstFixedDate) FirstFixedDate = p.Contract_Month__c;
			if (LastFixedDate==null ||  p.Contract_Month__c > LastFixedDate  ) LastFixedDate = p.Contract_Month__c;
		}

		system.debug('Position List is ======================================================================' + plist);
		insert plist;
		o.Position_Status__c = 'Created'; 
		o.Total_Fixed_Volume__c=totalVolume; 
		o.Earliest_Fixed_Position__c=FirstFixedDate;
		o.Last_Fixed_Position__c=LastFixedDate;
		update o;
	}
	
	public static SmartBill_Index__c LoadTheSBI (premises__c thepremise){
		return  [select id, Index_1__r.name, Index_1__r.index_cost__c, Index_1_Percentage__c, 
								  Index_2__r.name, Index_2__r.index_cost__c,Index_2_Percentage__c, 
								  Index_3__r.name, Index_3__r.index_cost__c,Index_3_Percentage__c,  
								  Fuel_Gross_Up__c, Transport_Cost__c, Transport_Reservation_Fee__c,Wholesale_Cost_Adjustment__r.name,Storage_Cost__c,
								  Dist_Fixed_Monthly_30000__c, Dist_Fixed_Monthly_5000_or_less__c, Dist_Fixed_Monthly_5001_to_30000__c,
								  Dist_per_Therm_30000__c, Dist_per_Therm_5000_or_less__c, Dist_per_Therm_5001_to_30000__c,
								  Above_threshold_cost__c, Below_threshold_distribution_cost__c, Nebraska_Dist_Fixed__c, Nebraska_Distribution_Threshhold__c, 
								  Above_threshold_cost_COM__c, Below_threshold_distribution_cost_COM__c, Nebraska_COM_Dist_Fixed__c, Nebraska_COM_Distribution_Threshhold__c,
								  Tax_Factor__c, Monthly_Supplier_Fee__c, minimum_annual_usage__c, maximum_annual_usage__c
				 from SmartBill_Index__c 
				 where Program__c =: thepremise.program__c and (program__c = 'Ag' or division__c =:thepremise.division__c)];
	}
	
	public static list<SmartBill_Index__c> LoadTheSBIs (list<premises__c> thepremises){
		set<string> Divisions = new set<string>();
		set<string> Programs = new set<string>();
		for (premises__c p:thepremises){
			Divisions.add(p.division__c);
			Programs.add(p.program__c);
		}
		return  [select id, Index_1__r.name, Index_1__r.index_cost__c, Index_1_Percentage__c, 
								  Index_2__r.name, Index_2__r.index_cost__c,Index_2_Percentage__c, 
								  Index_3__r.name, Index_3__r.index_cost__c,Index_3_Percentage__c,  
								  Fuel_Gross_Up__c, Transport_Cost__c, Transport_Reservation_Fee__c,Wholesale_Cost_Adjustment__r.name,Storage_Cost__c,
								  Dist_Fixed_Monthly_30000__c, Dist_Fixed_Monthly_5000_or_less__c, Dist_Fixed_Monthly_5001_to_30000__c,
								  Dist_per_Therm_30000__c, Dist_per_Therm_5000_or_less__c, Dist_per_Therm_5001_to_30000__c,
								  Above_threshold_cost__c, Below_threshold_distribution_cost__c, Nebraska_Dist_Fixed__c, Nebraska_Distribution_Threshhold__c, 
								  Above_threshold_cost_COM__c, Below_threshold_distribution_cost_COM__c, Nebraska_COM_Dist_Fixed__c, Nebraska_COM_Distribution_Threshhold__c,
								  Tax_Factor__c, Monthly_Supplier_Fee__c, minimum_annual_usage__c, maximum_annual_usage__c
				 from SmartBill_Index__c 
				 where Program__c in: Programs and (program__c = 'Ag' or division__c in: divisions)];
	}
	
	
	
	public static list<decimal> getTaxFactor(premises__c thepremise){
		list<Sales_Tax_Rate__c> STR = [select combined_Tax_Rate__c, Unit_of_Measure__c, Franchise_Fees__c from Sales_Tax_Rate__c where City_Name__c =:thepremise.Electric_Service_Address_City__c order by combined_Tax_Rate__c DESC limit 1];
		list<decimal> output=new list<Decimal>();               
		if (STR.isempty()){output.add(0.07); output.add(0.01); return output;}

		if (STR[0].Franchise_Fees__c == null) {output.add(STR[0].combined_Tax_Rate__c/100); output.add(0);}
		else if (STR[0].Unit_of_Measure__c == 'Percentage') { output.add(STR[0].combined_Tax_Rate__c/100 + STR[0].Franchise_Fees__c); output.add(0);}
		else if (STR[0].Unit_of_Measure__c == 'Therms') { output.add(STR[0].combined_Tax_Rate__c/100); output.add(STR[0].Franchise_Fees__c/10);}
		system.debug('Tax Factor is ' + output);
		return output;
	}
	
	public static map<string, map<date, decimal>> getStrips(list<string> indices){
		map<string, map<date, decimal>> output = new map<string, map<date, decimal>>();
		for (string s:indices){
			output.put(s, new map<date, decimal>{});
		}
		
		list<index_future__c> IndexFutures = [select id, name, delivery_date__c, index__r.name, price__c
												from index_future__c
												where index__r.name in: indices 
												and delivery_date__c>:system.today() 
												and delivery_date__c<:system.today().addmonths(36)
												order by index__r.name ASC, delivery_date__c ASC];
		for (index_future__c IndexFuture:IndexFutures){            
			output.get(IndexFuture.index__r.name).put(IndexFuture.delivery_date__c,indexFuture.price__c);
		}
		
		system.debug(logginglevel.Error, 'Output is ' + output);
		return output;
	}
	
	public static map<string, map<date, decimal>> getStrips(list<string> indices, boolean AddCosts){
		map<string, map<date, decimal>> output = new map<string, map<date, decimal>>();
		for (string s:indices){
			output.put(s, new map<date, decimal>{});
		}
		
		list<index_future__c> IndexFutures = [select id, name, delivery_date__c, index__r.name, price__c,
											  index__r.index_cost__c
												from index_future__c
												where index__r.name in: indices 
												and delivery_date__c>:system.today() 
												and delivery_date__c<:system.today().addmonths(36)
												order by index__r.name ASC, delivery_date__c ASC];
		for (index_future__c IndexFuture:IndexFutures){       
			if (AddCosts && IndexFuture.index__r.index_cost__c!=null){
				output.get(IndexFuture.index__r.name).put(IndexFuture.delivery_date__c,(indexFuture.price__c+IndexFuture.index__r.index_cost__c));
			}
			else{
				output.get(IndexFuture.index__r.name).put(IndexFuture.delivery_date__c,indexFuture.price__c);
			}
		}
		
		system.debug(logginglevel.Error, 'Output is ' + output);
		return output;
	}
	
	
	public static map<string, map<date, decimal>> getStrips(list<string> indices, boolean AddCosts, date startdate, date enddate){
		map<string, map<date, decimal>> output = new map<string, map<date, decimal>>();
		for (string s:indices){
			output.put(s, new map<date, decimal>{});
		}
		
		list<index_future__c> IndexFutures = [select id, name, delivery_date__c, index__r.name, price__c,
											  index__r.index_cost__c
												from index_future__c
												where index__r.name in: indices 
												and delivery_date__c>=:startdate
												and delivery_date__c<=:enddate
												order by index__r.name ASC, delivery_date__c ASC];
		for (index_future__c IndexFuture:IndexFutures){       
			if (AddCosts && IndexFuture.index__r.index_cost__c!=null){
				output.get(IndexFuture.index__r.name).put(IndexFuture.delivery_date__c,(indexFuture.price__c+IndexFuture.index__r.index_cost__c));
			}
			else{
				output.get(IndexFuture.index__r.name).put(IndexFuture.delivery_date__c,indexFuture.price__c);
			}
		}
		
		system.debug(logginglevel.Error, 'Output is ' + output);
		return output;
	}
	
	public static void MakeMonthlyUsageOffSourceGasAnnual(id FL){
		list<monthly_usage__c> MUs = new list<monthly_usage__c>();
		list<annual_usage__c> AUs = [select id, April__c, August__c, December__c,February__c, January__c, July__c, June__c,
									 March__c, May__c, November__c, October__c, Premise__c, Premise__r.id, Year__c, September__c
									 from annual_usage__c where premise__r.facility_list__r.id =: FL];
		for (annual_usage__c AU:AUs){
			system.debug(AU);
			
			try{
				MUs.add(new monthly_usage__c(estimated__c=false, Start_Date__c=date.newInstance(integer.valueof(au.Year__c), 1, 1), Premise__c=au.Premise__r.id, Usage__c=au.January__c/10));
			}catch (exception e){
				MUs.add(new monthly_usage__c(Start_Date__c=date.newInstance(integer.valueof(au.Year__c), 1, 1), Premise__c=au.Premise__r.id, Usage__c=0));
			}
			try{
				MUs.add(new monthly_usage__c(estimated__c=false, Start_Date__c=date.newInstance(integer.valueof(au.Year__c), 2, 1), Premise__c=au.Premise__r.id, Usage__c=au.February__c/10));
			}catch (exception e){
				MUs.add(new monthly_usage__c(Start_Date__c=date.newInstance(integer.valueof(au.Year__c), 2, 1), Premise__c=au.Premise__r.id, Usage__c=0));
			}
			try{
				MUs.add(new monthly_usage__c(estimated__c=false, Start_Date__c=date.newInstance(integer.valueof(au.Year__c), 3, 1), Premise__c=au.Premise__r.id, Usage__c=au.March__c/10));
			}catch (exception e){
				MUs.add(new monthly_usage__c(Start_Date__c=date.newInstance(integer.valueof(au.Year__c), 3, 1), Premise__c=au.Premise__r.id, Usage__c=0));
			}
			try{
				MUs.add(new monthly_usage__c(estimated__c=false, Start_Date__c=date.newInstance(integer.valueof(au.Year__c), 4, 1), Premise__c=au.Premise__r.id, Usage__c=au.April__c/10));
			}catch (exception e){
				MUs.add(new monthly_usage__c(Start_Date__c=date.newInstance(integer.valueof(au.Year__c), 4, 1), Premise__c=au.Premise__r.id, Usage__c=0));
			}
			try{
				MUs.add(new monthly_usage__c(estimated__c=false, Start_Date__c=date.newInstance(integer.valueof(au.Year__c), 5, 1), Premise__c=au.Premise__r.id, Usage__c=au.May__c/10));
			}catch (exception e){
				MUs.add(new monthly_usage__c(Start_Date__c=date.newInstance(integer.valueof(au.Year__c), 5, 1), Premise__c=au.Premise__r.id, Usage__c=0));
			}
			try{
				MUs.add(new monthly_usage__c(estimated__c=false, Start_Date__c=date.newInstance(integer.valueof(au.Year__c), 6, 1), Premise__c=au.Premise__r.id, Usage__c=au.June__c/10));
			}catch (exception e){
				MUs.add(new monthly_usage__c(Start_Date__c=date.newInstance(integer.valueof(au.Year__c), 6, 1), Premise__c=au.Premise__r.id, Usage__c=0));
			}
			try{
				MUs.add(new monthly_usage__c(estimated__c=false, Start_Date__c=date.newInstance(integer.valueof(au.Year__c), 7, 1), Premise__c=au.Premise__r.id, Usage__c=au.July__c/10));
			}catch (exception e){
				MUs.add(new monthly_usage__c(Start_Date__c=date.newInstance(integer.valueof(au.Year__c), 7, 1), Premise__c=au.Premise__r.id, Usage__c=0));
			}
			try{
				MUs.add(new monthly_usage__c(estimated__c=false, Start_Date__c=date.newInstance(integer.valueof(au.Year__c), 8, 1), Premise__c=au.Premise__r.id, Usage__c=au.August__c/10));
			}catch (exception e){
				MUs.add(new monthly_usage__c(Start_Date__c=date.newInstance(integer.valueof(au.Year__c), 8, 1), Premise__c=au.Premise__r.id, Usage__c=0));
			}
			try{
				MUs.add(new monthly_usage__c(estimated__c=false, Start_Date__c=date.newInstance(integer.valueof(au.Year__c), 9, 1), Premise__c=au.Premise__r.id, Usage__c=au.September__c/10));
			}catch (exception e){
				MUs.add(new monthly_usage__c(Start_Date__c=date.newInstance(integer.valueof(au.Year__c), 9, 1), Premise__c=au.Premise__r.id, Usage__c=0));
			}
			try{
				MUs.add(new monthly_usage__c(estimated__c=false, Start_Date__c=date.newInstance(integer.valueof(au.Year__c), 10, 1), Premise__c=au.Premise__r.id, Usage__c=au.October__c/10));
			}catch (exception e){
				MUs.add(new monthly_usage__c(Start_Date__c=date.newInstance(integer.valueof(au.Year__c), 10, 1), Premise__c=au.Premise__r.id, Usage__c=0));
			}
			try{
				MUs.add(new monthly_usage__c(estimated__c=false, Start_Date__c=date.newInstance(integer.valueof(au.Year__c), 11, 1), Premise__c=au.Premise__r.id, Usage__c=au.November__c/10));
			}catch (exception e){
				MUs.add(new monthly_usage__c(Start_Date__c=date.newInstance(integer.valueof(au.Year__c), 11, 1), Premise__c=au.Premise__r.id, Usage__c=0));
			}
			try{
				MUs.add(new monthly_usage__c(estimated__c=false, Start_Date__c=date.newInstance(integer.valueof(au.Year__c), 12, 1), Premise__c=au.Premise__r.id, Usage__c=au.December__c/10));
			}catch (exception e){
				MUs.add(new monthly_usage__c(Start_Date__c=date.newInstance(integer.valueof(au.Year__c), 12, 1), Premise__c=au.Premise__r.id, Usage__c=0));
			}           
		}
		insert MUs;
	}

	public static position__c makeWACOGPosition(list<position__c> ps){
		map<date, decimal> weightFactors = new map<date, decimal>();
		decimal totalVolume = 0;
		position__c  WACOGPosition = new position__c(Other_Charges__c=0, Adder__c=0, Balancing__c=0, Customer_Price__c=0, DT_Basis__c=0, DT_NYMEX__c=0, DT_Basis_Physical__c=0, Volume__c=0, Weatherized_Volume__c=0,
									   Fuel_Cost__c=0, historical_volume__c=0, PL_Commodity__c=0, PL_Demand__c=0, Swing_Cost__c=0, Temp_BL__c=0, Temp_NL__c=0);
		for (position__c p:ps){ //loop through the positions to get total volume
			totalVolume=totalVolume + Math.abs(p.Volume__c);
			try{WACOGPosition.Temp_BL__c = WACOGPosition.Temp_BL__c + p.Temp_BL__c;}catch(exception e) {WACOGPosition.Temp_BL__c=0;}
			try{WACOGPosition.Temp_NL__c = WACOGPosition.Temp_NL__c + p.Temp_NL__c;}catch(exception e) {WACOGPosition.Temp_NL__c=0;}
		}
		for (position__c p:ps){ //loop through the positions to get volume weighting factors
			decimal weightFactor=0;
			try{ weightFactor=Math.abs(p.volume__c)/totalVolume;} catch(exception e){} //safe becasue we set it to zero initially
			WACOGPosition = ApplyWeightFactor(WACOGPosition, p, weightFactor);
		}
		return WACOGPosition;
	}

	public static list<position__c> makeWACOGPositionsByMonth(list<position__c> ps){
		map<date, position__c> WacogOutput = new map<date, position__c>();
		map<date, decimal> MonthVolumeTree = new map<date, decimal>();
		///gets the total volume for weight factoring
		for (position__c p:ps){ //what's the total volume by month?
			//does the month exist already in the tree?
			if (MonthVolumeTree.get(p.Contract_Month__c)!=null)  {
				MonthVolumeTree.put(p.Contract_Month__c, MonthVolumeTree.get(p.Contract_Month__c)+Math.abs(p.Volume__c)); //if there's already a value, just add the new one
			} else { //if the map node didn't already exist
				MonthVolumeTree.put(p.Contract_Month__c, Math.abs(p.Volume__c));
			}
		}


		for (position__c p:ps){ //loop through the positions and wacog them as the % of that month's usage
			decimal weightfactor = Math.abs(p.Volume__c)/MonthVolumeTree.get(p.Contract_Month__c); //what is that position's percent of that month's total volume?
			WacogOutput.put(p.Contract_Month__c, ApplyWeightFactor(WacogOutput.get(p.Contract_Month__c), p, weightfactor)); //now increment the weighted average
		}

		return WacogOutput.values();
	}

	public static position__c ApplyWeightFactor(position__c RunningTotalPosition, position__c positionToWeight, decimal weightFactor){
		//init a position to prevent nulls on anything we don't calculate here
		position__c  output = new position__c(Other_Charges__c=0, Adder__c=0, Balancing__c=0, Customer_Price__c=0, DT_Basis__c=0, DT_NYMEX__c=0, DT_Basis_Physical__c=0, Volume__c=0, Weatherized_Volume__c=0,
									   Fuel_Cost__c=0, historical_volume__c=0, PL_Commodity__c=0, PL_Demand__c=0, Swing_Cost__c=0, Temp_BL__c=0, Temp_NL__c=0, hedged_volume__c=0);

		//null handling stuff
		if (positionToWeight.Other_Charges__c == null) positionToWeight.Other_Charges__c=0;
		if (positionToWeight.DT_Basis_Physical__c == null) positionToWeight.DT_Basis_Physical__c=0;
		if (positionToWeight.Balancing__c == null) positionToWeight.Balancing__c=0;
		if (positionToWeight.DT_Basis_Physical__c == null) positionToWeight.DT_Basis_Physical__c=0;

		if (positionToWeight.Customer_Price__c == null) positionToWeight.Customer_Price__c=0;
		if (positionToWeight.DT_Basis__c == null) positionToWeight.DT_Basis__c=0;
		if (positionToWeight.Adder__c == null) positionToWeight.Adder__c=0;
		if (positionToWeight.DT_NYMEX__c == null) positionToWeight.DT_NYMEX__c=0;
		if (positionToWeight.Volume__c == null) positionToWeight.Volume__c=0;
		if (positionToWeight.Weatherized_Volume__c == null) positionToWeight.Weatherized_Volume__c=0;
		if (positionToWeight.Fuel_Cost__c == null) positionToWeight.Fuel_Cost__c=0;
		if (positionToWeight.historical_volume__c == null) positionToWeight.historical_volume__c=0;
		if (positionToWeight.PL_Commodity__c == null) positionToWeight.PL_Commodity__c=0;
		if (positionToWeight.PL_Demand__c == null) positionToWeight.PL_Demand__c=0;
		if (positionToWeight.Swing_Cost__c == null) positionToWeight.Swing_Cost__c=0;

		if (RunningTotalPosition!=null){
			output.Other_Charges__c = (RunningTotalPosition.Other_Charges__c + positionToWeight.Other_Charges__c * weightFactor).setscale(4);
			output.Adder__c = (RunningTotalPosition.Adder__c + (positionToWeight.Adder__c + positionToWeight.DT_Basis_Physical__c)  * weightFactor).setscale(4);
			output.Balancing__c = (RunningTotalPosition.Balancing__c + positionToWeight.Balancing__c * weightFactor).setscale(4);
			output.Customer_Price__c = (RunningTotalPosition.Customer_Price__c + positionToWeight.Customer_Price__c * weightFactor).setscale(4);
			output.DT_Basis__c = (RunningTotalPosition.DT_Basis__c + positionToWeight.DT_Basis__c * weightFactor).setscale(4);
			output.DT_Basis_Physical__c = (RunningTotalPosition.DT_Basis_Physical__c + positionToWeight.DT_Basis_Physical__c * weightFactor).setscale(4);
			output.DT_NYMEX__c = (RunningTotalPosition.DT_NYMEX__c + positionToWeight.DT_NYMEX__c * weightFactor).setscale(4);
			output.Volume__c = (RunningTotalPosition.Volume__c + positionToWeight.Volume__c).setscale(0); //don't add anything since we already added it earlier
			try{output.Weatherized_Volume__c = (RunningTotalPosition.Weatherized_Volume__c + positionToWeight.Weatherized_Volume__c).setscale(0);}catch(exception e){}
			output.Fuel_Cost__c = (RunningTotalPosition.Fuel_Cost__c + positionToWeight.Fuel_Cost__c * weightFactor).setscale(4);
			try{output.historical_volume__c = (RunningTotalPosition.historical_volume__c + positionToWeight.historical_volume__c).setscale(0);}catch(exception e){}
			output.PL_Commodity__c = (RunningTotalPosition.PL_Commodity__c + positionToWeight.PL_Commodity__c * weightFactor).setscale(4);
			output.PL_Demand__c = (RunningTotalPosition.PL_Demand__c + positionToWeight.PL_Demand__c * weightFactor).setscale(4);
			output.Swing_Cost__c = (RunningTotalPosition.Swing_Cost__c + positionToWeight.Swing_Cost__c * weightFactor).setscale(4);
		} else{ //nothing there, so we just do the weight on the one that we have

			output.Other_Charges__c = (positionToWeight.Other_Charges__c * weightFactor).setscale(4);
			output.Adder__c = ((positionToWeight.Adder__c + positionToWeight.DT_Basis_Physical__c) * weightFactor).setscale(4);
			output.Balancing__c = (positionToWeight.Balancing__c * weightFactor).setscale(4);
			output.Customer_Price__c = (positionToWeight.Customer_Price__c * weightFactor).setscale(4);
			output.DT_Basis__c = (positionToWeight.DT_Basis__c * weightFactor).setscale(4);
			output.DT_Basis_Physical__c = (positionToWeight.DT_Basis_Physical__c * weightFactor).setscale(4);
			output.DT_NYMEX__c = (positionToWeight.DT_NYMEX__c * weightFactor).setscale(4);
			output.Volume__c = (positionToWeight.Volume__c).setscale(0);
			output.Weatherized_Volume__c = (positionToWeight.Weatherized_Volume__c).setscale(0);
			output.Fuel_Cost__c = (positionToWeight.Fuel_Cost__c * weightFactor).setscale(4);
			output.historical_volume__c = (positionToWeight.historical_volume__c).setscale(0);
			output.PL_Commodity__c = (positionToWeight.PL_Commodity__c * weightFactor).setscale(4);
			output.PL_Demand__c = (positionToWeight.PL_Demand__c * weightFactor).setscale(4);
			output.Swing_Cost__c = (positionToWeight.Swing_Cost__c * weightFactor).setscale(4);
		}
		output.Contract_Month__c = positionToWeight.Contract_Month__c;
		return output;
	}

	public static list<plan__c> GetPlansByPremise(Premises__c thepremise, string ProgramYear){
		return [select id, name, Margin_per_Dth__c, Full_Requirements_Premium__c, rate_type__c, SG_Pricing_Resolution_Primary_Th__c, SG_Pricing_Resolution_Secondary_Th__c, contract_length__c, Plan_Description__c
			from plan__c 
			where REP_Profile__r.name = 'CenterPoint Energy Services' and active__c = true and recordtypeid = '012300000018Sz7'
			and id in (
				select plan__c from rate__c
				where SG_Available_for_Dynamic__c = true                
				and recordtypeid='012300000018Sz8'
				and confirmation_code_year__c =: programyear
				and 
				(
					(Program__c =: thepremise.Program__c and Division__c =: thepremise.Division__c)
					 or
					 (Program__c =: thepremise.Program__c and Program__c = 'Ag')
					 or
					 (Program__c =: thepremise.Program__c and Program__c='Nebraska' and Division__c ='Default')
				)
			)
		];

	}

	//will only return fixed or indexed.  This is for high-level price estimates.
	public static list<plan__c> GetFewerPlansByPremise(Premises__c thepremise, string ProgramYear){
		return [select id, name, Margin_per_Dth__c, Full_Requirements_Premium__c, rate_type__c, SG_Pricing_Resolution_Primary_Th__c, SG_Pricing_Resolution_Secondary_Th__c, contract_length__c, Plan_Description__c
			from plan__c 
			where REP_Profile__r.name = 'CenterPoint Energy Services' and active__c = true and recordtypeid = '012300000018Sz7'
			and (rate_type__c='Fixed' or rate_type__c='Index')
			and Contract_Length__c=12
			and id in (
				select plan__c from rate__c
				where SG_Available_for_Dynamic__c = true
				and recordtypeid='012300000018Sz8'
				and confirmation_code_year__c =: programyear
				and 
				(
					(Program__c =: thepremise.Program__c and Division__c =: thepremise.Division__c)
					 or
					 (Program__c =: thepremise.Program__c and Program__c = 'Ag')
					 or
					 (Program__c =: thepremise.Program__c and Program__c='Nebraska' and Division__c ='Default')
				)
			)
		];

	}

	public static Premises__c getPremiseDetailsById(string searchId){
		return [select id, Program__c, Zone__c, Division__c, Location__Latitude__s, Location__Longitude__s, Consultant_Margin__c, 
					  Account_Number__c,Balloted__c, Gas_Premise_Number__c, Meter_Number__c, Meter_Read_Cycle__c,
					  Pin__c, PointD__c, Premise_Type__c, annual_usage__c, Electric_Service_Address_City__c,
					  SG_Account_Name__c, SG_Customer_Number__c, SG_DBA_Name__c, SG_First_Name__c, SG_Last_Name__c, 
					  SG_Mailing_Address__c, SG_Mailing_City_State__c, SG_Mailing_Zip_Code__c, SG_Second_Name__c, SG_Telephone__c
					  from premises__c where id =:searchId];  
	}

	public static void LiquidateFutureChoicePositions(string orderid){
		list<position__c> plist = [select id, Closed__c, Adder__c, AdderWACOG__c, Balancing__c, BalancingWACOG__c, Basis_Option_Financial__c,Basis_Option__c,
		Basis_F_Wacog__c, Basis_Lock__c, Basis_P_Wacog__c, Contract_Month__c, Customer_Price__c, 
		Customer_PriceWACOG__c, Deal_Ticket__c, DT_Basis__c, DT_Basis_Physical__c, DT_NYMEX__c, Fuel_Cost__c, Fuel_Cost_Wacog__c, Fuel_only_nymex_memory__c, Hedged_Volume__c, historical_volume__c, Notes__c,
		NYMEX_lock__c, Nymex_Wacog__c, Order__c, Other_Charges__c, PL_Commodity__c, PL_Commodity_Wacog__c, PL_Demand__c, PL_Demand_Wacog__c, Swing_Cost__c, Swing_Cost_Wacog__c, Volume__c, Weatherized_Volume__c
		from position__c 
		where Order__c =: orderid and Contract_Month__c>:system.today()];
		list<position__c> newps = new list<position__c>();
		for (position__c p:plist){
			if (p.Closed__c && p.NYMEX_lock__c && p.Basis_Lock__c){ //if it's closed, then we'll make an offsetting position
					position__c newp = p.clone();
					newp.Closed__c = false;
					newp.Volume__c = newp.Volume__c*-1;
					newp.Hedged_Volume__c = newp.Hedged_Volume__c*-1;
					newps.add(newp);
				} else{ //if it's not closed, we'll zero it out and close it.
					p.Volume__c = 0;
					p.Hedged_Volume__c = 0;
					p.Closed__c = true;
				}            
		}
		update plist;
		insert newps;
	}
}