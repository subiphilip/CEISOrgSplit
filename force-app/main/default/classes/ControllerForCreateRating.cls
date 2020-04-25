public class ControllerForCreateRating {
    
    public rep_rating__c newrating{get; set;}
    public account whichaccount{get;set;}
    public order__c CurrentPlan{get;set;}    
    
    public ControllerForCreateRating(){
        try{
            newrating = [select id, Author__c, Review__c, wants_contact__c, REP_Profile__c, Rating__c, Order__c, Plan__c from rep_rating__c where id =:ApexPages.CurrentPage().GetParameters().get('ratingid')];
                } catch (exception e){
                    newrating=new rep_rating__c(); 
                    newrating.Rating__c=5;
                }
        try{
            whichaccount=[select id, ispersonaccount, Personemail, phone, Billing_Adrs_Line_1__c, Billing_Adrs_Line_2__c, Billing_City__c, State__c, Billing_zip_code__c from account where id=:TrueCostUtilities.getTheAccount(UserInfo.getUserId()) limit 1];
        } catch (exception e){whichaccount = new account();}
        try{
            CurrentPlan= [select id, parent_account__r.id, rep_profile__r.name, rep_profile__r.id, plan__r.id from order__c where id=:ApexPages.CurrentPage().GetParameters().get('orderid')];
        } catch (exception e){}
    }
    
    public pageReference saverating(){
        try{
            if(whichaccount.id == CurrentPlan.Parent_Account__r.id){
                newrating.Author__c=whichaccount.id;
                newrating.REP_Profile__c=CurrentPlan.REP_Profile__R.id;
                newrating.Order__c=CurrentPlan.id;
                newrating.Plan__c=CurrentPlan.plan__r.id;
                upsert newrating;
            } else {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'There has been an error saving your review.');
                ApexPages.addMessage(myMsg);
                return null;
            }
        } catch(exception e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'There has been an error saving your review.');
            ApexPages.addMessage(myMsg);
            return null;
        }
        
    return Page.Myaccount;        
}
    
 
//Methods to set valus on Rating Stars

public void its1(){newrating.Rating__c=1;}
public void its2(){newrating.Rating__c=2;}
public void its3(){newrating.Rating__c=3;}
public void its4(){newrating.Rating__c=4;}
public void its5(){newrating.Rating__c=5;}


    public list<rep_rating__c> getRecentReviews(){        
        return TrueCostUtilities.getRatingsForREP(CurrentPlan.REP_profile__r.id);
    }
    
}