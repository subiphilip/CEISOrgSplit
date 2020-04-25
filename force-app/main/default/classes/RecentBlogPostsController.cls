/*
1/24/2012   Shane McLaughlin        Added if statements to show only published blog depending on a Custom Setting field
2/22/2012   Shane McLaughlin        Changed query to allow registered users to see FULL blog content but guests can only see published content.
3/28/2012   Shane McLaughlin        Added variable to allow page to specify how many posts it wants
6/8/2012    Shane McLaughlin        Added SOQL offset to reduce code length
*/

public class RecentBlogPostsController{
      
    public list<Content_BlogEntry__c> blogposts {get;set;}
    public integer TheLimit{get;set;}      
    public Profile p{get;set;}
    public integer showblocks{get;set;}
    public integer totalblogcount{get;set;}
    
    public RecentBlogPostsController(){     
        p = [select name from Profile where id =:UserInfo.getProfileId()]; 
        showblocks=1;       
        totalblogcount=counttheblogs();
    }   
    
    public integer counttheblogs(){
        integer x = [select count()
                            from content_blogentry__c
                            where publish_date__c <:system.now() and published__c = true
                            ];
        return x;
    
    }
    
    public list<Content_BlogEntry__c> getAllPosts(){
        blogposts = [select ID, Title__c, body__c, above_the_fold__c, author__c, friendly_url__c, publish_date__c, deck__c, lastmodifieddate
            from content_blogentry__c
            where publish_date__c <:system.now() and published__c = true
            order by publish_date__c DESC];         
        return ContentRewriter.Rewrite(blogposts);    
    }
    
    public list<Content_BlogEntry__c> getMyPosts(){
        
        integer offsetamt = (showblocks-1)*10;        
        if(totalblogcount<(showblocks-1)*10) return null;        
        if (TheLimit==null) TheLimit=10;
        
        blogposts = [select ID, Title__c, body__c, above_the_fold__c, author__c, publish_date__c, deck__c
            from content_blogentry__c
            where publish_date__c <:system.now() and published__c = true
            order by publish_date__c DESC limit: TheLimit offset: offsetamt];         
        return ContentRewriter.Rewrite(blogposts);    
    }
    
    public pageReference ViewMore(){
        showblocks=showblocks+1;
        return null;
    }
    
    public pageReference nada(){return null;}
    
    
}