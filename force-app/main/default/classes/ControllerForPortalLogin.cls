global virtual class ControllerForPortalLogin {
	//Login related stuff--register part only!
    public string loginpassword{get;set;}
    public string loginemail{get;set;}

    global pageReference login(){
        system.debug('password is ' + loginpassword);
        system.debug('username is ' + loginemail);
        return Site.login(loginemail, loginpassword, '/MobileAddressSetup');
    }

	@RemoteAction
        global static string RemoteLogin(string email, string password, string url){
            PageReference result = new PageReference('temp');
            try {
            	result = Site.login(email, password, url);
              	system.debug(result);
            }catch (exception e){
              	return e.getMessage();
            }
            if (result!=null) {
                return result.getURL(); 
            } else {
                return 'login error';
            }
        }
}