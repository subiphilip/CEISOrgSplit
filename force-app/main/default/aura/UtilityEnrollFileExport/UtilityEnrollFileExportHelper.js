({
    /*
	getData : function(component) {
		var recordId = component.get("v.recordId");
        var articleURL = window.location.origin + '/lightning/r/';
        
        component.set("v.exportComplete", false);
        
        var action = component.get("c.getNipscoEnrollmentsForExport");
        action.setParams({"utilityId": recordId});
        action.setCallback(this, function(response){
            var enrolls = response.getReturnValue();
            
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS"){
                enrolls.forEach(function(row){
                    if (row.Id) row.NavId = articleURL+'Utility_Enrollment__c/'+row.Id+'/view';
                    if (row.Premise__r){
                        row.PremiseId = articleURL+'Premises__c/'+row.Premise__c+'/view';
                        row.premiseName = row.Premise__r.Premise_Nickname__c;
                        row.transportId = row.Premise__r.Transport_ID__c;
                        row.todayText = 'Today';
                    }
                });
                component.set("v.mydata", enrolls);
            } else {console.log(response.getError());}
        });
        $A.enqueueAction(action);
    }
    */
})