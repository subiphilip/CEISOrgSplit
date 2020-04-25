global class ResultsContainer implements Comparable{    
    
        public rate__c rateplan {get;set;}
    	public integer rank {get;set;}
        public decimal price {get;set;}
        public decimal pricekWh {get;set;}
        public decimal green_score {get;set;}
        public decimal year_score {get;set;}
        public decimal star_score {get;set;}
        public decimal price_score {get;set;}
        public decimal total_score {get;set;}
        public string rewardsText {get;set;}
        public boolean saved {get;set;}
        public resultscontainer(Rate__c r){
            saved=false;
            rateplan = r;
            price=0;
            green_score=0;
            year_score=0;
            star_score=0;
            price_score=0;
            total_score=0;
            rewardsText='';
            
     }   
    
    
    global Integer compareTo(Object compareTo) {
        resultscontainer CompareToRC = (resultscontainer)CompareTo;
        if (total_score == CompareToRC.total_score) return 0;
        else if (total_score > CompareToRC.total_score) return -1;
        else return 1;
    }
    

}