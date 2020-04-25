@RestResource(urlMapping='/Address/*')
global class AddressResource {
    @HttpGet
    global static String checkZip() {
        RestRequest request = RestContext.request;
        String Zip = request.params.get('Zip');
       
        try {
        	return TrueCostUtilities.checkZipCode(Zip);
        } catch (Exception e) {
            System.debug(e);
        }
        
        return null;
    }
}