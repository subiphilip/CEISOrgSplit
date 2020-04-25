/*
This class is used for getting nymex future data into lightning component to display further in table
*/
public class NymexNaturalGasFuturePriceTableCtrl {
    @AuraEnabled
    public static Map<String,String> getIndexMap(){
        //creating date instance equivalent to effective/delivery dates which is generally first day of month
        date dt = date.newInstance(system.today().year(), system.today().month(), 1);
        Map<String,String> indexMap = new Map<String,String>();
        //list of nymex master records from which we can retrieve child future records 
        List<String> lstOfStr = new List<String>{'DTN HO DELAYED','DTN Propane DELAYED','DTN CL DELAYED'};
        List<Index__c> indexs = [
            select id,name,
            (Select Id,Month__c,Year__c,Price__c,Daily_Change__c,Delivery_Date__c 
             from Index_Futures__r 
             WHERE Delivery_Date__c >=:dt ORDER BY Delivery_Date__c DESC limit 1) 
            from Index__c 
            WHERE name IN : lstOfStr
        ];
        
        for(Index__c ind: indexs){
            if(ind.Index_Futures__r.size()>0){     
                if(ind.Name=='DTN HO DELAYED'){
                    indexMap.put('Heating Oil',string.valueOf(ind.Index_Futures__r[0].Price__c));
                }else if(ind.Name=='DTN Propane DELAYED'){
                    indexMap.put('Propane',string.valueOf(ind.Index_Futures__r[0].Price__c));
                }else{
                    indexMap.put('Crude Oil',string.valueOf(ind.Index_Futures__r[0].Price__c));
                }
            }
        }
        system.debug('indexMap'+indexMap);
        return indexMap;
    }
    
    public static date getFirstFutureMonthDate() {
        date dT = system.today();
        
        return getFirstFutureMonthDate(dT);
    }
    
    
    public static date getFirstFutureMonthDate(date dRef) {
        
        date startDate;
        date enddate;
        
        Integer numberOfDays = Date.daysInMonth(dRef.year(), dRef.month());
        Date templastDateOfMonth = Date.newInstance(dRef.year(), dRef.month(), numberOfDays);
       
        
        enddate = templastDateOfMonth;
        startDate = templastDateOfMonth.addDays(-2);
        
        DateTime lastDateOfMonth = DateTime.newInstance(templastDateOfMonth, Time.newInstance(0, 0, 0, 0));
        System.debug('lastDateOfMonth:  ' + lastDateOfMonth);
        DateTime last2DateOfMonth = DateTime.newInstance(startDate, Time.newInstance(0, 0, 0, 0));
        System.debug('last2DateOfMonth:  ' + last2DateOfMonth);
        
        String dayOfWeek = lastDateOfMonth.format('E');
        System.debug('dayOfWeek:  ' + dayOfWeek);
        String dayOfWeek1 = last2DateOfMonth.format('E');
        System.debug('dayOfWeek1:  ' + dayOfWeek1);
        if(dayOfWeek == 'Sun' || dayOfWeek1 == 'Sun'|| dayOfWeek1 == 'Sat'){
            startDate = startDate.addDays(-2);
        } else if(dayOfWeek == 'Sat') {
            startDate = startDate.addDays(-1);
        }
        
        System.debug('*** dRef:  ' + dRef);
        System.debug('startDate:  ' + startDate);
        System.debug('enddate:  ' + enddate);
        
        Date firstFutureMonthDate;
        if(dRef >= startDate && dRef <= enddate){
            firstFutureMonthDate = dRef.addMonths(2);
        } else {
            firstFutureMonthDate = dRef.addMonths(1);
        }        

        // set reference date to first date of the month
        firstFutureMonthDate = firstFutureMonthDate.toStartOfMonth();
        
        return firstFutureMonthDate;
    }
    
