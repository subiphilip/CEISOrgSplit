@isTest
private class ControllerForTrueCostPeople_Test {

    static testMethod void testControllerForTrueCostPeople(){
        Profile myProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        ControllerForTrueCostPeople c = new ControllerForTrueCostPeople();
        User u = new User();
        u.Make_Profile_Public__c=true;
        u.Username='faketestperson@centerpointenergy.com';
        u.LastName='FTP';
        u.Email='faketestperson@centerpointenergy.com';
        u.Alias='trcyphm';
        u.CommunityNickname='faketestperson';
        u.TimeZoneSidKey='America/Chicago';
        u.LocaleSidKey='en_US';
        u.EmailEncodingKey='ISO-8859-1';
        u.ProfileId=myProfile.Id;
        u.LanguageLocaleKey='en_US';
        insert u;
        c.getPeople();
        
    }
 }