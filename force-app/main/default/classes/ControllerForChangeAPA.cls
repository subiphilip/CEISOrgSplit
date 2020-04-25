public class ControllerForChangeAPA {
    
    public id accountID {get;set;}
    public string SelectedAPA {get;set;}
    
    public ControllerForChangeAPA(){
               accountID = [select id from account where id=:TrueCostUtilities.GetTheAccount(Userinfo.getuserid())][0].id;
               //selectedAPA = APAUtilities.getActiveAPA(accountID).id;
    }
    
    public list<SelectOption> getAPAOPtions(){
        list<AccountPremiseAssociation__c> APAs = APAUtilities.GetAllAPAs(AccountID);
        List<SelectOption> options = new List<SelectOption>();
        //first, add the selected one
        for(AccountPremiseAssociation__c APA:APAs){
            if (APA.selected__c){options.add(new SelectOption( APA.id, APA.premise__r.Electric_Service_Address__c));}
        }
        //then, add the other ones
        for(AccountPremiseAssociation__c APA:APAs){
            if (!APA.selected__c){options.add(new SelectOption(APA.id, APA.premise__r.Electric_Service_Address__c));}
        }
        //then, add the other standard options
        options.add(new SelectOption( 'New', 'Add a new Service Address'));
        options.add(new SelectOption( 'Manage', 'Manage Service Addresses'));
        //then return
        return options;        
    }
    public list<SelectOption> getAPAOPtionsNoManage(){
        list<AccountPremiseAssociation__c> APAs = APAUtilities.GetAllAPAs(AccountID);
        List<SelectOption> options = new List<SelectOption>();
        //first, add the selected one
        for(AccountPremiseAssociation__c APA:APAs){
            if (APA.selected__c){options.add(new SelectOption( APA.id, APA.premise__r.Electric_Service_Address__c));}
        }
        //then, add the other ones
        for(AccountPremiseAssociation__c APA:APAs){
            if (!APA.selected__c){options.add(new SelectOption(APA.id, APA.premise__r.Electric_Service_Address__c));}
        }
        //then, add the other standard options
        options.add(new SelectOption( 'New', 'Add a new Service Address'));

        //then return
        return options;        
    }
        
    public pageReference Submit(){
        system.debug('=============================SelectedAPA is '+selectedAPA);
        if (SelectedAPA=='New'){return page.AddAddressAfterRegistration;}
        if (SelectedAPA=='Manage'){return page.MyAccount;}        
        APAUtilities.ChangeSelectedAPA(SelectedAPA, accountID); //set the selected on as active
        PageReference pr = ApexPages.CurrentPage();
        pr.setredirect(true);
        return pr;        
    }

    public pageReference ShopPlans(){
        system.debug('=============================SelectedAPA is '+selectedAPA);
        if (SelectedAPA=='New'){return page.AddAddressAfterRegistration;}
        if (SelectedAPA=='Manage'){return page.MyAccount;}        
        APAUtilities.ChangeSelectedAPA(SelectedAPA, accountID); //set the selected on as active
        PageReference pr = new PageReference('/Account_Profile?redirect=Shop_Plans');

        //PageReference pr = ApexPages.CurrentPage();
        //PageReference pr = new PageReference('/Shop_Plans');
        //pr.setredirect(true);
        return pr;        
    }
    
    public pageReference ShopPlansCommercial(){
        system.debug('=============================SelectedAPA is '+selectedAPA);
        if (SelectedAPA=='New'){return page.AddAddressAfterRegistration;}
        if (SelectedAPA=='Manage'){return page.MyAccount;}        
        APAUtilities.ChangeSelectedAPA(SelectedAPA, accountID); //set the selected on as active
        PageReference pr = new PageReference('/Account_Profile?redirect=Shop_Plans_Commercial');

        //PageReference pr = ApexPages.CurrentPage();
        //PageReference pr = new PageReference('/Shop_Plans');
        //pr.setredirect(true);
        return pr;        
    }
    
    public pageReference SubmitRefresh(){
        system.debug('=============================SelectedAPA is '+selectedAPA);
        if (SelectedAPA=='New'){return page.AddAddressAfterRegistration;}
        if (SelectedAPA=='Manage'){return page.MyAccount;}        
        APAUtilities.ChangeSelectedAPA(SelectedAPA, accountID); //set the selected on as active
        
        return null;        
    }
    
    
    public list<APAUtilities.APAWrapper> getAPAstoManage(){ 
        list<APAUtilities.APAWrapper> output = new list<APAUtilities.APAWrapper>();
        for(AccountPremiseAssociation__c item:APAUtilities.GetAllAPAs(AccountID)){
            APAUtilities.APAWrapper wrapper = new APAUtilities.APAWrapper(item);
            output.add(wrapper);
        }
        
        return output;
        
    }
    
    public PageReference DeleteAPA(){
        
        AccountPremiseAssociation__c APA2Delete = [select id from AccountPremiseAssociation__c where id=: SelectedAPA];
        try{delete APA2Delete;} catch(exception e){}
        return null;
    }
    
}