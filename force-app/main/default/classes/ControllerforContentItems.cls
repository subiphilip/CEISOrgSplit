/*
1/24/2012   Shane McLaughlin        Added if statement for control of whether only approved content can be shown
*/

public class ControllerforContentItems {    
    public string whichcontent {get;set;}
    public content_item__c thecontent {get;set;}
    
    public content_item__c getmycontent(){  
        list<content_item__c>thecontentlist = new list<content_item__c>();  
        if(TrueCostUtilities.showOnlyPublished()){
            thecontentlist = [select Definition__c, title__c, deck__c from content_item__c where name =: whichcontent and published__c = true limit 1];
        }   else{
                thecontentlist = [select Definition__c, title__c, deck__c from content_item__c where name =: whichcontent limit 1];
            }
        
        
        if (thecontentlist.size()>0) {thecontent=ContentRewriter.Rewrite(thecontentlist)[0];}        
        return thecontent;
        
    }
    
}