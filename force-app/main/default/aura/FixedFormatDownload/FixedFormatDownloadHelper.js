({
    /*
	doExport : function(component) {
		// get the Records [contact] list from 'ListOfContact' attribute 
		var me = this;
        var dataType;
        var recordId = component.get("v.recordId");
        var fileType = component.get("v.fileType");
        var stockData = component.get("v.mydata");
        var columns = component.get("v.mycolumns");
        //var show = component.get("v.show");
        
        if (fileType == 'NIPSCO Choice'){dataType = 'NipscoEnroll';}
        
        var action = component.get("c.prepareFixedFormatFileData");
        action.setParams({"recordId": recordId, "fileType": fileType});
        action.setCallback(this, function(response){
            var dataString = response.getReturnValue();
            
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS"){
                if (dataString == null || dataString == ''){return;}
                
                // ####--code to create a temp. <a> html tag [link tag] for download the file--####     
                var hiddenElement = document.createElement('a');
                hiddenElement.href = 'data:text/ftp;charset=utf-8,' + encodeURI(dataString);
                hiddenElement.target = '_self'; // 
                //hiddenElement.download = dataType + '.ftp';
                hiddenElement.download = me.getSaveFileName(dataType); // file Name
                document.body.appendChild(hiddenElement); // Required for FireFox browser
                hiddenElement.click(); // using click() js function to download the file
                document.body.removeChild(hiddenElement);
                component.set("v.exportComplete", true);
            } else {console.log(response.getError());}
        });
        $A.enqueueAction(action);
        
	},
    getSaveFileName : function(dataType){
        if (dataType == 'NipscoEnroll'){
            // return nipsco enroll file save name
            var saveName = 'signup.ftp_';
            var saveDate = new Date(Date.now());
            console.log(saveDate);
            var month = '';
            var day = '';
            var hour = '';
            var minute = '';
            var second = '';
            
            // get necessary leading zeros
            if (saveDate.getMonth() + 1 < 10){month = '0';}
            if (saveDate.getDate() < 10){day = '0';}
            if (saveDate.getHours() < 10){hour = '0';}
            if (saveDate.getMinutes() < 10){minute = '0';}
            if (saveDate.getSeconds() < 10){second = '0';}
            
            saveName += saveDate.getFullYear() + '-' + month + (saveDate.getMonth() + 1) + '-' + day + saveDate.getDate()
            	+ ' ' + hour + saveDate.getHours() + '-' + minute + saveDate.getMinutes() 
            	+ '-' + second + saveDate.getSeconds() + '.ftp';
            
            return saveName;
        }
    }
    */
})