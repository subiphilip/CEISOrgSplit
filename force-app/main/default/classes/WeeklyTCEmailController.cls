public with sharing class WeeklyTCEmailController {


	public string APAid {get;set;}
	private list<daily_usage__c> Last7;

	public WeeklyTCEmailController() {
		
	}

	public string GetDays(){
		if (Last7 == null) SetAllData();

		string output = '';
		
		for (integer x=6; x>=0; x--){ //for each day
			output=output+(string.valueof(last7[x].total_for_the_day__c))+',';			
		}
		output = output.substringBeforeLast(',');
		return output;
	}	

	public void SetAllData(){
		system.debug('The APA is ' + apaid);
		if (Last7==null){
			Last7 = [select id, date__c, Intervals__c, Max_for_the_day__c, Day_of_Week__c, total_for_the_day__c from daily_usage__c where Account_Premise_Association__c =: APAid and Account_Premise_Association__c!=null order by date__c DESC limit 7];
			
		}
	}

	public list<daily_usage__c> GetLast7(){
		if (Last7 == null) SetAllData();
		return last7;
	}

	public date GetEnddate(){
		if (Last7 == null) SetAllData();
		return Last7[0].date__c;
	}

	public date GetStartdate(){
		if (Last7 == null) SetAllData();
		return Last7[6].date__c;
	}

	public decimal GetWeekMax(){
		if (Last7 == null) SetAllData();
		
		decimal output =0;
		for (daily_usage__c du:Last7){
			output = math.max(output, du.Max_for_the_day__c);
		}
		return output;
	}

}