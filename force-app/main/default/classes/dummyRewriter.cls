global class dummyRewriter implements Site.UrlRewriter{
//Variables to represent the friendly URLs for pages 

 String BLOGDIRECTORY = '/news/';
 String REVIEWDIRECTORY = '/electric-companies/';

 //Variables to represent my custom Visualforce pages that display page information

 String BLOG_PAGE = '/TrueCostBlogPost?id=';
 String REVIEW_PAGE = '/readreviews?id=';

 // The first global method for mapping external URL to an internal one

 global PageReference mapRequestUrl(PageReference myFriendlyUrl){

    String url = myFriendlyUrl.getUrl();

    if(url.startsWith(BLOGDIRECTORY)){

       String friendlyURL = url.substring(BLOGDIRECTORY.length(),url.length());       
       //strip out query strings if they exist
       if( friendlyURL.contains('?') ){
                system.debug('=================Found a ?');
                friendlyURL=friendlyURL.split('\\?',2)[0]; //stuff before the ?
       }
       if( friendlyURL.contains('&') ){
                system.debug('=================Found a &');
                friendlyURL=friendlyURL.split('\\&',2)[0]; //stuff before the ?
       }
       
       Content_BlogEntry__c blogItem = [select id from Content_BlogEntry__c where friendly_url__c =: friendlyURL LIMIT 1];
      
       //Construct a new page reference in the form of my Visualforce page
       

       return new PageReference(BLOG_PAGE  + blogitem.id);

    }
    
    else if(url.startsWith(REVIEWDIRECTORY)){

       String friendlyURL = url.substring(REVIEWDIRECTORY.length(),url.length());       
       //strip out query strings if they exist
       if( friendlyURL.contains('?') ){
                system.debug('=================Found a ?');
                friendlyURL=friendlyURL.split('\\?',2)[0]; //stuff before the ?
       }
       if( friendlyURL.contains('&') ){
                system.debug('=================Found a &');
                friendlyURL=friendlyURL.split('\\&',2)[0]; //stuff before the ?
       }
       
       REP_Profile__c rep = [select id from REP_Profile__c where friendly_url__c =: friendlyURL LIMIT 1];
      
       //Construct a new page reference in the form of my Visualforce page
       

       return new PageReference(REVIEW_PAGE  + rep.id);

    }
    
    
    else 
    //If the URL isn't in the form of a cmasforce page, continue with the request

    return null;

  }

  // The second global method for mapping internal Ids to URLs

  global List<PageReference> generateUrlFor(List<PageReference> mySalesforceUrls){
        
    //A list of pages to return after all the links have been evaluated

    List<PageReference> myFriendlyUrls = new List<PageReference>();

    for(PageReference mySalesforceUrl : mySalesforceUrls){
        system.debug('==========================starting PageReference is ' + mySalesforceUrl); 

      //Get the URL of the page

      String url = mySalesforceUrl.getUrl();
      system.debug('==========================starting url string is ' + url);  

      //If this looks like a page that needs to be mapped, transform it

      try{
            if(url.startsWith(BLOG_PAGE)){
    
            //Extract the ID from the query parameter.  The plus 4 is for the characters of ?id=
    
            String id= url.substring(BLOG_PAGE.length(), url.length());
            system.debug('=================The incoming URL is' + id);
            string querystring ='';
            if( id.contains('?') ){
                system.debug('=================Found a ?');
                querystring = id.split('\\?', 2)[1]; //stuff after the query string starts
                system.debug('=================querystring is ' + querystring);
                id=id.split('\\?',2)[0]; //stuff before the ?
                   system.debug('------------------id is ' + id);
            }
                if( id.contains('&')){
                    system.debug('=================Found a &');
                querystring = id.split('\\&', 2)[1]; //stuff after the query string starts
                system.debug('=================querystring is ' + querystring);
                id=id.split('\\&',2)[0]; //stuff before the ?
                   system.debug('------------------id is ' + id);
            }
            
            system.debug('Entered the generateURLFOR method with string =================' + id);
            
            //Query for the name of the cmsforce page to put in the URL
    
            Content_BlogEntry__c blogItem2 = [select title__c, friendly_url__c from Content_BlogEntry__c where id =:id LIMIT 1];
    
            //Construct the new URL
            
    
            myFriendlyUrls.add(new PageReference(BLOGDIRECTORY+ blogItem2.friendly_url__c) );
         }  
         
         else if(url.startsWith(REVIEW_PAGE)){
            //Extract the ID from the query parameter.  The plus 4 is for the characters of ?id=
    
            String id= url.substring(REVIEW_PAGE.length(), url.length());
            system.debug('=================The incoming URL is ' + id);
            string querystring ='';
            if( id.contains('?') ){
                system.debug('=================Found a ?');
                querystring = id.split('\\?', 2)[1]; //stuff after the query string starts
                system.debug('=================querystring is ' + querystring);
                id=id.split('\\?',2)[0]; //stuff before the ?
                system.debug('------------------id is ' + id);
            }
                if( id.contains('&')){
                    system.debug('=================Found a &');
                querystring = id.split('\\&', 2)[1]; //stuff after the query string starts
                system.debug('=================querystring is ' + querystring);
                id=id.split('\\&',2)[0]; //stuff before the ?
                   system.debug('------------------id is ' + id);
            }
            
            
            system.debug('Entered the generateURLFOR method with string =================' + id);
            
            //Query for the name of the cmsforce page to put in the URL
    
            REP_Profile__c REP = [select friendly_url__c from REP_Profile__c where id =:id LIMIT 1];
            
            //Construct the new URL
            
            system.debug('==================going to add the directory as ' + REVIEWDIRECTORY + REP.friendly_url__c);
             if(REP.friendly_url__c != null){
                myFriendlyUrls.add(new PageReference(REVIEWDIRECTORY + REP.friendly_url__c) );
             } else {myFriendlyUrls.add(mySalesforceUrl);}
         
         }
         
         else {
    
           //If this doesn't start like an cmsforce page, don't do any transformations
    
           myFriendlyUrls.add(mySalesforceUrl);
    
         }

    }catch(exception e){myFriendlyUrls.add(mySalesforceUrl);}
  }
  //Return the full list of pages

  return myFriendlyUrls;

  
  }
}