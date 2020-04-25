global class PIIViewController{
	
    @RemoteAction
        global static order__c getRemoteREPOrder(string orderid, string flavor){
            if (flavor=='cc'){
            return [SELECT id,
                Payment_Card_3_digit_code__c, Payment_Card_Address_City__c, Payment_Card_Address_Line_1__c,
                Payment_Card_Address_State__c, Payment_Card_Address_Zip__c,  Payment_Card_Month__c, Payment_Card_Year__c, 
                Payment_Card_Number__c, Payment_Card_Type__c, Name_as_it_appears_on_Payment_Card__c 
                from order__c where id =: orderid];
            }
            
            if (flavor=='ssn'){
            	return [SELECT id, ssn__c from order__c where id =: orderid];
            }
            
            return null; //just in case
        }
    
       
    
    
    
}