    @AuraEnabled
    public static UsageWrapper getIndexRec(){
		date firstFutureMonthDate;
        
        firstFutureMonthDate = getFirstFutureMonthDate();
        
        // firstFutureMonthDate = firstFutureMonthDate.toStartOfMonth();
        Date lastFutureMonthDate = firstFutureMonthDate.addMonths(60);
        
        /*      
            Date lastMonth = firstFutureMonthDate.addMonths(60);
            Integer numberOfDays = Date.daysInMonth(lastMonth.year(), lastMonth.month());
            Date templastDayOfMonth = Date.newInstance(lastMonth.year(), lastMonth.month(), numberOfDays);
            
            DateTime myDateTime = (DateTime) templastDayOfMonth;
            String dayOfWeek = myDateTime.format('E');
            if(dayOfWeek == 'Sun'){
                lastFutureMonthDate = templastDayOfMonth.addDays(-2);
            } else if(dayOfWeek == 'Sat') {
                lastFutureMonthDate = templastDayOfMonth.addDays(-1);
            }
        */      
        
        String Index='DTN GNG DELAYED'; 
        //variables used for storing calculated data
        decimal promptValue;
        decimal MntsAvg3=0;
        decimal MntsAvg6;
        decimal MntsAvg9;
        decimal MntsAvg12;
        decimal MntsAvg18;
        decimal MntsAvg24;
        decimal MntsAvg36;
        decimal MntsAvg48;
        decimal MntsAvg60;
        decimal WtrValue1=0;
        decimal WtrValue2=0;
        decimal WtrValue3=0;
        decimal SmrValue1=0;
        decimal SmrValue2=0;
        decimal SmrValue3=0;
        
        integer i;
        
        decimal HeatOil=0;
        decimal CrudeOil=0;
        decimal Propane=0;
        
        String wtrLabel1;
        String wtrLabel2;
        String wtrLabel3;
        String smrLabel1;
        String smrLabel2;
        String smrLabel3;
        String CalLabel1;
        String CalLabel2;
        String CalLabel3;
        String CalLabel4;
        String CalLabel5;
        
        decimal CalTotalValue1=0;
        decimal CalTotalValue2=0;
        decimal CalTotalValue3=0;
        decimal CalTotalValue4=0;
        decimal CalTotalValue5=0;
        
        decimal CalAvg1=0;
        decimal CalAvg2=0;
        decimal CalAvg3=0;
        decimal CalAvg4=0;
        decimal CalAvg5=0;
        
        UsageWrapper uwrp = new UsageWrapper(); 
        //first list used to display records in first section of table(left)
        List<Index_Future__c> listOfFirstThirtyFutures = new List<Index_Future__c>();
        //second list used to display records in second section of table(right)
        List<Index_Future__c> listOfSecondThirtyFutures = new List<Index_Future__c>();
        Map<String,Decimal> promptData = new Map<String, Decimal>();
        
        List<Index_Future__c> futurePrices = [Select Id, Name, Month__c, Year__c, Price__c, Daily_Change__c, Delivery_Date__c 
                                              from Index_Future__c 
                                              WHERE Delivery_Date__c <= :lastFutureMonthDate  
                                              AND Delivery_Date__c >= :firstFutureMonthDate 
                                              AND Index__r.name = :Index 
                                              //AND CreatedDate >= LAST_N_DAYS:15
                                              // the above line is included because of bad data in QA and DEV
                                              ORDER BY Delivery_Date__c
                                              ];
        
//System.debug('NymexNaturalGasFuturePriceTableCtrl: firstFutureMonthDate ' + firstFutureMonthDate);        
//System.debug('NymexNaturalGasFuturePriceTableCtrl: lastFutureMonthDate ' + lastFutureMonthDate);        
//System.debug('NymexNaturalGasFuturePriceTableCtrl: futurePrices ' + futurePrices);                
//System.debug('NymexNaturalGasFuturePriceTableCtrl: futurePrices Size ' + futurePrices.Size());    
        
        if(futurePrices.size()>0){

            if(futurePrices[0].Price__c!=null){
                promptValue = (futurePrices[0].Price__c).setScale(3);  //scaling to 3 chars after decimal 
            }
            
            for(i=0;i<futurePrices.size() && i<3;i++){
                if(futurePrices[i].Price__c!=null)
                    MntsAvg3 = MntsAvg3 +futurePrices[i].Price__c;
            }
            MntsAvg6 = MntsAvg3;
            MntsAvg3 = (MntsAvg3/3).setScale(3);

            if(futurePrices.size()>4){
                for(i=3;i<futurePrices.size() && i<6;i++){
                    if(futurePrices[i].Price__c!=null)
                        MntsAvg6 = MntsAvg6 +futurePrices[i].Price__c;
                }              
                MntsAvg9 = MntsAvg6;
                MntsAvg6 = (MntsAvg6/6).setScale(3);
            } else { MntsAvg6 = 0; }
            if(futurePrices.size()>7){
                for(i=6;i<futurePrices.size() && i<9;i++){                   
                    if(futurePrices[i].Price__c!=null)
                        MntsAvg9 = MntsAvg9 +futurePrices[i].Price__c;
                }
                MntsAvg12 = MntsAvg9;
                MntsAvg9 = (MntsAvg9/9).setScale(3);
            } else { MntsAvg9 = 0; }
            if(futurePrices.size()>10){
                for(i=9;i<futurePrices.size() && i<12;i++){
                    if(futurePrices[i].Price__c!=null)
                        MntsAvg12 = MntsAvg12 +futurePrices[i].Price__c;
                }
                MntsAvg18 = MntsAvg12;
                MntsAvg12 = (MntsAvg12/12).setScale(3);
            } else { MntsAvg12 = 0; }
            if(futurePrices.size()>16){
                for(i=12;i<futurePrices.size() && i<18;i++){
                    if(futurePrices[i].Price__c!=null)
                        MntsAvg18 = MntsAvg18 +futurePrices[i].Price__c;
                }
                MntsAvg24 = MntsAvg18;
                MntsAvg18 = (MntsAvg18/18).setScale(3);
            } else { MntsAvg18 = 0; }
            if(futurePrices.size()>22){
                for(i=18;i<futurePrices.size() && i<24;i++){
                    if(futurePrices[i].Price__c!=null)
                        MntsAvg24 = MntsAvg24 +futurePrices[i].Price__c;
                }
                MntsAvg36 = MntsAvg24;
                MntsAvg24 = (MntsAvg24/24).setScale(3);
            } else { MntsAvg24 = 0; }
            if(futurePrices.size()>34){                
                for(i=24;i<futurePrices.size() && i<36;i++){
                    if(futurePrices[i].Price__c!=null)
                        MntsAvg36 = MntsAvg36 +futurePrices[i].Price__c;
                }
                MntsAvg48 = MntsAvg36;
                MntsAvg36 = (MntsAvg36/36).setScale(3);
            } else { MntsAvg36 = 0; }
            if(futurePrices.size()>46){
                for(i=36;i<futurePrices.size() && i<48;i++){
                    if(futurePrices[i].Price__c!=null)
                        MntsAvg48 = MntsAvg48 +futurePrices[i].Price__c;
                }
                MntsAvg60 = MntsAvg48;
                MntsAvg48 = (MntsAvg48/48).setScale(3);
            } else { MntsAvg48 = 0; }
            if(futurePrices.size()>58){
                for(i=48;i<futurePrices.size() && i<60;i++){
                    if(futurePrices[i].Price__c!=null)
                        MntsAvg60 = MntsAvg60 +futurePrices[i].Price__c;
                }
                MntsAvg60 = (MntsAvg60/60).setScale(3);
            } else { MntsAvg60 = 0; }
            CalLabel1 = '';
            CalLabel2 = '';
            CalLabel3 = '';
            CalLabel4 = '';
            CalLabel5 = '';
            if(futurePrices.size() >= 0){
                CalLabel1 = 'Cal'+String.valueOf(futurePrices[0].Year__c).right(2);
                
            }
            if(futurePrices.size() >= 12){
                CalLabel2 = 'Cal'+String.valueOf(futurePrices[12].Year__c).right(2);
                
            }
            if(futurePrices.size() >= 24){
                CalLabel3 = 'Cal'+String.valueOf(futurePrices[24].Year__c).right(2);
            }
            if(futurePrices.size() >= 36){
                CalLabel4 = 'Cal'+String.valueOf(futurePrices[36].Year__c).right(2);
            }
            if(futurePrices.size() >= 48){
                CalLabel5 = 'Cal'+String.valueOf(futurePrices[48].Year__c).right(2);
            }       
            
            //system.debug('CalAvg2'+CalLabel4);
            
            
            //if current month is Dec
            if(futurePrices[0].Month__c == 'Jan'){
                if(futurePrices.size()>2){
                    for(i=0;i<futurePrices.size() && i<3;i++){
                        if(futurePrices[i].Price__c!=null)
                            WtrValue1 = WtrValue1 +futurePrices[i].Price__c;
                    }
                    WtrValue1 = (WtrValue1/3).setScale(3);
                }
                if(futurePrices.size()>9){
                    for(i=3;i<futurePrices.size() && i<10;i++){
                        if(futurePrices[i].Price__c!=null)
                            SmrValue1 = SmrValue1 +futurePrices[i].Price__c;
                    }
                    SmrValue1 = (SmrValue1/7).setScale(3);
                }
                if(futurePrices.size()>14){
                    for(i=10;i<futurePrices.size() && i<15;i++){
                        if(futurePrices[i].Price__c!=null)
                            WtrValue2 = WtrValue2 +futurePrices[i].Price__c;
                    }
                    WtrValue2 = (WtrValue2/5).setScale(3);
                }
                if(futurePrices.size()>21){
                    for(i=15;i<futurePrices.size() && i<22;i++){
                        if(futurePrices[i].Price__c!=null)
                            SmrValue2 = SmrValue2 +futurePrices[i].Price__c;
                    }
                    SmrValue2 = (SmrValue2/7).setScale(3);
                }
                if(futurePrices.size()>26){
                    for(i=22;i<futurePrices.size() && i<27;i++){
                        if(futurePrices[i].Price__c!=null)
                            WtrValue3 = WtrValue3 +futurePrices[i].Price__c;
                    }
                    WtrValue3 = (WtrValue3/5).setScale(3);
                }
                if(futurePrices.size()>33){
                    for(i=27;i<futurePrices.size() && i<34;i++){
                        if(futurePrices[i].Price__c!=null)
                            SmrValue3 = SmrValue3 +futurePrices[i].Price__c;
                    }
                    SmrValue3 = (SmrValue3/7).setScale(3);
                }
            }
            //if current month is Jan
            else if(futurePrices[0].Month__c == 'Feb'){
                if(futurePrices.size()>1){
                    for(i=0;i<futurePrices.size() && i<2;i++){
                        if(futurePrices[i].Price__c!=null)
                            WtrValue1 = WtrValue1 +futurePrices[i].Price__c;
                    }
                    WtrValue1 = (WtrValue1/2).setScale(3);
                }
                if(futurePrices.size()>8){
                    for(i=2;i<futurePrices.size() && i<9;i++){
                        if(futurePrices[i].Price__c!=null)
                            SmrValue1 = SmrValue1 +futurePrices[i].Price__c;
                    }
                    SmrValue1 = (SmrValue1/7).setScale(3);
                }
                if(futurePrices.size()>13){
                    for(i=9;i<futurePrices.size() && i<14;i++){
                        if(futurePrices[i].Price__c!=null)
                            WtrValue2 = WtrValue2 +futurePrices[i].Price__c;
                    }
                    WtrValue2 = (WtrValue2/5).setScale(3);
                }
                if(futurePrices.size()>20){
                    for(i=14;i<futurePrices.size() && i<21;i++){
                        if(futurePrices[i].Price__c!=null)
                            SmrValue2 = SmrValue2 +futurePrices[i].Price__c;
                    }
                    SmrValue2 = (SmrValue2/7).setScale(3);
                }
                if(futurePrices.size()>25){
                    for(i=21;i<futurePrices.size() && i<26;i++){
                        if(futurePrices[i].Price__c!=null)
                            WtrValue3 = WtrValue3 +futurePrices[i].Price__c;
                    }
                    WtrValue3 = (WtrValue3/5).setScale(3);
                }
                if(futurePrices.size()>32){
                    for(i=26;i<futurePrices.size() && i<33;i++){
                        if(futurePrices[i].Price__c!=null)
                            SmrValue3 = SmrValue3 +futurePrices[i].Price__c;
                    }
                    SmrValue3 = (SmrValue3/7).setScale(3);
                }
            }
            //if current month is Feb
            else if(futurePrices[0].Month__c == 'Mar'){
                WtrValue1 = futurePrices[0].Price__c.setScale(3);
                
                if(futurePrices.size()>7){
                    for(i=1;i<futurePrices.size() && i<8;i++){
                        if(futurePrices[i].Price__c!=null)
                            SmrValue1 = SmrValue1 +futurePrices[i].Price__c;
                    }
                    SmrValue1 = (SmrValue1/7).setScale(3);
                }
                if(futurePrices.size()>12){
                    for(i=8;i<futurePrices.size() && i<13;i++){
                        if(futurePrices[i].Price__c!=null)
                            WtrValue2 = WtrValue2 +futurePrices[i].Price__c;
                    }
                    WtrValue2 = (WtrValue2/5).setScale(3);
                }
                if(futurePrices.size()>19){
                    for(i=13;i<futurePrices.size() && i<20;i++){
                        if(futurePrices[i].Price__c!=null)
                            SmrValue2 = SmrValue2 +futurePrices[i].Price__c;
                    }
                    SmrValue2 = (SmrValue2/7).setScale(3);
                }
                if(futurePrices.size()>24){
                    for(i=20;i<futurePrices.size() && i<25;i++){
                        if(futurePrices[i].Price__c!=null)
                            WtrValue3 = WtrValue3 +futurePrices[i].Price__c;
                    }
                    WtrValue3 = (WtrValue3/5).setScale(3);
                }
                if(futurePrices.size()>31){
                    for(i=25;i<futurePrices.size() && i<32;i++){
                        if(futurePrices[i].Price__c!=null)
                            SmrValue3 = SmrValue3 +futurePrices[i].Price__c;
                    }
                    SmrValue3 = (SmrValue3/7).setScale(3);
                }
            }
            //if current month is Mar
            else if(futurePrices[0].Month__c == 'Apr'){
                if(futurePrices.size()>6){
                    for(i=0;i<futurePrices.size() && i<7;i++){
                        if(futurePrices[i].Price__c!=null)
                            SmrValue1 = SmrValue1 +futurePrices[i].Price__c;
                    }
                    SmrValue1 = (SmrValue1/7).setScale(3);
                }
                if(futurePrices.size()>11){
                    for(i=7;i<futurePrices.size() && i<12;i++){
                        if(futurePrices[i].Price__c!=null)
                            WtrValue1 = WtrValue1 +futurePrices[i].Price__c;
                    }
                    WtrValue1 = (WtrValue1/5).setScale(3);
                }
                if(futurePrices.size()>18){
                    for(i=12;i<futurePrices.size() && i<19;i++){
                        if(futurePrices[i].Price__c!=null)
                            SmrValue2 = SmrValue2 +futurePrices[i].Price__c;
                    }
                    SmrValue2 = (SmrValue2/7).setScale(3);
                }
                if(futurePrices.size()>23){
                    for(i=19;i<futurePrices.size() && i<24;i++){
                        if(futurePrices[i].Price__c!=null)
                            WtrValue2 = WtrValue2 +futurePrices[i].Price__c;
                    }
                    WtrValue2 = (WtrValue2/5).setScale(3);
                }if(futurePrices.size()>30){
                    for(i=24;i<futurePrices.size() && i<31;i++){
                        if(futurePrices[i].Price__c!=null)
                            SmrValue3 = SmrValue3 +futurePrices[i].Price__c;
                    }
                    SmrValue3 = (SmrValue3/7).setScale(3);
                }
                if(futurePrices.size()>35){
                    for(i=31;i<futurePrices.size() && i<36;i++){
                        if(futurePrices[i].Price__c!=null)
                            WtrValue3 = WtrValue3 +futurePrices[i].Price__c;
                    }
                    WtrValue3 = (WtrValue3/5).setScale(3);
                }
                
            }
            //if current month is Apr
            else if(futurePrices[0].Month__c == 'May'){
                if(futurePrices.size()>5){
                    for(i=0;i<futurePrices.size() && i<6;i++){
                        if(futurePrices[i].Price__c!=null)
                            SmrValue1 = SmrValue1 +futurePrices[i].Price__c;
                    }
                    SmrValue1 = (SmrValue1/6).setScale(3);
                }
                if(futurePrices.size()>10){
                    for(i=6;i<futurePrices.size() && i<11;i++){
                        if(futurePrices[i].Price__c!=null)
                            WtrValue1 = WtrValue1 +futurePrices[i].Price__c;
                    }
                    WtrValue1 = (WtrValue1/5).setScale(3);
                }
                if(futurePrices.size()>17){
                    for(i=11;i<futurePrices.size() && i<18;i++){
                        if(futurePrices[i].Price__c!=null)
                            SmrValue2 = SmrValue2 +futurePrices[i].Price__c;
                    }
                    SmrValue2 = (SmrValue2/7).setScale(3);
                }
                if(futurePrices.size()>22){
                    for(i=18;i<futurePrices.size() && i<23;i++){
                        if(futurePrices[i].Price__c!=null)
                            WtrValue2 = WtrValue2 +futurePrices[i].Price__c;
                    }
                    WtrValue2 = (WtrValue2/5).setScale(3);
                }if(futurePrices.size()>29){
                    for(i=23;i<futurePrices.size() && i<30;i++){
                        if(futurePrices[i].Price__c!=null)
                            SmrValue3 = SmrValue3 +futurePrices[i].Price__c;
                    }
                    SmrValue3 = (SmrValue3/7).setScale(3);
                }
                if(futurePrices.size()>34){
                    for(i=30;i<futurePrices.size() && i<35;i++){
                        if(futurePrices[i].Price__c!=null)
                            WtrValue3 = WtrValue3 +futurePrices[i].Price__c;
                    }
                    WtrValue3 = (WtrValue3/5).setScale(3);
                }
                
            }
            //if current month is May
            else if(futurePrices[0].Month__c == 'Jun'){
                if(futurePrices.size()>4){
                    for(i=0;i<futurePrices.size() && i<5;i++){
                        if(futurePrices[i].Price__c!=null)
                            SmrValue1 = SmrValue1 +futurePrices[i].Price__c;
                    }
                    SmrValue1 = (SmrValue1/5).setScale(3);
                }
                if(futurePrices.size()>9){
                    for(i=5;i<futurePrices.size() && i<10;i++){
                        if(futurePrices[i].Price__c!=null)
                            WtrValue1 = WtrValue1 +futurePrices[i].Price__c;
                    }
                    WtrValue1 = (WtrValue1/5).setScale(3);
                }
                if(futurePrices.size()>16){
                    for(i=10;i<futurePrices.size() && i<17;i++){
                        if(futurePrices[i].Price__c!=null)
                            SmrValue2 = SmrValue2 +futurePrices[i].Price__c;
                    }
                    SmrValue2 = (SmrValue2/7).setScale(3);
                }
                if(futurePrices.size()>21){
                    for(i=17;i<futurePrices.size() && i<22;i++){
                        if(futurePrices[i].Price__c!=null)
                            WtrValue2 = WtrValue2 +futurePrices[i].Price__c;
                    }
                    WtrValue2 = (WtrValue2/5).setScale(3);
                }if(futurePrices.size()>28){
                    for(i=22;i<futurePrices.size() && i<29;i++){
                        if(futurePrices[i].Price__c!=null)
                            SmrValue3 = SmrValue3 +futurePrices[i].Price__c;
                    }
                    SmrValue3 = (SmrValue3/7).setScale(3);
                }
                if(futurePrices.size()>33){
                    for(i=29;i<futurePrices.size() && i<34;i++){
                        if(futurePrices[i].Price__c!=null)
                            WtrValue3 = WtrValue3 +futurePrices[i].Price__c;
                    }
                    WtrValue3 = (WtrValue3/5).setScale(3);
                }
            }
            //if current month is Jun
            else if(futurePrices[0].Month__c == 'Jul'){
                if(futurePrices.size()>3){
                    for(i=0;i<futurePrices.size() && i<4;i++){
                        if(futurePrices[i].Price__c!=null)
                            SmrValue1 = SmrValue1 +futurePrices[i].Price__c;
                    }
                    SmrValue1 = (SmrValue1/4).setScale(3);
                }
                if(futurePrices.size()>8){
                    for(i=4;i<futurePrices.size() && i<9;i++){
                        if(futurePrices[i].Price__c!=null)
                            WtrValue1 = WtrValue1 +futurePrices[i].Price__c;
                    }
                    WtrValue1 = (WtrValue1/5).setScale(3);
                }
                if(futurePrices.size()>15){
                    for(i=9;i<futurePrices.size() && i<16;i++){
                        if(futurePrices[i].Price__c!=null)
                            SmrValue2 = SmrValue2 +futurePrices[i].Price__c;
                    }
                    SmrValue2 = (SmrValue2/7).setScale(3);
                }
                if(futurePrices.size()>20){
                    for(i=16;i<futurePrices.size() && i<21;i++){
                        if(futurePrices[i].Price__c!=null)
                            WtrValue2 = WtrValue2 +futurePrices[i].Price__c;
                    }
                    WtrValue2 = (WtrValue2/5).setScale(3);
                }
                if(futurePrices.size()>27){
                    for(i=21;i<futurePrices.size() && i<28;i++){
                        if(futurePrices[i].Price__c!=null)
                            SmrValue3 = SmrValue3 +futurePrices[i].Price__c;
                    }
                    SmrValue3 = (SmrValue3/7).setScale(3);
                }
                if(futurePrices.size()>32){
                    for(i=28;i<futurePrices.size() && i<33;i++){
                        if(futurePrices[i].Price__c!=null)
                            WtrValue3 = WtrValue3 +futurePrices[i].Price__c;
                    }
                    WtrValue3 = (WtrValue3/5).setScale(3);
                }
            }
            //if current month is Jul
            else if(futurePrices[0].Month__c == 'Aug'){
                if(futurePrices.size()>2){
                    for(i=0;i<futurePrices.size() && i<3;i++){
                        if(futurePrices[i].Price__c!=null)
                            SmrValue1 = SmrValue1 +futurePrices[i].Price__c;
                    }
                    SmrValue1 = (SmrValue1/3).setScale(3);
                }
                if(futurePrices.size()>7){
                    for(i=3;i<futurePrices.size() && i<8;i++){
                        if(futurePrices[i].Price__c!=null)
                            WtrValue1 = WtrValue1 +futurePrices[i].Price__c;
                    }
                    WtrValue1 = (WtrValue1/5).setScale(3);
                }
                if(futurePrices.size()>14){
                    for(i=8;i<futurePrices.size() && i<15;i++){
                        if(futurePrices[i].Price__c!=null)
                            SmrValue2 = SmrValue2 +futurePrices[i].Price__c;
                    }
                    SmrValue2 = (SmrValue2/7).setScale(3);
                }
                if(futurePrices.size()>19){
                    for(i=15;i<futurePrices.size() && i<20;i++){
                        if(futurePrices[i].Price__c!=null)
                            WtrValue2 = WtrValue2 +futurePrices[i].Price__c;
                    }
                    WtrValue2 = (WtrValue2/5).setScale(3);
                }
                if(futurePrices.size()>26){
                    for(i=20;i<futurePrices.size() && i<27;i++){
                        if(futurePrices[i].Price__c!=null)
                            SmrValue3 = SmrValue3 +futurePrices[i].Price__c;
                    }
                    SmrValue3 = (SmrValue3/7).setScale(3);
                }
                if(futurePrices.size()>32){
                    for(i=27;i<futurePrices.size() && i<33;i++){
                        if(futurePrices[i].Price__c!=null)
                            WtrValue3 = WtrValue3 +futurePrices[i].Price__c;
                    }
                    WtrValue3 = (WtrValue3/5).setScale(3);
                }
                
            }
            //if current month is Aug
            else if(futurePrices[0].Month__c == 'Sep'){
                if(futurePrices.size()>1){
                    for(i=0;i<futurePrices.size() && i<2;i++){
                        if(futurePrices[i].Price__c!=null)
                            SmrValue1 = SmrValue1 +futurePrices[i].Price__c;
                    }
                    SmrValue1 = (SmrValue1/2).setScale(3);
                }
                if(futurePrices.size()>6){
                    for(i=2;i<futurePrices.size() && i<7;i++){
                        if(futurePrices[i].Price__c!=null)
                            WtrValue1 = WtrValue1 +futurePrices[i].Price__c;
                    }
                    WtrValue1 = (WtrValue1/5).setScale(3);
                }
                if(futurePrices.size()>13){
                    for(i=7;i<futurePrices.size() && i<14;i++){
                        if(futurePrices[i].Price__c!=null)
                            SmrValue2 = SmrValue2 +futurePrices[i].Price__c;
                    }
                    SmrValue2 = (SmrValue2/7).setScale(3);
                }
                if(futurePrices.size()>20){
                    for(i=14;i<futurePrices.size() && i<21;i++){
                        if(futurePrices[i].Price__c!=null)
                            WtrValue2 = WtrValue2 +futurePrices[i].Price__c;
                    }
                    WtrValue2 = (WtrValue2/7).setScale(3);
                }
                if(futurePrices.size()>25){
                    for(i=21;i<futurePrices.size() && i<26;i++){
                        if(futurePrices[i].Price__c!=null)
                            SmrValue3 = SmrValue3 +futurePrices[i].Price__c;
                    }
                    SmrValue3 = (SmrValue3/5).setScale(3);
                }
                if(futurePrices.size()>32){
                    for(i=26;i<futurePrices.size() && i<33;i++){
                        if(futurePrices[i].Price__c!=null)
                            WtrValue3 = WtrValue3 +futurePrices[i].Price__c;
                    }
                    WtrValue3 = (WtrValue3/7).setScale(3);
                }
                
            }
            //if current month is Sep
            else if(futurePrices[0].Month__c == 'Oct'){
                SmrValue1 = (futurePrices[0].Price__c).setScale(3);
                if(futurePrices.size()>5){
                    for(i=1;i<futurePrices.size() && i<6;i++){
                        if(futurePrices[i].Price__c!=null)
                            WtrValue1 = WtrValue1 +futurePrices[i].Price__c;
                    }
                    WtrValue1 = (WtrValue1/5).setScale(3);
                }
                if(futurePrices.size()>12){
                    for(i=6;i<futurePrices.size() && i<13;i++){
                        if(futurePrices[i].Price__c!=null)
                            SmrValue2 = SmrValue2 +futurePrices[i].Price__c;
                    }
                    SmrValue2 = (SmrValue1/7).setScale(3);
                }
                if(futurePrices.size()>17){
                    for(i=13;i<futurePrices.size() && i<18;i++){
                        if(futurePrices[i].Price__c!=null)
                            WtrValue2 = WtrValue2 +futurePrices[i].Price__c;
                    }
                    WtrValue2 = (WtrValue2/5).setScale(3);
                }
                if(futurePrices.size()>24){
                    for(i=18;i<futurePrices.size() && i<25;i++){
                        if(futurePrices[i].Price__c!=null)
                            SmrValue3 = SmrValue3 +futurePrices[i].Price__c;
                    }
                    SmrValue3 = (SmrValue3/7).setScale(3);
                }
                if(futurePrices.size()>29){
                    for(i=25;i<futurePrices.size() && i<30;i++){
                        if(futurePrices[i].Price__c!=null)
                            WtrValue3 = WtrValue3 +futurePrices[i].Price__c;
                    }
                    WtrValue3 = (WtrValue3/5).setScale(3);
                }
                
            }
            //if current month is oct
            else if(futurePrices[0].Month__c == 'Nov'){
                if(futurePrices.size()>4){
                    for(i=0;i<futurePrices.size() && i<5;i++){
                        if(futurePrices[i].Price__c!=null)
                            WtrValue1 = WtrValue1 +futurePrices[i].Price__c;
                    }
                    WtrValue1 = (WtrValue1/5).setScale(3);
                }
                if(futurePrices.size()>11){
                    for(i=5;i<futurePrices.size() && i<12;i++){
                        if(futurePrices[i].Price__c!=null)
                            SmrValue1 = SmrValue1 +futurePrices[i].Price__c;
                    }
                    SmrValue1 = (SmrValue1/7).setScale(3);
                }
                if(futurePrices.size()>16){
                    for(i=12;i<futurePrices.size() && i<17;i++){
                        if(futurePrices[i].Price__c!=null)
                            WtrValue2 = WtrValue2 +futurePrices[i].Price__c;
                    }
                    WtrValue2 = (WtrValue2/5).setScale(3);
                }
                if(futurePrices.size()>23){
                    for(i=17;i<futurePrices.size() && i<24;i++){
                        if(futurePrices[i].Price__c!=null)
                            SmrValue2 = SmrValue2 +futurePrices[i].Price__c;
                    }
                    SmrValue2 = (SmrValue2/7).setScale(3);
                }
                if(futurePrices.size()>28){
                    for(i=24;i<futurePrices.size() && i<29;i++){
                        if(futurePrices[i].Price__c!=null)
                            WtrValue3 = WtrValue3 +futurePrices[i].Price__c;
                    }
                    WtrValue3 = (WtrValue3/5).setScale(3);
                }
                if(futurePrices.size()>35){
                    for(i=29;i<futurePrices.size() && i<36;i++){
                        if(futurePrices[i].Price__c!=null)
                            SmrValue3 = SmrValue3 +futurePrices[i].Price__c;
                    }
                    SmrValue3 = (SmrValue3/7).setScale(3);
                }
            }
            //if current month is Nov
            else if(futurePrices[0].Month__c == 'Dec'){
                if(futurePrices.size()>3){
                    for(i=0;i<futurePrices.size() && i<4;i++){
                        if(futurePrices[i].Price__c!=null)
                            WtrValue1 = WtrValue1 +futurePrices[i].Price__c;
                    }
                    WtrValue1 = (WtrValue1/4).setScale(3);
                }
                if(futurePrices.size()>10){
                    for(i=4;i<futurePrices.size() && i<11;i++){
                        if(futurePrices[i].Price__c!=null)
                            SmrValue1 = SmrValue1 +futurePrices[i].Price__c;
                    }
                    SmrValue1 = (SmrValue1/7).setScale(3);
                }
                if(futurePrices.size()>15){
                    for(i=11;i<futurePrices.size() && i<16;i++){
                        if(futurePrices[i].Price__c!=null)
                            WtrValue2 = WtrValue2 +futurePrices[i].Price__c;
                    }
                    WtrValue2 = (WtrValue2/5).setScale(3);
                }
                if(futurePrices.size()>22){
                    for(i=16;i<futurePrices.size() && i<23;i++){
                        if(futurePrices[i].Price__c!=null)
                            SmrValue2 = SmrValue2 +futurePrices[i].Price__c;
                    }
                    SmrValue2 = (SmrValue2/7).setScale(3);
                }
                if(futurePrices.size()>27){
                    for(i=23;i<futurePrices.size() && i<28;i++){
                        if(futurePrices[i].Price__c!=null)
                            WtrValue3 = WtrValue3 +futurePrices[i].Price__c;
                    }
                    WtrValue3 = (WtrValue3/5).setScale(3);
                }
                if(futurePrices.size()>34){
                    for(i=28;i<futurePrices.size() && i<35;i++){
                        if(futurePrices[i].Price__c!=null)
                            SmrValue3 = SmrValue3 +futurePrices[i].Price__c;
                    }
                    SmrValue3 = (SmrValue3/7).setScale(3);
                }
            }
            else{              
            }
            if(futurePrices[0].Month__c == 'Jan' || futurePrices[0].Month__c == 'Feb' || futurePrices[0].Month__c == 'Mar'){
                wtrLabel1 = 'Winter '+String.valueOf((integer.valueOf(futurePrices[0].Year__c)-1)).right(2)
                    +'-'+(futurePrices[0].Year__c).right(2);
                wtrLabel2 = 'Winter '+(futurePrices[0].Year__c).right(2)+'-'+
                    +String.valueOf((integer.valueOf(futurePrices[0].Year__c)+1)).right(2);
                wtrLabel3 = 'Winter '+String.valueOf((integer.valueOf(futurePrices[0].Year__c)+1)).right(2)+'-'+
                    String.valueOf((integer.valueOf(futurePrices[0].Year__c)+2)).right(2);
                smrLabel1 = 'Summer '+(futurePrices[0].Year__c);
                smrLabel2 = 'Summer '+String.valueOf((integer.valueOf(futurePrices[0].Year__c)+1));
                smrLabel3 = 'Summer '+String.valueOf((integer.valueOf(futurePrices[0].Year__c)+2));
            }else if(futurePrices[0].Month__c == 'Nov' || futurePrices[0].Month__c == 'Dec'){
                wtrLabel1 = 'Winter '+(futurePrices[0].Year__c).right(2)+'-'+
                    String.valueOf((integer.valueOf(futurePrices[0].Year__c)+1)).right(2);
                wtrLabel2 = 'Winter '+String.valueOf((integer.valueOf(futurePrices[0].Year__c)+1)).right(2)+'-'+
                    String.valueOf((integer.valueOf(futurePrices[0].Year__c)+2)).right(2);
                wtrLabel3 = 'Winter '+String.valueOf((integer.valueOf(futurePrices[0].Year__c)+2)).right(2)+'-'+
                    String.valueOf((integer.valueOf(futurePrices[0].Year__c)+3)).right(2);
                smrLabel1 = 'Summer '+String.valueOf((integer.valueOf(futurePrices[0].Year__c)+1));
                smrLabel2 = 'Summer '+String.valueOf((integer.valueOf(futurePrices[0].Year__c)+2));
                smrLabel3 = 'Summer '+String.valueOf((integer.valueOf(futurePrices[0].Year__c)+3));
            }else{
                wtrLabel1 = 'Winter '+(futurePrices[0].Year__c).right(2)+'-'+
                    String.valueOf((integer.valueOf(futurePrices[0].Year__c)+1)).right(2);
                wtrLabel2 = 'Winter '+String.valueOf((integer.valueOf(futurePrices[0].Year__c)+1)).right(2)+'-'+
                    String.valueOf((integer.valueOf(futurePrices[0].Year__c)+2)).right(2);
                wtrLabel3 = 'Winter '+String.valueOf((integer.valueOf(futurePrices[0].Year__c)+2)).right(2)+'-'+
                    String.valueOf((integer.valueOf(futurePrices[0].Year__c)+3)).right(2);
                smrLabel1 = 'Summer '+(futurePrices[0].Year__c);
                smrLabel2 = 'Summer '+String.valueOf((integer.valueOf(futurePrices[0].Year__c)+1));
                smrLabel3 = 'Summer '+String.valueOf((integer.valueOf(futurePrices[0].Year__c)+2));
            }
            
            integer x = 0;
            integer y = 0;
            if(futurePrices.size()>0){
                for(Index_Future__c ifc : futurePrices){
                    if(ifc.Price__c!=null){
                        if(ifc.Year__c == futurePrices[0].Year__c){
                            CalTotalValue1 = CalTotalValue1+ifc.Price__c;
                            x++;
                        }else if(futurePrices[12]!=null && ifc.Year__c == futurePrices[12].Year__c){
                            CalTotalValue2 = CalTotalValue2+ifc.Price__c;
                        }else if(futurePrices[24]!=null && ifc.Year__c == futurePrices[24].Year__c){
                            CalTotalValue3 = CalTotalValue3+ifc.Price__c;
                        }else if(futurePrices[36]!=null && ifc.Year__c == futurePrices[36].Year__c){
                            CalTotalValue4 = CalTotalValue4+ifc.Price__c;
                        }else if(futurePrices[48]!=null && ifc.Year__c == futurePrices[48].Year__c){
                            CalTotalValue5 = CalTotalValue5+ifc.Price__c;
                            y++;
                        }
                    }
                }
            }
            if(x!=0){
                CalAvg1 = (CalTotalValue1/x).setScale(3);
              
            }
            
            CalAvg2 = (CalTotalValue2/12).setScale(3);
            CalAvg3 = (CalTotalValue3/12).setScale(3);
            CalAvg4 = (CalTotalValue4/12).setScale(3);
            if(y!=0){
                CalAvg5 = (CalTotalValue5/y).setScale(3);
            }
            
            promptData.put('Prompt',promptValue);
            promptData.put('3-Mth',MntsAvg3);
            promptData.put('6-Mth',MntsAvg6);
            promptData.put('9-Mth',MntsAvg9);
            promptData.put('12-Mth',MntsAvg12);
            promptData.put('18-Mth',MntsAvg18);
            promptData.put('24-Mth',MntsAvg24);
            promptData.put('36-Mth',MntsAvg36);
            promptData.put('48-Mth',MntsAvg48);
            promptData.put('60-Mth',MntsAvg60);
            if(futurePrices[0].Month__c == 'Jan' || futurePrices[0].Month__c == 'Feb' || futurePrices[0].Month__c == 'Mar' || futurePrices[0].Month__c == 'Nov' || futurePrices[0].Month__c == 'Dec' ) {
                promptData.put(wtrLabel1,WtrValue1); 
                promptData.put(smrLabel1,SmrValue1); 
                promptData.put(wtrLabel2,WtrValue2);
                promptData.put(smrLabel2,SmrValue2);
                promptData.put(wtrLabel3,WtrValue3);
                promptData.put(smrLabel3,SmrValue3);
            } else  {
                promptData.put(smrLabel1,SmrValue1); 
                promptData.put(wtrLabel1,WtrValue1);                
                promptData.put(smrLabel2,SmrValue2);                
                promptData.put(wtrLabel2,WtrValue2);
                promptData.put(smrLabel3,SmrValue3);
                promptData.put(wtrLabel3,WtrValue3);
            }   

            promptData.put(CalLabel1,CalAvg1);
            promptData.put(CalLabel2,CalAvg2);
            promptData.put(CalLabel3,CalAvg3);
            promptData.put(CalLabel4,CalAvg4);
            promptData.put(CalLabel5,CalAvg5);
            uwrp.promptMap = promptData;
            
            system.debug('@@promptData val---'+promptData);
            for(i=0;i<futurePrices.size();i++){
                if(i<30){
                    listOfFirstThirtyFutures.add(futurePrices[i]);
                }else{
                    listOfSecondThirtyFutures.add(futurePrices[i]);
                }
            }
        }
        uwrp.listOfFirstThirtyFutures = listOfFirstThirtyFutures;
        uwrp.listOfSecondThirtyFutures = listOfSecondThirtyFutures;
        
        return uwrp;
        
    }
    //wrapper class defined for storing all required data
    public class UsageWrapper {
        @AuraEnabled public Map<String, Decimal> promptMap{get; private set;}
        @AuraEnabled public List<Index_Future__c> listOfFirstThirtyFutures{get; private set;}
        @AuraEnabled public List<Index_Future__c> listOfSecondThirtyFutures{get; private set;}
    }
}