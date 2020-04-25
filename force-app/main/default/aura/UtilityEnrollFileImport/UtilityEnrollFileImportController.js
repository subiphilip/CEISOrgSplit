({
    /*
	doInit : function(component, event, helper) {
		component.set('v.mycolumns', [
				{label: 'Response', fieldName: 'NavId', type: 'url',sortable: false,initialWidth:115, typeAttributes: {label: { fieldName: 'Name'}}},
            	{label: 'Premise', fieldName: 'premiseNavId', type: 'url',sortable: false,initialWidth:200, typeAttributes: {label: { fieldName: 'premiseName'}}},
            	{label: 'Transport ID', fieldName: 'transportId', type: 'text',sortable: false, initialWidth:130},
            	{label: 'Meter #', fieldName: 'meterId', type: 'text',sortable: false, initialWidth:100},
            	{label: 'Eff Date', fieldName: 'Effective_Date__c', type: 'date-local', sortable: false, initialWidth:125},
                {label: 'Type', fieldName: 'Type__c', type: 'text',sortable: false, initialWidth:75},
            	{label: 'Status', fieldName: 'Status_Code__c', type: 'text',sortable: false, initialWidth:90},
            ]);
	},
    handleFilesChange : function(component, event, helper) {
        var files = event.getSource().get("v.files");
        //alert(files.length + ' files !!');
        var file = files[0];
        console.log(file);
        var fr = new FileReader();
        
        fr.onload = function() {
            var fileContents = fr.result;
    	    //var base64Mark = 'base64,';
            //var dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;

            //fileContents = fileContents.substring(dataStart);
        
    	    //helper.upload(component, file, fileContents);
    	    console.log(fileContents);
            if ($A.util.isEmpty(fileContents) || fileContents == ''){
                alert('Error:  The file is empty');
            } else {
            	helper.uploadData(component, fileContents, file.name);
            }
        };

        fr.readAsText(file);        
    },
    */
})