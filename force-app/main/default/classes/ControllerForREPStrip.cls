public class ControllerForREPStrip {
	
	public static list<REP_Profile__c> getREPs(){
        return [select id, name, about_us__c, Logo_URL__c, friendly_url__c, lastmodifieddate, Star_Rating_Avg__c from REP_Profile__c where active__c=true order by random_number_for_sorting__c, lastmodifieddate DESC];
    }

}