/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TestRichTextFieldCopies {

    static testMethod void TestContentItem() {
        //Make Data
        Content_Item__c item = new Content_Item__c();
        item.published__c=true;
        item.draft_content__c='My draft content';
        //Insert
        insert item;
        //Flip flag that starts trigger
        item.run_copy_trigger__c=true;
        update item;
    }
    
    static testMethod void TestFAQ() {
        //Make Data
        FAQ__c item = new FAQ__c();
        item.public__c=true;
        item.draft_question__c='My draft content';
        item.draft_answer__c='My draft content';
        //Insert
        insert item;
        //Flip flag that starts trigger
        item.run_copy_trigger__c=true;
        update item;
    }
    
    static testMethod void TestBlog() {
        //Make Data
        Content_BlogEntry__c item = new Content_BlogEntry__c();
        item.published__c=true;
        item.deck__c='Deck Deck Deck';
        item.author__c='Shane McLaughlin';
        item.title__c='Hamlet';
        item.friendly_url__c='i-welcome-our-new-google-overlords';
        //Insert
        insert item;
        //Flip flag that starts trigger
        item.run_copy_trigger__c=true;
        update item;
    }
}