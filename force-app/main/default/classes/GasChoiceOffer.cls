global class GasChoiceOffer implements Comparable{
    
        public rate__c r{get;set;}
        public decimal costPerTherm {get;set;}
        public decimal marginPerTherm {get;set;}
        public decimal totalMargin {get;set;}
        public integer outerRanking {get;set;}
        public integer innerRanking {get;set;}
        public decimal targetFixedBeforeMargin {get;set;}
        public decimal targetIndexBeforeMargin {get;set;}
        public decimal targetFixedAfterMargin {get;set;}
        public decimal targetIndexAfterMargin {get;set;}
        public decimal estimatedFixedperUnitMargin {get;set;}
        public decimal estimatedVariableperUnitMargin {get;set;}
        public decimal estimatedindexUsage{get;set;}
        public decimal estimatedFixedUsage{get;set;}
        public decimal estimatedTotalUsage{get;set;}
        public decimal discountFactor{get;set;}
        public decimal SBQ {get;set;}
        public decimal IndexAdder {get;set;}
        public decimal FixedPrice {get;set;}
        public string ProgramYear {get;set;}
        public string PriceDetails {get;set;}
        public plan__c p {get;set;}
        public integer ListIndex {get;set;}
        public string IndexReference {get;set;}
    
    global Integer compareTo(Object compareTo) {
        GasChoiceOffer CompareToRC = (GasChoiceOffer)CompareTo;
        if (p.name > CompareToRC.p.name) return 1;
        else if (p.name < CompareToRC.p.name) return -1;
        else if (p.name == CompareToRC.p.name){
        	if (FixedPrice > CompareToRC.FixedPrice) return -1;
            else if (FixedPrice < CompareToRC.FixedPrice) return 1;
            else if (FixedPrice == CompareToRC.FixedPrice){
            	if (IndexAdder > CompareToRC.IndexAdder) return -1;
                else if (IndexAdder < CompareToRC.IndexAdder) return 1;
                else return 0;
            }
        }        
        else return 0;
        return 0;
    }
}