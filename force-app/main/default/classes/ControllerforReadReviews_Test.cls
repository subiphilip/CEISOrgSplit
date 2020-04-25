@isTest
private class ControllerforReadReviews_Test {

    static testmethod void test1(){

        REP_Profile__c oREP_Profile = TrueCostTestUtilities.getREPProfile();
        
        PageReference pageRef = Page.ReadReviews;
        pageRef.getParameters().put('id', oREP_Profile.ID);
        Test.setCurrentPageReference(pageRef);
        
        ControllerforReadReviews thecontroller = new ControllerforReadReviews ();
        thecontroller.getrep();
        thecontroller.getratings();


    }
    
    @isTest (seeAllData=true)
    static void RandomReview(){

        REP_Profile__c oREP_Profile = TrueCostTestUtilities.getREPProfile();
        TrueCostTestUtilities.MakeReviews(oREP_Profile.id);
        ControllerforReadReviews.getRandomReview();
               
    }

    @isTest (seeAllData=true)
    static void RandomReviewbyREP(){

        REP_Profile__c oREP_Profile = TrueCostTestUtilities.getREPProfile();
        TrueCostTestUtilities.MakeReviews(oREP_Profile.id);
        ControllerforReadReviews.getRandomReview(oREP_Profile.id);
               
    }
}