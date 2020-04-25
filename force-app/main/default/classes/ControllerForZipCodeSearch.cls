public with sharing class ControllerForZipCodeSearch {

    public String getSearchText() {
    return null;
    }
    private List<ValidZipCode__c> result = new List<ValidZipCode__c>();
    private String searchText;
    public ControllerForZipCodeSearch(){}
    public List<ValidZipCode__c> getResult() {return result;}

    public void setSearchText(String searchText){
        this.searchText = searchText; 
        }
    public PageReference search(){
        result = [select Name from ValidZipCode__c Where Name like :searchText ];
        return null;    
    }
    
    public PageReference navigate(){
        PageReference acctPage = Page.W2LforCallCenter;
        acctPage.setRedirect(true);
        return acctPage;
        
    
    
    
    }
    

    
}