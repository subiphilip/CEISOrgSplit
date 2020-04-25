public with sharing class UHITAsync {
    
    
    @future (callout=true)
    public static void UHITSummaryCalloutFuture(string apaid){
        MakeUHITCalloutSummary(apaid);
    }

    public static UsageRequest.PremiseHistoricalUsageRequestAckList_element[] calloutSender(UsageRequest.PremiseHistoricalUsageRequestList reqList){
        //TrueCostSystemVariables__c tcsv = TrueCostSystemVariables__c.getOrgDefaults();


        UsageRequest.PremiseHistoricalUsageRequestAckList_element[] rep ;

        String Party        = 'ThirdParty';
        String ReqId        = '838611739';
        String CallBackURI  = 'https://centerpoint-sbx.us-e1.cloudhub.io/uhit/HistoricalUsage'; 
        //String CallBAckURI =  tcsv.UHITCallback__c;
        String techEmail    = 'shane.mclaughlin@centerpointenergy.com';

        UsageRequest.ExecutePortType prt = new UsageRequest.ExecutePortType();
        
        system.debug('requestmgr reqList'+reqList);

        rep = prt.RequestForHistoricalUsage(Party, ReqId, CallBackURI, techEmail, reqList );       

        system.debug('requestmgr req result'+rep);

        return rep;
    }


    public static void MakeUHITCallout(string ApaID){
        AccountPremiseAssociation__c APA = getAPA(APAid);
        if (APA.Premise__r.TDSP_Lookup__r.Name!='CenterPoint Energy Houston Electric') return;

        //OUTPUT OBJECTS
        List<UsageRequest.PremiseHistoricalUsageRequest> lst = new  List<UsageRequest.PremiseHistoricalUsageRequest>(); 

        UsageRequest.PremiseHistoricalUsageRequestList reqList = new UsageRequest.PremiseHistoricalUsageRequestList();

        //Organizing the Callout info
        lst.add(BuildRequest(APA, true));
        reqList.PremiseHistoricalUsageRequest = lst;
        
        //Make The Callout 
        UsageRequest.PremiseHistoricalUsageRequestAckList_element[] rep  = calloutSender(reqList);

        String requestId = rep[0].PremiseHistoricalUsageAck.RequestID;

        system.debug('requestmgr req id'+requestId);

        UHITRequest__c  request = new UHITRequest__c(
            APA__c=APA.id,
            requestId__c=rep[0].PremiseHistoricalUsageAck.RequestID,
            ESID__c=rep[0].PremiseHistoricalUsageAck.ESIID
        );

        
        
        apa.Meter_Data_Daily_Status__c = 'In Progress';
        apa.Meter_Data_Request_Status__c = 'Complete' ;   
        apa.lastDaily__c = Datetime.now();
        apa.RequestId__c = requestId;

        update apa;
        insert request;
    }   

    public static void MakeUHITCleanupCallout(string ApaID){
        AccountPremiseAssociation__c APA = getAPA(APAid);
        if (APA.Premise__r.TDSP_Lookup__r.Name!='CenterPoint Energy Houston Electric') return;

        //OUTPUT OBJECTS
        List<UsageRequest.PremiseHistoricalUsageRequest> lst = new  List<UsageRequest.PremiseHistoricalUsageRequest>(); 

        UsageRequest.PremiseHistoricalUsageRequestList reqList = new UsageRequest.PremiseHistoricalUsageRequestList();

        //Organizing the Callout info
        lst.add(BuildCleanupRequest(APA, true));
        reqList.PremiseHistoricalUsageRequest = lst;
        
        //Make The Callout 
        UsageRequest.PremiseHistoricalUsageRequestAckList_element[] rep  = calloutSender(reqList);

        String requestId = rep[0].PremiseHistoricalUsageAck.RequestID;

        system.debug('requestmgr req id'+requestId);

        UHITRequest__c  request = new UHITRequest__c(
            APA__c=APA.id,
            requestId__c=rep[0].PremiseHistoricalUsageAck.RequestID,
            ESID__c=rep[0].PremiseHistoricalUsageAck.ESIID
        );

        
        
        apa.Meter_Data_Daily_Status__c = 'In Progress';
        apa.Meter_Data_Request_Status__c = 'Complete' ;   
        apa.lastDaily__c = Datetime.now();
        apa.RequestId__c = requestId;

        update apa;
        insert request;
    }   


    public static void MakeUHITCalloutSummary(string ApaID){
        AccountPremiseAssociation__c APA = getAPA(APAid);

        if (APA.Premise__r.TDSP_Lookup__r.Name!='CenterPoint Energy Houston Electric') return;

        //OUTPUT OBJECTS
        List<UsageRequest.PremiseHistoricalUsageRequest> lst = new  List<UsageRequest.PremiseHistoricalUsageRequest>(); 

        UsageRequest.PremiseHistoricalUsageRequestList reqList = new UsageRequest.PremiseHistoricalUsageRequestList();

        //Organizing the Callout info
        lst.add(BuildRequest(APA, false));
        reqList.PremiseHistoricalUsageRequest = lst;
        
        //Make The Callout
        try{ 
            UsageRequest.PremiseHistoricalUsageRequestAckList_element[] rep  = calloutSender(reqList);
           
            String requestId = rep[0].PremiseHistoricalUsageAck.RequestID;

            system.debug('requestmgr req id'+requestId);

            UHITRequest__c  request = new UHITRequest__c(
                APA__c=APA.id,
                requestId__c=rep[0].PremiseHistoricalUsageAck.RequestID,
                ESID__c=rep[0].PremiseHistoricalUsageAck.ESIID
            );
            
            apa.Meter_Data_Request_Status__c = 'In Progress';
            apa.RequestId__c = requestId;

            update apa;
            insert request;
        } catch(CalloutException e){
            system.debug('callout exception ' +e);
            apa.Meter_Data_Request_Status__c = 'Error-'+e;
            update apa;
            //throw an exception so that UHIT retries on the next batch of ASR
            throw new UHITErrorCodeException('Callout Exception ' +e);          

            
        }   
    }



    public static UsageRequest.PremiseHistoricalUsageRequest BuildRequest(AccountPremiseAssociation__c APA, boolean interval){

        //variables
        string CallType;
        date mydate = date.today()-1;
        UsageRequest.PremiseHistoricalUsageRequest req = new  UsageRequest.PremiseHistoricalUsageRequest() ;

        //Shared data for all calls
        req.AuthorizationType                                       = 'Unlimited';
        req.AuthorizationOnFile                                     = true;
        req.ESIID                                                   = APA.premise__r.ESID__c;
        req.MeterNumber                                             = APA.premise__r.Meter_Number__c;
        req.ServiceAddress                                          = APA.premise__r.Electric_Service_Address__c;
        req.ServiceCity                                             = APA.premise__r.Electric_Service_Address_City__c;
        req.ServiceState                                            = APA.premise__r.Electric_Service_Address_State2__c;
        req.ServiceZip                                              = APA.premise__r.Electric_Service_Address_Zip__c.substring(0,5);
        //  req.TypeOfData                                              = 'Summary Billing Data';
        //req.TypeOfData                                              = CallType;
        req.CustomerNameGrantingAuthorization                       = APA.account__r.Name;
        req.CustomerTitleGrantingAuthorization                      = 'Owner';
        req.CustomerTelephoneNumberGrantingAuthorization            = APA.account__r.PersonHomePhone;
        req.CustomerBillingStreetAddressGrantingAuthorization       = APA.account__r.Billing_Adrs_Line_1__c;
        req.CustomerBillingCityGrantingAuthorization                = APA.account__r.Billing_City__c;
        req.CustomerBillingStateGrantingAuthorization               = APA.account__r.Billing_State_Code__c;
        if (APA.premise__r.Electric_Service_Address_Zip__c != null){
            req.CustomerBillingZipGrantingAuthorization                 = APA.premise__r.Electric_Service_Address_Zip__c.substring(0,5);
        }else{
            req.CustomerBillingZipGrantingAuthorization                 = APA.premise__r.Electric_Service_Address_Zip__c;
        }
        req.OriginalAuthorizationDate = mydate;

        //specific to one branch or the other

        if (interval){
            req.TypeOfData='Interval Data';
            List<AggregateResult>  queryDate  = [select max(Date__c) day FROM Daily_Usage__c WHERE Account_Premise_Association__c =: apa.id]; 

            if(String.ValueOf(queryDate[0].get('day')) != null )    {               
                date d= date.valueof(queryDate[0].get('day'));
                req.UsageStartDate = d.adddays(1);
            }
        } else{
            req.TypeOfData='Summary Billing Data';
            req.UsageEndDate = date.today()-2;
        }       

        return req;
    }
    
    public static UsageRequest.PremiseHistoricalUsageRequest BuildCleanupRequest(AccountPremiseAssociation__c APA, boolean interval){

        //variables
        string CallType;
        date mydate = date.today()-1;
        UsageRequest.PremiseHistoricalUsageRequest req = new  UsageRequest.PremiseHistoricalUsageRequest() ;

        //Shared data for all calls
        req.AuthorizationType                                       = 'Unlimited';
        req.AuthorizationOnFile                                     = true;
        req.ESIID                                                   = APA.premise__r.ESID__c;
        req.MeterNumber                                             = APA.premise__r.Meter_Number__c;
        req.ServiceAddress                                          = APA.premise__r.Electric_Service_Address__c;
        req.ServiceCity                                             = APA.premise__r.Electric_Service_Address_City__c;
        req.ServiceState                                            = APA.premise__r.Electric_Service_Address_State2__c;
        req.ServiceZip                                              = APA.premise__r.Electric_Service_Address_Zip__c.substring(0,5);
        //  req.TypeOfData                                              = 'Summary Billing Data';
        //req.TypeOfData                                              = CallType;
        req.CustomerNameGrantingAuthorization                       = APA.account__r.Name;
        req.CustomerTitleGrantingAuthorization                      = 'Owner';
        req.CustomerTelephoneNumberGrantingAuthorization            = APA.account__r.PersonHomePhone;
        req.CustomerBillingStreetAddressGrantingAuthorization       = APA.account__r.Billing_Adrs_Line_1__c;
        req.CustomerBillingCityGrantingAuthorization                = APA.account__r.Billing_City__c;
        req.CustomerBillingStateGrantingAuthorization               = APA.account__r.Billing_State_Code__c;
        if (APA.premise__r.Electric_Service_Address_Zip__c != null){
            req.CustomerBillingZipGrantingAuthorization                 = APA.premise__r.Electric_Service_Address_Zip__c.substring(0,5);
        }else{
            req.CustomerBillingZipGrantingAuthorization                 = APA.premise__r.Electric_Service_Address_Zip__c;
        }
        req.OriginalAuthorizationDate = mydate;

        //specific to one branch or the other

        if (interval){
            req.TypeOfData='Interval Data';
            
                req.UsageStartDate = date.valueof('2013-09-28');
                req.UsageEndDate = date.valueof('2014-08-27');
            }


        return req;
    }

    public static void UHITRequestTriggerHandler(list<UHITRequest__c> UHRs, map<id, UHITRequest__c> oldUHRs){
        list<AsyncRequest__c> ASRs = new list<AsyncRequest__c>();

        for (UHITRequest__c UHR:UHRs){
            if (UHR.StatusCode__c !=null){ //it has an error
                if (UHR.StatusCode__c != oldUHRs.get(UHR.id).StatusCode__c){ //and didn't before
                    ASRs.add(
                        new AsyncRequest__c(
                            type__c='UHITRequestError', 
                            params__c=UHR.APA__c+','
                            +UHR.StatusCode__c)
                        );
                }
            }
        }

        insert ASRs;
    }

    public static void ProcessErrorASR(string params){
        string APAid = params.split(',')[0];
        string errorCode = params.split(',')[1];

        AccountPremiseAssociation__c APA = [select id, Meter_Data_Request_Status__c from AccountPremiseAssociation__c where id=:APAid];

        if (errorCode=='21'){ //meter number problem
            APA.Meter_Data_Request_Status__c='Error-Invalid Meter/ESID Match';
            } else if (errorCode=='7'){ //no rep of record
                APA.Meter_Data_Request_Status__c='Error-No REP of Record';
                } else if (errorCode=='9'){ //service address issue
                    APA.Meter_Data_Request_Status__c='Error-Invalid Service Address';
                    } else if (errorCode=='1'){ //service address issue
                        //do nothing, it's just a warning about the date range.
                        } else if (errorCode=='14'){ //service address issue
                            //do nothing--that's multiple requests per day not allowed
                            } else if (errorCode=='13'){ //service address issue
                                APA.Meter_Data_Request_Status__c='Error-ServiceZip does not match the address CEHE has' ;
                                } else if (errorCode=='22'){ //service address issue, needs to reauthorize with present owner of premise
                                    APA.Meter_Data_Request_Status__c='Error-MVI/MVO completed after authorization date' ;
                                    }else if (errorCode==''){
                                        throw new UHITErrorCodeException('UHIT Error Code Is Null');
                                        } else {
                                            throw new UHITErrorCodeException('Unknown UHIT Error Code');
                                        }
        update APA;
    }

    public class UHITErrorCodeException extends Exception {}


    //just for handling a common query for UHIT
    public static AccountPremiseAssociation__c GetAPA(string APAid){
        return [select id,      
        Premise__r.meter_number__c, meter_data_permission__c,
        Premise__r.Electric_Service_Address__c, premise__r.ESID__c, premise__r.Electric_Service_Address_City__c, premise__r.Electric_Service_Address_State2__c, premise__r.Electric_Service_Address_Zip__c,

        Premise__r.TDSP_Lookup__r.Name,

        Account__r.id, Account__r.Name, Account__r.PersonHomePhone, Account__r.ispersonAccount, Account__r.PersonEmail, Account__r.phone, Account__r.Billing_Adrs_Line_1__c, Account__r.Billing_Adrs_Line_2__c, Account__r.Billing_City__c, Account__r.Billing_State_Code__c, Account__r.State__c, Account__r.Billing_zip_code__c,

        Meter_Data_Daily_Status__c, Meter_Data_Request_Status__c, lastDaily__c, RequestId__c

        from AccountPremiseAssociation__c
        where id=:ApaID];
    }
}