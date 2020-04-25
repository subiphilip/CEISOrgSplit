/*
***********Modification Log********************
Hemanth Chandra     02/06/2012      Moved testmethod to test class
Shane McLaughlin    02/23/2012      Add queries to fetch all FAQs, or Fees, or Glossary Items
Jason Ramm          02/24/2012      Updated 'all' query for fees and glossary to sort by name asc (alphabetical)
Jason Ramm          02/24/2012      Added query to get glossary or fee content by beginning alpha character
Shane McLaughlin    02/26/2012      Added class to create alpha links for glossary and fees.

*/

public class SupportLinks {
    public boolean fees{get;set;}
    public boolean glossary{get;set;}
    public boolean FAQ{get;set;}
    public string FAQRecordType{get;set;}
        
    public list<string> UniqueCategories {Get;set;}
      
    
    public SupportLinks(){
        string ThePage = string.valueof(ApexPages.CurrentPage());       
        faq=false;
        fees=false;
        glossary=false;
        if(thePage.contains('FAQ') ){faq = true;}   
        if(thePage.contains('fees') ){fees = true;}         
        if(thePage.contains('Glossary') ){glossary = true;}             
    }
    
    public string getThePage(){
        return string.valueof(ApexPages.CurrentPage()).split('/', 3)[2].replace(']', '');
        }
    
    public list<string> getUniqueCategoriesList(){
        list<string> uniqueCategories = new list<string>();
        list<faq__c> catquery = new list<faq__C>();
        catquery=[select id, category__c from faq__c where Record_Type_Name__c =: FAQRecordType and Public__c =:true order by category__c];
        set<string> catset=new set<string>();
        for (faq__c f:catquery){                
                    catset.add(f.category__c);
        }
        
        for (string f:catset){
        	if (f!='Other') UniqueCategories.add(f);
        }
        UniqueCategories.sort();
        if ( catset.contains('Other') ) UniqueCategories.add('Other');
        return UniqueCategories;
    }   
    
    /* Alpha Selection for Fees/Glossary Items */
    public string[] getAlphaList() {
        return new string[]{'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'};
    }
    
    public list<content_item__c> getFeeAlpha(){
        return ContentRewriter.Rewrite(
        	[select id, Name, definition__c 
                    from content_item__c where published__c =:true and fee__c =:true and Name LIKE:ApexPages.CurrentPage().getParameters().get('alpha')+'%' order by Name]  
    	);
    }
    
    public list<content_item__c> getGlossaryAlpha(){
        return ContentRewriter.Rewrite(
        	[select id, Name, definition__c  
                    from content_item__c where published__c =:true and glossary_term__c =:true and Name LIKE:ApexPages.CurrentPage().getParameters().get('alpha')+'%' order by Name]
         );   
    
    }
    
    /*public set<string>getGlossaryAlphalinks(){
        return makeAlphaLinks(getAllGlossary());
    }
    public set<string>getFeesAlphalinks(){
        return makeAlphaLinks(getAllFee());
    }*/
    
    public set<string> makealphalinks(list<content_item__c> stuff){             
        set<string> presentletters = new set<string>();         
        for (content_item__c item:stuff){
            presentletters.add(item.name.substring(0,1)); 
        }        
        return presentletters;
    }
    
    class LetterAndPresent{
        public string letter{get;set;}
        public Boolean present{get;set;}          
    }    
    
    public list<LetterAndPresent> GetFullAlphabetGlossary(){
        list<LetterAndPresent> ListofLAP = new list<LetterAndPresent>();
        set<string> presentletters = new set<string>();
        
        for (content_item__c item:getAllGlossary() ){
            presentletters.add(item.name.substring(0,1)); 
        }
        
        for(string s:getAlphaList()){
            LetterAndPresent LAP = new LetterAndPresent();
            LAP.letter = s;
            LAP.present = presentletters.contains(s);
            ListofLAP.add(LAP);         
        }
        Return ListofLAP;
    }
    
