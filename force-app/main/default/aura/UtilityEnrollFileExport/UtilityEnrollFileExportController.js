({
    /*
	doInit : function(component, event, helper) {
		component.set('v.mycolumns', [
				{label: 'Enroll #', fieldName: 'NavId', type: 'url',sortable: false,initialWidth:125, typeAttributes: {label: { fieldName: 'Name'}}},
            	{label: 'Premise', fieldName: 'PremiseId', type: 'url',sortable: false,initialWidth:200, typeAttributes: {label: { fieldName: 'premiseName'}}},
            	{label: 'Transport ID', fieldName: 'Transport_ID__c', type: 'text',sortable: false, initialWidth:150},
            	{label: 'Meter #', fieldName: 'Meter_Number__c', type: 'text',sortable: false, initialWidth:100},
            	{label: 'Pool ID', fieldName: 'Pool_ID__c', type: 'text',sortable: false, initialWidth:100},
            	{label: 'Eff Date', fieldName: 'todayText', type: 'text', sortable: false, initialWidth:100},
                {label: 'Type', fieldName: 'Type__c', type: 'text',sortable: false, initialWidth:75},
            ]);
    	
        helper.getData(component);
	},
    refresh : function(component, event, helper) {
    	helper.getData(component);
    },
    export : function(component, event, helper) {
        component.set("v.exportComplete", false);
        var exporter = component.find('exporter');
        if (!$A.util.isEmpty(exporter)){
            exporter.handleExport();
        }
    },
    process : function(component, event, helper) {
        var enrollments = component.get("v.mydata");
        
        if (!$A.util.isEmpty(enrollments) && enrollments.length > 0){
            // clear the dummy fields and update legit fields
            var processDate = new Date();
            var utcDate = $A.localizationService.formatDateUTC(processDate, 'yyyy-MM-dd');
            //var utcDate = $A.localizationService.formatDateTimeUTC(processDate);
            enrollments.forEach(function(enroll){
            	delete enroll.premiseName;
            	delete enroll.todayText;
            	
            	enroll.Process__c = false;
            	enroll.Processed_Date__c = utcDate;
            });
            // update the records as processed
            var action = component.get("c.updateNipscoEnrollmentStatus");
            action.setParams({"enrollments": enrollments});
            action.setCallback(this, function(response){
                var enrolls = response.getReturnValue();
                
                var state = response.getState();
                if (component.isValid() && state === "SUCCESS"){
                    component.set("v.exportComplete", false);
                    component.set("v.mydata", null);
                } else {console.log(response.getError());}
            });
            $A.enqueueAction(action);
    	}
    },
    */
})