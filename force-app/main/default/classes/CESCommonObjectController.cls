public class CESCommonObjectController {

    //
    // If you make changes to this list. Make changes in these classes as well. Replacing the static hardcoded
    // list with a call to CESCommonObjectController.getMyCESProfileList()
    // 
    // this class (CESCommonObjectController)
    // PortalUserAccessBatch
    // RevokeShareRecordAccessController
    // UserTriggerHandler
    //
    public static List<Profile> getMyCESProfileList() {
        List<Profile> validProfileList;
        
        validProfileList = [
            SELECT Id, Name
            FROM Profile
            WHERE Name IN ('MyCES Consultant', 'MyCES ExtFA', 'MyCES ExtLA', 'MyCES Internal')
        ];
        
        if (validProfileList.size() > 0)
            return validProfileList;
       
        return null;
    }  
    
    public static boolean isMyCESProfileValid(Profile profile) {
        List<Profile> validProfileList = new List<Profile>();
        validProfileList = [
            SELECT Id, Name
            FROM Profile
            WHERE Name IN ('MyCES Consultant', 'MyCES ExtFA', 'MyCES ExtLA', 'MyCES Internal')
            AND ID = :profile.Id
            LIMIT 1
        ];
        
        if (validProfileList.size() > 0)
            return true;
        
        return false;
    }  
    
    
/*
* Common Code to access Account records
* Used in Filter components by myCES reports
* 
* Sys Admins have access to 'Account' via share rules on Account
* Contacts have access to 'Account' via custom share rules initially mananged by 'AccountContactRelation' object
*  
*/
    @AuraEnabled
    public static List<Account> getCommonAccountRecordList () {
        system.debug('getCommonAccountRecordList top ----------');
        
        List<Account> accountRecordList = new List<Account>();
        /*       
        List<Division> divisionList = new List<Division>();
        divisionList = [Select Id from Division where Name = 'C&I Sales' LIMIT 1];
        Id	CNISalesID = Division.Id;        
        */        
        Id	CNISalesID = '02d30000000PB5sAAG';   // 02d30000000PB5sAAG
        
        //Id	userId = userinfo.getUserId();
        //
        profile sysAdmin = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User currentUser = [Select Id, ProfileId,ContactId From User Where Id =:userinfo.getUserId()];
        
System.debug('adding code coverage | ' + currentUser);
        
        if(currentUser.ProfileId == sysAdmin.Id){
            accountRecordList = [
                SELECT Id, Name, Division
                FROM Account
                WHERE RecordType.Name = 'Business Account'
                AND Account.Division = '02d30000000PB5sAAG'
                AND Account.Type = 'Commercial Customer'  // may add 2nd type of 'Commercial Customer and Paid Consultant '
                AND Account.OwnerId != '00530000005wfQm'  // Troy
                ORDER BY LastModifiedDate DESC
                LIMIT 10
            ]; 
        } else if (currentUser.ContactId != null) {
            List<AccountContactRelation> relationList = [
                SELECT Id, ContactId, AccountId
                FROM AccountContactRelation
                WHERE IsActive = true
                AND ContactId = :currentUser.contactId
            ]; 
            Set<Id> accountIdSet = new Set<Id>();              
            for (AccountContactRelation relation :relationList){
                accountIdSet.add(relation.AccountId);
            }
            
            system.debug('getCommon accountIdSet----------'+accountIdSet);
            accountRecordList = [
                SELECT Id, Name, Division
                FROM Account
                WHERE ID IN :accountIdSet 
                /*WHERE RecordType.Name = 'Business Account'
                  AND ID IN :accountIdSet
                  AND Account.Division = '02d30000000PB5sAAG'
                  AND Account.Type = 'Commercial Customer'  // may add 2nd type of 'Commercial Customer and Paid Consultant '
                  AND Account.OwnerId != '00530000005wfQm'  // Troy
                LIMIT 50000*/
                ORDER BY Name ASC
            ]; 
        } 
        else 
        {
            // currentUser.ContactId
            // if(currentUser.ContactId == null && currentUser.ProfileId != sysAdmin.Id)
            
            Set<Id> internalUserRecentAccountIdSet = new Set<Id>();
            List<RecentlyViewed> recentlyViewedList = [
                SELECT Id, Name
                FROM RecentlyViewed
                WHERE Type in ('Account')
            ];
            for (RecentlyViewed rv :recentlyViewedList){
                internalUserRecentAccountIdSet.add(rv.Id);
            } 
			
            
            Set<Id> internalUserRecentContactIdSet = new Set<id>();
            List<RecentlyViewed> contactRelationList = [
                SELECT Id, Name
                FROM RecentlyViewed
                WHERE Type in ('Contact')
            ];
            for (RecentlyViewed relation :contactRelationList){
                internalUserRecentContactIdSet.add(relation.Id);
            }  
            List<AccountContactRelation> accountRelationList = [
                SELECT Id, ContactId, AccountId
                FROM AccountContactRelation
                WHERE ContactId = :internalUserRecentContactIdSet
            ];
            for (AccountContactRelation relation :accountRelationList){
                internalUserRecentAccountIdSet.add(relation.AccountId);
            }            

			//
			// for internal user access via the App 
			//
            accountRecordList = [
                SELECT Id, Name, Division
                FROM Account
                WHERE RecordType.Name = 'Business Account'
                AND Account.Division = '02d30000000PB5sAAG'
                AND Account.Type = 'Commercial Customer'  // may add 2nd type of 'Commercial Customer and Paid Consultant '
                AND Account.OwnerId != '00530000005wfQm'  // Troy
                AND Account.Id in :internalUserRecentAccountIdSet
				
                ORDER BY 
                	// LastReferencedDate DESC NULLS LAST,
                	Name ASC				
				
                //LIMIT 20 -- unable to use LastRefernceDate because it is not always set
            ]; 			
		}        
  
        system.debug('getCommon accountRecordList----------'+accountRecordList);
        return accountRecordList;
        
    }
    
    
/*
* Common Code to access Billing Groups records
* Used in Filter components by myCES reports
*/
    @AuraEnabled
    public static List<Bill_Group__c> getCommonBillingGroupList(Id accountRecordId) {
        List<Bill_Group__c> billingGroupList = new List<Bill_Group__c>();
        billingGroupList = [
            SELECT Id, Name, Customer_ID_and_Name__c
            FROM Bill_Group__c 
            WHERE Account__c = :accountRecordId and Customer_ID__c != null
            //
            // the share code should exclude bill group records where External_ID__c != null 
            // AND External_ID__c != null 
            //      
            ORDER BY Customer_ID_and_Name__c ASC
        ];
        
        system.debug('getCommon billingGroupList----------'+billingGroupList);
        return billingGroupList;
        
    }    

/*
* Common Code to access Billing Groups records
* Used in Filter components by myCES reports
*
* The ORDER BY clause includes LastReferencedDate
*/
    @AuraEnabled
    public static List<Bill_Group__c> getCommonBillingGroupListByReferencedDate(Id accountRecordId) {
        List<Bill_Group__c> billingGroupList = new List<Bill_Group__c>();
        billingGroupList = [
            SELECT Id, Name, Customer_ID_and_Name__c
            FROM Bill_Group__c 
            WHERE Account__c = :accountRecordId and Customer_ID__c != null
               
            ORDER BY 
            	//LastReferencedDate DESC NULLS LAST,
            	Customer_ID_and_Name__c ASC
        ];
        
        system.debug('getCommon billingGroupList----------'+billingGroupList);
        return billingGroupList;
        
    }    
    
/*
* Common Code to provide Month filters a list of months in order
* Used in Filter components by myCES reports
*/    
    @AuraEnabled 
    public static List<String> getCommonMonthList () {
        List<String> monthList = new List<String>();
        Map<integer,string> monthMap = new Map<integer,string>();
        monthMap.put(1,'Jan');
        monthMap.put(2,'Feb');
        monthMap.put(3,'Mar');
        monthMap.put(4,'Apr');
        monthMap.put(5,'May');
        monthMap.put(6,'Jun');
        monthMap.put(7,'Jul');
        monthMap.put(8,'Aug');
        monthMap.put(9,'Sep');
        monthMap.put(10,'Oct');
        monthMap.put(11,'Nov');
        monthMap.put(12,'Dec');
        integer currentMonth = Date.today().MONTH();
        system.debug('currentMonth ------------'+currentMonth);
        for(integer i = currentMonth - 1 ; i >= 1 ; i--){
            monthList.add(monthMap.get(i));
        }
        for(integer i = 12; i >= currentMonth ; i--){
            monthList.add(monthMap.get(i));
        }
        system.debug('monthList ------------'+monthList);
        return monthList;
    }
    
/*
* Common Code to provide Month Map 
* Used in reports and chart compononents by myCES reports
*/     
    @AuraEnabled 
    public static Map<Integer,String> getCommonMonthMap () {
        Map<Integer,String> monthMap = new Map<Integer,String>();
        monthMap.put(1,'Jan');
        monthMap.put(2,'Feb');
        monthMap.put(3,'Mar');
        monthMap.put(4,'Apr');
        monthMap.put(5,'May');
        monthMap.put(6,'Jun');
        monthMap.put(7,'Jul');
        monthMap.put(8,'Aug');
        monthMap.put(9,'Sep');
        monthMap.put(10,'Oct');
        monthMap.put(11,'Nov');
        monthMap.put(12,'Dec');
        
        return monthMap;
    }    
    
    
//
// TFS-17570
// was in DailyUsageController moved get Bill Group Name method into common class
//      
	@AuraEnabled
    public static String getBillGroupRecordName (String billingGroupId) {
        String billName;
        system.debug('------billingGroupId  '+billingGroupId);
        if (billingGroupId != null && billingGroupId != 'All') {
            Bill_Group__c billGroupRecord = [
                SELECT Id, Name, Customer_ID_and_Name__c
                FROM Bill_Group__c
                WHERE id = :billingGroupId 
            ];
            system.debug('------billGroupRecord'+billGroupRecord);
            system.debug('------billGroupRecord'+billGroupRecord.Customer_ID_and_Name__c);
            billName = billGroupRecord.Customer_ID_and_Name__c;
        }
        system.debug('------billName'+billName);
        return billName;
    }

    
//
// TFS-17570
// was in MonthlyUsageController moved get Account Record Name method into common class
//     
    @AuraEnabled
    public static String getAccountRecordName (String accountId) {
        String accName; 
        if (accountId != null) {
            Account acc = [
                SELECT Id, Name
                FROM Account
                WHERE id = :accountId 
            ];
            
            accName = acc.Name;
        }
        return accName;
    }    
    

	@AuraEnabled
    public static void logRecentlyViewedBillGroupForReference (String billingGroupId) {
        try {
            if (billingGroupId != null) {
                Bill_Group__c billGroupRecord = [
                    SELECT Id, Name FROM Bill_Group__c WHERE id = :billingGroupId
                    LIMIT 1 FOR REFERENCE
                ];
                
        		//system.debug('logRecentlyViewedBillGroupForReference------billingGroupId'+billingGroupId);                
            }    
        } catch (Exception e) {
            // unable to log
            system.debug('logRecentlyViewedBillGroupForReference------unable to log'+billingGroupId);                
        }
    }
    
    @RemoteAction
    public static void chatterCommunityActivity(string communityName, string description, Id recordId, string BillGroupId) {
        Id	recordOwnerId;
        Id	communityUserId;
        Id	communityContactId;
        String chatterText;
        //
        // look up if Account.ChatterCommunityActivity is false
        // then return;
        // 
       
        if (recordOwnerId == null) {
        	User currentUser = [Select Id, ProfileId,ContactId From User Where Id =:userinfo.getUserId()];
        	recordOwnerId = currentUser.ContactId;
        }
        
        if (communityName == null) {
            chatterText = ' myCES Activity';
        } else {
            chatterText = ' ' + communityName;
        }
        if (description != null)
        chatterText += ' ' + description;
        
        if (BillGroupId == null) {
            chatterText += ' : All Bill Groups';
        } else {
            chatterText += ' : BillGroup | ' + String.valueOf(BillGroupId);
        }

        if (recordId != null) {
            Account acc = [SELECT Id, Name, OwnerId FROM Account WHERE id = :recordId];            
            recordOwnerId = acc.OwnerId;        
        }
        
		//  public static void mentionOnRecord(Id recordid, Id userToMentionId, String postText) {  
		ChatterUtils.mentionOnRecord(recordid, recordOwnerId, chatterText);
    }          
}