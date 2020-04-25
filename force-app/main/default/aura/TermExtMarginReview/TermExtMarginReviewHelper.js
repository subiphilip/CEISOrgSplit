({
    /*
    getData : function(component, event, methodName, targetAttribute) {
        console.log('in helper: getData')
        
        var termExtId = component.get("v.recordId");
        console.log('termExtId'+termExtId);
        var action = component.get('c.'+methodName);
        console.log('calling component:' + methodName);

       
          action.setParams({
            "termExtId": termExtId
            
        });
        
        
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
               // console.log('keyword:'+vkeyword);
                console.log('Got Raw Response for ' + methodName + ' ' + targetAttribute);
                var returnedData = response.getReturnValue();

                
                if (methodName === "getTermExtensionsContractsLineItems")
                {
                    console.log(response.getReturnValue());
                  // kns 2020-04-06 no longer need this
                  // component.set("v.myData", this.lineItemUpdate(response.getReturnValue())) ; 
                  component.set("v.myData", this.formatData(response.getReturnValue())) ; 
                  component.set("v.myData",response.getReturnValue());
                     component.set("v.preInit", false);
                }
                

            } else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
            }
        }));
        $A.enqueueAction(action);
    }
   ,
 	navigateToLink: function(component, rowid){
        var recordId = rowid;   
            console.log(recordId);
        var navEvt;
            if(recordId != null )
            {
				navEvt = $A.get("e.force:navigateToSObject");
				navEvt.setParams({
				"recordId": recordId,
				"slideDevName" : "Related"
             });
			navEvt.fire();	
		}  
	},     
    
    formatData : function(rows){
        var articleURL = window.location.origin;
        console.log("massaging data for display");
		var myData = [];
        _.each (rows, function(row,key){
            		row.ContractUrl = articleURL+'/lightning/r/CESContract__c/'+row.Contract__c+'/view';
            		row.TermExtUrl = articleURL+'/lightning/r/Term_Extension__c/'+row.Id+'/view';
            		row.TermExtName = row.Name;
            		row.lastRefreshDate = row.Last_Price_Refresh2__c;
           			row.priorMargin = row.Prior_Period_Unit_Margin__c;
           			row.ExtensionMargin = row.Term_Extension_Unit_Margin__c;
            		if (row.Contract__c) row.ContractName = row.Contract__r.Name;
					if (row.Contract__c) row.AccountName = row.Contract__r.Account__r.Name;
            		if (row.Contract__c) row.AccountUrl = articleURL+'/lightning/r/Account/'+row.Contract__r.Account__c+'/view';
            		if (row.Contract__r.Sales_Rep__c) row.SalesRepName = row.Contract__r.Sales_Rep__r.Name;
            		if (row.Contract__r.Utility_Lookup__c) row.UtilityName = row.Contract__r.Utility_Lookup__r.Name;
            		if (row.Contract__r.CES_Office__c) row.OfficeName = row.Contract__r.CES_Office__r.Name;
            		if (row.Contract__c) row.ActionStartDate = row.Contract__r.Renewal_Action_Start_Date__c;
                	if (row.Contract__c) row.RenewalType = row.Contract__r.Renewal_Type__c;
            		if (row.Contract__c) row.RenewalExpirationDate = row.Contract__r.Renewal_Notice_Expiration_Date__c;
            		if (row.Contract__c) row.RenewalTerm = row.Contract__r.Renewal_Term__c;
            		row.marginChange = row.ExtensionMargin - row.priorMargin; 
            		row.grossMarginChange = row.marginChange * row.Volume__c; 
            
                         if(row.grossMarginChange == -0){
                            row.grossMarginChange = 0 ;
                        }
            if(row.priorMargin > row.ExtensionMargin){
                row.extMarginIcon = 'utility:arrowdown';
            }
            else if(row.priorMargin < row.ExtensionMargin){
                row.extMarginIcon = 'utility:arrowup';
            }
            else {
                row.extMarginIcon = 'utility:dash';
            };
          
            myData.push(row);
            		
                });
        
        console.log(myData);

        return myData;
        
    },
    lineItemUpdateOld : function (rows){
                
        var articleURL = window.location.origin;
        console.log("massaging data for display");
		var myData = [];
        _.each (rows, function(row,key){
            		var keyString = key.toString();
            		row.priorMargin = key.split('|')[1];
            		row.ExtensionMargin = key.split('|')[2];
            		row.ContractUrl = articleURL+'/lightning/r/CESContract__c/'+row.Contract__c+'/view';
            		row.TermExtUrl = articleURL+'/lightning/r/Term_Extension__c/'+row.Id+'/view';
            		row.TermExtName = row.Name;
            		row.lastRefreshDate = row.Last_Price_Refresh2__c;
            		if (row.Contract__c) row.ContractName = row.Contract__r.Name;
					if (row.Contract__c) row.AccountName = row.Contract__r.Account__r.Name;
            		if (row.Contract__c) row.AccountUrl = articleURL+'/lightning/r/Account/'+row.Contract__r.Account__c+'/view';
            		if (row.Contract__r.Sales_Rep__c) row.SalesRepName = row.Contract__r.Sales_Rep__r.Name;
            		if (row.Contract__r.Utility_Lookup__c) row.UtilityName = row.Contract__r.Utility_Lookup__r.Name;
            		if (row.Contract__r.CES_Office__c) row.OfficeName = row.Contract__r.CES_Office__r.Name;
            		if (row.Contract__c) row.ActionStartDate = row.Contract__r.Renewal_Action_Start_Date__c;
                	if (row.Contract__c) row.RenewalType = row.Contract__r.Renewal_Type__c;
            		if (row.Contract__c) row.RenewalExpirationDate = row.Contract__r.Renewal_Notice_Expiration_Date__c;
            		if (row.Contract__c) row.RenewalTerm = row.Contract__r.Renewal_Term__c;
            row.marginChange = row.ExtensionMargin - row.priorMargin; 
            row.grossMarginChange = row.marginChange * row.Volume__c; 
            
             if(row.grossMarginChange == -0){
                row.grossMarginChange = 0 ;
            }
            if(row.priorMargin > row.ExtensionMargin){
                row.extMarginIcon = 'utility:arrowdown';
            }
            else if(row.priorMargin < row.ExtensionMargin){
                row.extMarginIcon = 'utility:arrowup';
            }
            else {
                row.extMarginIcon = 'utility:dash';
            };
            myData.push(row);
            		
                });
        
        console.log(myData);

        return myData;
    }

     ,
   sendPricingRequest: function(component, termExt){
       //quote only -- not for this UI: var quote = component.get("v.quote");
        //call function to create XML payload
        console.log('in sendPricingRequest');
       	console.log(JSON.stringify(termExt));
        var termExtList = [];
       	termExtList.push(termExt);
       
        console.log(termExtList);
        var Action = component.get("c.createPayload");
        Action.setParams({"listTermExt": termExtList} );
        Action.setCallback(this, function(response){
            
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS"){
                console.log('payload: '+response.getReturnValue());
                //---commented out in Subi's code: helper.updateLastPriceRequestDate(component);
                var eAction = component.get("c.makePostCalloutEndur");
                eAction.setParams({"payload": response.getReturnValue()} );
                eAction.setCallback(this, function(response){   
                    var state = response.getState();
                    if ( component.isValid() && (state === "SUCCESS") &&(response.getReturnValue() != 'ERROR: Pricing Refresh Timed Out') ){
                        
                        console.log('Endur response: '+JSON.parse(response.getReturnValue()) );
                        //ADD THIS TO APEX:
                        var pAction = component.get("c.ProcessQuoteResponse");
                        //requestType = "term Extension"
                        pAction.setParams({"XMLString": JSON.parse(response.getReturnValue()), "requestType":"Term Request" } );
                        pAction.setCallback(this, function(response){   
                            var state = response.getState();
                            if (component.isValid() && state === "SUCCESS" && response.getReturnValue()=='true'){
                                console.log('Processing response: '+response.getReturnValue());
                                var showToast = $A.get('e.force:showToast');
                                //set the title and message params
                                showToast.setParams(
                                    {
                                        'title': 'Success: ',
                                        'message': 'Price Refresh Complete: Refreshing Component',
                                        'type' : 'success'
                                    }
                                );
                                //fire the event
                                showToast.fire();
                                
                                this.getData(component, event, 'getTermExtensionsContractsLineItems', 'myData');
                            } else {
                                console.log('makePostCalloutEndur error: '+response.getReturnValue() );
                                var showToast = $A.get('e.force:showToast');
                                //set the title and message params
                                showToast.setParams(
                                    {
                                        'title': 'Error: ',
                                        'message': 'Process error: '+response.getReturnValue(),
                                        'type' : 'error'
                                    }
                                );
                                //fire the event
                                showToast.fire();
                            }
                        });
                        $A.enqueueAction(pAction);
                        
                        
                    } else {
                        console.log('makePostCalloutEndur error');
                        var showToast = $A.get('e.force:showToast');
                        //set the title and message params
                        showToast.setParams(
                            {
                                'title': 'Error: ',
                                'message': 'Request error: '+response.getReturnValue(),
                                'type' : 'error'
                            }
                        );
                        //fire the event
                        showToast.fire();
                    }
                });
                $A.enqueueAction(eAction);
            }  else {console.log('createPayload error');}
        });
        $A.enqueueAction(Action);
    }
    */
})