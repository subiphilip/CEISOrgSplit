@isTest
private class ControllerForCustomerRewardsView_Test {

    static testMethod void myUnitTest() {

    //First create REP Profile
    REP_Profile__c prflObj=new REP_Profile__c();
    prflObj.Customer_Service_Phone_Number__c='123456789';
    prflObj.Business_Start_Date__c=System.today();
    prflObj.Fax_Number__c='123456';
    prflObj.Home_Page__c='www.google.com';
    prflObj.Legal_Name__c='Test REP Profile';
    prflObj.Mailing_City__c='NewYork';
    prflObj.Mailing_Street_Address__c='ABCDEF';
    prflObj.Mailing_Zip__c='78992';
    insert prflObj;
    
    //Create a Plan
    Plan__c planObj=new Plan__c();
    planObj.recordtypeid = [select id from recordtype where name='Electric Plan'].id;
    planObj.REP_Profile__c=prflObj.Id;
    planObj.Plan_ID__c='testplan';
    planObj.Plan_Start_Date__c=System.today();
    planObj.Plan_End_Date__c=System.today()+365;
    planObj.Contract_Length__c=3.3;
    planObj.Renewable_Content__c=25;
    insert planObj;
    
    
    //Create a Rate record
    Rate__c rtObj=new Rate__c();
    rtObj.Plan__c=planObj.Id;
    rtObj.Active__c=true;
    rtObj.EFL_Url__c='www.google.com';
    rtObj.Cancellation_Fee__c=35000;
    rtObj.Energy_Base_Rate_cents__c=2.2;
    rtObj.TOS_Url__c='www.google.com';
    rtObj.X1000_kWh_rate__c=11.2;
    rtObj.X2000_kWh_rate_cents__c=10.40;
    rtObj.X500_kWh_rate_cents__c=8.5;
    rtObj.YRAC_Url__c='www.google.com';
    insert rtObj;
    
    
    //Create a reward record
    Rewards__c rewardObj=new Rewards__c();
    rewardObj.Reward_Start_Date__c=System.today();
    rewardObj.Reward_End_Date__c=System.today()+365;
    rewardObj.Name='Test Reward';
    rewardObj.Reward_Type__c='Hotel Points';
    rewardObj.Reward_Value__c=100;
    rewardObj.REP_Profile__c=prflObj.Id;
    rewardObj.Reward_Description__c='test comments';
    insert rewardObj;
    
    //Create a rate-reward association record
    RateRewardAssociation__c associateObj=new RateRewardAssociation__c();
    associateObj.Rate__c=rtObj.Id;
    associateObj.Reward__c=rewardObj.Id;
    insert associateObj;
        
    ControllerForCustomerRewardsView viewClsObj=new ControllerForCustomerRewardsView();
    viewClsObj.therateid=rtObj.Id;
    viewClsObj.getTheRewards();        
    }
}