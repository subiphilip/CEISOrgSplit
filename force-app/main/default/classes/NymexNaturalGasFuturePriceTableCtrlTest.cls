@isTest
public class NymexNaturalGasFuturePriceTableCtrlTest {
    static testMethod void getIndexRecTest(){
        Map<String,String> indexMap = NymexNaturalGasFuturePriceTableCtrl.getIndexMap();
        system.assertEquals(3, indexMap.keySet().size());
        NymexNaturalGasFuturePriceTableCtrl.UsageWrapper uw = NymexNaturalGasFuturePriceTableCtrl.getIndexRec();
        if (uw != null) {
        	system.assertEquals(30, uw.listOfFirstThirtyFutures.size());
        	system.assertEquals(30, uw.listOfSecondThirtyFutures.size());
        }
    }
    static testMethod void getIndexRecTestForMonth1(){
        List<Index_Future__c> indexFutureList = [select id, Month__c, name, Year__c, Index__c, Price__c, Delivery_Date__c from Index_Future__c];
        For(Index_Future__c inf: indexFutureList){
            inf.Delivery_Date__c = date.newInstance(system.today().year(), system.today().month()+1, 1);
        }
        indexFutureList[12].Delivery_Date__c = date.newInstance(system.today().year()+1, system.today().month()+1, 1);
        indexFutureList[24].Delivery_Date__c = date.newInstance(system.today().year()+1, system.today().month()+1, 1);
        indexFutureList[36].Delivery_Date__c = date.newInstance(system.today().year()+1, system.today().month()+1, 1);
        indexFutureList[48].Delivery_Date__c = date.newInstance(system.today().year()+1, system.today().month()+1, 1);
        
        update indexFutureList;
        Map<String,String> indexMap = NymexNaturalGasFuturePriceTableCtrl.getIndexMap();
        NymexNaturalGasFuturePriceTableCtrl.UsageWrapper uw = NymexNaturalGasFuturePriceTableCtrl.getIndexRec();
        
    }
    static testMethod void getIndexRecTestForMonth2(){
        List<Index_Future__c> indexFutureList = [select id, Month__c, name, Index__c, Price__c, Delivery_Date__c from Index_Future__c];
        For(Index_Future__c inf: indexFutureList){
            inf.Delivery_Date__c = date.newInstance(system.today().year(), system.today().month()+2, 1);
        }
        update indexFutureList;
        Map<String,String> indexMap = NymexNaturalGasFuturePriceTableCtrl.getIndexMap();
        NymexNaturalGasFuturePriceTableCtrl.UsageWrapper uw = NymexNaturalGasFuturePriceTableCtrl.getIndexRec();
        
    }
    static testMethod void getIndexRecTestFoMonth3(){
        List<Index_Future__c> indexFutureList = [select id, Month__c, name, Index__c, Price__c, Delivery_Date__c from Index_Future__c];
        For(Index_Future__c inf: indexFutureList){
            inf.Delivery_Date__c = date.newInstance(system.today().year(), system.today().month()+3, 1);
        }
        update indexFutureList;
        Map<String,String> indexMap = NymexNaturalGasFuturePriceTableCtrl.getIndexMap();
        NymexNaturalGasFuturePriceTableCtrl.UsageWrapper uw = NymexNaturalGasFuturePriceTableCtrl.getIndexRec();
        
    }
    static testMethod void getIndexRecTestForMonth4(){
        List<Index_Future__c> indexFutureList = [select id, Month__c, name, Index__c, Price__c, Delivery_Date__c from Index_Future__c];
        For(Index_Future__c inf: indexFutureList){
            inf.Delivery_Date__c = date.newInstance(system.today().year(), system.today().month()+4, 1);
        }
        update indexFutureList;
        Map<String,String> indexMap = NymexNaturalGasFuturePriceTableCtrl.getIndexMap();
        NymexNaturalGasFuturePriceTableCtrl.UsageWrapper uw = NymexNaturalGasFuturePriceTableCtrl.getIndexRec();
        
    }
    static testMethod void getIndexRecTestForMonth5(){
        List<Index_Future__c> indexFutureList = [select id, Month__c, name, Index__c, Price__c, Delivery_Date__c from Index_Future__c];
        For(Index_Future__c inf: indexFutureList){
            inf.Delivery_Date__c = date.newInstance(system.today().year(), system.today().month()+5, 1);
        }
        update indexFutureList;
        Map<String,String> indexMap = NymexNaturalGasFuturePriceTableCtrl.getIndexMap();
        NymexNaturalGasFuturePriceTableCtrl.UsageWrapper uw = NymexNaturalGasFuturePriceTableCtrl.getIndexRec();
        
    }static testMethod void getIndexRecTestForMonth6(){
        List<Index_Future__c> indexFutureList = [select id, Month__c, name, Index__c, Price__c, Delivery_Date__c from Index_Future__c];
        For(Index_Future__c inf: indexFutureList){
            inf.Delivery_Date__c = date.newInstance(system.today().year(), system.today().month()+6, 1);
        }
        update indexFutureList;
        Map<String,String> indexMap = NymexNaturalGasFuturePriceTableCtrl.getIndexMap();
        NymexNaturalGasFuturePriceTableCtrl.UsageWrapper uw = NymexNaturalGasFuturePriceTableCtrl.getIndexRec();
        
    }static testMethod void getIndexRecTestForMonth7(){
        List<Index_Future__c> indexFutureList = [select id, Month__c, name, Index__c, Price__c, Delivery_Date__c from Index_Future__c];
        For(Index_Future__c inf: indexFutureList){
            inf.Delivery_Date__c = date.newInstance(system.today().year(), system.today().month()+7, 1);
        }
        update indexFutureList;
        Map<String,String> indexMap = NymexNaturalGasFuturePriceTableCtrl.getIndexMap();
        NymexNaturalGasFuturePriceTableCtrl.UsageWrapper uw = NymexNaturalGasFuturePriceTableCtrl.getIndexRec();
        
    }static testMethod void getIndexRecTestForMonth8(){
        List<Index_Future__c> indexFutureList = [select id, Month__c, name, Index__c, Price__c, Delivery_Date__c from Index_Future__c];
        For(Index_Future__c inf: indexFutureList){
            inf.Delivery_Date__c = date.newInstance(system.today().year(), system.today().month()+8, 1);
        }
        update indexFutureList;
        Map<String,String> indexMap = NymexNaturalGasFuturePriceTableCtrl.getIndexMap();
        NymexNaturalGasFuturePriceTableCtrl.UsageWrapper uw = NymexNaturalGasFuturePriceTableCtrl.getIndexRec();
        
    }static testMethod void getIndexRecTestForMonth9(){
        List<Index_Future__c> indexFutureList = [select id, Month__c, name, Index__c, Price__c, Delivery_Date__c from Index_Future__c];
        For(Index_Future__c inf: indexFutureList){
            inf.Delivery_Date__c = date.newInstance(system.today().year(), system.today().month()+9, 1);
        }
        update indexFutureList;
        Map<String,String> indexMap = NymexNaturalGasFuturePriceTableCtrl.getIndexMap();
        NymexNaturalGasFuturePriceTableCtrl.UsageWrapper uw = NymexNaturalGasFuturePriceTableCtrl.getIndexRec();
        
    }static testMethod void getIndexRecTestForMonth10(){
        List<Index_Future__c> indexFutureList = [select id, Month__c, name, Index__c, Price__c, Delivery_Date__c from Index_Future__c];
        For(Index_Future__c inf: indexFutureList){
            inf.Delivery_Date__c = date.newInstance(system.today().year(), system.today().month()+10, 1);
        }
        update indexFutureList;
        Map<String,String> indexMap = NymexNaturalGasFuturePriceTableCtrl.getIndexMap();
        NymexNaturalGasFuturePriceTableCtrl.UsageWrapper uw = NymexNaturalGasFuturePriceTableCtrl.getIndexRec();
        
    }static testMethod void getIndexRecTestForMonth11(){
        List<Index_Future__c> indexFutureList = [select id, Month__c, name, Index__c, Price__c, Delivery_Date__c from Index_Future__c];
        For(Index_Future__c inf: indexFutureList){
            inf.Delivery_Date__c = date.newInstance(system.today().year(), system.today().month()+11, 1);
        }
        update indexFutureList;
        Map<String,String> indexMap = NymexNaturalGasFuturePriceTableCtrl.getIndexMap();
        NymexNaturalGasFuturePriceTableCtrl.UsageWrapper uw = NymexNaturalGasFuturePriceTableCtrl.getIndexRec();
        
    }
    static testMethod void getIndexRecTestForMonth12(){
        List<Index_Future__c> indexFutureList = [select id, Month__c, name, Index__c, Price__c, Delivery_Date__c from Index_Future__c];
        For(Index_Future__c inf: indexFutureList){
            inf.Delivery_Date__c = date.newInstance(system.today().year(), system.today().month()+12, 1);
        }
        update indexFutureList;
        Map<String,String> indexMap = NymexNaturalGasFuturePriceTableCtrl.getIndexMap();
        NymexNaturalGasFuturePriceTableCtrl.UsageWrapper uw = NymexNaturalGasFuturePriceTableCtrl.getIndexRec();
        
    }
    @testSetup static void setup() {
        
		// system.debug('NymexNaturalGasFuturePriceTableCtrlTest setup: ');        
        
        List<Index_Settlement__c> indexSettlementList = new List<Index_Settlement__c>();
        List<Index_Future__c> indexFutureList = new List<Index_Future__c>();
        List<Index__c> indexList = new List<Index__c>();
        List<String> lstOfStr = new List<String>{'DTN HO DELAYED','DTN Propane DELAYED','DTN CL DELAYED','DTN GNG DELAYED'};
            
            for(integer i=0;i<lstOfStr.size();i++){
                Index__c indx = new Index__c();
                indx.name = lstOfStr[i];
                indexList.add(indx);
            }
        
        insert indexList;
        
        for(integer i=0;i<indexList.size();i++){
            Index_Future__c inf = new Index_Future__c();
            inf.name = 'Test Index Future';
            inf.Index__c = indexList[i].id;
            inf.Price__c = 12.345;
            inf.Delivery_Date__c = date.newInstance(system.today().year(), system.today().month(), 1);
            indexFutureList.add(inf);
        }
        
        // initialize with actual start date based on method
        Date testDeliveryDate = NymexNaturalGasFuturePriceTableCtrl.getFirstFutureMonthDate();
        
        for(integer i=0;i<60;i++){
            Index_Future__c inf = new Index_Future__c();
            inf.name = 'Test Index Future';
            inf.Index__c = indexList[3].id;   //; 'DTN GNG DELAYED'
            inf.Price__c = 12.345;
            inf.Delivery_Date__c = testDeliveryDate;
            indexFutureList.add(inf);
            
            // add one month for each delivery period out to 60 months
            testDeliveryDate = testDeliveryDate.addMonths(1);            
        }
        insert indexFutureList;
        
		// system.debug('indexFutureList: ' + indexFutureList);
        
    }
}