public class W2L {
    
    public lead l {get;set;}
    public boolean saved {get;set;}
    public string WebSource {get;set;}
    public string LeadSource {get;set;}
        
    public W2L(){
        saved=false;
        l = new lead(); 
        //l.SFGA__Web_Source__c=WebSource; 
        l.leadsource = LeadSource;
    }
    
    public pageReference saveL(){
        try{
            insert l;
        } catch (exception e){return null;}
        saved = true;
        return null;
    }
    
    public pageReference reload(){
    saved = false;
        PageReference PR = Page.W2L;
        PR.setredirect(true);
        return pr;
    }
}