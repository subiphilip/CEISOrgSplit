public class fpqAlerts {
	
	public static void CheckQuote(id quoteId){

		Fixed_Quote__c fpq = sharedQuery(quoteId);		
		//did a contract rollOff?

		list<FQPosition> positions = FixedQuoteToContract.quoteJSON2Positions(fpq.Position_List_JSON__c);

		//to handle expiring quotes!!

		date PromptMonthLastTrading = [select id, Prompt_Month_Last_Trading_Day__c from Index__c where Entegrate_Index_Key__c = 'NYMEX Master'].Prompt_Month_Last_Trading_Day__c;

		if (fpq.Start_Date__c < PromptMonthLastTrading){
			string ChatterText = 'Pricing Alert: Quote for ' +fpq.Opportunity__r.Name + 'has expired.  To reactivate your alert, change the start date and update the alert prices.';
			ChatterUtils.mentionOnRecord(fpq.Opportunity__c, fpq.Opportunity__r.OwnerId, ChatterText);
			fpq.Notifications_On__c = false;
			update fpq;
			return;
		}

		//OK, if you got this far, then the quote isn't expiring.

		map<date, decimal> NYMEX = new map<date, decimal>();
		map<date, decimal> Basis = new map<date, decimal>();


		if (fpq.Lock_Type__c == 'Lock Citygate' || fpq.Lock_Type__c == 'Lock NYMEX'){			
			//get the nymex
			NYMEX = GasChoiceUtilities.getStrips(new String[]{'NYMEX'}, true).get('NYMEX');

			//update the positions		
			for (FQPosition p:positions){
				decimal NewNymex = NYMEX.get(dateTimeToDate(p.Contract_Month));
				p.Customer_Price = p.Customer_Price + NewNymex-p.DT_NYMEX ;
				p.DT_NYMEX = NewNymex;
			}
		
		}
		if (fpq.Lock_Type__c == 'Lock Citygate' || fpq.Lock_Type__c == 'Lock Basis'){
			//get the basis
			Basis = GasChoiceUtilities.getStrips(new String[]{fpq.Index__r.Name}, true).get(fpq.Index__r.Name);

			//update the positions
			for (FQPosition p:positions){
				decimal NewBasis = Basis.get(dateTimeToDate(p.Contract_Month));
				p.Customer_Price = p.Customer_Price + NewBasis-p.DT_Basis ;
				p.DT_Basis = NewBasis;
			}		
		}
		//re-wacog and save price
		fpq.Price_at_Last_Check__c = wacog(positions);
		fpq.Last_Notification_Price_Check__c = system.now();

		string ChatterText;

		//price checks and chatter calls
		if (fpq.Price_at_Last_Check__c >= fpq.Notify_above__c){
			ChatterText = ' The price for ' +fpq.Opportunity__r.Name+'exceeded your threshold of '+fpq.Notify_above__c+'. It is now ' + fpq.Price_at_Last_Check__c+ '.  See '+fpq.Name+' below. #FixedPriceAlert';

		} else if (fpq.Price_at_Last_Check__c <= fpq.Notify_below__c){
			ChatterText = ' The price for ' +fpq.Opportunity__r.Name+' went below your threshold of '+fpq.Notify_below__c+'. It is now ' + fpq.Price_at_Last_Check__c + '.  See '+fpq.Name+' below. #FixedPriceAlert';
		}

		//if there was anything to say, say it:
		if (ChatterText!=null){
			ChatterUtils.mentionOnRecord(fpq.Opportunity__c, fpq.Opportunity__r.OwnerId, ChatterText);
			fpq.Notifications_On__c = false;
		}

		update fpq;


	}

	public static Fixed_Quote__c sharedQuery(id quoteId){
		return [select Id, Name, Index__r.Name, Notifications_On__c, Notify_above__c, Notify_below__c, Opportunity__c, Opportunity__r.OwnerId, Opportunity__r.Name, Position_List_JSON__c, Price__c, Price_at_Last_Check__c, Sales_Rep__c,Start_Date__c, Status__c, Term__c, Utility__c, Volume__c, WACOG_Position_JSON__c,  Margin__c, Lock_Type__c, Cost__c, Account__c, Account__r.Name from Fixed_Quote__c where id =: quoteId];
	} 

	public static date dateTimeToDate(datetime dt){
		return date.newinstance(dT.year(), dT.month(), dT.day());
	}

	public static decimal Wacog(list<FQPosition> positions){
		//get the total
		decimal runningTotal = 0;
		for (FQPosition p:positions){
			runningTotal = runningTotal + p.Volume;
		}		

		decimal output = 0;

		for (FQPosition p:positions){
			output = output + p.Customer_Price*(p.Volume/runningTotal);
		}	

		return output.setScale(4);
	}

}