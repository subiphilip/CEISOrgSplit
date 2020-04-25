public with sharing class TC2SwitchReminderPlans  {

      public string recipientId;
      public string relatedToId;

      public Lead recipient {get;set;}
      public Lead relatedTo {get;set;}

      public string getRecipientId() {return recipientId; }
      public void setRecipientId(string inString) {
        recipientId = inString;
        recipient = [SELECT id,name,email FROM Lead WHERE id = :recipientId];
      }

      public string getRelatedToId() { return relatedToId;}
      public void setRelatedToId(string inString) {
        relatedToId = inString;
        relatedTo = [SELECT id,name,email FROM Lead WHERE id = :relatedToId];
      }

      public TC2SwitchReminderPlans() {
        // Whatever code you need in the constructor....
      }

      public list<ResultsContainer> getPlans(){
          list<ResultsContainer> result = ShopRemote(recipient.Zip__c);
          list<ResultsContainer> newList = new List<ResultsContainer>();
          for(Integer i = 0; i< 3;i++){
            newList.add(result[i]);
          }
          return newList;
      }

      public list<ResultsContainer> ShopRemote(string zipcode){

        list<ResultsContainer> PricedRates;
        id tdspid=TDSPIDfromZipCode(zipcode);
        list<rate__c> planlist2 = TrueCostCalc.getActivePlans2(null, tdspid, 'Residential');
        list<Saved_Plan__c> savedplans = new list<Saved_Plan__c>();
        string loadcurve; //starts null, which is fine for all but commercial.
        PricedRates = SimpleResults(TrueCostCalc.makeTempMonthEstimates(null,planlist2), planlist2, TrueCostUtilities.pullTheMonthlyUsage(null));
        return PricedRates;
    }
    public static string TDSPIDfromZipCode(string zip2check){ //checks to see if the entered zip code is served by TrueCost or in our expansion plans
        list<validzipcode__c> ziplist = new list<validzipcode__c>();
        ziplist= [select id, name, tdsp_lookup__r.name, tdsp_lookup__r.id, served_by_TrueCost__c from ValidZipCode__c where name =: zip2check];
        system.debug(ziplist);
        if (ziplist.size()==0) return null;
        if (ziplist.size()==1) {
            system.debug('returning ' + ziplist[0].tdsp_lookup__r.id);
            return ziplist[0].tdsp_lookup__r.id;
        }
        //if (ziplist.size()>1)
        return ziplist[0].tdsp_lookup__r.id; // if ziplist.size() is not 0 or 1 then it must be >1
        //return null;
    }
    public list<resultscontainer> SimpleResults(list<Month_Estimate__c> estimates,  list<Rate__c> planlist, list<Monthly_Usage__c> usage){

       list<resultscontainer> scoringresults = new list<resultscontainer> ();
       map<id, string> rewardmap = TrueCostUtilities.GrabRewardsText2(planlist);
       map<id, decimal> MEMAP = TrueCostCalc.MakeMonthEstimateMap(estimates);

        for (rate__c pi:planlist){
            resultscontainer rc=new resultscontainer(pi); //TrueCostUtilities.resultscontainer rc=new TrueCostUtilities.resultscontainer(pi);
            rc.rewardstext=rewardmap.get(pi.id);
            rc.price=MEMAP.get(pi.id);
            rc.pricekWh=rc.price/(TrueCostCalc.totaltheusage(usage) );      //calculate cents per kWh
            scoringresults.add(rc);
        }
        return scoringresults;
    }
}