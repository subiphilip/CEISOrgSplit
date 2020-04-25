@isTest
private class SupportLinks_Test{       
    static testMethod void testTheComponent(){
    
        faq__c faq = new faq__c(Public__c = true,category__c = 'test',top_faq__c = true);
        insert faq;
        
        content_item__c item = new content_item__c(glossary_term__c = true, fee__c = true);
        insert item;
        
        PageReference pageRef = page.faq;
        pageRef.getParameters().put('cat','test');
        test.setCurrentPage(PageRef);
        supportlinks controller = new supportlinks();
        controller.getUniqueCategoriesList();
        controller.getTopFaq();
        controller.getTCFaq();
        controller.togglefees();
        controller.toggleFAQ();
        controller.toggleGlossary();
        controller.GetFullAlphabetFee();
        controller.GetFullAlphabetGlossary();
        controller.getAllFaq();
        controller.getAllFee();
        controller.getAllGlossary();
        controller.getresponselist();
        controller.getGlossaryAlpha();
        controller.getglossarylist();
        controller.getThePage();
        controller.getFeeAlpha();
    }
}