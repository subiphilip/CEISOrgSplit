public with sharing class FixedQuoteToContract {


		public static list<PremiseWithPctg> quoteJSON2Percentages (string jsonStuff){
			return (List<PremiseWithPctg>) Json.deserialize(jsonStuff, list<PremiseWithPctg>.class);   
		}

		public static list<FQPosition> quoteJSON2Positions (string jsonStuff){
			return (List<FQPosition>) Json.deserialize(jsonStuff, list<FQPosition>.class);   
		}

		public class PremiseWithPctg{
			public id premId {get;set;}
			public decimal Percentage {get;set;}

			public PremiseWithPctg(){

			}
		}

}