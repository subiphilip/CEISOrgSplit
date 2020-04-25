@isTest
private class ControllerForTrueCostPeople_Test {

    static testMethod void testControllerForTrueCostPeople(){
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
        u.ProfileId='00e30000001nhsfAAA';
        u.LanguageLocaleKey='en_US';
        insert u;
        c.getPeople();
        
    }
 }