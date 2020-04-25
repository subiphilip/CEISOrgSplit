@isTest(seeAllData=true)

private class ControllerForAnonymousRating_Test {
  static testmethod void testControllerForAnonymousRating(){
    REP_Rating__c newrating = new REP_Rating__c(Rating__c=1);
    insert newrating ;
    attachment a = new attachment();
    a.name='abc';
    a.Body=Blob.valueOf('abc');
    a.ParentId = newRating.id;
    insert a;
    ControllerForAnonymousRating  cf=new ControllerForAnonymousRating();
    cf.fileBody =a.Body;
    cf.fileName =a.Name;
    cf.UploadFile();
    cf.saverating();
    cf.its1();
    cf.its2();  
    cf.its3();
    cf.its4();
    cf.its5();
  }
}