public with sharing class ControllerforContactUs {
    
    public truecost_case__C tcc {get; set;}{tcc=new truecost_case__c();}
    public boolean Page1 {get;set;}{Page1=true;}
    
    public ControllerforContactUs(){
    	
    	if (userinfo.getName()!='TrueCost Site Guest User' ){
	    	tcc.Caller_Name__c = UserInfo.getName();
	    	tcc.Account__c = TrueCostUtilities.getTheAccount(  UserInfo.getUserId()  ) ;
	    	tcc.Non_Account_Email__c = userinfo.getUserName();
    	}
    }
    
    
    
    public void saveCase(){
        page1=false;
        tcc.origin__c='web';
        tcc.Entity_Type__c='Customer';
        insert tcc;
        
    }
   }