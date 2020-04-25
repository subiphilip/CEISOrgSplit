global class EnrollRemoteController2 extends ControllerForMobileMain{

    public rate__c enrollrate {get;set;}
    
    @RemoteAction
        public static order__c startOrderRegistered(id userid, id rateId){
            //Get the Record Type Id
            list<RecordType> recType = [Select Id From RecordType Where Name = 'Electric Order' AND SObjectType='Order__c' LIMIT 1];
            ///get the APA
            //populate what we can on the order
            order__c o=new order__c(rate__c=rateID, order_status__c='Remote Page 1 Started', recordtypeid = recType[0].Id, Language_Preference__c='English');
            insert o;
            //does the order require the customer to select a reward?
            order__c o2 = [select id, name, rate__c, order_status__c, Incentive__c, recordtypeid, Language_Preference__c
                        from order__c where id=:o.id];
            o2.Incentive__c = isThereAChoiceOfRewards(rateid);
            return o2;
        } 
    
    public static boolean isThereAChoiceOfRewards(id rateid){
        list<RateRewardAssociation__c> rewardChoices = [select id, reward__r.id from RateRewardAssociation__c 
            where rate__r.id =: rateid and reward__r.Choice__c = true and reward__r.Reward_Start_Date__c<=:system.today() and reward__r.Reward_End_Date__c>=:system.today()];
        id repid = [select id, plan__r.rep_profile__c from rate__c where id =: rateid].plan__r.rep_profile__c;
        list<Rewards__c> allplansRewards = [select id from Rewards__c 
            where Applies_to_All_Plans__c = true and REP_Profile__c =: repid and choice__c = true
            and Reward_Start_Date__c<=:system.today() and Reward_End_Date__c>=:system.today()
            ]; 
        if (!rewardChoices.isEmpty() || !allplansRewards.isempty()){
            return true;
        } else return false;
    }
    
    
    @RemoteAction
    public static AccountPremiseAssociation__c getAPA(id userid){
        try{ return [select id, 
                premise__r.id, premise__c, premise__r.premise_type__c, 
                premise__r.Electric_Service_Address_Zip__c, 
                premise__r.ESID__c, premise__r.Electric_Service_Address__c, premise__r.Electric_Service_Address_City__c, 
                premise__r.Electric_Service_Address_State2__c,
                account__r.Billing_Adrs_Line_1__c,account__r.Billing_Adrs_Line_2__c, 
                account__r.Billing_City__c, account__r.Billing_zip_code__c, account__r.State__c,
                account__r.FirstName, account__r.LastName, account__r.Phone, 
                account__r.PersonBirthdate, account__r.SSN__c, account__r.Fed_Tax_ID__c,
                account__r.DBA_Name__c ,  account__r.DUNS_Number__c,
                account__r.isPersonAccount, account__r.PersonEmail, account__r.Language_Preference__c
                from AccountPremiseAssociation__c 
                where selected__c=true and account__r.id=:TrueCostUtilities.getTheAccount(userid) order by lastmodifieddate limit 1];
           }catch (exception e){return null;}
        
    }
    
    public EnrollRemoteController2(){
        enrollrate=EnrollQuery(ApexPages.currentPage().getParameters().get('id'));
    }
    
    @RemoteAction
        public static rate__c getRepRate(id rateId){
            return EnrollQuery(rateId);
        }
    
    public static rate__c EnrollQuery(string rateid){
        return [select id, X1000_kWh_rate__c,  TOS_Url__c, YRAC_Url__c, EFL_Url__c, Record_Type_Name__c, 
                                                    plan__r.name,
                                                    Standard_Move_In_for_New_Meters__c,
                                                    plan__r.contract_length__c,
                                                    plan__r.plan_id__c,
                                                    plan__r.Rate_Class_del__c,
                                                    plan__r.REP_Profile__r.REP_Account__c,
                                                    plan__r.REP_profile__r.Star_Rating_Avg__c,
                                                    plan__r.REP_profile__r.total_reviews__c,
                                                    plan__r.REP_profile__r.logo_url__c, 
                                                    plan__r.REP_profile__r.name,
                                                    plan__r.REP_profile__r.Fax_Number__c,
                                                    plan__r.REP_Profile__r.ownerid,
                                                    plan__r.REP_profile__r.Customer_Service_Email__c,
                                                    plan__r.REP_profile__r.Home_Page__c,
                                                    plan__r.REP_profile__r.Mailing_City__c,
                                                    plan__r.REP_profile__r.Mailing_State__c,
                                                    plan__r.REP_profile__r.Mailing_Street_Address__c,
                                                    plan__r.REP_profile__r.Mailing_Zip__c,
                                                    plan__r.REP_profile__r.PUCT_License_Number__c,
                                                    plan__r.REP_profile__r.Legal_Name__c,
                                                    plan__r.REP_profile__r.Allow_credit_card_for_autopay__c,
                
                                                    plan__r.REP_profile__r.Accept_American_Express__c,
                                                    plan__r.REP_profile__r.Accept_Discover__c,
                                                    plan__r.REP_profile__r.Accept_MasterCard__c,
                                                    plan__r.REP_profile__r.Accept_Visa__c,

                                                    plan__r.REP_profile__r.Customer_Service_Phone_Number__c,
                                                    plan__r.Renewable_Content__c,
                                                    plan__r.REP_profile__r.Soonest_Switch_Date__c,
                                                    plan__r.REP_profile__r.Soonest_Move_Date__c,
                                                    plan__r.REP_profile__r.Maximum_Switch_Days__c,
                                                    plan__r.Card_Required_For_Payment__c,
                                                    Self_Selected_Switch_Fee__c, 
                                                    Move_in_Fee__c,
                                                    name,
                                                    Link_for_EFL__c,
                                                    Link_for_TOS__c,Link_for_YRAC__c
                                                    
                                                                            
                                                    from rate__c 
                                                    where id=: rateid];
    }
}