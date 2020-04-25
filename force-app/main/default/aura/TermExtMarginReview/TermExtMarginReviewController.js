({
    /*
    doInit : function(component, event, helper) {		                
        console.log('init');
        
        var profileList = [];
        profileList.push('CES Sales Manager Q219');
        profileList.push('CES Standard User Q219');
        //REMOVE THIS FOR PRODUCTION:
        profileList.push('System Administrator');
        
		console.log(profileList);
  
        var action = component.get("c.getUserProfile");
        
              
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log(response.getReturnValue());
                var profileInfo = response.getReturnValue();
                var profileString = profileInfo[0].Profile.Name;
                
                
                if (
                    //profiles for margin tab == sales and sys admin
                    profileString == 'CES Sales Manager Q219'
                    || profileString == 'CES Standard User Q219'//this is also sales - confirmed with Ben McCann 9-28-18
                    || profileString == 'System Administrator'
                )
                {
                                     
                    component.set('v.myColumns', [
						{label: 'Contract', fieldName: 'ContractUrl', type: 'url',sortable: true,initialWidth:110, typeAttributes: {label: { fieldName: 'ContractName'}}},                                	
						{label: 'Sales Rep', fieldName: 'SalesRepName', type: 'text', sortable: true, initialWidth:150},
                        {label: 'Refresh Price', type:  'button',initialWidth:120, typeAttributes: {iconName: 'action:refresh', label: '', name: 'refreshPrice', title: 'RefreshPrice', disabled: false, value: 'test' } },
                        {label: 'Last Refresh Date', fieldName: 'lastRefreshDate', type: 'text', sortable: true, initialWidth:180},
                        {label: 'Prior Margin', fieldName: 'priorMargin', type: 'number', sortable: true, initialWidth:150},
                        {label: 'Ext Margin', fieldName: 'ExtensionMargin', type: 'number', sortable: true, initialWidth:120, cellAttributes: { iconName: {fieldName: 'extMarginIcon'}}},
                        {label: 'Margin Change', fieldName: 'marginChange', type: 'number', sortable: true, initialWidth:150, cellAttributes: { iconName: {fieldName: 'extMarginIcon'}}},
                        {label: 'Gross Margin Change', fieldName: 'grossMarginChange', type: 'currency', sortable: true, initialWidth:200},
                        //{label: 'Approve', type:  'button',initialWidth:80, typeAttributes: {iconName: 'action:approval', label: '', name: 'approve', title: 'Approve', disabled: false, value: 'test' } },
                        //{label: 'Reject', type:  'button',initialWidth:80, typeAttributes: {iconName: 'action:close', label: '', name: 'reject', title: 'Reject', disabled: false, value: 'test' } },
                        
                        ]);
                        }
                        else{
                                             
                        component.set('v.myColumns', [
                        
                        {label: 'Contract', fieldName: 'ContractUrl', type: 'url',sortable: true,initialWidth:110, typeAttributes: {label: { fieldName: 'ContractName'}}},                                	
                        {label: 'Sales Rep', fieldName: 'SalesRepName', type: 'text', sortable: true, initialWidth:150},
                        //user cannot refresh price	
                        //{label: 'Refresh Price', type:  'button',initialWidth:120, typeAttributes: {iconName: 'action:refresh', label: '', name: 'refreshPrice', title: 'RefreshPrice', disabled: false, value: 'test' } },
                        {label: 'Last Refresh Date', fieldName: 'lastRefreshDate', type: 'text', sortable: true, initialWidth:180},
                        {label: 'Prior Margin', fieldName: 'priorMargin', type: 'number', sortable: true, initialWidth:150},
                        {label: 'Ext Margin', fieldName: 'ExtensionMargin', type: 'number', sortable: true, initialWidth:120, cellAttributes: { iconName: {fieldName: 'extMarginIcon'}}},
                        //user cannot reject or approve contract   
                        // {label: 'Approve', type:  'button',initialWidth:80, typeAttributes: {iconName: 'action:approval', label: '', name: 'reject', title: 'Approve', disabled: false, value: 'test' } },
                        // {label: 'Reject', type:  'button',initialWidth:80, typeAttributes: {iconName: 'action:close', label: '', name: 'reject', title: 'Reject', disabled: false, value: 'test' } },
                        
                    ]);
                    
                }
                
                
                
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
            }
        }));
        $A.enqueueAction(action);
        
        
        helper.getData(component, event, 'getTermExtensionsContractsLineItems', 'myData');
        
        
        
        console.log(component.get("v.myData"));
        
       
        console.log(component.get("v.myColumns"));
        
        
       
    },
    
    getSelectedName: function (component , event) {
        
        var selectedRows = event.getParam('selectedRows');
        component.set("v.selectedRows",selectedRows);
    },
    // Client-side controller called by the onsort event handler
   
    handleRowAction: function (component, event, helper) {
        //UPDATE THIS 
        
        var action = event.getParam('action');
        var row = event.getParam('row');
        console.log('row button was clicked:' + action.name); console.log(JSON.stringify(row));
        switch (action.name) {
                
            case 'refreshPrice':
                //get the system showToast event
                var showToast = $A.get('e.force:showToast');
                //set the title and message params
                showToast.setParams(
                    {
                        'title': 'Term Extension Price Refresh ',
                        'message': 'Refresh Submitted',
                        'type' : 'info'
                    }
                );
                //fire the event
                showToast.fire();
                console.log('row');
                console.log(row);
                
                //call helper: sendPricingRequest
                //pass row into termExt variable as part of sendPricingRequest
                helper.sendPricingRequest(component,row);
                break;
            case 'approve':
                var rowList = [];
                rowList.push(row);
                console.log(rowList);
                 var action = component.get('c.approveTermExtensions');
        
        action.setParams({
            "termExt": rowList
            //this component is querying contracts expiring today --- category = expired
            , "tabId" : 'margin'
        });
        
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('Successfully completed: approveTermExtensions');
                console.log(response.getReturnValue());
                helper.getData(component, event, 'getTermExtensionsContractsLineItems', 'myData');
                
               
            } else if (state === "ERROR") {
                var errors = response.getError();
                                var saveResultRaw = errors[0].message;
                                console.error(errors);
                                var showToast = $A.get('e.force:showToast');
                                //set the title and message params
                                showToast.setParams(
                                    {
                                        'title': 'Error ',
                                        'message': 'Processing error: '+ saveResultRaw,
                                        'type' : 'error'
                                    }
                                );
                                //fire the event
                                showToast.fire();
            }
        }));
        $A.enqueueAction(action);
                	break;
            case 'reject':
                //alert('Showing Details: ' + JSON.stringify(row));
                var action = component.get('c.rejectTermExtensions');
                
                action.setParams({
                    "recordToUpdate": row
                    //this component is querying contracts expiring today --- category = expired
                    , "tabId" : 'margin'
                });
                
                action.setCallback(this, $A.getCallback(function (response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        console.log('Successfully completed: rejectTermExtensions');
                        console.log(response.getReturnValue());
                        helper.getData(component, event, 'getTermExtensionsContractsLineItems', 'myData');
                        
                     
                        
                    } else if (state === "ERROR") {
                        var errors = response.getError();
                                var saveResultRaw = errors[0].message;
                                console.error(errors);
                                var showToast = $A.get('e.force:showToast');
                                //set the title and message params
                                showToast.setParams(
                                    {
                                        'title': 'Error ',
                                        'message': 'Processing error: '+ saveResultRaw,
                                        'type' : 'error'
                                    }
                                );
                                //fire the event
                                showToast.fire();
                    }
                }));
                $A.enqueueAction(action);
                
                
                
                
                break;
                
                
        }   
        
    }
    ,
    
    renewSelected : function (component,event,helper){
        
        var selectedRows = component.get("v.selectedRows");
        
       
        
    }
  
    */
    
})