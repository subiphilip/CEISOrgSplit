public with sharing class ContentRewriter {

	public static list<Content_BlogEntry__c> Rewrite (list<Content_BlogEntry__c> incoming){
		for (Content_BlogEntry__c b:incoming){
			try{ 
		        b.body__c = b.body__c.replace('http://www.mytruecost.com/', '/');
		        b.body__c = b.body__c.replace('http://www.myTrueCost.com/', '/');
		        b.body__c = b.body__c.replace('http://myTrueCost.com/', '/');
		        b.body__c = b.body__c.replace('http://mytruecost.com/', '/');
		        b.body__c = b.body__c.replace('http://centerpointenergy.force.com/', '/');
		        b.body__c = b.body__c.replace('https://centerpointenergy.secure.force.com/', '/');
		        b.above_the_fold__c = b.above_the_fold__c.replace('http://www.mytruecost.com/', '/');
		        b.above_the_fold__c = b.above_the_fold__c.replace('http://www.myTrueCost.com/', '/');
		        b.above_the_fold__c = b.above_the_fold__c.replace('http://myTrueCost.com/', '/');
		        b.above_the_fold__c = b.above_the_fold__c.replace('http://mytruecost.com/', '/');
		        b.above_the_fold__c = b.above_the_fold__c.replace('http://centerpointenergy.force.com/', '/');
		        b.above_the_fold__c = b.above_the_fold__c.replace('https://centerpointenergy.secure.force.com/', '/');
	        } catch (exception e){}
        
		}
		return incoming;
	}
	
	public static list<FAQ__c> Rewrite (list<FAQ__c> incoming){
		for (FAQ__c b:incoming){
			try{
		        b.answer__c = b.answer__c.replace('http://www.mytruecost.com/', '/');
		        b.answer__c = b.answer__c.replace('http://www.myTrueCost.com/', '/');
		        b.answer__c = b.answer__c.replace('http://myTrueCost.com/', '/');
		        b.answer__c = b.answer__c.replace('http://mytruecost.com/', '/');
		        b.answer__c = b.answer__c.replace('http://centerpointenergy.force.com/', '/');
		        b.answer__c = b.answer__c.replace('https://centerpointenergy.secure.force.com/', '/');
	        } catch (exception e){}
        
		}
		return incoming;
	}
	
	public static list<content_item__c> Rewrite (list<content_item__c> incoming){
		for (content_item__c b:incoming){
			try{
		        b.Definition__c = b.Definition__c.replace('http://www.mytruecost.com/', '/');
		        b.Definition__c = b.Definition__c.replace('http://www.myTrueCost.com/', '/');
		        b.Definition__c = b.Definition__c.replace('http://myTrueCost.com/', '/');
		        b.Definition__c = b.Definition__c.replace('http://mytruecost.com/', '/');
		        b.Definition__c = b.Definition__c.replace('http://centerpointenergy.force.com/', '/');
		        b.Definition__c = b.Definition__c.replace('https://centerpointenergy.secure.force.com/', '/');
	        } catch (exception e){}
        
		}
		return incoming;
	}
	
}