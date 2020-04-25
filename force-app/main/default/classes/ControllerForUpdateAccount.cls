/**
 * An apex class that keeps updates of a portal user in sync with its corresponding contact.
   Guest users are never able to access this page.
  
Modification Log
01/27/2012  Hemanth Chandra     Fixed null pointer exception for Premise SOQL in getUser method
03/23/2012  Barry     Fixed DML exception separated updates into two phase with @future call
 */
public with sharing class ControllerForUpdateAccount {

    private User user;
    private boolean isEdit = false;
    
    public User getUser() {
        premises__c prem = null;
        ID premiseID = TrueCostUtilities.getThePremise(UserInfo.getUserId());
        if(premiseID == null)
            prem = new premises__c();
        else
            prem = [select id, Electric_Service_Address_City__c, Electric_Service_Address__c,Electric_Service_Address_Zip__c from premises__c where id =: premiseID];
        account acct = [select id, Billing_Adrs_Line_1__c, Billing_City__c, Billing_zip_code__c, State__c
                         from account where id=: TrueCostUtilities.getTheAccount(UserInfo.getUserId())];
        if (user.Street == null) {
            if (acct.Billing_Adrs_Line_1__c!=null){
                user.Street=acct.Billing_Adrs_Line_1__c;
            } else {
                user.Street=prem.Electric_Service_Address__c;
            }
        }
        if (user.City == null) {
            if (acct.Billing_City__c!=null){
                user.City=acct.Billing_City__c;
            } else {
                user.City=prem.Electric_Service_Address_City__c;
            }
        }
        if (user.PostalCode == null) {
            if (acct.Billing_zip_code__c!=null){
                user.PostalCode=acct.Billing_zip_code__c;
            } else {
                user.PostalCode=prem.Electric_Service_Address_Zip__c;
            }
        }       
        if (user.State == null) {
            if (acct.State__c!=null){
                user.State=acct.State__c;
            } 
        }
        return user;
    }

    public ControllerForUpdateAccount() {
        user = [SELECT id, email, username, usertype, communitynickname, timezonesidkey, languagelocalekey, firstname, lastname, phone, title,
                street, city, country, postalcode, state, localesidkey, mobilephone, extension, fax, contact.email
                FROM User
                WHERE id = :UserInfo.getUserId()];
        // guest users should never be able to access this page
        if (user.usertype == 'GUEST') {
            throw new NoAccessException();
        }
    }
    
    public Boolean getIsEdit() {
        return isEdit;
    }
    
    public void edit() {
        isEdit=true;
    }    
    
    public void save() {
        user.Username = user.email;
        
        if (user.contact != null) {              
            setContactFields(user.contact, user);
        }
       
        try {
            //update user;
             saveUser(user.id, user.Street,user.City,user.PostalCode,user.State, user.username, user.firstname, user.lastname );
            if (user.contact != null) {
                system.debug('contact!' + user.contact);
                update user.contact;
            }
            isEdit=false;
        } catch(DmlException e) {
            ApexPages.addMessages(e);
        }
       
    } 
    
   @future 
   private static void saveUser(String id, String street, String city, String zip, String state,String username, String firstname, String lastname)
   {
   	
   	 User usr = new User();
      usr = [Select id, street, city,  postalcode, state, username, firstname, lastname from User where Id = :UserInfo.getUserId()];
     
     usr.street = street;
     usr.City   = city;
     usr.PostalCode = zip;
     usr.state = state;
     usr.email = username;
     usr.FirstName = firstname;
     usr.LastName  = lastname;
   try {
        
         update usr;
     
    } catch(DmlException e) {
            ApexPages.addMessages(e);
        }
   
   
   }
    
    public PageReference changePassword() {
        return Page.ChangePassword;
    }
    
    public PageReference Back() {
        return Page.MyAccount;
    }
    
    public void cancel() {
        isEdit=false;
        user = [SELECT id, email, username, communitynickname, timezonesidkey, languagelocalekey, firstname, lastname, phone, title,
                street, city, country, postalcode, state, localesidkey, mobilephone, extension, fax, contact.email
                FROM User
                WHERE id = :UserInfo.getUserId()];
    }
    
    private static void setContactFields( Contact c,User u ) {
        
        c.firstname = u.firstname;
        c.lastname = u.lastname;
        c.email = u.email;
        c.phone = u.phone;
        c.mobilephone = u.mobilephone;
        c.fax = u.fax;
        c.mailingstreet = u.street;
        c.mailingcity = u.city;
        c.mailingstate = u.state;
        c.mailingpostalcode = u.postalcode;
        c.mailingcountry = u.country;
    }
    
     
    static testMethod void testSave() {         
        // Modify the test to query for a portal user that exists in your org
        List<User> existingPortalUsers = [SELECT id, profileId, userRoleId FROM User WHERE UserRoleId <> null AND UserType='CustomerSuccess'];

        if (existingPortalUsers.isEmpty()) {
            User currentUser = [select id, title, firstname, lastname, email, phone, mobilephone, fax, street, city, state, postalcode, country
                                FROM User WHERE id =: UserInfo.getUserId()];
            MyProfilePageController controller = new MyProfilePageController();
            System.assertEquals(currentUser.Id, controller.getUser().Id, 'Did not successfully load the current user');
            //System.assert(controller.isEdit == false, 'isEdit should default to false');
            controller.edit();
            //System.assert(controller.isEdit == true);
            controller.cancel();
            //System.assert(controller.isEdit == false);
            
            Contact c = new Contact();
            c.LastName = 'TestContact';
            insert c;
            
            setContactFields(c, currentUser);
            controller.save();
            System.assert(Page.ChangePassword.getUrl().equals(controller.changePassword().getUrl()));
        } else {
            User existingPortalUser = existingPortalUsers[0];
            String randFax = Math.rint(Math.random() * 1000) + '5551234';
            
            System.runAs(existingPortalUser) {
                MyProfilePageController controller = new MyProfilePageController();
                System.assertEquals(existingPortalUser.Id, controller.getUser().Id, 'Did not successfully load the current user');
                //System.assert(controller.isEdit == false, 'isEdit should default to false');
                controller.edit();
                //System.assert(controller.isEdit == true);
                
                controller.cancel();
                //System.assert(controller.isEdit == false);
                
                controller.getUser().Fax = randFax;
                controller.save();
                //System.assert(controller.isEdit == false);
            }
            
            // verify that the user and contact were updated
            existingPortalUser = [Select id, fax, Contact.Fax from User where id =: existingPortalUser.Id];
            System.assert(existingPortalUser.fax == randFax);
            System.assert(existingPortalUser.Contact.fax == randFax);
        }
    }
    
}