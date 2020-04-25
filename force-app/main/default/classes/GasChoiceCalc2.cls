public class GasChoiceCalc2{
	
	public static list<GasChoiceOffer> getAvailableOffersDynamicWideOPen(premises__c thepremise, string programYear, boolean ShowAll){
		system.debug('Program year is ' + programyear);
		//what rates are available?
		list<plan__c> PlanOptions = GasChoiceUtilities.GetPlansByPremise(thepremise, programyear);
		
		system.debug('>>>' + planoptions);
		system.debug('>>> Gonna Work ' + planoptions.size());
		
		//What time period are we talking about?
		date startdate = GasChoiceUtilities.WhenDoesItStart(thepremise, programYear);
		date enddate = startdate.addmonths(23);
		system.debug('Startdate is ' + startdate + ' and enddate is ' + enddate);
		//use that to calculate the base per unit supply costs for the following for 24 months out:        
		map<integer,decimal> usage = GasChoiceUtilities.NormalizeUsage(thepremise);
		
		//if we're only doing the move-ins, this will blank the capacity charge portion of the costs!
		
		
		map<string, map<date, decimal>> Costs = GasChoiceCalc2.getCosts2(thepremise, startdate, enddate); //gets everything including distrubtion
		
		//if there are smartBill plans, verify that the customer can have a smartbill with the usage given.  If not, remove it from the list.
		if (thepremise.program__c == 'Ag' || !SmartBillUtilities.SmartBillTests3(usage, thepremise)){            
			planOptions = SmartBillUtilities.removeSmartBills(planOptions);
		} else {system.debug('SmartBill test passed!');}
		
		map<plan__c, map<string, decimal>> customerCosts = GasChoiceCalc2.getPlanCosts(thepremise, Costs, usage, planoptions);           
		//for each plan, add the margin, go through rates,  and find the closest matches
		//list<GasChoiceOffer2> results = new list<GasChoiceOffer2>();
		list<GasChoiceOffer> results = GasChoiceDynamicRatePicker.getResultsWideOpen(thepremise, customerCosts, usage, programYear);
		system.debug(results);  

		try{
			list<GasChoiceOffer> SCresults=SmartCaps.GetOffers(startdate, enddate, thePremise, Costs, CustomerCosts, Usage, ProgramYear, PlanOptions);
			system.debug(SCresults);  
			results.addAll(SCresults);
		} catch (exception e){
			system.debug(e.getStackTraceString());
		}
		//build offer structure to return for screen
		results.sort();
		results=GasChoiceDynamicRatePicker.AddIndexes(results);
		
		if (!ShowAll){//web pricing
			results=GasChoiceDynamicRatePicker.ReturnOnlyHighestOne(results);
		}

		      
		
		return results;
		
		
		
		
		return null;
	}


	public static void JustGetCosts(string premId){


		Premises__c thepremise = GasChoiceUtilities.getPremiseDetailsById(premId);

		GasChoiceCalcInputs__c gcci = GasChoiceCalcInputs__c.getOrgDefaults();

        string programyear = gcci.Next_Program_Year__c;

		system.debug('Program year is ' + programyear);
		//what rates are available?

		//let's not do anything besides the 1Y fixed and 1Y index
		list<plan__c> PlanOptions = GasChoiceUtilities.GetFewerPlansByPremise(thepremise, programyear);

		
		//What time period are we talking about?
		date startdate = GasChoiceUtilities.WhenDoesItStart(thepremise, programYear);
		date enddate = startdate.addmonths(11);
		system.debug('Startdate is ' + startdate + ' and enddate is ' + enddate);
		//use that to calculate the base per unit supply costs for the following for 24 months out:        
		map<integer,decimal> usage = GasChoiceUtilities.NormalizeUsage(thepremise);
		
		//if we're only doing the move-ins, this will blank the capacity charge portion of the costs!
		
		map<string, map<date, decimal>> Costs = GasChoiceCalc2.getCosts2(thepremise, startdate, enddate); //gets everything including distrubtion
		
		map<plan__c, map<string, decimal>> customerCosts = GasChoiceCalc2.getPlanCosts(thepremise, Costs, usage, planoptions);           
				
		for (plan__c p:customerCosts.keySet()){
			if (p.Rate_Type__c == 'Fixed'){
					thepremise.Fixed_Cost_Estimate__c = customerCosts.get(p).get('Fixed');
				}else if (p.Rate_Type__c=='Index'){
					thepremise.Index_Cost_Estimate__c = customerCosts.get(p).get('Variable');
				}
		}		
		update thepremise;
		
	}


	public static list<GasChoiceOffer> getAvailableOffersDynamic(premises__c thepremise, string programYear, boolean ShowAll){
		system.debug('Program year is ' + programyear);
		//what rates are available?
		list<plan__c> PlanOptions = GasChoiceUtilities.GetPlansByPremise(thepremise, programyear);
		
		system.debug('>>>' + planoptions);
		system.debug('>>> Gonna Work ' + planoptions.size());
		
		//What time period are we talking about?
		date startdate = GasChoiceUtilities.WhenDoesItStart(thepremise, programYear);
		date enddate = startdate.addmonths(23);
		system.debug('Startdate is ' + startdate + ' and enddate is ' + enddate);
		//use that to calculate the base per unit supply costs for the following for 24 months out:        
		map<integer,decimal> usage = GasChoiceUtilities.NormalizeUsage(thepremise);
		
		//if we're only doing the move-ins, this will blank the capacity charge portion of the costs!
		
		
		map<string, map<date, decimal>> Costs = GasChoiceCalc2.getCosts2(thepremise, startdate, enddate); //gets everything including distrubtion
		
		//if there are smartBill plans, verify that the customer can have a smartbill with the usage given.  If not, remove it from the list.
		if (thepremise.program__c == 'Ag' || !SmartBillUtilities.SmartBillTests3(usage, thepremise)){            
			planOptions = SmartBillUtilities.removeSmartBills(planOptions);
		} else {system.debug('SmartBill test passed!');}
		
		map<plan__c, map<string, decimal>> customerCosts = GasChoiceCalc2.getPlanCosts(thepremise, Costs, usage, planoptions);           
		//for each plan, add the margin, go through rates,  and find the closest matches
		//list<GasChoiceOffer2> results = new list<GasChoiceOffer2>();
		list<GasChoiceOffer> results = GasChoiceDynamicRatePicker.getResults(thepremise, customerCosts, usage, programYear);
		//build offer structure to return for screen
		results.sort();
		if (!ShowAll){
			results=GasChoiceDynamicRatePicker.ReturnOnlyHighestOne(results);
		}
		system.debug(results);        
		
		return results;
		
		
		
		
		return null;
	}
	
	public static map<plan__c, map<string, decimal>> getPlanCosts(premises__c thepremise, map<string, map<date, decimal>> Costs, map<integer,decimal> usage, list<plan__c> planoptions){
		
		//Initial Setup                
		decimal totalContractUsage=0;        decimal fixedContractUsage=0;        decimal VariableContractUsage=0;
		map<plan__c, map<string, decimal>> output = new map<plan__c, map<string, decimal>>();
		map<plan__c, map<string, decimal>> preoutput = new map<plan__c, map<string, decimal>>();       
		for (plan__c p:planoptions){            
			map<string, decimal> placeholders = new map<string, decimal>{'Fixed'=>0, 'Variable'=>0};
			output.put(p, placeholders);    
			preoutput.put(p, placeholders);
		}        
		decimal iterationCounter = 1;
		list<date> dlist = new list<date>();        
		dlist.addall(Costs.get('NYMEX').keySet());
		dlist.sort();
		list<decimal> taxFactor = GasChoiceUtilities.GetTaxFactor(thepremise);
		if (thepremise.consultant_margin__c == null){thepremise.consultant_margin__c=0;}
		decimal WYFee=0;
		GasChoiceCalcInputs__c gcci = GasChoiceCalcInputs__c.getOrgDefaults();
		if (thepremise.Program__c== 'Wyoming') WYFee = gcci.Wyoming_Choice_Fee__c;
				
		for (date d:dlist){ //loop through each month
			
			totalContractUsage= totalContractUsage+usage.get(d.month()); //keep a running total of the usage so we can calculate per-therm costs
			decimal vol = math.max(usage.get(d.month()), 0.1);
			
			//debug section/////////
			
			system.debug('============== the date is ' + d);
			system.debug('=== usage in Dth is ' + vol   );
			system.debug('=========================== Fixed Supply is '+Costs.get('TotalFixedCosts').get(d));
			system.debug('=========== Index Adder is '+Costs.get('TotalAdder').get(d));
			system.debug('=================== DPA is '+Costs.get('DPAperDth').get(d));
			//system.debug('===== Straddle is '+Costs.get('Straddle').get(d));
			//system.debug('======= Cap is '+Costs.get('Cap').get(d));
			for (plan__c p:planoptions){ //loop through each plan for that month  
				
				system.debug('============================================= doing plan ' + p.name + ' for date '+d);
				system.debug('============================================= Variable map 1 is ' + preoutput.get(p).get('Variable') ); 
				system.debug('============================================= Fixed 1 is ' + preoutput.get(p).get('Fixed') ); 
				//do an if/then wrap to omit SmartBillQuotes
				if(iterationCounter<=p.contract_length__c){  //don't do this plan if we've already closed it out.
					
					if (p.Rate_Type__c=='SmartBill'){
						system.debug('============================================= I think  this is a SmartBill: ' + p.name);
						system.debug('tax factor is '+taxfactor);                                                
						preoutput.put(p, new map<string, decimal>{'Fixed' => preoutput.get(p).get('Fixed') 
							+ taxfactor[1]*vol //per therm tax
							+ WYFee //WY fee isn't in adder--we're going to put it in the fixed cost for the smartbills.  for NE, this is already set to 0;
							+ (1+taxfactor[0])*(
								(Costs.get('TotalFixedCosts').get(d)+p.margin_per_Dth__c +p.Full_Requirements_Premium__c+ thepremise.Consultant_Margin__c)*vol
								+ Costs.get('DistributionCosts').get(d)*vol
							), 'Variable' => (preoutput.get(p).get('Variable'))});                        
					}
					else if(p.Rate_Type__c == 'Index'){
						system.debug('============================================= I think  this is Index: ' + p.name);
						preoutput.put(p, new map<string, decimal>{'Fixed' => (preoutput.get(p).get('Fixed')), 'Variable' => (preoutput.get(p).get('Variable') + (Costs.get('WholesaleAdjustment').get(d) + Costs.get('TotalAdder').get(d))*vol) } ); //get the cost for that month
					}
					else if(p.Rate_Type__c == 'IndexNoSpread'){
						system.debug('============================================= I think  this is IndexNoSpread: ' + p.name);
						preoutput.put(p, new map<string, decimal>{'Fixed' => (preoutput.get(p).get('Fixed')), 'Variable' => (preoutput.get(p).get('Variable') + Costs.get('TotalAdder').get(d)  *vol) } ); //get the cost for that month
					}
					else if (p.Rate_Type__c == 'SmartFixed'){ //fixed with dpa  
						//TODO--allow flexibility for multiple DPA Percentages.
						system.debug('============================================= I think  this is smartFixed: ' + p.name);
						preoutput.put(p, new map<string, decimal>{
							'Fixed' => (preoutput.get(p).get('Fixed') //what was there
										+ Costs.get('DPAperDth').get(d)*vol*0.1 //plus the DPA cost
										+   Costs.get('TotalFixedCosts').get(d)*vol), //plus the fixed component
								'Variable' => (preoutput.get(p).get('Variable'))                         } );
					}
					else if (p.Rate_Type__c == 'Fixed'){ //fixed with dpa  
						system.debug('============================================= I think  this is smartFixed: ' + p.name);
						preoutput.put(p, new map<string, decimal>{
							'Fixed' => (preoutput.get(p).get('Fixed') //what was there
										+   Costs.get('TotalFixedCosts').get(d)*vol), //plus the fixed component
								'Variable' => (preoutput.get(p).get('Variable'))                         } );
					}
					//smartblended
					else if (p.Rate_Type__c == 'SmartBlended'){
						system.debug('============================================= I think  this is SmartBlended: ' + p.name);
						if(d.month()>5 && d.month()<11){ //here it's the index
							preoutput.put(p, new map<string, decimal>{'Variable' => (preoutput.get(p).get('Variable')+ (Costs.get('WholesaleAdjustment').get(d) + Costs.get('TotalAdder').get(d))*vol), 'Fixed' => (preoutput.get(p).get('Fixed') ) } );                               
							VariableContractUsage += usage.get(d.month());
						} else{ //here it's the fixed
							preoutput.put(p, new map<string, decimal>{
								'Variable' => (preoutput.get(p).get('Variable')), 
								'Fixed' => (preoutput.get(p).get('Fixed') + Costs.get('TotalFixedCosts').get(d)*vol) 
									} );                                                                                              
							fixedContractUsage += usage.get(d.month());                                
						}
					}                
					else if (p.Rate_Type__c == 'Blended'){ //do the full value of each one.  We'll just keep both versions for the final offer
						system.debug('============================================= I think  this is Blended: ' + p.name);  
						preoutput.put(p, new map<string, decimal>{
							'Variable' => (preoutput.get(p).get('Variable') + (Costs.get('TotalAdder').get(d) + Costs.get('WholesaleAdjustment').get(d) )*vol), 
								'Fixed' => (preoutput.get(p).get('Fixed')+ Costs.get('TotalFixedCosts').get(d)*vol) }
									 );
					}
					//TODO: indexWithCap
					else if (p.Rate_Type__c == 'SmartCap'){ 
						system.debug('============================================= I think  this is SmartCap: ' + p.name);
						system.debug('SmartCap are not fully supported yet');
						preoutput.put(p, new map<string, decimal>{
							'Fixed' => (preoutput.get(p).get('Fixed')), 
							'Variable' => (preoutput.get(p).get('Variable') + (Costs.get('WholesaleAdjustment').get(d) + Costs.get('TotalAdder').get(d))*vol
						//+  Costs.get('Cap').get(d)*usage.get(d.month())
						) } ); //get the cost for that month
					}                
					else {  
						system.debug('============================================= This didnt match anything' + p.name);
						system.debug('Rate Type "' + p.Rate_Type__c+'" is not supported yet'); 
					} //unhandled types
					
					if(iterationCounter>=p.contract_length__c){ // if that plan is done, let's close it out
						system.debug('============================================= Closing out section');
						system.debug('closing out' + p);
						system.debug('Total cost is Fixed: ' + preoutput.get(p).get('Fixed') + ' and Variable ' + preoutput.get(p).get('Variable'));
						system.debug('Usage was ' + TotalContractUsage + '... Fixed was ' + FixedContractUsage+ ' and Variable was ' + VariableContractUsage + ' . ');
						
						//take the preoptions and calculate the cost per decatherm so they'll be locked
						if (thepremise.Consultant_Margin__c ==null){ thepremise.Consultant_Margin__c=0;}
						if (p.Rate_Type__c =='SmartBill'){
							system.debug('closing out smartbill with totalcost = ' + preoutput.get(p).get('Fixed')   );
							output.put(p, new map<string, decimal>{'SBQ' => preoutput.get(p).get('Fixed')});
							system.debug('SBQ is set to ' + output.get(p).get('SBQ'));
						}
						else if (p.Rate_Type__c == 'SmartBlended'){                            
							output.put(p, new map<string, decimal>{'Fixed' => (preoutput.get(p).get('Fixed')/math.max(1, FixedContractUsage))+thepremise.Consultant_Margin__c, 'Variable' => (preoutput.get(p).get('Variable')/math.max(1, VariableContractUsage))+thepremise.Consultant_Margin__c});
						}
						else {
							output.put(p, new map<string, decimal>{'Fixed' => (preoutput.get(p).get('Fixed')/math.max(1,TotalContractUsage))+thepremise.Consultant_Margin__c, 'Variable' => (preoutput.get(p).get('Variable')/math.max(1,TotalContractUsage))+thepremise.Consultant_Margin__c});
						}
						system.debug('Final Results for ' + p + ' : ' + output.get(p));
					}//end the closeout if/then    
				}//end the contract length if/then
				
			}//end the plan for loop
			iterationCounter++;
		}
		system.debug('@@@@@@@ Here is is!!!');        
		system.debug(output);        
		return output;
	}

	public static map<string, map<date, decimal>> getCosts2(premises__c prem, date startdate, date enddate){
		map<string, map<date, decimal>> output = new map<string, map<date, decimal>>(); 
		Pipeline_Scenario__c PS = getPS(prem); //what scenario?
		list<string> stripNames = getStripList(PS); //build the list of indexes we'll need
		map<integer,decimal> usage = GasChoiceUtilities.NormalizeUsage(prem); //we need usage for pin costs
		
		//determine capacity cost (0 if current program year).  It'll be the same for each month
		decimal pin = 0; 
		pin = GasChoiceUtilities.getDiscount(prem, usage); 
		system.debug('Capacity is ' + pin);
		
		map<string, map<date, decimal>> Strips = GasChoiceUtilities.getStrips(stripNames, true, startdate, enddate);
		list<fee__c> tariffs = getTariffs(prem);
		
		return StripsToCosts(Strips, PS, startdate, enddate, pin, usage, WhichCustomerCharge(prem), tariffs);
	} 
	/*
	public static map<string, map<date, decimal>> getCosts(premises__c prem, date startdate, date enddate, boolean IncludeCapacity){
		map<string, map<date, decimal>> output = new map<string, map<date, decimal>>(); 
		Pipeline_Scenario__c PS = getPS(prem); //what scenario?
		list<string> stripNames = getStripList(PS); //build the list of indexes we'll need
		map<integer,decimal> usage = GasChoiceUtilities.NormalizeUsage(prem); //we need usage for pin costs
		
		//determine capacity cost (0 if current program year).  It'll be the same for each month
		decimal pin = 0; 
		if (IncludeCapacity) pin = GasChoiceUtilities.getDiscount(prem, usage);
		system.debug('Capacity is ' + pin);
		
		map<string, map<date, decimal>> Strips = GasChoiceUtilities.getStrips(stripNames, true, startdate, enddate);
		list<fee__c> tariffs = getTariffs(prem);
		
		return StripsToCosts(Strips, PS, startdate, enddate, pin, usage, WhichCustomerCharge(prem), tariffs);
	} */
	
	public static decimal WhichCustomerCharge(premises__c prem){
		GasChoiceCalcInputs__c gcci = GasChoiceCalcInputs__c.getOrgDefaults();
		try{
			if (prem.Program__c=='Ag'){
				return gcci.Nebraska_Ag_Customer_Charge__c;
			} else if (prem.Program__c=='Nebraska'){ 
				return gcci.Nebraska_R_C_Customer_Charge__c;
			}
			else return 0;
		}catch (exception e){system.debug('There was an error retrieving the customer charges (Custom Settings) for program ' + prem.Program__c); }
		return null;
	}
	
	
	public static map<string, map<date, decimal>> StripsToCosts(map<string, map<date, decimal>> Strips, Pipeline_Scenario__c PS, date startdate, 
														date enddate, decimal pin, map<integer,decimal> usage, decimal fee, list<fee__c> tariffs){
		//what all we're going to output
		map<date, decimal> NYMEX = new map<date, decimal>();
		map<date, decimal> Basis = new map<date, decimal>();
		map<date, decimal> PhysicalPremiumToIndex = new map<date, decimal>();
		map<date, decimal> Fuel = new map<date, decimal>();
		map<date, decimal> DPAperDth = new map<date, decimal>();
		map<date, decimal> StorageOther = new map<date, decimal>();
		map<date, decimal> Capacity = new map<date, decimal>();
		map<date, decimal> PLCommodity = new map<date, decimal>();
		map<date, decimal> WholesaleAdjustment = new map<date, decimal>();
		map<date, decimal> TotalAdder = new map<date, decimal>();
		map<date, decimal> TotalFixedCosts = new map<date, decimal>();
		map<date, decimal> DistributionCosts = new map<date, decimal>(); //for smartbills only                                                     

		date d = startdate; date NextProgramYearStartDate;
		GasChoiceCalcInputs__c gcci = GasChoiceCalcInputs__c.getOrgDefaults();

		if (pin>0) NextProgramYearStartDate = GasChoiceUtilities.WhenDoesItStart(false, gcci.Next_Program_Year__c);
			else NextProgramYearStartDate = GasChoiceUtilities.WhenDoesItStart(true, gcci.Next_Program_Year__c);
		
		
		
		do {
			system.debug('doing date ' + d);
			NYMEX.put(d, strips.get('NYMEX').get(d)); //nymex is the actual index plus the index cost
			
			if (PS.Secondary_Financial_Basis__c!=null){
				Basis.put(d, strips.get(PS.Main_Financial_Basis__r.name).get(d)*PS.Main_Financial_Basis_Percent__c 
						  + strips.get(PS.Secondary_Financial_Basis__r.name).get(d)*PS.Secondary_Physical_Basis_Percent__c );
			} else Basis.put(d, strips.get(PS.Main_Financial_Basis__r.name).get(d));
			//add the physical premium (constant version), add to whatever the raw basis was (no option for both to be present!!)
			if (PS.Physical_Premium_to_Index_Constant__c!=null) 
				PhysicalPremiumToIndex.put(d, PS.Physical_Premium_to_Index_Constant__c);
			//add the physical premium (strip version), add to whatever the raw basis was (no option for both to be present!!)
			else if (PS.Physical_Premium_to_Index__c!=null) 
				PhysicalPremiumToIndex.put(d, strips.get(PS.Physical_Premium_to_Index__r.Name).get(d));
			else PhysicalPremiumToIndex.put(d, 0);
			
			DPAperDth.put(d,  strips.get('NYMEX ATM INDEX PUT').get(d));
			system.debug('Basis is ' + Basis.get(d) );
			system.debug('NYMEX is ' + NYMEX.get(d) );
			system.debug('Fuel is ' + strips.get(PS.fuel__r.name).get(d) );
			
			Fuel.put(d,  (Basis.get(d) + NYMEX.get(d))/(1-strips.get(PS.fuel__r.name).get(d)) - (Basis.get(d) + NYMEX.get(d))   );
			PLCommodity.put(d,  strips.get(PS.Pipeline_Commodity__r.Name).get(d));
			if (PS.Other_Charges_or_Items__c!= null) StorageOther.put(d,  PS.Other_Charges_or_Items__c); else StorageOther.put(d, 0);
			if (PS.Miscellaneous_Adjustment_Strip__c!=null)
				WholesaleAdjustment.put(d, strips.get(PS.Miscellaneous_Adjustment_Strip__r.Name).get(d));
			else WholesaleAdjustment.put(d, 0);
			
			if (d>NextProgramYearStartDate) Capacity.put(d, pin); else Capacity.put(d, 0); //current program year has no capacity
			
			//customer charge into adder
			decimal cc=fee;
			try{cc = fee/usage.get(d.month());}catch (exception e){}

			//distribution, so it will be there for smartbills.
			//whatIsDistribution(date d, decimal volume, list<fee__c> fees)
			DistributionCosts.put(d, whatIsDistribution(usage.get(d.month()), tariffs));
				
			//sums
			TotalAdder.put(d, cc+Fuel.get(d)+StorageOther.get(d)+PLCommodity.get(d)+Capacity.get(d)+PhysicalPremiumToIndex.get(d));
			system.debug('TotalAdder for ' + d + ' is ' + TotalAdder.get(d));
			TotalFixedCosts.put(d, TotalAdder.get(d) + NYMEX.get(d) + Basis.get(d));         
			d=d.addMonths(1);
		} while(d<=enddate); 
		
		
				
		map<string, map<date, decimal>> output = new map<string, map<date, decimal>>();

		output.put('NYMEX',NYMEX);
		output.put('Basis',Basis);
		output.put('PhysicalPremiumToIndex',PhysicalPremiumToIndex);
		output.put('Fuel',Fuel);
		output.put('DPAperDth',DPAperDth);
		output.put('StorageOther',StorageOther);
		output.put('Capacity',Capacity);
		output.put('PLCommodity',PLCommodity);
		output.put('WholesaleAdjustment',WholesaleAdjustment);
		output.put('TotalAdder',TotalAdder);
		output.put('TotalFixedCosts',TotalFixedCosts);
		output.put('DistributionCosts',DistributionCosts);
		return output;
	}
	
	//logic for which scenario, based on program and division
	public static string WhichPricingScenario(premises__c prem){
		if (prem.Program__c == 'Ag') {
			return 'SourceGas Choice Ag Nebraska';
		}
		else {
			if (prem.Division__c == 'Casper') return 'SourceGas Choice Casper WY';
			else if (prem.Division__c == 'Torrington') return 'SourceGas Choice Torrington WY';
			else if (prem.Division__c == 'Gillette') return 'SourceGas Choice Gillette WY';
			else if (prem.Division__c == 'Central') return 'SourceGas Choice Central NE';
			else if (prem.Division__c == 'Western') return 'SourceGas Choice Western NE';
		}
		return null;
	}
	
	//keeping execution code clean by putting nasty-looking queries in their own method
	public static Pipeline_Scenario__c getPS(premises__c prem){
		return [select id, name, Balancing__c,
			  Physical_Premium_to_Index_Constant__c, Physical_Premium_to_Index__r.name, Physical_Only_Premium__r.name,
			  Main_Physical_Basis__r.name, Main_Physical_Basis__r.id,
			  Main_Financial_Basis__r.name, Main_Financial_Basis__r.id,
			  Secondary_Physical_Basis__r.name, Secondary_Physical_Basis__r.id,
			  Secondary_Financial_Basis__r.name, Secondary_Financial_Basis__r.id,
			  Main_Financial_Basis_Percent__c, Main_Physical_Basis_Percent__c, 
			  Secondary_Financial_Basis_Percent__c, Secondary_Physical_Basis_Percent__c,
			  summer_swing__c, winter_swing__c, 
			  fuel__r.name, Pipeline_Commodity__r.name, Demand_Charge__r.name,
			  Miscellaneous_Adjustment_Strip__r.name, Other_Charges_or_Items__c
			  from Pipeline_Scenario__c where name=:WhichPricingScenario(prem)];
	}
	
	public static list<string> getStripList(Pipeline_Scenario__c PS){
		return new list<string>{
			'NYMEX', 'NYMEX ATM INDEX PUT', PS.Secondary_Financial_Basis__r.name, 
				PS.Main_Financial_Basis__r.name, PS.fuel__r.name, PS.Pipeline_Commodity__r.name, 
				PS.Miscellaneous_Adjustment_Strip__r.name
				};
	}
	
	public static list<Fee__c> getTariffs(premises__c prem){
		string rateclass;
		if (prem.Premise_Type__c == 'RES') rateclass = 'Residential Gas';
		if (prem.Premise_Type__c == 'COM') rateclass = 'Commercial Gas';
		if (prem.Premise_Type__c == 'IND') rateclass = 'Commercial Gas';
		if (prem.Premise_Type__c == 'AGR') rateclass = 'Agriculture Gas';
		
		return [select Basis__c, Upper_Threshhold__c, Value__c, Minimum_usage__c from Fee__c where Utility_Zone__c =: prem.Division__c and Rate_Class__c =: rateclass];
	
	}
	
	public static decimal whatIsDistribution(decimal volume, list<fee__c> fees){
		//go through each tarriff, to see whether it applies in that case.
		decimal totalcost = 0;
		for (fee__c f:fees){
			system.debug('calculating cost for fee' + f);
			if (f.basis__c == 'Monthly' && volume > f.Minimum_usage__c && volume<=f.Upper_Threshhold__c){
				totalcost = totalcost + f.value__c;
			}
			if (f.basis__c == 'Volumetric' && volume > f.Minimum_usage__c && volume<=f.Upper_Threshhold__c){
				totalcost = totalcost + f.value__c*volume;
			}
		}
		system.debug('distribution cost is ' + totalcost + ' on Dth usage of '+volume);
		if (volume ==0) volume = 0.1; ///control the divide by zero issue--assume 1 therm in all months so the cost still comes in.
		return totalcost/volume;        
	}
}