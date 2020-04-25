public class GasChoiceDynamicRatePicker{

	public class CodeManagementException extends Exception{}

	public static String GetIndexReferenceByPremise(premises__c thepremise){
		if (thepremise.Program__c == 'Nebraska' || thepremise.Program__c == 'Ag') return 'PEPL';
		if (thepremise.Program__c == 'Wyoming') return 'CIG';
		return null;
	}

	public static void LockChoiceRate(string rateid){
		rate__c r = [select Id, Confirmation_Code_Status__c from rate__c where id=:rateid limit 1];
		r.Confirmation_Code_Status__c='Activated with pricing';
		update r;
	}

	public static rate__c ConfirmationCodeManagement(GasChoiceOffer O, premises__c thepremise){
		rate__c r = new rate__c();
		list<rate__c> Rates = [select id, name, plan__r.name, plan__r.id, Confirmation_Code__c, 
		plan__r.rate_type__c, plan__r.rep_Profile__r.id, plan__r.contract_length__c,
		Confirmation_Code_Year__c, Price_Details__c, notes__c
		from rate__c 
		where plan__c =: o.p.id
		and SG_Available_for_Dynamic__c = true
		and Index_Adder__c =: o.IndexAdder
		and Fixed_Rate__c =: o.FixedPrice
		and recordtypeid='012300000018Sz8'
		and confirmation_code_year__c =: o.programyear
		and Index_reference__r.name =: o.IndexReference
		and 
		(
			(Program__c =: thepremise.Program__c and Division__c =: thepremise.Division__c)
			or
			(Program__c =: thepremise.Program__c and Program__c = 'Ag')
			
			) limit 1];	
		if (!Rates.isEmpty()){return Rates[0];}

		//still not got a rate?  Grab from activated without pricing, and make one.		
		Rates = [select id, name, plan__r.name, plan__r.id, Confirmation_Code__c, 
		plan__r.rate_type__c, plan__r.rep_Profile__r.id, plan__r.contract_length__c,
		Confirmation_Code_Year__c, Price_Details__c, notes__c, 
		Index_Adder__c, Fixed_Rate__c,  SG_Available_for_Dynamic__c, Confirmation_Code_Status__c, 
		Index_Rate_Percentage__c, Fixed_Rate_Percentage__c, Index_reference__c
		from rate__c 
		where plan__c =: o.p.id
		and Confirmation_Code_Status__c = 'Activated, not priced'
		and recordtypeid='012300000018Sz8'
		and confirmation_code_year__c =: o.programyear
		and 
		(
			(Program__c =: thepremise.Program__c and Division__c =: thepremise.Division__c)
			or
			(Program__c =: thepremise.Program__c and Program__c = 'Ag')
			
			) limit 1];	
		if (Rates.isEmpty()){ //still no rate?  go for the unactivated ones
			Rates = [select id, name, plan__r.name, plan__r.id, Confirmation_Code__c, 
			plan__r.rate_type__c, plan__r.rep_Profile__r.id, plan__r.contract_length__c,
			Confirmation_Code_Year__c, Price_Details__c, notes__c, 
			Index_Adder__c, Fixed_Rate__c,  SG_Available_for_Dynamic__c, Confirmation_Code_Status__c, 
			Index_Rate_Percentage__c, Fixed_Rate_Percentage__c, Index_reference__c
			from rate__c 
			where plan__c =: o.p.id
			and Confirmation_Code_Status__c = 'Unactivated (not sent to the utility)'
			and recordtypeid='012300000018Sz8'
			and confirmation_code_year__c =: o.programyear
			and 
			(
				(Program__c =: thepremise.Program__c and Division__c =: thepremise.Division__c)
				or
				(Program__c =: thepremise.Program__c and Program__c = 'Ag')
				
				) limit 1];
}

try {
	r = Rates[0];
		} catch (exception e){  //there really just aren't any rates for this one
		DiagnosticEntry.RecordCrash(e);
		throw new CodeManagementException ('No codes available for ' + O + ':' + e.getMessage(), e);
	}
		//set up the code details
		r.Index_Adder__c = o.IndexAdder;
		r.Fixed_Rate__c = o.FixedPrice;
		r.SG_Available_for_Dynamic__c = true;

		if (r.Confirmation_Code_Status__c=='Activated, not priced'){
			r.Confirmation_Code_Status__c = 'Activated with pricing';
			if (o.p.Rate_Type__c!='SmartBill' && HowManyAreLeft(o, thepremise)<5){
				insert new AsyncRequest__c(params__c = r.id, type__c='lowCodeInventory');
			}
			} else if (r.Confirmation_Code_Status__c == 'Unactivated (not sent to the utility)'){
				r.Confirmation_Code_Status__c = 'Unactivated with order';
				insert new AsyncRequest__c(params__c = r.id, type__c='UsedUnactivatedCode');
			}
		//plan-based 
		//Fixed_Rate_Percentage__c, Index_Rate_Percentage__c

		r.Index_reference__c = [select id from index__c where name =: o.IndexReference].id;

		if (o.p.Rate_Type__c=='Index' ||o.p.Rate_Type__c=='IndexNoSpread' || o.p.Rate_Type__c=='SmartCap'){
			r.Index_Rate_Percentage__c = 100; r.Fixed_Rate_Percentage__c = 0;
		} 
		if (o.p.Rate_Type__c=='Blended' ||o.p.Rate_Type__c=='SmartBlended'){
			r.Index_Rate_Percentage__c = 50; r.Fixed_Rate_Percentage__c = 50;
		} 
		
		if (o.p.Rate_Type__c=='Fixed' || o.p.Rate_Type__c=='SmartBill') {
			r.Index_Rate_Percentage__c = 0; r.Fixed_Rate_Percentage__c = 100;
		}
		if (o.p.Rate_Type__c=='SmartFixed') {
			r.Index_Rate_Percentage__c = 10; r.Fixed_Rate_Percentage__c = 90;
		}
		update r;

		return [select id, name, plan__r.name, plan__r.id, Confirmation_Code__c, 
		plan__r.rate_type__c, plan__r.rep_Profile__r.id, plan__r.contract_length__c,
		Confirmation_Code_Year__c, Price_Details__c, notes__c
		from rate__c where id =: r.id];
	}

	public static integer HowManyAreLeft(GasChoiceOffer o, premises__c thepremise){
		list<Rate__c> remaining = new list<rate__c>();
		//Ag
		if (thepremise.program__c=='Ag'){
			remaining = [select id from Rate__c 
			where plan__c =: o.p.id and Program__c = 'Ag' and Confirmation_Code_Status__c='Activated, not priced'];

			} else {  //Not ag
				remaining = [select id from Rate__c 
				where plan__c =: o.p.id and Program__c =: thepremise.Program__c and Division__c =: thepremise.Division__c and Confirmation_Code_Status__c='Activated, not priced'];
			}
			return remaining.size();
			
		}

		public static list<GasChoiceOffer> getResultsWideOpen(premises__c thepremise, map<Plan__c, map<String, decimal>> CustomerCosts, map<integer,decimal> usage, String programYear){
			String NormalIndexReference = GetIndexReferenceByPremise(thepremise);

			list<GasChoiceOffer> output = new list<GasChoiceOffer>();
			decimal totalusage = GasChoiceUtilities.getTotalUsage(usage);
			decimal blendFix = GasChoiceUtilities.getBlendFix(usage);
			decimal blendIndex = GasChoiceUtilities.getBlendIndex(usage);

		decimal discountFactor = GasChoiceUtilities.CalculateMarginVolumeDiscount(usage); //discount for margin adding        

		Plan__c i1 = new Plan__c();
		Plan__c i2= new Plan__c();

		//We need the index plan so that we can use that index cost for the SmartFixed DPA adder. Only want to do this once!
		for (Plan__c p:CustomerCosts.keyset()){
			if (p.Rate_Type__c=='Index' && p.Contract_Length__c==12){i1=p;}
			if (p.Rate_Type__c=='Index' && p.Contract_Length__c==24){i2=p;}
		}

		for (Plan__c p:CustomerCosts.keyset()){
			decimal termFactor = p.contract_length__c/12; 
			system.debug('==========calculating targets for plan ' + p.name +' with discount factor of ' + discountFactor); 
			
			if (p.Rate_Type__c=='SmartBill'){
				system.debug ('it is a smart bill');
				//get the SmartBill rate info
				//make the offer using that info
				GasChoiceOffer o = new GasChoiceOffer();
				o.p = p;
				o.FixedPrice = 0;
				o.IndexAdder = 0;
				system.debug('SBQ is ' + CustomerCosts.get(p).get('SBQ'));
				o.sbq = (CustomerCosts.get(p).get('SBQ')/p.contract_length__c).setscale(2);
				o.ProgramYear = ProgramYear;
				o.IndexReference = NormalIndexReference;
				o.estimatedFixedUsage = TotalUsage*termFactor;
				o.totalMargin = TotalUsage*termFactor*o.p.Margin_per_Dth__c;
				output.add(o);
			}
			else if (p.Rate_Type__c=='SmartCap'){
				//handled by something completely different!
			}
			else { //"simple" kinds of rates
				decimal PrimaryOffer;
				

				if (p.Rate_Type__c=='Index' || p.Rate_Type__c=='IndexNoSpread'){
						PrimaryOffer = RoundUpByResolution(CustomerCosts.get(p).get('Variable'), p.SG_Pricing_Resolution_Primary_Th__c*10); //keeping it in Dth for now					
						} else if (p.Rate_Type__c=='Fixed' || p.Rate_Type__c=='SmartFixed' || p.Rate_Type__c=='SmartBlended' || p.Rate_Type__c=='Blended'){
						PrimaryOffer = RoundUpByResolution(CustomerCosts.get(p).get('Fixed'), p.SG_Pricing_Resolution_Primary_Th__c*10); //keeping it in Dth for now
					}

					decimal PrimaryOfferMax = RoundUpByResolution(PrimaryOffer+p.Margin_per_Dth__c, p.SG_Pricing_Resolution_Primary_Th__c*10) ; //set it as a constant so it only has to be computed once
					decimal PrimaryOfferOriginal = PrimaryOffer; //for keeping track of the delta that we're up so far--blended should parallel

					do {
						//Construct the default offer as a starting point
						GasChoiceOffer o = ConstructOfferFromPlan(p, CustomerCosts, discountFactor, totalusage, termFactor, NormalIndexReference);
						//if (p.Rate_Type__c=='Index' || p.Rate_Type__c=='IndexNoSpread')
						//margin calc and setscale of the margin
						o = SetPricesMarginVolumes(i1, i2, o, CustomerCosts, totalusage, termFactor, PrimaryOffer, blendFix, blendIndex, PrimaryOfferOriginal, p.SG_Pricing_Resolution_Primary_Th__c*10); //all the logic to set pricing and margin by plan type
						o.PriceDetails = ConstructPriceDetails(GetIndexReferenceByPremise(thepremise), o);
						o.ProgramYear = ProgramYear;
						output.add(o); 
						PrimaryOffer = PrimaryOffer + p.SG_Pricing_Resolution_Primary_Th__c*10;

					} while (PrimaryOffer<PrimaryOfferMax); //keep adding the pricing resolution and creating an offer unless the offer price is above the target margin 

			}
			
		}              		
		return output;

	}

	public static list<GasChoiceOffer> AddIndexes(list<GasChoiceOffer> Incoming){
		integer x=0;
		for (GasChoiceOffer gco:incoming){
			gco.ListIndex = x;
			x=x+1;
		}
		return incoming;
	}

	

	public static String ConstructPriceDetails(String NormalIndexReference, GasChoiceOffer o){
		if (o.p.Rate_Type__c=='Index') return NormalIndexReference +  ' + $' + o.IndexAdder+ ' per therm';
		if (o.p.Rate_Type__c=='IndexNoSpread') return 'CIG + $' + o.IndexAdder+ ' per therm';
		if (o.p.Rate_Type__c=='Fixed') return '$' + o.FixedPrice+ ' per therm';
		if (o.p.Rate_Type__c=='SmartFixed') return '$' + o.FixedPrice+ ' per therm; 10% of usage at ' + NormalIndexReference +  ' + $' + o.IndexAdder + ' if lower';
		if (o.p.Rate_Type__c=='Blended') return '50% at $' + o.FixedPrice+ '; 50% at '+NormalIndexReference +  ' + $' + o.IndexAdder+ ' per therm';
		if (o.p.Rate_Type__c=='SmartBlended') return 'Nov-May at $' + o.FixedPrice+ '; Jun-Oct at '+NormalIndexReference +  ' + $' + o.IndexAdder+ ' per therm';
		if (o.p.Rate_Type__c=='SmartCap') return NormalIndexReference +  ' + $' + o.IndexAdder+ ' but never more than $'+o.FixedPrice+' per therm';

		if (o.p.Rate_Type__c=='SmartBill') return '$' + o.SBQ+ ' per month';
		return null;
	}

	public static GasChoiceOffer SetPricesMarginVolumes(plan__c i1, plan__c i2, GasChoiceOffer o, map<Plan__c, map<String, decimal>> CustomerCosts, decimal totalUsage, decimal termFactor, decimal PrimaryOffer, decimal blendFix, decimal blendIndex, decimal PrimaryOfferOriginal, decimal Resolution){
		//if(r.Fixed_Rate__c!=null)   o.estimatedFixedperUnitMargin=r.Fixed_Rate__c*10-CustomerCosts.get(p).get('Fixed'); 
		//if(r.Index_Adder__c!=null)  o.estimatedVariableperUnitMargin=r.Index_Adder__c*10-CustomerCosts.get(p).get('Variable');
		if (o.p.Rate_Type__c == 'Fixed' || o.p.Rate_Type__c =='SmartFixed'){
			o.FixedPrice = PrimaryOffer/10; //now, finally put it in Therms			
			o.estimatedVariableperUnitMargin=0;
			o.estimatedindexUsage=0;
			o.estimatedFixedUsage=TotalUsage*termFactor;		
			o.estimatedFixedperUnitMargin=PrimaryOffer-CustomerCosts.get(o.p).get('Fixed');
			o.totalMargin=o.estimatedFixedperUnitMargin*TotalUsage*termFactor;
			if (o.p.Rate_Type__c == 'SmartFixed'){
				if (o.p.Contract_Length__c == 12) o.IndexAdder = RoundUpByResolution(CustomerCosts.get(i1).get('Variable')+o.p.Margin_per_Dth__c, Resolution)/10; //full margin on the DPA, now converted into Therms
				if (o.p.Contract_Length__c == 24) o.IndexAdder = RoundUpByResolution(CustomerCosts.get(i2).get('Variable')+o.p.Margin_per_Dth__c, Resolution)/10; //full margin on the DPA, now converted into Therms
				} else {
					o.IndexAdder = 0;
				}
			}
			
			else if (o.p.Rate_Type__c=='SmartBlended'){
			o.FixedPrice = PrimaryOffer/10; //now, finally put it in Therms			
			o.IndexAdder = RoundUpByResolution(CustomerCosts.get(o.p).get('Variable')+PrimaryOffer-PrimaryOfferOriginal, Resolution)/10; //in therms
			o.estimatedFixedperUnitMargin=PrimaryOffer-CustomerCosts.get(o.p).get('Fixed');
			o.estimatedVariableperUnitMargin=o.IndexAdder*10-CustomerCosts.get(o.p).get('Variable'); //back to Dth for just a second :)
			o.estimatedindexUsage=blendIndex*termFactor;
			o.estimatedFixedUsage=blendFix*termFactor;
			o.totalMargin=(o.estimatedFixedperUnitMargin*o.estimatedFixedUsage+o.estimatedVariableperUnitMargin*o.estimatedindexUsage);		
			}
			else if (o.p.Rate_Type__c=='Blended'){
						o.FixedPrice = PrimaryOffer/10; //now, finally put it in Therms			
						o.IndexAdder = RoundUpByResolution(CustomerCosts.get(o.p).get('Variable')+PrimaryOffer-PrimaryOfferOriginal, Resolution)/10; //in therms
						o.estimatedFixedperUnitMargin=PrimaryOffer-CustomerCosts.get(o.p).get('Fixed');
						o.estimatedVariableperUnitMargin=o.IndexAdder*10-CustomerCosts.get(o.p).get('Variable'); //back to Dth for just a second :)
			o.estimatedindexUsage=TotalUsage*.5*termFactor;
			o.estimatedFixedUsage=TotalUsage*.5*termFactor;
			o.totalMargin=(o.estimatedFixedperUnitMargin*o.estimatedFixedUsage+o.estimatedVariableperUnitMargin*o.estimatedindexUsage);			
			}
			else if (o.p.Rate_Type__c=='Index' || o.p.Rate_Type__c=='IndexNoSpread'){
				o.IndexAdder = PrimaryOffer/10;
				o.FixedPrice = 0;
						o.estimatedVariableperUnitMargin=o.IndexAdder*10-CustomerCosts.get(o.p).get('Variable'); //back to Dth for just a second :)
			o.estimatedindexUsage=TotalUsage*termFactor;
			o.totalMargin=o.estimatedVariableperUnitMargin*o.estimatedindexUsage;
			o.estimatedFixedUsage=0;
			}


			o.totalMargin=o.totalMargin.setscale(2);
			return o;
			}

	//the things that are common among all rate types
	public static GasChoiceOffer ConstructOfferFromPlan(Plan__c p, map<Plan__c, map<String, decimal>> CustomerCosts, decimal discountFactor, decimal totalUsage, decimal termFactor, string NormalIndexReference){
		GasChoiceOffer o = new GasChoiceOffer();
		o.p = p; //set the plan
		o.targetFixedBeforeMargin=(CustomerCosts.get(p).get('Fixed')).setscale(4); 
		system.debug('================================FixedTargetBeforeMargin' + o.targetFixedBeforeMargin);
		o.targetIndexBeforeMargin=(CustomerCosts.get(p).get('Variable')).setscale(4);
		system.debug('================================VariableTargetBeforeMargin' + o.targetIndexBeforeMargin);
		system.debug('================================MarginPerTherm is' + p.Margin_per_Dth__c);
		system.debug('================================Discount Factor  is' + discountFactor);
		o.targetFixedAfterMargin=o.targetFixedBeforeMargin+p.Margin_per_Dth__c*discountFactor;
		o.targetIndexAfterMargin=o.targetIndexBeforeMargin+p.Margin_per_Dth__c*discountFactor;
		o.discountFactor=discountFactor;
		o.estimatedTotalUsage=TotalUsage*termFactor;

		o.estimatedTotalUsage=TotalUsage*termFactor;
		system.debug('Contructed Offer: ' + o);

		if ( p.Rate_Type__c=='IndexNoSpread'){
			o.IndexReference = 'CIG';
			} else {
				o.IndexReference = NormalIndexReference;
			}
		return o;
	}

			public static list<GasChoiceOffer> getResults(premises__c thepremise, map<Plan__c, map<String, decimal>> CustomerCosts, map<integer,decimal> usage, String programYear){
				list<GasChoiceOffer> output = new list<GasChoiceOffer>();
				decimal totalusage = GasChoiceUtilities.getTotalUsage(usage);
				decimal blendFix = GasChoiceUtilities.getBlendFix(usage);
				decimal blendIndex = GasChoiceUtilities.getBlendIndex(usage);

								decimal discountFactor = GasChoiceUtilities.CalculateMarginVolumeDiscount(usage); //discount for margin adding        
								map<Plan__c, map<String, decimal>> targets = new map<Plan__c, map<String, decimal>>();
								list<rate__c> ConfirmationCodes = new list<rate__c>();
								decimal fixedTarget=0;
								decimal varTarget=0;
								
								for (Plan__c p:CustomerCosts.keyset()){
									system.debug('==========calculating targets for plan ' + p.name +' with discount factor of ' + discountFactor); 
									if (p.Rate_Type__c=='SmartBill'){
										system.debug ('it is a smart bill');
																//get the SmartBill rate info
																list<rate__c> thisRate = [select id, name, plan__r.name, plan__r.id, Plan__c, Confirmation_Code__c, Confirmation_Code_Year__c, Index_Reference__r.Name,
																Price_Details__c, notes__c, plan__r.Rate_Type__c, plan__r.contract_length__c, plan__r.plan_description__c,Fixed_Rate__c, Index_Adder__c
																from rate__c where plan__r.id=:p.id and division__c =: thepremise.division__c and Confirmation_Code_Year__c=:ProgramYear];
																//make the offer using that info
																if (!thisRate.isempty()){
																	GasChoiceOffer o = new GasChoiceOffer();
																	o.r = thisRate[0];
																	system.debug('SBQ is ' + CustomerCosts.get(p).get('SBQ'));
																	o.sbq = (CustomerCosts.get(p).get('SBQ')/p.contract_length__c).setscale(2);
																	output.add(o);
																}
															}
															if (p.Rate_Type__c=='Fixed' || p.Rate_Type__c=='SmartFixed' || p.Rate_Type__c=='SmartCap' || p.Rate_Type__c=='SmartBlended' || p.Rate_Type__c=='Blended'){
																fixedTarget = CustomerCosts.get(p).get('Fixed')+p.Margin_per_Dth__c*discountFactor; system.debug('=============================================== fixed target is ' + fixedtarget + ' per Dth');
																} else fixedTarget=0;
																if (p.Rate_Type__c=='Index' || p.Rate_Type__c=='IndexNoSpread' || p.Rate_Type__c=='SmartCap' || p.Rate_Type__c=='SmartBlended' || p.Rate_Type__c=='Blended'){
																	varTarget = CustomerCosts.get(p).get('Variable')+p.Margin_per_Dth__c*discountFactor; system.debug('=============================================== var target is ' + varTarget + ' per Dth');
																	} else varTarget=0;

																	if (p.Rate_Type__c != 'SmartBill'){
												//Pull all rates with positive margin, up to and including the target margin
												list<String> FixedStuff = new list<String>{'SmartFixed', 'Fixed', 'Blended', 'SmartBlended', 'SmartCap'};
												system.debug('Plan is ' + p);
												system.debug('Fixed Customer Costs:  ' + CustomerCosts.get(p).get('Fixed'));
												system.debug('Var Customer Costs:  ' + CustomerCosts.get(p).get('Variable'));
												
												system.debug('Fixed target is ' + FixedTarget);
												system.debug('Var target is   ' + varTarget);

												list<rate__c> ConfirmationCodesTargets =[select id, name, plan__r.name, plan__r.id, Plan__c, Confirmation_Code__c, Confirmation_Code_Year__c, Index_Reference__r.Name,
												Price_Details__c, notes__c, plan__r.Rate_Type__c, plan__r.contract_length__c, plan__r.plan_description__c,Fixed_Rate__c, Index_Adder__c
												from rate__c
												where SG_available_for_dynamic__c = true
												and plan__r.Rate_Type__c != 'SmartBill'                                
												and plan__r.id =: p.id and Confirmation_Code_Year__c =: ProgramYear and plan__r.REP_Profile__r.name = 'CenterPoint Energy Services'
												and ((Fixed_Rate__c != 0 and Fixed_Rate__c!=null) or plan__r.Rate_Type__c not in: FixedStuff)
												and Index_Adder__c!=0
												and (Fixed_Rate__c <=: FixedTarget/10 or Fixed_Rate__c=null or Fixed_Rate__c= 0 or plan__r.Rate_Type__c = 'Index' or plan__r.Rate_Type__c='IndexNoSpread')
												and (Index_Adder__c <=: varTarget/10 or  Index_Adder__c=null or plan__r.Rate_Type__c = 'SmartFixed' or plan__r.Rate_Type__c = 'Fixed')
												and (Fixed_Rate__c >=: CustomerCosts.get(p).get('Fixed')/10 or Fixed_Rate__c=null or Fixed_Rate__c= 0 or plan__r.Rate_Type__c = 'Index' or plan__r.Rate_Type__c='IndexNoSpread') //going for the target margin
												and (Index_Adder__c >=: CustomerCosts.get(p).get('Variable')/10 or  Index_Adder__c=null or plan__r.Rate_Type__c = 'SmartFixed' or plan__r.Rate_Type__c = 'Fixed') //going for the target margin
												and
												((Program__c =: thepremise.Program__c and Division__c =: thepremise.Division__c)
													or 
													(Program__c =: thepremise.Program__c and Program__c = 'Ag')
													or
													(Program__c =: thepremise.Program__c and Program__c='Nebraska' and Division__c ='Default'))                               
];
												if (ConfirmationCodesTargets.isempty()){ //if there were none within the target range, grab any code higher than the target
													ConfirmationCodesTargets =[select id, name, plan__r.name, plan__r.id, Plan__c, Confirmation_Code__c, Confirmation_Code_Year__c, Index_Reference__r.Name,
													Price_Details__c, notes__c, plan__r.Rate_Type__c, plan__r.contract_length__c, plan__r.plan_description__c,Fixed_Rate__c, Index_Adder__c
													from rate__c
													where SG_available_for_dynamic__c = true
													and plan__r.Rate_Type__c != 'SmartBill'                                
													and plan__r.id =: p.id and Confirmation_Code_Year__c =: ProgramYear and plan__r.REP_Profile__r.name = 'CenterPoint Energy Services'
													and (Fixed_Rate__c != 0 or plan__r.Rate_Type__c not in: FixedStuff)
													and Index_Adder__c!=0

													and (Fixed_Rate__c >=: CustomerCosts.get(p).get('Fixed')/10 or Fixed_Rate__c=null or Fixed_Rate__c= 0 or plan__r.Rate_Type__c = 'Index' or plan__r.Rate_Type__c='IndexNoSpread') //going for the target margin
													and (Index_Adder__c >=: CustomerCosts.get(p).get('Variable')/10 or  Index_Adder__c=null or plan__r.Rate_Type__c = 'SmartFixed' or plan__r.Rate_Type__c = 'Fixed') 
													and
													((Program__c =: thepremise.Program__c and Division__c =: thepremise.Division__c)
														or 
														(Program__c =: thepremise.Program__c and Program__c = 'Ag')
														or
														(Program__c =: thepremise.Program__c and Program__c='Nebraska' and Division__c ='Default'))                               
order by Fixed_Rate__c ASC, Index_Adder__c ASC limit 1
];
}
												if (ConfirmationCodesTargets.isempty() || ConfirmationCodesTargets.size()==1){ //and then if it's still empty
																//set notice
																/*GasChoiceCalcInputs__c gcci = GasChoiceCalcInputs__c.getOrgDefaults();
																				ExceptionalChatter.PostChatter(
																				'Plan ' + p.name + ' for division ' + thepremise.division__c + 'had ' + ConfirmationCodesTargets.size() + 'confirmation codes with sufficient margin to offer for premise ' + thepremise.id,
																				gcci.Pricing_Manager_UserID__c,
																				'Gas Choice Nebraska/Wyoming'
																				);*/
system.debug('Plan ' + p.name + ' for division ' + thepremise.division__c + 'did not have any confirmation codes with sufficient margin to offer for premise ' + thepremise.id);

}

if (!ConfirmationCodesTargets.isempty()){
												//expected case. Build the offers
												for (rate__c r:ConfirmationCodesTargets){
													try{
														decimal termFactor = r.plan__r.contract_length__c/12; 
														GasChoiceOffer o = new GasChoiceOffer();
														o.r=r;
														system.debug('doing this rate: '+o.r);
														o.targetFixedBeforeMargin=(CustomerCosts.get(p).get('Fixed')).setscale(4); 
														system.debug('================================FixedTargetBeforeMargin' + o.targetFixedBeforeMargin);
														o.targetIndexBeforeMargin=(CustomerCosts.get(p).get('Variable')).setscale(4);
														system.debug('================================VariableTargetBeforeMargin' + o.targetIndexBeforeMargin);
														system.debug('================================MarginPerTherm is' + p.Margin_per_Dth__c);
														system.debug('================================Discount Factor  is' + discountFactor);
														o.targetFixedAfterMargin=o.targetFixedBeforeMargin+p.Margin_per_Dth__c*discountFactor;
														o.targetIndexAfterMargin=o.targetIndexBeforeMargin+p.Margin_per_Dth__c*discountFactor;
														if(r.Fixed_Rate__c!=null)   o.estimatedFixedperUnitMargin=r.Fixed_Rate__c*10-CustomerCosts.get(p).get('Fixed'); 
														if(r.Index_Adder__c!=null)  o.estimatedVariableperUnitMargin=r.Index_Adder__c*10-CustomerCosts.get(p).get('Variable');
																								//now lets calculate total margin
																								system.debug('before rate types are considered: '+o);
																								
																								if (p.Rate_Type__c=='SmartFixed' || p.Rate_Type__c == 'Fixed'){
																									o.totalMargin=o.estimatedFixedperUnitMargin*TotalUsage*termFactor;
																									o.estimatedindexUsage=0;
																									o.estimatedFixedUsage=TotalUsage*termFactor;

																								}
																								else if (p.Rate_Type__c=='SmartBlended'){
																									o.totalMargin=o.estimatedFixedperUnitMargin*blendFix+o.estimatedVariableperUnitMargin*blendIndex*termFactor;
																									o.estimatedindexUsage=blendIndex*termFactor;
																									o.estimatedFixedUsage=blendFix*termFactor;
																								}
																								
																								else if (p.Rate_Type__c=='Index' || p.Rate_Type__c=='SmartCap' ||  p.Rate_Type__c=='IndexNoSpread'){
																									o.totalMargin=o.estimatedVariableperUnitMargin*TotalUsage*termFactor;
																									o.estimatedindexUsage=TotalUsage*termFactor;
																									o.estimatedFixedUsage=0;
																								}
																								else if (p.Rate_Type__c=='Blended'){
																									o.totalMargin=(o.estimatedFixedperUnitMargin*TotalUsage*.5*termFactor+o.estimatedVariableperUnitMargin*TotalUsage*.5*termFactor);
																									o.estimatedindexUsage=TotalUsage*.5*termFactor;
																									o.estimatedFixedUsage=TotalUsage*.5*termFactor;
																								}
																								//everything does this
																								if (p.Rate_Type__c!='SmartBill'){
																									o.discountFactor=discountFactor;
																									o.totalMargin=o.totalMargin.setscale(2);                    
																									o.estimatedTotalUsage=TotalUsage*termFactor;
																									output.add(o); 
																									system.debug('added: ' + o);
																								}
																								}catch(exception e){}
																							}
																						}
																					}              
																				}
																				return output;
																			}

																			public static list<GasChoiceOffer> ReturnOnlyHighestOne(list<GasChoiceOffer> incoming){
																				if (incoming.size()<=1) return incoming;

																				list<GasChoiceOffer> output = new list<GasChoiceOffer>();
																				output.add(incoming[0]);
																				for (integer k=1; k<incoming.size()-1; k++){
			//if it's a different plan than the one we just did?
			if (incoming[k].p.name != incoming[k-1].p.name){
				output.add(incoming[k]);
				} else { //otherwise, it's the same plan, so compare its margin?
				if (incoming[k].totalMargin>output[output.size()-1].totalMargin){
						//if this plan has higher margin, replace it in the output;
						output[output.size()-1]=incoming[k];  
					}
				}
			}
			return output;

		}

	//resolution should be "the nearest", for example, .01 for nearest hundredth, 5 for nearest 5, etc.
	public static decimal RoundUpByResolution(decimal ToRound, decimal Resolution){
		return Math.ceil(ToRound*(1/Resolution))*Resolution;
	}   
}