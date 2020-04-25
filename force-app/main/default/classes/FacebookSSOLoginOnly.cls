global class FacebookSSOLoginOnly implements Auth.RegistrationHandler{

    global User createUser(Id portalId, Auth.UserData data){
        string extension = [select username from user where id = '00530000004bSMC'].UserName.substringAfterLast('.');
        system.debug(extension);
        user u;
        List<User> l = [SELECT Id FROM User WHERE UserName = :data.email or UserName = :(data.email+'.'+extension)];
            if (l.size() > 0) {
                u = l[0];
                System.debug('Found existing user record for '+data.username);
    
                // Update existing record
                u.Email = data.email;
                u.LastName = data.lastName; 
                u.FirstName = data.firstName;
                // Useful to save the Facebook ID in a custom field
                u.Facebook_ID__c = data.identifier;
    
                System.debug('Updating user record for '+data.username);
                
                update(u);
                return u;
            } else {
                return null;
            }
    }

    
    
    
    
    global void updateUser(Id userId, Id portalId, Auth.UserData data){
        string extension = [select username from user where id = '00530000004bSMC'].UserName.substringAfterLast('.');
        system.debug(extension);

        system.debug('Matched user with id ' + userId);
        User u = [select id, email, lastname, firstname, Facebook_id__c, contactid from user where email =: data.email or email =: (data.email+'.'+extension)];
    
        //Update the contact
        String cid = u.contactId;
        Contact c = [SELECT Id, AccountId from contact WHERE id=:cid];
        Account a = [SELECT Id, PersonEmail, firstname, lastname from account WHERE id=:c.accountID];
        a.personemail = data.email;
        a.firstName = data.firstName;
        a.lastName = data.lastName;
        update(a);
    
        AsyncRequest__c ASR = new AsyncRequest__c(Params__c = a.PersonEmail, type__c='TrueCostLoginTracking');
        insert ASR;
        
        u.email = data.email;
        u.lastName = data.lastName;
        u.firstName = data.firstName;
        u.Facebook_ID__c = data.identifier;
    
        update(u);
    }
}