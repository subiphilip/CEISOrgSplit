@isTest

private class MeterDataUtilities_Test {

    static testMethod void testUHITDeduper(){

        //let's give it 12
        list<uhitmessage__c> UHMs = UsageRequestManager.DedupeUHIT(MakeUHMs());
        system.assert(UHMs.size()==12);

        //now give it the same 12 again
        UHMS.addAll(MakeUHMs());
        system.assert(UHMs.size()==24);
        UHMS=UsageRequestManager.DedupeUHIT(UHMS);
        system.assert(UHMs.size()==12);



    }


        /*
        MeterDataUtilities.AppendDailies(AccountPremiseAssociation__c APA);
        MeterDataUtilities.CleanDailies(AccountPremiseAssociation__c APA);
        MeterDataUtilities.getDailies(AccountPremiseAssociation__c APA);
        MeterDataUtilities.getExistingJSONfromAttachment(AccountPremiseAssociation__c APA);
        MeterDataUtilities.IntervalsToJSONAttachment(LIST input, Id parentid);
        MeterDataUtilities.QueryAll(AccountPremiseAssociation__c APA);
        */
        //TrueCostTestUtilities.createAlltheData();
        /*TrueCosttestUtilities.createTestZipCodes();
        TrueCosttestUtilities.makeREP();
        TrueCosttestUtilities.makePlan();
        TrueCosttestUtilities.createTestPremisewithUsage();
        User u = TrueCosttestUtilities.createTestAccountContactUserPremiseAPA();
        */
        //User u=TrueCosttestUtilities.createTestAccountContactUserPremiseAPA();
        
        
        //MeterDataUtilities.AppendDailies(APAUtilities.getActiveAPA(u.id));
        /*
        MeterDataUtilities.CleanDailies(a);
        MeterDataUtilities.getDailies(a);
        MeterDataUtilities.getExistingJSONfromAttachment(a);
        //MeterDataUtilities.IntervalsToJSONAttachment(LIST input, Id parentid);
        MeterDataUtilities.QueryAll(a);*/

    public static list<Daily_Usage__c> MakeDUs(){
        list<Daily_Usage__c> output = new list<Daily_Usage__c>();
        return output;
    }

    public static list<uhitmessage__c> MakeUHMs(){
        list<uhitmessage__c> output = new list<uhitmessage__c>();
        for (integer x=1; x<13; x++){
            output.add(new uhitmessage__c(ActkWh__c=x*100, BilledKVA__c=25, StartDate__c=Date.newinstance(2014, x, 5), EndDate__c = Date.newinstance(2014, x, 5).addmonths(1).addDays(-1)));
        }        
        return output;
    }

 }