public class VariableRatesController {
	
	public static list<REP_Profile__c> getREPs(){
        return [select id, name, 
        	Curent_CEHE__c, CEHE_Variable_Rate_Last_Updated__c,
			Current_Oncor_Variable_Rate_cents__c, Oncor_Variable_Rate_Last_Updated__c,
			Current_TNMP_Variable_Rate_cents__c, TNMP_Variable_Rate_Last_Updated__c,
			Current_AEPC_Variable_Rate_cents__c, AEPC_Variable_Rate_Last_Updated__c,
			Current_AEPN_Variable_Rate_cents__c, AEPN_Variable_Rate_Last_Updated__c			
			
        	from REP_Profile__c where Curent_CEHE__c!=null and CEHE_Variable_Rate_Last_Updated__c!=null order by Curent_CEHE__c DESC];
    }

}