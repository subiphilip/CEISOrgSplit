/*
Shane McLaughlin     7/5/2012     Removed commercial address check since they're now ok for use.
*/
public with sharing class ControllerForAddServiceAddress {
    
    public ControllerForAddServiceAddress () {
    
        dummyenrollment=new enrollment__C();
        dummyenrollment.Address__c = ApexPages.currentpage().GetParameters().get('a');
        if (dummyenrollment.Address__c == 'null') dummyenrollment.Address__c =null;
        dummyenrollment.Zip__c = ApexPages.currentpage().GetParameters().get('z');
        ZipCodeLightboxFlag = false;
        if (dummyenrollment.Zip__c == 'null') dummyenrollment.Zip__c =null;
        
        
    }
    
    public static boolean ZipCodeLightboxFlag {get;set;}
    public integer zipcodelightboxmessage {get; set;}
    
    public string SearchESID {get;set;}
    public id selectedpremiseid {get;set;}
    public boolean wantmeterdata{Get;set;}
    public enrollment__c dummyenrollment{Get;set;}{}
    public premises__c dummypremise{Get;set;}   
    public string whichresult{get;set;}{whichresult='default';}
    public list<premises__C> premiselist {get;set;}
    public user u {get;set;}{u = new User();}  
        
    public void falseTheZipcodeLightboxFlag(){  //action method for the zipcode lightbox, used by the lightbox component
        zipcodelightboxflag=false;
    }
     
    /*public submitzip() {
        string zipcodecheck=TrueCostUtilities.checkZipCode(dummyenrollment.zip__c);
        if (zipcodecheck=='Now'){return null;}
                else{if (zipcodecheck=='Later'){
                        zipcodelightboxmessage=1;
                        zipcodelightboxflag=true;
                        return null;}
                    else{
                        zipcodelightboxmessage=0;
                        zipcodelightboxflag=true;
                        return null;}
                }
    }*/
    
    public PageReference AddressSearch() {       
       
        if (dummyenrollment.Address__c.length()<2) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Your address is not long enough to search');
            ApexPages.addMessage(msg);
            
            return null;
        }
        
        string zipcodecheck=TrueCostUtilities.checkZipCode(dummyenrollment.zip__c);
        if (zipcodecheck == 'Later'){
        	zipcodelightboxmessage=1;
            zipcodelightboxflag=true;
            return null;
        } else {
        	if (zipcodecheck != 'Now'){
		    	zipcodelightboxmessage=0;
		        zipcodelightboxflag=true;
		        return null;
        	}                        
        }
        
        whichresult=null;
        
        if (searchESID==null||searchESID.length()<2){ //length >2 prevents error thrown by lookup method
            premiselist = TrueCostUtilities.exactMatchServiceAddress(dummyenrollment.address__c, dummyenrollment.zip__c);
                if(premiselist.size()==0){whichresult='no match';}
                    else{if(premiselist.size()==1){whichresult='one match';selectedpremiseid=premiselist[0].id;}
                        else{if(premiselist.size()>1){whichresult='multi match';}
                        }
                    }                
            return null;
        }
        
        if (searchESID!=null&&searchESID.length()>=2){  //length >2 prevents error thrown by lookup method
            premiselist = TrueCostUtilities.searchByESID(searchESID);
                if(premiselist.size()==0){whichresult='no match';}
                    else{if(premiselist.size()==1){whichresult='one match';selectedpremiseid=premiselist[0].id;}
                        else{if(premiselist.size()>1){whichresult='multi match';}
                        }
                    }
            searchESID = null;    
            return null;
        }
        return null;   
    }
        //first, let's get that service address matched.  Try an exact match
    public list<premises__c> getmatch(){    
               return premiselist;
    }
        
    public void nada(){} //kludge sometimes used to make rerenders happen
        
    public pagereference confirmSingleAddress() {                 
        premises__c selectedpremise2 = [select id, Electric_Service_Address_City__c,Premise_Type__c, Electric_Service_Address__c, 
                                                    Electric_Service_Address_State2__c, Electric_Service_Address_Zip__c, tdsp_lookup__r.name
                                                    from premises__C where id=:selectedpremiseid];
        
        list<account> newuseraccount = new list<account>();   
        newuseraccount = [select Billing_City__c, State__c, Billing_Adrs_Line_1__c, Billing_zip_code__c, Search_Zip_Code__c from Account where id=:TrueCostUtilities.getTheAccount(UserInfo.getUserId() )];
        
        //if the user doesn't have a billing address saved, why not assume it's the premise they're creating?
        if(newuseraccount[0].Billing_Adrs_Line_1__c==null){
        newuseraccount[0].Billing_City__c=selectedpremise2.Electric_Service_Address_City__c;
        newuseraccount[0].Billing_Adrs_Line_1__c=selectedpremise2.Electric_Service_Address__c;
        newuseraccount[0].State__c=selectedpremise2.Electric_Service_Address_State2__c;
        newuseraccount[0].Billing_zip_code__c=selectedpremise2.Electric_Service_Address_Zip__c.substring(0,5);
        }        
        if(newuseraccount[0].Search_Zip_Code__c==null){
        	newuseraccount[0].Search_Zip_Code__c=selectedpremise2.Electric_Service_Address_Zip__c.substring(0,5);
        }        
        update newuseraccount[0];        
        APAUtilities.makeapa(newuseraccount[0].id, selectedpremiseid);
        if (selectedpremise2.tdsp_lookup__r.name != 'CenterPoint Energy'){
            return page.Shopplans; //no point doing calculation choice if they're not UHIT/CEHE eligible!
        }
        if (selectedpremise2.premise_type__c != 'Residential'){
            PageReference PR = Page.Calculation_Choice; //if you're not resi, you need to get meter data!
            PR.getparameters().put('mode', 'MeterData');
            return pr;
        }        
        return Page.Calculation_Choice;
    }    
    
        
    public pagereference AddressSelect(id SelectedPremise) {
        return null;}
        
   



}