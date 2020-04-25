public class ControllerforSelectedPlanEnroll {
	public rate__c myrate {get;set;}

	/*public rate__c myrate{get;set;}{
	
				rate__c myrate = new rate__C();
				myrate=[select id, X1000_kWh_rate__c,  TOS_Url__c, YRAC_Url__c, EFL_Url__c,
                                                    plan__r.name,
                                                    plan__r.contract_length__c,
                                                    plan__r.plan_id__c,
                                                    plan__r.REP_profile__r.logo_url__c, 
                                                    plan__r.REP_profile__r.name,
                                                    plan__r.REP_profile__r.Fax_Number__c, 
                                                    plan__r.REP_profile__r.Customer_Service_Email__c,
                                                    plan__r.REP_profile__r.Home_Page__c,
                                                    plan__r.REP_profile__r.Mailing_City__c,
                                                    plan__r.REP_profile__r.Mailing_State__c,
                                                    plan__r.REP_profile__r.Mailing_Street_Address__c,
                                                    plan__r.REP_profile__r.Mailing_Zip__c,
                                                    plan__r.REP_profile__r.PUCT_License_Number__c,
                                                    plan__r.REP_profile__r.Legal_Name__c,
                                                    plan__r.REP_profile__r.Customer_Service_Phone_Number__c,
                                                    plan__r.Renewable_Content__c
                                                                            
        			from rate__c where id=:theplan.id limit 1];
	}*/
}