public with sharing class ControllerForAnonymousRating {
	public REP_Rating__c newrating{get;set;}
	public boolean showAttachment{get;set;} 
	public boolean showSubmit {get;set;} 
	public attachment A {Get;set;}
    
	
	
	public ControllerForAnonymousRating(){
		newrating = new REP_Rating__c();
		showAttachment = false;
		showSubmit = true;
		attachment A = new attachment();
	}	
	public pageReference saverating(){
    	
	    insert newrating;
	   
	    showAttachment=true;
	    showSubmit=false;
		return null;
	}
	
	public string fileName   
    {    get;set;    }  
      
    public Blob fileBody   
    {    get;set;    }  
    
    public PageReference UploadFile()  
    {  
        PageReference pr;  
       
        if(fileBody != null && fileName != null && fileName.length() > 0)  
        {  
          A = new attachment();
          a.name=filename;
          a.Body=filebody;  
          a.ParentId = newRating.id;
          try {
          
          insert a;  
          ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'File uploaded successfully'));
          } catch (DMLException e) {

      		ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading file'+e));

      

    } finally {

      A.body = null; // clears the viewstate

      new attachment();

    }
          
           
          
       showSubmit=true;
        return page.myaccount;  
        }else{
        return null;
        }
        
    } 
	
	
	
	//methods for the stars
    public void its1(){newrating.Rating__c=1;}
	public void its2(){newrating.Rating__c=2;}
	public void its3(){newrating.Rating__c=3;}
	public void its4(){newrating.Rating__c=4;}
	public void its5(){newrating.Rating__c=5;}
	
	
}