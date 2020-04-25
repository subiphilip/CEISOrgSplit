public class ControllerForFeeDisplay {
    public id therateid {get;set;}
    
    public rate__c getthefees(){
        list<rate__c> theratelist = new list<rate__C>();
        theratelist = [select id, plan__r.REP_Profile__r.name, 
                            cancellation_fee__c, Cancellation_Fee_Type__c, Cancellation_Fee_Description__c,
                       		
                            Alternate_Payment_Surcharge__c, 
                            Changed_Start_Date_Fee__c, Same_Day_Move_In_Fee__c, Move_in_Fee__c,
                            Disconnect_Fee__c, Reconnect_Fee__c, Excessive_Payments_Fee__c, 
                            Late_Payment_Fee__c, 
                            Standard_Move_In_for_New_Meters__c, 
                            Insufficient_Funds_Cancelled_Checks__c,  Reminder_Fee__c,
                            Manual_Assistance_Fee__c, Paper_Bill_Request_Fee__c, Third_Party_Payment_Fee__c, Self_Selected_Switch_Fee__c,
                       		Minimum_Usage_Charge__c, Minimum_Usage_Charge_Threshold_kWh__c,
                            Minimum_Usage_Charge2__c, Minimum_Usage_Charge_Threshold2__c,
                            Minimum_Usage_Charge3__c, Minimum_Usage_Charge_Threshold3__c,
                            Usage_Discount_Amount__c, Usage_Discount_Minimum__c,
                       	    Monthly_Base_Charge__c, Zero_Usage_Fee__c
                            from rate__c where id =: therateid];
        return theratelist[0];
    }
    
    
    
}