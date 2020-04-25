public class HSPSController {

    public list<HSP_S__c> objlist {get;set;}
    
    public HSPSController() {

        objlist = [SELECT 
            Name,
            Headline__c, 
            Product_Body__c,
            Product_Name__c,
            Active__c, 
            Activation_Date__c, 
            Confirmation_Name__c, 
            Icon__c, 
            Plan_Id__c, 
            Price_List__c, 
            Price_Net__c, 
            Product_Details_Link__c, 
            Terms_URL__c,
            sort_order__c,
            downsell__c,
            leading__c
        FROM HSP_S__c WHERE Active__c = true ORDER BY sort_order__c];
        
    }    
}