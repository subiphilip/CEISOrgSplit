({
    /*
	getData : function(component) {
		var itemId = component.get("v.recordId");
        var articleURL = window.location.origin;
        var mapping = [];
        var sysVars;
        
        // get system variables - non-dependent on other actions
        var sysAction = component.get("c.getCnISysVariables");
        sysAction.setCallback(this, function(response){
            sysVars = response.getReturnValue();
            
            var state = response.getState();
            if (component.isValid() && state=== "SUCCESS"){
                
                //component.set("v.sysVars", sysVars);
                
            } else {console.log(response);}
        });
        $A.enqueueAction(sysAction);
        
        // get field mapping
        var maction = component.get("c.getVolumetricFieldMapping");
        maction.setCallback(this, function(response){
            mapping = response.getReturnValue();
            
            if (component.isValid() && response.getState() === "SUCCESS"){
                
            }
            
        });
        $A.enqueueAction(maction);
        
        var action = component.get("c.getLineItemData");
        action.setParams({"itemId": itemId});
        action.setCallback(this, function(response){
            var item = response.getReturnValue();
            var state = response.getState();
            console.log(item);
            if (component.isValid() && state === "SUCCESS"){
                var masterList = [];
                var children = [];
                console.log(item);
                console.log(item.Line_Item_Fees__r);
                
                if (!$A.util.isEmpty(item.Line_Item_Fees__r)){
                    item.Line_Item_Fees__r.forEach(function (fee){
                        if (fee.Fee__r.Fee_Category__c == sysVars.FeeCategoryPrice__c && fee.Fee__r.Fee_Volume_Type__c == null){
                            if (fee.Fee__r.Fee_Type__r.Cost_Group__c == sysVars.FeeGroupNymex__c
                                    || fee.Fee__r.Fee_Type__r.Cost_Group__c == sysVars.FeeGroupBasis__c
                                    || fee.Fee__r.Fee_Type__r.Cost_Group__c == sysVars.FeeGroupPhyPrem__c){
                                if (fee.Include_in_Cost_Rollup_Direct__c){
                                    children.push({"NavId": articleURL+'/lightning/r/Line_Item_Fee__c/'+fee.Id+'/view', "feeName": fee.Fee__r.Fee_Type__r.Name, "fixFloat": "Fix", "value": fee.Cost__c});
                                } else {
                                    children.push({"NavId": articleURL+'/lightning/r/Line_Item_Fee__c/'+fee.Id+'/view', "feeName": fee.Fee__r.Fee_Type__r.Name, "fixFloat": "Float", "value": ""}); //fee.Fee__r.TC_Float_Desc__c
                                }
                            }
                        }
                    });
                    
                    var master = {"NavId": articleURL+'/lightning/r/Line_Item__c/'+item.Id+'/view', "feeName": "Cost", "fixFloat":"", "value": item.Cost__c, "_children": children};
                    masterList.push(master);
                    
                    children = [];
                    item.Line_Item_Fees__r.forEach(function (fee){
                        if (fee.Fee__r.Fee_Category__c == sysVars.FeeCategoryPrice__c && fee.Fee__r.Fee_Volume_Type__c == null){
                            if (fee.Fee__r.Fee_Type__r.Cost_Group__c == sysVars.FeeGroupMargin__c
                                || fee.Fee__r.Fee_Type__r.Cost_Group__c == sysVars.FeeGroupConsultant__c){
                                if (fee.Include_in_Cost_Rollup_Direct__c){
                                    children.push({"NavId": articleURL+'/lightning/r/Line_Item_Fee__c/'+fee.Id+'/view', "feeName": fee.Fee__r.Fee_Type__r.Name, "fixFloat": "Fix", "value": fee.Cost__c});
                                } else {
                                    children.push({"NavId": articleURL+'/lightning/r/Line_Item_Fee__c/'+fee.Id+'/view', "feeName": fee.Fee__r.Fee_Type__r.Name, "fixFloat": "Float", "value": ""}); //fee.Fee__r.TC_Float_Desc__c
                                }
                            }
                        }
                    });
                    
                    master = {"NavId": articleURL+'/lightning/r/Line_Item__c/'+item.Id+'/view', "feeName": "Price", "fixFloat":"", "value": item.Sales_Price__c, "_children": children};
                    masterList.push(master);
                    
                    // other fees
                    children = [];
                    item.Line_Item_Fees__r.forEach(function (fee){
                        if (fee.Fee__r.Fee_Category__c != sysVars.FeeCategoryPrice__c && fee.Fee__r.Fee_Volume_Type__c == null){                        
                            if (fee.Fee__r.Flex_Option__c == sysVars.FlexOptionFix__c){
                                children.push({"NavId": articleURL+'/lightning/r/Line_Item_Fee__c/'+fee.Id+'/view', "feeName": fee.Fee__r.Fee_Type__r.Name, "fixFloat": "Fix", "value": fee.Cost__c});
                            } else {
                                children.push({"NavId": articleURL+'/lightning/r/Line_Item_Fee__c/'+fee.Id+'/view', "feeName": fee.Fee__r.Fee_Type__r.Name, "fixFloat": "Float", "value": ""}); //fee.Fee__r.TC_Float_Desc__c
                            }
                        }
                    });
                    
                    if (children.length > 0){
                        master = {"NavId": articleURL+'/lightning/r/Line_Item__c/'+item.Id+'/view', "feeName": "Other Fees", "fixFloat":"", "value": "", "_children": children};
                    	masterList.push(master);
                    }
                    
                    // volumetric fees
                    children = [];                    
                    mapping.forEach(function(field){
                        var child = {};
                        var grandchildren = [];
                        item.Line_Item_Fees__r.forEach(function (fee){
                            if (fee.Fee__r.Fee_Volume_Type__c != null){
                                if (field.MasterLabel == fee.Fee__r.Fee_Volume_Type__c){
                                    // line item fee matches this volumetric fee field name
                                    if (fee.Fee__r.Flex_Option__c == 'fix'){
                                        grandchildren.push({"NavId": articleURL+'/lightning/r/Line_Item_Fee__c/'+fee.Id+'/view', "feeName": fee.Fee__r.Fee_Type__r.Name, "fixFloat": "fix", "value": fee.Cost__c});
                                    } else {
                                        grandchildren.push({"NavId": articleURL+'/lightning/r/Line_Item_Fee__c/'+fee.Id+'/view', "feeName": fee.Fee__r.Fee_Type__r.Name, "fixFloat": "Float", "value": ""}); //fee.Fee__r.TC_Float_Desc__c
                                    }
                                }                                
                            }
                        });
                        if (grandchildren.length > 0){
                            child = {"NavId": articleURL+'/lightning/r/Line_Item__c/'+item.Id+'/view', "feeName": field.MasterLabel, "fixFloat":"vol: "+String(item[field.Field_API_Name__c]), "value": "", "_children": grandchildren};
                            children.push(child);
                        }
                    });                    
                    
                    if (children.length > 0){
                        master = {"NavId": articleURL+'/lightning/r/Line_Item__c/'+item.Id+'/view', "feeName": "Volumetric Fees", "fixFloat":"", "value": "", "_children": children};
                    	masterList.push(master);
                    }
                    
                    // volumetric fees
                    /*
                    children = [];
                    item.Line_Item_Fees__r.forEach(function (fee){
                        if (fee.Fee__r.Fee_Volume_Type__c != null){
                            var sVolume = "";
                            for (var i = 0; i < mapping.length; i++) {
                                if (fee.Fee__r.Fee_Volume_Type__c == mapping[i].MasterLabel){
                                    sVolume = String(item[mapping[i].Field_API_Name__c]);
                                    break;
                                }
                            }
                            console.log(sVolume);
                            if (fee.Fee__r.Flex_Option__c == 'fix'){
                                children.push({"NavId": articleURL+'/lightning/r/Line_Item_Fee__c/'+fee.Id+'/view', "feeName": fee.Fee__r.Fee_Type__r.Name, "fixFloat": sVolume, "value": fee.Cost__c});
                            } else {
                                children.push({"NavId": articleURL+'/lightning/r/Line_Item_Fee__c/'+fee.Id+'/view', "feeName": fee.Fee__r.Fee_Type__r.Name, "fixFloat": sVolume, "value": ""});
                            }
                        }
                    });
                    
                    if (children.length > 0){
                        master = {"NavId": articleURL+'/lightning/r/Line_Item__c/'+item.Id+'/view', "feeName": "Volumetric Fees", "fixFloat":"", "value": "", "_children": children};
                    	masterList.push(master);
                    }
                    */
                    /*
                    // make children of each cost category
                    // NYMEX
                    item.Line_Item_Fees__r.forEach(function (fee){
                        if (fee.Fee__r.Fee_Type__r.Cost_Group__c == '01 - NYMEX'){
                            if (fee.Include_in_Cost_Rollup_Direct__c){
                                children.push({"feeName": fee.Fee__r.Fee_Type__r.Name, "fixFloat": "Fix", "value": fee.Cost__c});
                            } else {
                                children.push({"feeName": fee.Fee__r.Fee_Type__r.Name, "fixFloat": fee.Fee__r.TC_Float_Desc__c, "value": ""});
                            }
                        }
                    });
                    if (children.length > 0){
                        var master = {"feeName": "Nymex", "fixFloat":"", "value": item.Nymex_Rollup__c, "_children": children};
                        masterList.push(master);
                    }
                    
                    // Fin Basis
                    children = [];
                    item.Line_Item_Fees__r.forEach(function (fee){
                        if (fee.Fee__r.Fee_Type__r.Cost_Group__c == '02 - FinBasis'){
                            if (fee.Include_in_Cost_Rollup_Direct__c){
                                children.push({"feeName": fee.Fee__r.Fee_Type__r.Name, "fixFloat": "Fix", "value": fee.Cost__c});
                            } else {
                                children.push({"feeName": fee.Fee__r.Fee_Type__r.Name, "fixFloat": fee.Fee__r.TC_Float_Desc__c, "value": ""});
                            }
                        }
                    });
                    if (children.length > 0){
                        var master = {"feeName": "Fin Basis", "fixFloat":"", "value": item.Fin_Basis_Rollup__c, "_children": children};
                        masterList.push(master);
                    }
                    
                    // Phy Prem
                    children = [];
                    item.Line_Item_Fees__r.forEach(function (fee){
                        if (fee.Fee__r.Fee_Type__r.Cost_Group__c == '03 - PhyPrem'){
                            if (fee.Include_in_Cost_Rollup_Direct__c){
                                children.push({"feeName": fee.Fee__r.Fee_Type__r.Name, "fixFloat": "Fix", "value": fee.Cost__c});
                            } else {
                                children.push({"feeName": fee.Fee__r.Fee_Type__r.Name, "fixFloat": fee.Fee__r.TC_Float_Desc__c, "value": ""});
                            }
                        }
                    });
                    if (children.length > 0){
                        var master = {"feeName": "Phy Prem", "fixFloat":"", "value": item.Phy_Prem_Rollup__c, "_children": children};
                        masterList.push(master);
                    }
                    
                    masterList.push({"feeName": "Cost", "fixFloat":"", "value": item.Cost__c});
                    
                    // Margin
                    children = [];
                    item.Line_Item_Fees__r.forEach(function (fee){
                        if (fee.Fee__r.Fee_Type__r.Cost_Group__c == '04 - Margin'){
                            if (fee.Include_in_Cost_Rollup_Direct__c){
                                children.push({"feeName": fee.Fee__r.Fee_Type__r.Name, "fixFloat": "Fix", "value": fee.Cost__c});
                            } else {
                                children.push({"feeName": fee.Fee__r.Fee_Type__r.Name, "fixFloat": fee.Fee__r.TC_Float_Desc__c, "value": ""});
                            }
                        }
                    });
                    if (children.length > 0){
                        var master = {"feeName": "Margin", "fixFloat":"", "value": item.Total_Margin_Rollup__c, "_children": children};
                        masterList.push(master);
                    }
                    
                    // Consultant
                    children = [];
                    item.Line_Item_Fees__r.forEach(function (fee){
                        if (fee.Fee__r.Fee_Type__r.Cost_Group__c == '05 - Consultant'){
                            if (fee.Include_in_Cost_Rollup_Direct__c){
                                children.push({"feeName": fee.Fee__r.Fee_Type__r.Name, "fixFloat": "Fix", "value": fee.Cost__c});
                            } else {
                                children.push({"feeName": fee.Fee__r.Fee_Type__r.Name, "fixFloat": fee.Fee__r.TC_Float_Desc__c, "value": ""});
                            }
                        }
                    });
                    if (children.length > 0){
                        var master = {"feeName": "Consultant", "fixFloat":"", "value": item.Consultant_Fee_Rollup__c, "_children": children};
                        masterList.push(master);
                    }
                    
                    masterList.push({"feeName": "Price", "fixFloat":"", "value": item.Sales_Price__c});
                    
                    console.log(masterList);
                    component.set("v.mydata", masterList);
                    
                    // expand all rows
                    var tree = component.find('mytree');
                    tree.expandAll();
                }
            }
        });
        $A.enqueueAction(action);
    }
    */
})