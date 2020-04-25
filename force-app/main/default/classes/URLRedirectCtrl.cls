/*This class is used to get url details from custm meta data for each community page*/
public class URLRedirectCtrl {

  
    public static boolean isSiteUserMyCESCommunityUser() {
		List<Profile> profile = [SELECT Id, Name 
                                 FROM Profile 
                                 WHERE Id =: userinfo.getProfileId() 
                                 LIMIT 1];
        
        return CESCommonObjectController.isMyCESProfileValid(profile[0]);
    } 
    
    @AuraEnabled
    public static String getURL(String currentPageName) {
        MyCES_1__mdt custMeta = [select URL__c from MyCES_1__mdt where label = :currentPageName];
        string url;
        if (!String.isEmpty(custMeta.URL__c)) {  // not empty
            
            try { 
                if (isSiteUserMyCESCommunityUser()) {
                    url = custMeta.URL__c;
                    //url = '';
                }
                // else
                    // in Builder
                    // 
            } catch (Exception ex) {
                // do nothing
            }
        }
        return url;
    }
}