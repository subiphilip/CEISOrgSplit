/*
2/1/2012	Shane McLaughlin	Converted Premise query to a list to avoid "no rows" errors

*/
public with sharing class Reminders {
	public premises__c prem {get;set;}
    public account acct {get;set;}
    public date expirationdate {Get;set;}
    public string email{Get;set;}
    public lead newlead {get;set;} 
	
	public Reminders(){
        newlead = new lead();
		list<premises__c> premlist = [select id, Current_Plan_Expiration_not_TrueCost__c from premises__c where id =: TrueCostUtilities.getThePremise(UserInfo.getUserId())];
		if (premlist.size()>0){
			prem=premlist[0];
		} else prem=new premises__c();
        
        list<Account> acctlist = [select id, Current_Plan_Expiration__c from account where id=:TrueCostUtilities.getTheAccount(UserInfo.getUserId())];
        if (acctlist.size()>0){
            acct=acctlist[0];
        } 
        if (prem.id!=null && prem.Current_Plan_Expiration_not_TrueCost__c!=null){
            acct.Current_Plan_Expiration__c = prem.Current_Plan_Expiration_not_TrueCost__c;
        }
		
	}
	
	public pagereference save(){
        acct.Current_Plan_Expiration__c = prem.Current_Plan_Expiration_not_TrueCost__c; //gonna keep this in multiple places for now.
        if (prem.id!=null){
            update prem;      
        }
        update acct;
		return null;
    }
    
    public pageReference saveGuest(){
        list<account> dupeAcct = [select id, Current_Plan_Expiration__c from account where PersonEmail =: newlead.email limit 1];
        if(dupeAcct.isempty()){
            lead l = new lead();
                try{
                    l=[select id from lead where email =: newlead.email limit 1];
                    l.Current_Plan_Expiration__c = newlead.Current_Plan_Expiration__c;
                    update l;
                }catch(exception e){                    
                        l.lastname='Not Set';
                        l.email = newlead.email;
                        //l.SFGA__Web_Source__c = 'Expiration Reminder Request';
                        insert l;
                    } 
              
            return page.homepage;
        } else { //there's already a registered account for that customer
            dupeAcct[0].Current_Plan_Expiration__c = newlead.Current_Plan_Expiration__c;
            update dupeAcct;
            return page.homepage;
        }
        return null; //shouldn't happen--should be one of the two.
    }

	
	@RemoteAction
	public static void RemindersRemote(string email, string JSONdate){
		string queryEmail = '%' + email + '%';
		list<account> dupeAcct = [select id, Current_Plan_Expiration__c from account where PersonEmail like: queryEmail limit 1];
        if(dupeAcct.isempty()){
            lead l = new lead();
                try{
                    l=[select id,Current_Plan_Expiration__c  from lead where email like: queryEmail limit 1];
                    l.Current_Plan_Expiration__c = date.valueOf(JSONdate);
                    update l;
                }catch(exception e){                    
                        l.lastname='Not Set';
                        l.Current_Plan_Expiration__c = date.valueOf(JSONdate);
                        l.email = email;
                        //l.SFGA__Web_Source__c = 'Expiration Reminder Request';
                        insert l;
                    } 
        } else { //there's already a registered account for that customer
            dupeAcct[0].Current_Plan_Expiration__c = date.valueOf(JSONdate);
            update dupeAcct;            
        }
	}	


}