    public list<LetterAndPresent> GetFullAlphabetFee(){
        list<LetterAndPresent> ListofLAP = new list<LetterAndPresent>();
        set<string> presentletters = new set<string>();
        
        for (content_item__c item:getAllFee() ){
            presentletters.add(item.name.substring(0,1)); 
        }
        
        for(string s:getAlphaList()){
            LetterAndPresent LAP = new LetterAndPresent();
            LAP.letter = s;
            LAP.present = presentletters.contains(s);
            ListofLAP.add(LAP);         
        }
        Return ListofLAP;
    }
    
    public list<faq__c> getAllFaq(){
    	return ContentRewriter.Rewrite(
        	[select id, category__c, question__c, answer__c 
                    from faq__c where Record_Type_Name__c = 'TrueCost FAQ' and public__c =:true order by createddate]
        );   
    }
    
    public list<faq__c> getAllFaqGC(){
    	return ContentRewriter.Rewrite(
        	[select id, category__c, question__c, answer__c 
                    from faq__c where Record_Type_Name__c = 'Gas Choice FAQ' and public__c =:true order by createddate]
        );   
    }
    
    public list<content_item__c> getAllFee(){
        return ContentRewriter.Rewrite( 
        	[select id, Name, definition__c 
                    from content_item__c where published__c =:true and fee__c =:true order by Name]
    	);
    }  
    public list<content_item__c> getAllGlossary(){
        return ContentRewriter.Rewrite(
        	 [select id, Name, definition__c 
                    from content_item__c where published__c =:true and glossary_term__c=:true order by Name]   
    	);
    }       
    
    public list<faq__c> getresponselist(){  
    	return ContentRewriter.Rewrite( 
	        [select id, category__c, question__c, answer__c 
	                    from faq__c where Record_Type_Name__c = 'TrueCost FAQ' and public__c =:true and category__c=:ApexPages.CurrentPage().getParameters().get('cat')
	                    order by createddate ]                              
    	);
    }
    public list<faq__c> getresponselistGC(){  
    	return ContentRewriter.Rewrite( 
	        [select id, category__c, question__c, answer__c 
	                    from faq__c where Record_Type_Name__c = 'Gas Choice FAQ' and public__c =:true and category__c=:ApexPages.CurrentPage().getParameters().get('cat')
	                    order by createddate ]                              
    	);
    }
        
    public list<content_item__c> getfeelist() {       
        return ContentRewriter.Rewrite( [select id, Name from content_item__c where fee__c =:true]  );       
    }
    
    public list<content_item__c> getglossarylist(){      
        return ContentRewriter.Rewrite( [select id, Name from content_item__c where glossary_term__c =:true] );       
        }
    
    public list<faq__c> gettopfaq (){     
        return ContentRewriter.Rewrite( [select id, question__c, answer__c from faq__c where Record_Type_Name__c = 'TrueCost FAQ' and public__c =:true and top_faq__c=:true] );       
    }
    public list<faq__c> gettopfaqGC (){     
        return ContentRewriter.Rewrite( [select id, question__c, answer__c from faq__c where Record_Type_Name__c = 'Gas Choice FAQ' and public__c =:true and top_faq__c=:true] );       
    } 
    
    public list<faq__c> gettcfaq (){     
        return ContentRewriter.Rewrite( [select id, question__c, answer__c from faq__c 
        	where Record_Type_Name__c = 'TrueCost FAQ' and public__c =:true and category__c='About TrueCost']);       
    }   
    
    public list<faq__c> getOtherCompaniesFAQ(){
        try{return ContentRewriter.Rewrite( [select id, answer__c from faq__c where Record_Type_Name__c = 'TrueCost FAQ' and public__c =: true and name='Why aren\'t all electric companies on TrueCost?']);}
        catch(exception e){
            list<faq__c> blank = new list<faq__c>(); 
            return blank;
        }
    }
    
    public pageReference toggleFees(){fees=!fees; return null;}
    public pageReference toggleGlossary(){glossary=!glossary; return null;}
    public pageReference toggleFAQ(){FAQ=!FAQ; return null;}
    
}