@isTest 
private class TrueCostEstimator_test{
    static testMethod void test(){
        String searchESID = '12345';
        id RTI = [select id from recordtype where name = 'Electric Premise'].id;
        Premises__c premise = new Premises__c (Electric_Service_Address_Zip__c = '90210', premise_type__c = 'Residential', Electric_Service_Address_City__c = 'Longview', ESID__c = searchESID, recordtypeid = RTI, Electric_Service_Address__c = '1123 Fake Street', DUNS__C = 4789735, ESI_ID_Status__c = 'Active', Square_Feet__c = 10, Year_Built__c = '2000', Year_of_Construction__c=2000);
        insert premise;
        monthly_usage__c mn=new monthly_usage__c(Premise__c=premise.Id);
        insert mn;
        
        TrueCostEstimator.makeUsageEstimateList(premise);
        TrueCostEstimator.MakeEstimateThenSave(premise);
        TrueCostEstimator.averageComps(premise);
        
         for (integer k =1; k<13; k++)
            insert new monthly_usage__c(month_number__C = k, usage__c = 10.0,premise__c = premise.ID);
    }
}