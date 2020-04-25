({
    /*
    uploadData : function(component, file, fileName){
        var recordId = component.get("v.recordId");
        var fileType = component.get("v.fileType");
        var articleURL = window.location.origin + '/lightning/r/';
        
        var qcAction = component.get("c.uploadEnrollmentData");
        qcAction.setParams({"data": file, "fileName": fileName, "fileType": fileType, "utilityId": recordId});
        qcAction.setCallback(this, function(response){
            var results = response.getReturnValue();
            console.log(results);
            var state = response.getState();
            console.log(state);
            if (component.isValid() && state === "SUCCESS"){
                if ($A.util.isEmpty(results) || results.length == 0){
                    alert('There was a problem processing the file.  This may be due to file being empty or containing data unrelated to premises in Salesforce.  Please review the file');
                } else {
                    results.forEach(function(row){
                        if (row.Id) row.NavId = articleURL+'Utility_Enrollment_Response__c/'+row.Id+'/view';
                        if (row.Premise__r){
                            row.premiseNavId = articleURL+'Premises__c/'+row.Premise__c+'/view';
                            row.premiseName = row.Premise__r.Premise_Nickname__c;
                            row.transportId = row.Premise__r.Transport_ID__c;
                            row.meterId = row.Premise__r.Meter_Number__c;
                        }
                    });
                    component.set("v.mydata", results);
                }
            } else {
                console.log(response.getError());
                alert('There was a problem processing the file.  Error: ' + response.getError());
            }
        });
        $A.enqueueAction(qcAction);
    },
    */
})