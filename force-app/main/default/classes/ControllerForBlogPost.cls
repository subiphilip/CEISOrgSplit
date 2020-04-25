public class ControllerForBlogPost {
    
    public id SpecifiedPostID {get;set;}
    
    public Content_BlogEntry__c getPost(){
        try{return getPostbyID(ApexPages.currentPage().getParameters().get('id'));} catch(exception e){return null;}
    }
    
    public Content_BlogEntry__c getSpecifiedPost(){         
        return getPostbyID(SpecifiedPostID);
    }
    
    public static Content_BlogEntry__c getPostbyID(id localblogid){     
        list<Content_BlogEntry__c> blog = [select id, 
        topscript__c, bottomscript__c, 
        above_the_fold__c, title__c, body__c, deck__c, friendly_url__c, author__c, publish_date__c 
                                            from Content_BlogEntry__c where id=:localblogid ];
        try{return ContentRewriter.Rewrite(blog)[0];} catch(exception e){return null;}  
    }
    
    
}