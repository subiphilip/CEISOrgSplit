@RestResource(urlMapping='/ZipCodeCheck/*')
    global class RESTZipCodeCheck{

    @HttpGet
    global static List<ValidZipCode__c> getAllZips() {
        String Zip = RestContext.request.params.get('zip');
        if (zip!=null){
        	return [SELECT Name, served_by_truecost__c from ValidZipCode__c where served_by_truecost__c = true and Name=:zip];
        } else return [SELECT Name, served_by_truecost__c from ValidZipCode__c where served_by_truecost__c = true];
       return null;
    }
    
    @HttpPost 
    global static boolean CheckAZip(string zipToCheck) {
        try{ 
            ValidZipCode__c vz = [SELECT id, Served_by_TrueCost__c from ValidZipCode__c where Name=:zipToCheck];
            return vz.Served_by_TrueCost__c;
        } catch(exception e){return false;}
    }
    
    
    
}