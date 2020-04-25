public class ControllerForUHITButtons {

    public pageReference ActionDoer(){
            system.debug ('APA id is ' + ApexPages.currentPage().getParameters().get('id'));
            AccountPremiseAssociation__c APA = [select id, Account__c, Premise__r.id, Selected__c, 
              premise__r.ESID__c, premise__r.Meter_Number__c, premise__r.Electric_Service_Address__c,
              premise__r.Electric_Service_Address_City__c, premise__r.Electric_Service_Address_State2__c, 
              premise__r.Electric_Service_Address_Zip__c
            from AccountPremiseAssociation__c where id =: ApexPages.currentPage().getParameters().get('id')];
            if (!apa.selected__c) {

                list <AccountPremiseAssociation__c> OtherSelectedAPAs = [select id, Selected__c from AccountPremiseAssociation__c where Selected__c = true and Account__c =: APA.Account__c];    
                
                if (!OtherSelectedAPAs.isEmpty()) {
                    for (AccountPremiseAssociation__c apas: OtherSelectedAPAs) {
                        apas.Selected__c = false;
                   }

                    update OtherSelectedAPAS;
              }
                apa.selected__c = true;
                update APA;
            }
            
          /*UHITBatchMgr UHBM = new UHITBatchMgr();
          UHBM.uhitFix(APA.premise__r.id);*/
          //UsageRequestManager urm = new UsageRequestManager();
          //public void sendRequest(Premises__c premise, AccountPremiseAssociation__c apapassed,  String callType)
          //urm.sendRequest(apa.Premise__r, apa, 'Summary Billing Data');
          UhitAsync.UHITSummaryCalloutFuture(APA.id);

      PageReference PR = new PageReference('/' + (ApexPages.currentPage().getParameters().get('ret')));
      return PR;
    }
}