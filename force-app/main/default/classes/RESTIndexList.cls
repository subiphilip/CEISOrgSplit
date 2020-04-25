@RestResource(urlMapping='/IndexesJSON/*')

global class RESTIndexList {

	@HttpGet
    global static list<string> getIndexes() {
        String filter = RestContext.request.params.get('filter');
        if (filter!=null){
      	
      	} else {
        	list<index__c> sobjectlist = [select id, name from index__c where name!=null];
        	//return sobjectlist;
        	list<string> output = new list<string>();
        	
        	
        	for (index__c i:sobjectlist){
        		output.add(i.name);
        	}
        	return output;
        }
       return null;
    }
}