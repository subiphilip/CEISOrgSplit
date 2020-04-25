public without sharing class ContractRequestController {
	
	@RemoteAction
	public static list<ExistingContact> getContacts(id aId){
		list<ExistingContact> ExistingContacts = new list<ExistingContact>();

        if (aID != null)
        {
            //Get Account contacts
            list<Contact> cons = new list<Contact>();
            cons = [select id, name, mailingstreet, mailingcity, mailingstate, phone, fax, email, Contact_Type__c, Account.Name
                	from contact where accountid =: aID and Active__c = true 
                	order by name asc];
            
            for (Contact c: cons){
                boolean missing = false;
                missing = CheckContactMissingData(c);

                ExistingContact ec = new ExistingContact(c, missing);
                ExistingContacts.add(ec);
            }
            
            //Get Account contact roles
            list<AggregateResult> roles = new list<AggregateResult>();
            roles = [select contactid from AccountContactRole where accountid =: aID group by contactid];

            if (roles.size()>0){
	            set<Id> roleSet = new set<Id>();
	            for (AggregateResult agr:roles){
	            	roleSet.add((Id)agr.get('contactid'));
	            }
            
                list<Contact> rCons = new list<Contact>();
                rCons = [select id, name, mailingstreet, mailingcity, mailingstate, phone, fax, email, Contact_Type__c, Account.Name
                				from contact where id in: roleSet];

                for (Contact c: rCons){
	                boolean missing = false;
	                missing = CheckContactMissingData(c);

	                ExistingContact ec = new ExistingContact(c, missing);
	                ExistingContacts.add(ec);
	            }
            }
            
            return ExistingContacts;
        }
        else
        {
        	return null;
        }
	}

    @RemoteAction
    public static list<ExistingAccountContact> getAccountContacts(id aId){
        list<ExistingAccountContact> ExistingAccountContacts = new list<ExistingAccountContact>();

        if (aID != null)
        {
            //Get Account Contact Relationships
            list<AccountContactRelation> acrs = new list<AccountContactRelation>();
            list<AccountContactRelation> indirects = new list<AccountContactRelation>();
            list<AccountContactRelation> directs = new list<AccountContactRelation>();
            set<Id> indirectIdSet = new set<Id>();

            // Get direct relationships for this account into main list
            acrs = [select accountid, contactid, isactive, isdirect, startdate, enddate, roles, 
                        contact.Name, contact.MailingStreet, contact.MailingCity, contact.MailingState,
                        contact.Phone, contact.Fax, contact.Email, contact.Contact_Type__c, account.Name
                    from AccountContactRelation where AccountId =:aID and isactive = true and isdirect = true
                    order by contact.Name];

            // Get indirect relationships
            indirects = [select accountid, contactid, isactive, isdirect, startdate, enddate, roles, 
                        contact.Name, contact.MailingStreet, contact.MailingCity, contact.MailingState,
                        contact.Phone, contact.Fax, contact.Email, contact.Contact_Type__c, account.Name
                    from AccountContactRelation where AccountId =:aID and isactive = true and isdirect = false
                    order by contact.Name];

            for (AccountContactRelation acr:indirects){
                indirectIdSet.add(acr.ContactId);
            }

            // Get direct accounts for the indirect relationships
            directs = [select accountid, contactid, isactive, isdirect, startdate, enddate, roles, 
                        contact.Name, contact.MailingStreet, contact.MailingCity, contact.MailingState,
                        contact.Phone, contact.Fax, contact.Email, contact.Contact_Type__c, account.Name
                    from AccountContactRelation where ContactId in:indirectIdSet and isactive = true and isdirect = true
                    order by contact.Name];

            // Add indirects with direct account to main list
            for (AccountContactRelation acr:directs){
                acrs.add(acr);
            }
            
            // Now we have a complete list of contacts
            // Check for missing required fields
            for (AccountContactRelation acr:acrs){
                boolean missing = false;
                missing = CheckAccountContactMissingData(acr);

                ExistingAccountContact ec = new ExistingAccountContact(acr, missing);
                ExistingAccountContacts.add(ec);
            }
            
            return ExistingAccountContacts;
        }
        else
        {
            return null;
        }
    }

// this is no longer used
/*
	@RemoteAction
	public static void AssignPremises(string jsonStuff){
		list<Premises__c> prems = new list<Premises__c>();

		prems = (list<Premises__c>) Json.deserialize(jsonStuff, list<Premises__c>.class);
		system.debug(prems);

		update prems;
	}
*/
    @RemoteAction
    public static void CreateCRPs(string jsonStuff){
        system.debug(jsonStuff);
        list<Contract_Request_Premise__c> crps = new list<Contract_Request_Premise__c>();

        crps = (list<Contract_Request_Premise__c>) Json.deserialize(jsonStuff, list<Contract_Request_Premise__c>.class);
        system.debug(crps);

        insert crps;
    }

	@RemoteAction
	public static String CreateContractFromRequest(id rid){
		Contract_Request__c req;
        list<Customer_Charge__c> scenarioCharges = new list<Customer_Charge__c>();

		//Get request record
        req = [select id, name, Record_Type_Name__c, Account__c, Account__r.Name, 
               Contact_for_Confirmations__c, Contact_for_Confirmations__r.Name, Contact_for_Confirmations__r.mailingstreet, Contact_for_Confirmations__r.mailingcity, Contact_for_Confirmations__r.mailingstate, Contact_for_Confirmations__r.phone, Contact_for_Confirmations__r.email,
               Contact_for_Invoices__c, Contact_for_Invoices__r.Name, Contact_for_Invoices__r.mailingstreet, Contact_for_Invoices__r.mailingcity, Contact_for_Invoices__r.mailingstate, Contact_for_Invoices__r.phone, Contact_for_Invoices__r.email,
               Contact_for_Notices__c, Contact_for_Notices__r.Name, Contact_for_Notices__r.mailingstreet, Contact_for_Notices__r.mailingcity, Contact_for_Notices__r.mailingstate, Contact_for_Notices__r.phone, Contact_for_Notices__r.email,
               Existing_Base_Agreement__c, Existing_Base_Agreement__r.Name, Existing_Base_Agreement__r.Contacts_Selected__c, 
               Facility_List__c, Facility_List__r.Name, Number_of_Premises__c, New_Agreement_Type__c, Opportunity__c,
               Other_Details__c, Pricing_Scenario__c, Pricing__c, Request_Utility_SubType__c, Start_Date__c, Term__c,
               Utility__c, Utility__r.Name, Utility__r.LDC_Default_Unit__c, Opportunity__r.Name, CES_Office__c, CES_Office__r.old_email__c, 
               Existing_Base_Agreement__r.Contact_for_Confirmations__c, Existing_Base_Agreement__r.Contact_for_Confirmations__r.Name, Existing_Base_Agreement__r.Contact_for_Confirmations__r.mailingstreet, Existing_Base_Agreement__r.Contact_for_Confirmations__r.mailingcity, Existing_Base_Agreement__r.Contact_for_Confirmations__r.mailingstate, Existing_Base_Agreement__r.Contact_for_Confirmations__r.phone, Existing_Base_Agreement__r.Contact_for_Confirmations__r.email,
               Existing_Base_Agreement__r.Contact_for_Invoices__c, Existing_Base_Agreement__r.Contact_for_Invoices__r.Name, Existing_Base_Agreement__r.Contact_for_Invoices__r.mailingstreet, Existing_Base_Agreement__r.Contact_for_Invoices__r.mailingcity, Existing_Base_Agreement__r.Contact_for_Invoices__r.mailingstate, Existing_Base_Agreement__r.Contact_for_Invoices__r.phone, Existing_Base_Agreement__r.Contact_for_Invoices__r.email,
               Existing_Base_Agreement__r.Contact_for_Notices__c, Existing_Base_Agreement__r.Contact_for_Notices__r.Name, Existing_Base_Agreement__r.Contact_for_Notices__r.mailingstreet, Existing_Base_Agreement__r.Contact_for_Notices__r.mailingcity, Existing_Base_Agreement__r.Contact_for_Notices__r.mailingstate, Existing_Base_Agreement__r.Contact_for_Notices__r.phone, Existing_Base_Agreement__r.Contact_for_Notices__r.email,
               Existing_Base_Agreement__r.Billing_Address__c, Existing_Base_Agreement__r.Billing_City__c, Existing_Base_Agreement__r.Billing_State__c, Existing_Base_Agreement__r.Billing_Postal_Code__c, Existing_Base_Agreement__r.Billing_Phone__c, Existing_Base_Agreement__r.Billing_Fax__c, Existing_Base_Agreement__r.Billing_Email__c, Existing_Base_Agreement__r.Invoice_Accounts_Payable__c, Existing_Base_Agreement__r.Invoice_Address_is_Notice_Address__c, 
               Pricing__r.Name, Pricing__r.Contract_Volume_Required__c, Pricing__r.Receipt_Obligation_Applies__c,
               Pricing__r.CES_Pricing_Rate_Type__c, Pricing__r.Cashout_Obligation_Applies__c, Pricing__r.Is_FOM_Price_Type__c, Pricing__r.Base_Pricing_Default__c, Pricing__r.Allow_Nomination_Change__c, 
               Pricing_Scenario__r.Name, Pricing_Scenario__r.Agency_Services__c, Pricing_Scenario__r.Auto_Renew__c,
               Pricing_Scenario__r.Balancing__c, Pricing_Scenario__r.Cashout_Obligation_Terms__c, 
               Pricing_Scenario__r.Cashout_Over_Index__c, Pricing_Scenario__r.Cashout_Over_Adder__c, Pricing_Scenario__r.Cashout_Over_Margin__c, 
               Pricing_Scenario__r.Cashout_Under_Index__c, Pricing_Scenario__r.Cashout_Under_Adder__c, Pricing_Scenario__r.Cashout_Under_Margin__c, 
               Pricing_Scenario__r.Delivery_Obligation__c, Pricing_Scenario__r.Delivery_Point__c, 
               Pricing_Scenario__r.Market_Rate_Index__c, Pricing_Scenario__r.Market_Rate_Margin__c, Pricing_Scenario__r.Over_Index__c, Pricing_Scenario__r.Over_Adder__c, 
               Pricing_Scenario__r.Margin_on_Over__c, Pricing_Scenario__r.Pipeline__c,
               Pricing_Scenario__r.Pricing_Index__c, Pricing_Scenario__r.Index_Adder__c, Pricing_Scenario__r.Margin_on_Index__c, 
               Pricing_Scenario__r.Pricing_Terms__c, Pricing_Scenario__r.Receipt_Obligation_Terms__c,
               Pricing_Scenario__r.Renewal_Notice_Days__c, Pricing_Scenario__r.Renewal_Term__c, Pricing_Scenario__r.Telemetry__c,
               Pricing_Scenario__r.Transport_Fuel__c, Pricing_Scenario__r.Under_Index__c, Pricing_Scenario__r.Under_Adder__c, 
               Pricing_Scenario__r.Margin_on_Under__c, Pricing_Scenario__r.Utility__c, Pricing_Scenario__r.Utility_Transportation__c, 
               Pricing_Scenario__r.Utility_Cashout__c, Pricing_Scenario__r.Utility_Meter_Read_Pooling__c,
               Pricing_Scenario__r.Utility_Rate_Index__c, Pricing_Scenario__r.Utility_Zone__c, //Pricing_Scenario__r.TC_Unit_of_Measure__c,
               Consultant__c, Consultant__r.Name, Request_Objects_Created__c,
               Needs_New_Agreement__c, Needs_New_Facility_List__c, Needs_New_TC__c, Contacts_Selected_for_New_Agreement__c, Invoice_Accounts_Payable__c, Invoice_Address_is_Notice_Address__c,
               Billing_Address__c, Billing_City__c, Billing_State__c, Billing_Postal_Code__c, Billing_Phone__c, Billing_Fax__c, Billing_Email__c 
               from Contract_Request__c 
               where id=: rid];  //Default_Consultant_Margin_Pctg__c, Default_Consultant_Unit_Margin__c

        // get the crps for this request if applicable
        list<Contract_Request_Premise__c> crps = new list<Contract_Request_Premise__c>();

        crps = [select id, name, Premise__c, Contract_Request__c, Premise__r.Account__c 
                from Contract_Request_Premise__c where Contract_Request__c =: req.id];
        
        // get the customer charges for the contract request pricing scenario
        scenarioCharges = [select id, name, Applicable_Fees_not_Specified__c, Charge_Level__c, Charge_Type__c, Index_Lookup__c, Pipeline_Loss_Index__c, Rate__c, Suppress_From_TC__c, Utility_Loss_Index__c
                            from Customer_Charge__c where Pricing_Scenario__c =: req.Pricing_Scenario__c];

        //get the premises assigned to this request if applicable
        /*
        list<Premises__c> prems = new list<Premises__c>();
        
        prems = [select id, name, Account__c, Contract_Request__c 
                     from Premises__c 
                     where Contract_Request__c =: req.id];
        */

        //Create contract object records
        //set savepoint in case error is caught and data needs to be rolled back
        Savepoint sp = Database.setSavepoint();
        
        try {
            //declare variables for object creation
            CESContract__c Agree;
            
            //Create Agreement record
            if (req.Needs_New_Agreement__c) {
                Agree = new CESContract__c();
                Agree.RecordTypeID = [select id from recordtype where name=: req.New_Agreement_Type__c and SobjectType = 'CESContract__c'].id;
                Agree.Account__c = req.Account__c;
                Agree.Opportunity__c = req.Opportunity__c;
                Agree.CES_Office__c = req.CES_Office__c;
                Agree.Contract_Admin_Mailbox__c = req.CES_Office__r.old_email__c;
                Agree.Effective_Date__c = Date.today();
                Agree.Contact_for_Confirmations__c = req.Contact_for_Confirmations__c;
                Agree.Contact_for_Invoices__c = req.Contact_for_Invoices__c;
                Agree.Contact_for_Notices__c = req.Contact_for_Notices__c;

                Agree.Invoice_Accounts_Payable__c = req.Invoice_Accounts_Payable__c;
                Agree.Invoice_Address_is_Notice_Address__c = req.Invoice_Address_is_Notice_Address__c;
                Agree.Billing_Address__c = req.Billing_Address__c;
                Agree.Billing_City__c = req.Billing_City__c;
                Agree.Billing_State__c = req.Billing_State__c;
                Agree.Billing_Postal_Code__c = req.Billing_Postal_Code__c;
                Agree.Billing_Phone__c = req.Billing_Phone__c;
                Agree.Billing_Fax__c = req.Billing_Fax__c;
                Agree.Billing_Email__c = req.Billing_Email__c;

                Agree.Contract_Status__c = 'Not Submitted';

                //code to go around default setting that has been deleted but not recognized
                Agree.Pricing_Terms__c = null;
                Agree.Receipt_Obligation_Terms__c = null;

                //Agreements pass validations since all fields are provided for insert
                Agree.Field_Validation_Check__c = 'Passed System';

                //assign the contract request id if a TC will NOT be created
                //if (req.Needs_New_TC__c != true) {
                    Agree.Contract_Request__c = req.id;
                    Agree.Contract_Request_Type__c = req.Record_Type_Name__c;
                    req.Request_Objects_Created__c = true;
                    update req;
                //}
                
                insert Agree;
            }
            
            //Create TC
            CESContract__c TC;
            if (req.Needs_New_TC__c){
                //get TC record type name and ID
                string TCRecType;
                
                if (String.isBlank(req.Request_Utility_SubType__c)) {
                    TCRecType = req.Pricing__r.Name;
                } else {
                    TCRecType = req.Pricing__r.Name + ' ' + req.Request_Utility_SubType__c;
                }
                id TCRecTypeID = [select id from recordtype where name=: TCRecType and SObjectType = 'CESContract__c'].id;
                
                //Set general fields
                TC = new CESContract__c();
                TC.RecordTypeID = TCRecTypeID;
                TC.Account__c = req.Account__c;
                TC.Opportunity__c = req.Opportunity__c;
                TC.Utility_Lookup__c = req.Utility__c;
                TC.Product_Subtype_Lookup__c = req.Pricing__c;
                TC.Base_Pricing__c = req.Pricing__r.Base_Pricing_Default__c;
                TC.Pricing_Scenario__c = req.Pricing_Scenario__c;
                TC.CES_Office__c = req.CES_Office__c;
                TC.Contract_Admin_Mailbox__c = req.CES_Office__r.old_email__c;
                TC.Effective_Date__c = Date.today();
                TC.Start_Date_New__c = req.Start_Date__c;
                TC.Term_New__c = req.Term__c;
                TC.Other_Details__c = req.Other_Details__c;
                TC.Contract_Status__c = 'Not Submitted';
                TC.MDQ_Unit__c = req.Utility__r.LDC_Default_Unit__c;
                TC.Consultant__c = req.Consultant__c;
                //TC.Consultant_Margin_Pctg__c = req.Default_Consultant_Margin_Pctg__c;
                //TC.Consultant_Unit_Margin__c = req.Default_Consultant_Unit_Margin__c;

                //TC validation set to fail since not all fields are provided for insert
                TC.Field_Validation_Check__c = 'Failed: Required fields missing values';

                //Track request ID to reverse the request if needed
                TC.Contract_Request__c = req.id;
                TC.Contract_Request_Type__c = req.Record_Type_Name__c;

                if (req.Pricing__r.Contract_Volume_Required__c){
                    TC.Volume_Validation_Check__c = 'Failed: Volumes are required';
                    //set volume entry type to monthly unless the pricing is FOM
                    if (req.Pricing__r.Is_FOM_Price_Type__c != true){
                    	TC.Volume_Entry_Type__c = 'Monthly';
                    }
                }
                
                //set agreement and contact information
                if (req.Existing_Base_Agreement__c != null){
                    TC.Existing_Base_Agreement__c = req.Existing_Base_Agreement__c;

                    // check to see if agreement has the confirmation contact selected.  if not, use request contact
                    if (req.Existing_Base_Agreement__r.Contact_for_Confirmations__c != null){
                        TC.Contact_for_Confirmations__c = req.Existing_Base_Agreement__r.Contact_for_Confirmations__c;
                        /*TC.Contact_for_Invoices__c = req.Existing_Base_Agreement__r.Contact_for_Invoices__c;
                        TC.Contact_for_Notices__c = req.Existing_Base_Agreement__r.Contact_for_Notices__c;

                        TC.Invoice_Accounts_Payable__c = req.Existing_Base_Agreement__r.Invoice_Accounts_Payable__c;
    	                TC.Invoice_Address_is_Notice_Address__c = req.Existing_Base_Agreement__r.Invoice_Address_is_Notice_Address__c;
    	                TC.Billing_Address__c = req.Existing_Base_Agreement__r.Billing_Address__c;
    	                TC.Billing_City__c = req.Existing_Base_Agreement__r.Billing_City__c;
    	                TC.Billing_State__c = req.Existing_Base_Agreement__r.Billing_State__c;
    	                TC.Billing_Phone__c = req.Existing_Base_Agreement__r.Billing_Phone__c;
    	                TC.Billing_Postal_Code__c = req.Existing_Base_Agreement__r.Billing_Postal_Code__c;
    	                TC.Billing_Fax__c = req.Existing_Base_Agreement__r.Billing_Fax__c;
    	                TC.Billing_Email__c = req.Existing_Base_Agreement__r.Billing_Email__c;*/
                    } else {
                        TC.Contact_for_Confirmations__c = req.Contact_for_Confirmations__c;
                        /*TC.Contact_for_Invoices__c = req.Contact_for_Invoices__c;
                        TC.Contact_for_Notices__c = req.Contact_for_Notices__c;

                        TC.Invoice_Accounts_Payable__c = req.Invoice_Accounts_Payable__c;
                        TC.Invoice_Address_is_Notice_Address__c = req.Invoice_Address_is_Notice_Address__c;
                        TC.Billing_Address__c = req.Billing_Address__c;
                        TC.Billing_City__c = req.Billing_City__c;
                        TC.Billing_State__c = req.Billing_State__c;
                        TC.Billing_Phone__c = req.Billing_Phone__c;
                        TC.Billing_Postal_Code__c = req.Billing_Postal_Code__c;
                        TC.Billing_Fax__c = req.Billing_Fax__c;
                        TC.Billing_Email__c = req.Billing_Email__c;*/
                    }
                } else {
                    TC.Existing_Base_Agreement__c = Agree.id;
                    TC.Contact_for_Confirmations__c = req.Contact_for_Confirmations__c;
                    /*TC.Contact_for_Invoices__c = req.Contact_for_Invoices__c;
                    TC.Contact_for_Notices__c = req.Contact_for_Notices__c;

                    TC.Invoice_Accounts_Payable__c = req.Invoice_Accounts_Payable__c;
	                TC.Invoice_Address_is_Notice_Address__c = req.Invoice_Address_is_Notice_Address__c;
	                TC.Billing_Address__c = req.Billing_Address__c;
	                TC.Billing_City__c = req.Billing_City__c;
	                TC.Billing_State__c = req.Billing_State__c;
	                TC.Billing_Phone__c = req.Billing_Phone__c;
	                TC.Billing_Postal_Code__c = req.Billing_Postal_Code__c;
	                TC.Billing_Fax__c = req.Billing_Fax__c;
	                TC.Billing_Email__c = req.Billing_Email__c;*/
                }
                
                //if this is manual, then update problem fields and skip to save and go to new contract page
                if (req.Pricing_Scenario__r.Name == 'Manual Contract Entry'){
                    TC.Pricing_Terms__c = null;
                    TC.Receipt_Obligation_Terms__c = null;
                } else {
                    //set general pricing scenario fields
                    TC.Agency_Services__c = req.Pricing_Scenario__r.Agency_Services__c;
                    TC.Auto_Renew__c = req.Pricing_Scenario__r.Auto_Renew__c;
                    TC.Delivery_Obligation__c = req.Pricing_Scenario__r.Delivery_Obligation__c;
                    TC.Delivery_Point__c = req.Pricing_Scenario__r.Delivery_Point__c;
                    TC.Pipeline_Lookup__c = req.Pricing_Scenario__r.Pipeline__c;
                    TC.Pricing_Terms__c = req.Pricing_Scenario__r.Pricing_Terms__c;
                    TC.Renewal_Notice_Days__c = req.Pricing_Scenario__r.Renewal_Notice_Days__c;
                    TC.Renewal_Term__c = req.Pricing_Scenario__r.Renewal_Term__c;
                    TC.Telemetry__c = req.Pricing_Scenario__r.Telemetry__c;
                    TC.Transport_Fuel__c = req.Pricing_Scenario__r.Transport_Fuel__c;
                    TC.Utility_Cashout__c = req.Pricing_Scenario__r.Utility_Cashout__c;
                    //TC.Utility_Meter_Read_Pooling__c = req.Pricing_Scenario__r.Utility_Meter_Read_Pooling__c;
                    TC.Utility_Zone__c = req.Pricing_Scenario__r.Utility_Zone__c;
                    TC.Utility_Transportation__c =  req.Pricing_Scenario__r.Utility_Transportation__c;
                    if (req.Pricing__r.Receipt_Obligation_Applies__c){
                        TC.Receipt_Obligation_Terms__c = req.Pricing_Scenario__r.Receipt_Obligation_Terms__c;
                        TC.Over_Index_Name__c = req.Pricing_Scenario__r.Over_Index__c;
                        TC.Over_Adder__c = req.Pricing_Scenario__r.Over_Adder__c;
                        TC.Margin_on_Over__c = req.Pricing_Scenario__r.Margin_on_Over__c;
                        TC.Under_Index_Name__c = req.Pricing_Scenario__r.Under_Index__c;
                        TC.Under_Adder__c = req.Pricing_Scenario__r.Under_Adder__c;
                        TC.Margin_on_Under__c = req.Pricing_Scenario__r.Margin_on_Under__c;
                    } else {
                        //code to go around default setting that has been deleted but not recognized
                        TC.Receipt_Obligation_Terms__c = null;
                    }
                    if (req.Pricing__r.Cashout_Obligation_Applies__c){
                        TC.Cashout_Obligation_Terms__c = req.Pricing_Scenario__r.Cashout_Obligation_Terms__c;
                        TC.Cashout_Over_Index_Name__c = req.Pricing_Scenario__r.Cashout_Over_Index__c;
                        TC.Cashout_Over_Adder__c = req.Pricing_Scenario__r.Cashout_Over_Adder__c;
                        TC.Cashout_Over_Margin__c = req.Pricing_Scenario__r.Cashout_Over_Margin__c;
                        TC.Cashout_Under_Index_Name__c = req.Pricing_Scenario__r.Cashout_Under_Index__c;
                        TC.Cashout_Under_Adder__c = req.Pricing_Scenario__r.Cashout_Under_Adder__c;
                        TC.Cashout_Under_Margin__c = req.Pricing_Scenario__r.Cashout_Under_Margin__c;
                    }
                    
                    //set record type specific pricing scenario fields
                    if (req.Pricing__r.CES_Pricing_Rate_Type__c == 'Index'){
                        TC.Index_Rate_Name__c = req.Pricing_Scenario__r.Pricing_Index__c;
                        TC.Index_Adder__c = req.Pricing_Scenario__r.Index_Adder__c;
                        TC.Margin_on_Index__c = req.Pricing_Scenario__r.Margin_on_Index__c;                            
                    // mod: consolidate contract indexes
                    /*
                    } else if (req.Pricing__r.CES_Pricing_Rate_Type__c == 'Market Price') {
                        TC.Market_Rate_Index_Name__c = req.Pricing_Scenario__r.Market_Rate_Index__c;
                        TC.Market_Rate_Margin__c = req.Pricing_Scenario__r.Market_Rate_Margin__c;
                    } else if (req.Pricing__r.CES_Pricing_Rate_Type__c == 'Utility') {
                        TC.Utility_Rate_Name__c = req.Pricing_Scenario__r.Utility_Rate_Index__c;
                    }
                    */
                    } else if (req.Pricing__r.CES_Pricing_Rate_Type__c == 'Market Price') {
                        // use market price index if exists, otherwise use pricing index
                        if (req.Pricing_Scenario__r.Market_Rate_Index__c != null){
                            TC.Index_Rate_Name__c = req.Pricing_Scenario__r.Market_Rate_Index__c;
                            TC.Index_Adder__c = 0;
                            TC.Margin_on_Index__c = req.Pricing_Scenario__r.Market_Rate_Margin__c;    
                        } else {
                            TC.Index_Rate_Name__c = req.Pricing_Scenario__r.Pricing_Index__c;
                            TC.Index_Adder__c = 0;
                            TC.Margin_on_Index__c = req.Pricing_Scenario__r.Margin_on_Index__c;
                        }
                    } else if (req.Pricing__r.CES_Pricing_Rate_Type__c == 'Utility') {
                        TC.Index_Rate_Name__c = req.Pricing_Scenario__r.Pricing_Index__c;
                        TC.Index_Adder__c = 0;
                        TC.Margin_on_Index__c = 0;
                    }
                    // end mod: consolidate contract indexes

                    //set allow nomination change
                    if (req.Pricing__r.Allow_Nomination_Change__c){
                        TC.Allow_Nomination_Change__c = true;
                    }
                }
                
                //save record
                insert TC;

                // create any charges for the contract
                if (scenarioCharges.size() > 0){
                    list<Customer_Charge__c> contractCharges = new list<Customer_Charge__c>();
                    // clone scenario charge and change it to a contract charge
                    for (Customer_Charge__c sc: scenarioCharges){
                        Customer_Charge__c cc = sc.clone(false, false, false, false);
                        cc.Contract__c = TC.Id;
                        cc.Pricing_Scenario__c = null;
                        contractCharges.add(cc);
                    }

                    insert contractCharges;
                }

                //set request objects created to truee
                req.Request_Objects_Created__c = true;
                update req;
                
                //create contract premise records for TC
                list<Contract_Premise__c> cps = new list<Contract_Premise__c>();
                if (crps.size() > 0){
                    //use request premises
                    for (Contract_Request_Premise__c crp:crps){
                        // remove premise from request since it was submitted and a tc was created
                        //prem.Contract_Request__c = null;
                        cps.add(new Contract_Premise__c(Premise__c=crp.Premise__c, CESContract__c=TC.id, Start_Date__c=req.Start_Date__c, End_Date__c=req.Start_Date__c.addMonths(req.Term__c.intValue()).addDays(-1)));
                    }
                    //update prems;
                }

                if (cps.size() > 0){insert cps;}                    
            }
            
            //Go to new Agreement or TC based on request type
            if (req.Needs_New_TC__c)
            {
                return '/' + TC.id + '/e?retURL=%2F' + TC.id;
            }
            else
            {
            	return '/' + Agree.id + '/e?retURL=%2F' + Agree.id;
            }
        }
        catch (exception e)
        {
            Database.rollback(sp);
            
            return e.getMessage();
        }
	}

	@RemoteAction
	public static integer DeleteContractsOnRequest(id rid){
		list<CESContract__c> cons = new list<CESContract__c>();
		integer delCount = 0;

		cons = [select id, name from CESContract__c where Contract_Request__c =: rid];

		delCount = cons.size();

		delete cons;

		return delCount;
	}

	@RemoteAction
	public static string SubmitContractRequest(id tcid){
        //get contract tc record
        CESContract__c CESC = [select id, name, existing_base_agreement__c, contract_request__c, contract_status__c, 
                               Product_Subtype_Lookup__r.Contract_Volume_Required__c, Validation_Check__c, Override_Validation__c,
                               Custom_Submit_Clicked__c
                            from CESContract__c where id =: tcid];
        
        //set savepoint in case error is caught and data needs to be rolled back
        Savepoint sp = Database.setSavepoint();
        
        try{
            //set custom submit clicked to true since the custom button was clicked
            CESC.Custom_Submit_Clicked__c = true;
            update CESC;
            
            //if this is a TC, check to see if the agreement needs to be submitted
            //if yes, then set custom submit clicked to true and submit the agreement
            if (CESC.Existing_Base_Agreement__c != null){
                CESContract__c AC = [select id, name, contract_status__c, custom_submit_clicked__c,
                                     Validation_Check__c, Override_Validation__c
                                    from CESContract__c where id =: CESC.Existing_Base_Agreement__c];
                
                if (AC.Contract_Status__c == null ||
                   AC.Contract_Status__c == 'Not Submitted'){
                    if (AC.Validation_Check__c == 'Passed' ||
                        AC.Override_Validation__c){
                        //Validation passed, submit the agreement
                        AC.Custom_Submit_Clicked__c = true;
                        update AC;
                        
                        string rslt = SubmitContractApproval(AC.id);
                        
                        if (rslt != null)
                        {
                            Database.rollback(sp);
                            return rslt;
                        }
                    } else {
                        //Validation failed, rollback and cancel process
                        Database.rollback(sp);
                        return 'The agreement assigned to this TC failed validation.  Correct validation issues and try again.';
                    }
                }
            }
            
            //submit this contract record
            string rslt = SubmitContractApproval(CESC.id);
            
            if (rslt != null){
                Database.rollback(sp);
                return rslt;
            }

            // remove premises from this request since it has been submitted
            // no longer needed since there is a premise junction object now
	        /*list<Premises__c> prems = new list<Premises__c>();
	        
	        prems = [select id, name, Account__c, Contract_Request__c 
	                     from Premises__c 
	                     where Contract_Request__c =: CESC.Contract_Request__c];

	        for (Premises__c p:prems){
	        	p.Contract_Request__c = null;
	        }

	        update prems;
            */

            //if no errors, go to contract
            return '/' + CESC.id;
        } catch (exception e) {
            Database.rollback(sp);
            
            return e.getMessage();
        }
    }
    
    public static String SubmitContractApproval(id cId){
        try {
            //Create the approval request
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(cId);
            
            //Submit the approval request for the contract
            Approval.ProcessResult result = Approval.process(req1);
        } catch (exception e){
            return e.getMessage();
        }
        
        return null;
    }

	public static boolean CheckContactMissingData(Contact con){
        if (con.MailingStreet == null || con.MailingCity == null || con.MailingState == null || con.Phone == null || (con.Email == null && con.fax == null)){
            return true;
        } else { return false; }
    }

    public static boolean CheckAccountContactMissingData(AccountContactRelation acr){
        if (acr.Contact.MailingStreet == null || acr.Contact.MailingCity == null || acr.Contact.MailingState == null || 
            acr.Contact.Phone == null || (acr.Contact.Email == null && acr.Contact.fax == null)){
            return true;
        } else { return false; }
    }

	public class ExistingContact 
    {
        public Contact con {get;set;}
        public boolean isMissingData {get;set;}
        public Id conId {get;set;}
        
        public ExistingContact(Contact Incon, boolean dataMissing){
            con = Incon;
            isMissingData = dataMissing;
            conId = Incon.Id;
        }
    }

    public class ExistingAccountContact 
    {
        public AccountContactRelation acr {get;set;}
        public boolean isMissingData {get;set;}
        public Id conId {get;set;}
        
        public ExistingAccountContact(AccountContactRelation inAcr, boolean dataMissing){
            acr = inAcr;
            isMissingData = dataMissing;
            conId = inAcr.ContactId;
        }
    }

    @RemoteAction
    public static void updateContractCharge(string sCharge){
        Customer_Charge__c passCharge = (Customer_Charge__c) Json.deserialize(sCharge, Customer_Charge__c.class);

        system.debug(passCharge);
        
        Customer_Charge__c updCharge = [select id, name, Contract__c, Charge_Level__c, Charge_Type__c, End_Date__c, Start_Date__c, Index_Lookup__c, Rate__c, 
                                        Utility_Loss_Index__c, Pipeline_Loss_Index__c, Applicable_Fees_not_Specified__c, Suppress_From_TC__c
                                        from Customer_Charge__c where id=:passCharge.Id];
        
        // check to see if the index needs to be set to null
        
            try {
                updCharge.Index_Lookup__c = passCharge.Index_Lookup__c;
            } catch (SObjectException e){
                updCharge.Index_Lookup__c = null;
            }       

        // check to see if the rate needs to be set to null
        
            try {
                updCharge.Rate__c = passCharge.Rate__c;
            } catch (SObjectException e){
                updCharge.Rate__c = null;
            } 

        // check to see if the utility loss needs to be set to null
        
            try {
                updCharge.Utility_Loss_Index__c = passCharge.Utility_Loss_Index__c;
            } catch (SObjectException e){
                updCharge.Utility_Loss_Index__c = null;
            }       

        // check to see if the pipeline loss needs to be set to null
        
            try {
                updCharge.Pipeline_Loss_Index__c = passCharge.Pipeline_Loss_Index__c;
            } catch (SObjectException e){
                updCharge.Pipeline_Loss_Index__c = null;
            }  

        // now update the rest of the fields
        updCharge.Charge_Level__c = passCharge.Charge_Level__c;
        updCharge.Charge_Type__c = passCharge.Charge_Type__c;
        updCharge.Applicable_Fees_not_Specified__c = passCharge.Applicable_Fees_not_Specified__c;
        updCharge.Suppress_From_TC__c = passCharge.Suppress_From_TC__c;
        //updCharge.End_Date__c = passCharge.End_Date__c;
        //updCharge.Start_Date__c = passCharge.Start_Date__c;

        // do update
        update updCharge;
    }
}