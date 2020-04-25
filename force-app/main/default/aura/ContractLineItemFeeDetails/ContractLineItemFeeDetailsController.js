({
	doInit : function(component, event, helper) {
		component.set("v.mycolumns",[
            {label: 'Fee Type', fieldName: 'NavId', type: 'url', sortable: false, initialWidth:250, typeAttributes: {label: { fieldName: 'feeName'}}},
            //{label: 'Fee Type', fieldName: 'feeName', type: 'text', sortable: false, initialWidth:200, editable: false},
            {label: 'Fix/Float', fieldName: 'fixFloat', type: 'text', sortable: false, initialWidth:125, editable: false},
            {label: 'Value', fieldName: 'value', type: 'currency', sortable: false, initialWidth:75, editable: false}
        ]);
        
        // helper.getData(component);
	}
})