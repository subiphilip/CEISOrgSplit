public class ControllerForElectricCompanies {

    public static list<rep_profile__c> getreplist() {              
        return [select id, name, Logo_URL__c, Friendly_Url__c, Star_Rating_Avg__c, total_reviews__c, About_Us__c from rep_profile__c where active__c=true order by random_number_for_sorting__c, lastmodifieddate DESC];
        
    }

    public static list<rep_profile__c> getInactiveReplist() {              
        return [select id, name, Star_Rating_Avg__c, total_reviews__c from rep_profile__c where active__c=false 
        	and Publish_Reviews_while_Inactive__c = true
        order by random_number_for_sorting__c, lastmodifieddate DESC];
        
    }
}