global class FacebookSSO implements Auth.RegistrationHandler{

    global User createUser(Id portalId, Auth.UserData data){
        user u;
        List<User> l = [SELECT Id FROM User WHERE UserName = :data.email];
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
                //TODO: Get an actual account
                Account a = new account();
                a.recordtypeid=[select id from recordtype where name='Electric Person Account'].id;                    
                a.Personemail = data.email;
                a.firstName = data.firstName;
                a.lastName = data.lastName;
                insert(a);
                a = [select id, name, isPersonAccount, PersonContactId from account where id=:a.id];
                
                //TODO: Customize the username and profile. Also check that the username doesn't already exist and
                //possibly ensure there are enough org licenses to create a user. Must be 80 characters or less.
                u = new User();
                Profile p = [SELECT Id FROM profile WHERE name='TrueCost Customer'];
                u.username = data.email;
                u.email = data.email;
                u.lastName = data.lastName;
                u.firstName = data.firstName;
                String alias = data.username;
                //Alias must be 8 characters or less
                if(alias.length() > 8) {
                    alias = alias.substring(0, 8);
                }
                u.alias = alias;
                u.languagelocalekey = UserInfo.getLocale();
                u.localesidkey = UserInfo.getLocale();
                u.emailEncodingKey = 'UTF-8';
                u.timeZoneSidKey = 'America/Chicago';
                u.profileId = p.Id;
                u.contactId = a.PersonContactId;
                return u;
    
            }
    }

    
    
    
    
    global void updateUser(Id userId, Id portalId, Auth.UserData data){
    
        system.debug('Matched user with id ' + userId);
        User u = [select id, email, lastname, firstname, Facebook_id__c, contactid from user where email =: data.email];
    
        //Update the contact
        String cid = u.contactId;
        Contact c = [SELECT Id, AccountId from contact WHERE id=:cid];
        Account a = [SELECT Id, PersonEmail, firstname, lastname from account WHERE id=:c.accountID];
        a.personemail = data.email;
        a.firstName = data.firstName;
        a.lastName = data.lastName;
        update(a);
    
        u.email = data.email;
        u.lastName = data.lastName;
        u.firstName = data.firstName;
        u.Facebook_ID__c = data.identifier;
    
        update(u);
    }
}