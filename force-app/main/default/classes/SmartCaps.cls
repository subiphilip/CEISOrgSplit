public class SmartCaps {
	
	public static map<decimal, map<date, decimal>> getOptions(decimal minimum, date startdate, date enddate){
		map<decimal, map<date, decimal>> output = new map<decimal, map<date, decimal>>();
		list<index_future__c> IndexFutures = [select id, name, delivery_date__c, index__r.name, price__c,
                                              index__r.index_cost__c, Index__r.Strike_Price__c
                                                from index_future__c
                                                where index__r.Strike_Price__c >=:minimum 
                                                and delivery_date__c>=:startdate
                                                and delivery_date__c<=:enddate
                                                order by index__r.Strike_Price__c ASC, delivery_date__c ASC];

        for (index_future__c IndexFuture:IndexFutures){       
        	if (output.get(IndexFuture.Index__r.Strike_Price__c)==null){ //the map doesn't exist
        		output.put(IndexFuture.Index__r.Strike_Price__c, new map<date, decimal>{});
        	}
    		output.get(IndexFuture.Index__r.Strike_Price__c).put(IndexFuture.delivery_date__c, IndexFuture.Price__c);
    	}        
        system.debug('options are' + output);
		return output;
	}
	


	public static list<GasChoiceOffer> GetOffers(date startdate, date enddate, premises__c ThePremise, map<string, map<date, decimal>> Costs, map<plan__c, map<string, decimal>> CustomerCosts, map<integer,decimal> Usage, string ProgramYear, list<plan__c> PlanOptions){

		list<GasChoiceOffer> output = new list<GasChoiceOffer>();
				
		//ingredients:
		//instance of the calculation inputs for tolerance, cap minimum and multiplier
		GasChoiceCalcInputs__c gcci = GasChoiceCalcInputs__c.getOrgDefaults();		
		
		//what's the minimum strike we care about?  it's the fixed rate--the inventory of options will take care of any rounding.
		//while we have the plans running, let's grab the margns off of them, too.
		decimal minimum =0;
		decimal margin1; decimal margin2;
		plan__c SC1; plan__c SC2; //where we'll keep the plans for future reference
		decimal totalUsage = GasChoiceUtilities.getTotalUsage(usage);
		string IndexReference = GasChoiceDynamicRatePicker.GetIndexReferenceByPremise(ThePremise);

		for (plan__c p:PlanOptions){
			if (p.Rate_Type__c=='SmartFixed') minimum = CustomerCosts.get(p).get('Fixed');
			if (p.Rate_Type__c=='SmartCap' && p.Contract_Length__c==12){
				margin1 = p.Margin_per_Dth__c;
				SC1 = p;
			}
			if (p.Rate_Type__c=='SmartCap' && p.Contract_Length__c==24){
				margin2 = p.Margin_per_Dth__c;
				SC2 = p;
			}
		}
		system.debug('SC1:' + sc1);
		system.debug('SC2:' + sc2);
		system.debug('Fixed min :' + minimum);

		if (sc1==null) return null;
		if (sc2==null) enddate = enddate.addMonths(-12); //don't do the second year if we don't need it.

		//the options values
		map<decimal, map<date, decimal>> Options = getOptions(0, startdate, enddate);		
		//the caps that we're going to price out
		list<decimal> CapValues = getCapValues(SC1, minimum + margin1, minimum+margin1+gcci.SmartCap_Guess_Factor_B__c);

		//for each cap offer
		for (decimal c:CapValues){			
			date datecounter = startdate;
			decimal runningUsageTotal;
			decimal runningWacog=0;
			//for each month
			map<date, decimal> CapCosts1 = new map<date, decimal>();  
			map<date, decimal> CapCosts2 = new map<date, decimal>();
			decimal TotalCapCost1=0; decimal TotalCapCost2 =0;

			do {
				if (sc1!=null){				
					decimal estimatedPrice1 = CapCostGuesser(c, datecounter, SC1, gcci, options, costs);
					system.debug('cap of ' + c + ' for date ' + datecounter + ' has cost of '+ estimatedPrice1);
					//CapCosts1.put(datecounter, estimatedPrice1;
					TotalCapCost1 = TotalCapCost1+estimatedPrice1;
				}

				if(sc2!=null){
					decimal estimatedPrice2 = CapCostGuesser(c, datecounter, SC2, gcci, options, costs);
					//CapCosts2.put(datecounter, estimatedPrice1);
					TotalCapCost2 = TotalCapCost2+estimatedPrice2;
				}
				datecounter=datecounter.addmonths(1);	
			} while (datecounter<=enddate);


			//putting the final cap costs on
			if (sc1!=null){	
				system.debug('Total cost for SC1 is '+ TotalCapCost1);
				GasChoiceOffer o1 = GasChoiceDynamicRatePicker.ConstructOfferFromPlan(SC1, CustomerCosts, 1, totalUsage, 1, IndexReference);
				system.debug('inital offer is '+ o1);
				o1=ApplyCapOfferDetails(o1, c, TotalCapCost1, totalUsage, ProgramYear);				
				o1.PriceDetails = GasChoiceDynamicRatePicker.ConstructPriceDetails(IndexReference, o1);
				if (o1.IndexAdder < 1) output.add(o1); //don't add stupid ones.
			}

			if(sc2!=null){
				GasChoiceOffer o2 = GasChoiceDynamicRatePicker.ConstructOfferFromPlan(SC2, CustomerCosts, 1, totalUsage, 2, IndexReference);
				o2=ApplyCapOfferDetails(o2, c, TotalCapCost2, totalUsage, ProgramYear);			
				o2.PriceDetails = GasChoiceDynamicRatePicker.ConstructPriceDetails(IndexReference, o2);

				if (o2.IndexAdder <1 ) output.add(o2);
			}
		}
		
		return output;
	}

	public static GasChoiceOffer ApplyCapOfferDetails(GasChoiceOffer o, decimal c, decimal TotalCapCost, decimal TotalUsage, string ProgramYear){
		o.ProgramYear = ProgramYear;
		o.FixedPrice=c/10; //set the cap
		o.targetIndexBeforeMargin=o.targetIndexBeforeMargin+(TotalCapCost/totalUsage).setscale(4); //just like normal index, plus the cap premium;
		o.targetIndexAfterMargin=(o.targetIndexBeforeMargin+o.p.Margin_per_Dth__c).setscale(4);
		o.IndexAdder=GasChoiceDynamicRatePicker.RoundUpByResolution(o.targetIndexAfterMargin/10, o.p.SG_Pricing_Resolution_Primary_Th__c);
		o.estimatedFixedperUnitMargin=0;
		o.estimatedindexUsage = totalUsage*o.p.Contract_Length__c/12;
		o.estimatedVariableperUnitMargin=o.IndexAdder*10-o.targetIndexBeforeMargin;
		o.TotalMargin=(o.estimatedVariableperUnitMargin*totalUsage*o.p.Contract_Length__c/12).setscale(2);
		system.debug('offer after applying cap premiums is ' + o);
		return o;

	}

	public static list<decimal> getCapValues(plan__c p, decimal FixedCost, decimal TopCap){
		list<decimal> output = new list<decimal>();

		decimal HighestCap=GasChoiceDynamicRatePicker.RoundUpByResolution(TopCap+FixedCost+p.Margin_per_Dth__c, P.SG_Pricing_Resolution_Secondary_Th__c);
		decimal priceTracker =GasChoiceDynamicRatePicker.RoundUpByResolution(FixedCost, p.SG_Pricing_Resolution_Secondary_Th__c);
		
		do {
			output.add(priceTracker);
			priceTracker = priceTracker + P.SG_Pricing_Resolution_Secondary_Th__c*10;
		} while (priceTracker<=HighestCap);

		return output;
	}

	public static decimal CapCostGuesser(decimal Cap, date d, plan__c p, GasChoiceCalcInputs__c gcci, map<decimal, map<date, decimal>> Options, map<string, map<date, decimal>> Costs){
		decimal output;

 		decimal NYMEX = Costs.get('NYMEX').get(d);
		decimal IndexAdder = Costs.get('TotalAdder').get(d);
		decimal margin = p.Margin_per_Dth__c;
		decimal ActualCapCost = gcci.SmartCap_Option_Minimum__c; 
		decimal CapCostGuess = (1/(Cap - (Nymex+IndexAdder+Margin) ))*gcci.SmartCap_Guess_Factor_A__c;

		system.debug('NYMEX:' + NYMEX);
		system.debug('Adder:' + IndexAdder);

		//do ths up until you get it right, or run out of tries
		for (integer x=1; x<gcci.SmartCap_Retry_Count__c; x++){
			//how much is the cap above the expected price
			decimal CapDelta = Cap-(Nymex+CapCostGuess+IndexAdder+Margin).setscale(3); 
			//what would that option be?
			decimal ImpliedStrike = GasChoiceDynamicRatePicker.RoundUpByResolution(Nymex+CapDelta, p.SG_Pricing_Resolution_Secondary_Th__c).setscale(3);
			system.debug('For Cap '+Cap+' the implied strike for date ' +d+ ' is ' + ImpliedStrike + '.  Cap Delta is ' + CapDelta + '. Guess on attempt ' + x + ' is ' + CapCostGuess);
			
			try{
				ActualCapCost = options.get(ImpliedStrike).get(d);
					system.debug('Actual value turned out to be ' + ActualCapCost);
				} catch (exception e){
					system.debug('could not find actual cap; using minimum price');
					//didn't find one that matches.  So it must be super high, so the optino price would be very low.  We'll leave it as the minimum price
				}
			decimal Error = math.abs(ActualCapCost - CapCostGuess);

			if (Error<gcci.SmartCap_Error_Tolerance__c || x==gcci.SmartCap_Retry_Count__c) {
				return math.max(gcci.SmartCap_Option_Minimum__c, ActualCapCost*gcci.SmartCap_Option_Cost_Multiplier__c);
			} else { //split the difference and try again?
				CapCostGuess = ((CapCostGuess+ActualCapCost*3)/4).setscale(3);
			} 
		}	
		
		return 1000000; //pinky in right side of mouth
	}




}