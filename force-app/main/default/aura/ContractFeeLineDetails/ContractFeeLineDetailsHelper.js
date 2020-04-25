({
    /*
	getData : function(component) {
		var dealFeeId = component.get("v.recordId");
        
        var articleURL = window.location.origin;
        
        
                var faction = component.get("c.getContractFeeLineData");
                faction.setParams({"dealFeeId": dealFeeId});
                faction.setCallback(this, function(response){
                    var feeLines = response.getReturnValue();
                    var state = response.getState();
                    console.log(feeLines);
                    if (component.isValid() && state === "SUCCESS"){
                        if (!$A.util.isEmpty(feeLines)){
                            var columns = [];
            
                            columns.push({label: 'Month', fieldName: 'NavId', type: 'url', sortable: false, initialWidth:125, typeAttributes: {label: { fieldName: 'contractMonth'}}},
                                         {label: 'Volume', fieldName: 'Fee_Contract_Volume__c', type: 'number', sortable: false, initialWidth:125, cellAttributes: { alignment: 'right'}});           
                            // add the applicable column type
                            if (!$A.util.isEmpty(feeLines[0].Fee__r) && feeLines[0].Fee__r.Flex_Option__c == 'float'){
                                columns.push({label: 'Cost', fieldName: 'Cost__c', type: 'text', sortable: false, initialWidth:125, cellAttributes: { alignment: 'right'}});
                            } else {
                                columns.push({label: 'Cost', fieldName: 'Cost__c', type: 'currency', sortable: false, initialWidth:125, cellAttributes: { alignment: 'right'}});
                            }
                            component.set("v.mycolumns", columns);
                            
                            
                            feeLines.forEach(function(fee){
                                if (fee.Id) {
                                    fee.NavId = articleURL+'/lightning/r/Line_Item_Fee__c/'+fee.Id+'/view';
                                }
                                if (!$A.util.isEmpty(fee.Line_Item__r) && fee.Line_Item__r.Contract_Month__c != ''){
                                    fee.contractMonth = fee.Line_Item__r.Contract_Month__c;
                                }
                                if (fee.Fee__r.Flex_Option__c == 'float'){
                                    fee.Cost__c = 'float';
                                }
                            });
                            component.set("v.mydata", feeLines);
                        }
                    }
                    
                });
                $A.enqueueAction(faction);
            
        
    }
    */
})