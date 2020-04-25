@isTest
private class SiteMapTests {
	
	@isTest(seeAllData=true) static void blogs() {
		 PageReference pageRef = Page.xmlsitemapblog;
    	 Test.setCurrentPage(pageRef);  
	}
	
	@isTest(seeAllData=true) static void zipcodes() {
		PageReference pageRef = Page.xmlsitemapzipcodes;
    	 Test.setCurrentPage(pageRef);  
	}

	@isTest(seeAllData=true) static void repsAndrates() {
		PageReference pageRef = Page.xmlsitemapREPsandReviews;
    	 Test.setCurrentPage(pageRef);  
	}

	@isTest(seeAllData=true) static void faqcontent() {
		PageReference pageRef = Page.xmlsitemapfaqcontent;
    	 Test.setCurrentPage(pageRef);  
	}
	
	
}