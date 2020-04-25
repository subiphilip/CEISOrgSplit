public class MyAccount {
    public boolean ShareMeterData { get; set; }
    public AccountPremiseAssociation__c theAPA { get; set; }
    public Account whichaccount { get; set; }
    public Enrollment__c theaccount { get; set; }
    public Premises__c thepremise { get; set; }
    public string dataRequestStatus { get; set; }
    //these are the months of the year, used to feed the usage table
    public boolean MeterDataPermission { get; set; }
    public order__C orderInProgress { Get; set; }
    private list < monthly_usage__c > usage { get; set; }
    public decimal Jan { get; set; }
    public decimal Feb { get; set; }
    public decimal Mar { get; set; }
    public decimal Apr { get; set; }
    public decimal May { get; set; }
    public decimal Jun { get; set; }
    public decimal Jul { get; set; }
    public decimal Aug { get; set; }
    public decimal Sep { get; set; }
    public decimal Oct { get; set; }
    public decimal Nov { get; set; }
    public decimal Dec { get; set; }

    public MyAccount() {
      
        try {

            ShareMeterData = false;
            whichaccount = new account();
            whichaccount = [select id, ispersonaccount, Personemail, phone, PersonMailingStreet, PersonMailingCity, PersonMailingState, PersonMailingPostalCode, Promo_Code__c from account where id = : TrueCostUtilities.getTheAccount(UserInfo.getUserId()) limit 1];
            theaccount = new enrollment__C();
            theaccount.phone__c = whichaccount.phone;
            theaccount.email__c = whichaccount.personemail;
            theaccount.address__c = whichaccount.PersonMailingStreet;
            theaccount.city__c = whichaccount.PersonMailingCity;
            theaccount.state__c = whichaccount.PersonMailingState;
            theaccount.zip__c = whichaccount.PersonMailingPostalCode;
            theaccount.Promo_Code__c = whichaccount.Promo_Code__c;

            theAPA = APAUtilities.getACtiveAPA(whichaccount.id);
            thepremise = [select id, ESID__c, premise_type__c, Electric_Service_Address__c, Square_Feet__c, Year_Built__c, Year_of_Construction__c, Heating_System__c, Pool__c, Occupants__c from premises__c where id = : theAPA.premise__r.id limit 1];
            MeterDataPermission = TrueCostUtilities.checkMeterDataPermission(theAPA.id);
            dataRequestStatus = TrueCostCalc.getMeterDataStatus(theAPA);
            ShareMeterData = theAPA.public_data__c;
            orderinprogress = TrueCostUtilities.orderinprogressNoDML(whichaccount.id, thepremise.id);
            system.debug('orderinprogress' + orderinprogress);
            usage = TrueCostUtilities.pullTheMonthlyUsage(theAPA);
            dec = usage[11].usage__c;
            nov = usage[10].usage__c;
            oct = usage[9].usage__c;
            sep = usage[8].usage__c;
            aug = usage[7].usage__c;
            jul = usage[6].usage__c;
            jun = usage[5].usage__c;
            may = usage[4].usage__c;
            apr = usage[3].usage__c;
            mar = usage[2].usage__c;
            feb = usage[1].usage__c;
            jan = usage[0].usage__c;

        } catch (exception e) {
            system.debug('=================================================NO APA found===========================================');
        }
    }

    public void makeDataPrivate() {
        theAPA.public_data__c = false;
        ShareMeterData = false;
        update theAPA;
    }

    public void makeDataPublic() {
        theAPA.public_data__c = true;
        ShareMeterData = true;
        update theAPA;
    }

    //tells page whether to show the order in progress area

    public boolean getMeterDataPermission() {
        return theAPA.Meter_Data_Permission__c;
    }

    public boolean getshowOrderinProgress() {
        try {
            return orderInProgress.name != null;
        } catch (exception e) {
            return false;
        }
    }

    public order__c GetCurrentPlan() {
        try {
            list < order__c > orderlist = [select id, order_status__c, REP_Profile__r.name, REP_Profile__r.id, Contract_Length__c, Plan_Expiration__c, plan__r.name, name
                from order__c where Plan_Expiration__c >= : system.today() and premise__c = : thepremise.id and(order_status__c = 'Confirmed') and Parent_Account__r.id = : whichaccount.id order by createddate DESC limit 1
            ];
            if (orderlist.size() > 0) {
                return orderlist[0];
            } else {
                return null;
            }
        } catch (exception e) {
            return null;
        }
    }

    public list < order__c > GetPreviousPlans() {
        try {
            list < order__c > oldplans = new list < order__c > ();
            oldplans = [select id, order_status__c, REP_Profile__r.name, REP_Profile__r.id, Contract_Length__c, Plan_Expiration__c, plan__r.name, createddate
                from order__c where(Plan_Expiration__c <= : system.today() or Plan_Expiration__c = null) and premise__c = : thepremise.id and(order_status__c = 'Confirmed') and Parent_Account__r.id = : whichaccount.id order by createddate DESC
            ];

            return oldplans;
        } catch (exception e) {
            return null;
        }
    }

    public decimal CurrentPlanRating { get; set; }
    public rep_rating__c newrating { get; set; } {
        newrating = new rep_rating__c();
    }

    public decimal getcurrentplanstars() {
        Order__c CurrentPlan = GetCurrentPlan();
        list < rep_rating__c > l = [select id, rating__c, review__c from rep_rating__c where order__c = : CurrentPlan.id order by createddate DESC limit 1];
        if (l.size() > 0) {
            CurrentPlanRating = l[0].Rating__c;
            newrating.rating__c = l[0].rating__c;
            newrating.Review__c = l[0].Review__c;
        }
        return CurrentPlanRating;
    }

    public pageReference rateyourrepedit() {
        //PageReference ratethem = Page.createrating;
        //ratethem.getParameters().put('o2r', CurrentPlan.id);
        PageReference pr = Page.Rating;
        pr.getParameters().put('orderid', GetCurrentPlan().id);
        list < rep_rating__c > l = [select id from rep_rating__c where order__c = : GetCurrentPlan().id and published__c = true order by createddate DESC limit 1];
        pr.getParameters().put('orderID', l[0].id);
        return PR;
    }
    public pageReference rateyourrep() {
        //PageReference ratethem = Page.createrating;
        //ratethem.getParameters().put('o2r', CurrentPlan.id);
        PageReference pr = Page.rating;
        pr.getParameters().put('orderID', GetCurrentPlan().id);
        return PR;
    }

    public pageReference saverating() {
        Order__c CurrentPlan = GetCurrentPlan();
        newrating.Author__c = whichaccount.id;
        newrating.REP_Profile__c = Currentplan.REP_Profile__R.id;
        newrating.Order__c = Currentplan.id;
        newrating.Plan__c = Currentplan.plan__r.id;
        upsert newrating;

        return Page.Myaccount;
    }
    public pageReference grantMeterDataPermission() {
        pageReference pageref = page.Calculation_Choice;
        pageref.getParameters().put('mode', 'MeterData');
        return pageref;
    }

    //Methods to set valus on Rating Stars

    public void its1() {
        newrating.Rating__c = 1;
    }
    public void its2() {
        newrating.Rating__c = 2;
    }
    public void its3() {
        newrating.Rating__c = 3;
    }
    public void its4() {
        newrating.Rating__c = 4;
    }
    public void its5() {
        newrating.Rating__c = 5;
    }

    //
    public list < rep_rating__c > getRecentReviews() {
        Order__c CurrentPlan = GetCurrentPlan();
        return TrueCostUtilities.getRatingsForREP(currentplan.REP_profile__r.id);
    }

    public list < rep_rating__c > getAnonReviews() {
        return [select id, rating__c, REP_without_Order__c from rep_rating__c where CreatedById = : UserInfo.getUserId() and Order__c = null];
    }

    public list < monthly_usage__c > getAverageUsage() {
        list < monthly_usage__c > alist = new list < monthly_usage__c > ();
        try {
            alist = TrueCostUtilities.pullAverageUsage(theAPA.premise__r.tdsp_lookup__r.id, '2018 Usage Per Customer');
        } catch (exception e) {
            alist = TrueCostUtilities.pullGuestMonthlyUsage();
        }
        return alist;

    }

}