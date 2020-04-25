/**
 * An apex page controller that exposes the site login functionality

2/9/2012    Shane McLaughlin    Added login counter and timestamp augment method
 */
global with sharing class SiteLoginController {
    global String username {get; set;}
    global String password {get; set;}

    global PageReference REPlogin(){
        return site.login(username, password, '/home/home.jsp');
    }
    
    global PageReference login() {
        String startUrl;
        /*string a; string b; string z;
        try{
            try{Cookie utma = ApexPages.currentPage().getCookies().get('utma'); a = utma.getValue();}catch(exception e){}
            try{Cookie utmb = ApexPages.currentPage().getCookies().get('utmb'); b = utmb.getValue();}catch(exception e){} 
            try{Cookie utmz = ApexPages.currentPage().getCookies().get('utmz'); z = utmz.getValue();}catch(exception e){}
            startUrl = System.currentPageReference().getParameters().get('startURL')+'?__utma='+a+'&__utmb='+b+'&__utmz='+z;
        } catch(exception e){startUrl = System.currentPageReference().getParameters().get('startURL');}
        */
        startUrl = System.currentPageReference().getParameters().get('startURL');
        //plandetails always creates problems...so let's send them back to shopplans if they login from there.
        if (startURL != null){
            if (startURL.contains('plandetails')){startURL='/shopplans';}
        
            //remove duplicate forwardslashes caused by URL-rewritten pages
            startURL = startURL.replace('//', '/');
            //remove duplicate question marks, replace last one with a &
            
            string[] splits = startURL.split('\\?',0);
            do {
                if (splits.size()>2){
                    startURL.split('\\?',0)[2].replace('?', '&');
                }
                splits = startURL.split('\\?',0);
            } while (splits.size()>2);
        }
        incrementLoginCounterTimestamp(username);
        return Site.login(username, password, startUrl);
    }
    
    global SiteLoginController () {}
    
    private static void incrementLoginCounterTimestamp(string e){
        list<account> a = new list<account>();
        a = [select id, isPersonAccount, Last_Login_Time_Stamp__c, TrueCost_login_count__c from account 
                        where personEmail like :e ];
        if (a.size()==1){
            a[0].Last_Login_Time_Stamp__c =system.now();
            if (a[0].TrueCost_login_count__c == null) {a[0].TrueCost_login_count__c = 0;}
            a[0].TrueCost_login_count__c ++;
            try{
                update a;
            } catch (DMLException dml){
                //just want to make sure login happens.  OK if counter is not perfect
              }
            
        }
    }
    
    global static testMethod void testSiteLoginController () {
        // Instantiate a new controller with all parameters in the page
        account acct = new account();
       
        acct.LastName = 'TestUser2';
        acct.FirstName = 'SuperFake2';
        acct.PersonEmail = 'test@salesforce.com';
        insert acct;
        SiteLoginController controller = new SiteLoginController ();
        controller.username = 'test@salesforce.com';
        controller.password = '123456'; 
        System.assertEquals(controller.login(),null);
    }
    
      
}