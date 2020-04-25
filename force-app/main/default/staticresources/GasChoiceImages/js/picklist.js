//// picklists & dependent Picklists ////
function picklist( id, picklist_id, controller_id, initialValue, attributes, nullable, isValid, filter)
{
    if(id) {
        if(!this.sanityCheck()) return null;
        this.setup(id,picklist_id,controller_id,initialValue,attributes,nullable,isValid,filter);

        this.nonelabel = pl.noneLabel;
        this.nalabel = pl.naLabel;
    }
}

// members

picklist.prototype.sanityCheck = function()
{
    if(picklist.loadFailure) return false;
    if(typeof(pl) == 'undefined') {
        wait(1000);
        if (typeof(pl) != 'undefined'){
            return true;
        }
        picklist.loadFailure = true;
        window.location.replace(UserContext.getUrl("/ex/errorduringprocessing.jsp?retURL=")+escape(window.location.pathname+window.location.search));
        return false;
    }
    return true;
}

picklist.prototype.setup = function( id, picklist_id, controller_id, initialValue, attributes, nullable, isValid, filter)
{
    this.id = id;
    this.attributes = attributes;
    this.values = this.filterValues(picklist_id, filter);
    this.initialValue = initialValue;
    // controller is null for "normal" pickists
    this.controller_id = controller_id;
    if( controller_id != null )
        this.mapping = eval( "pl.map_"+picklist_id );
    else
        this.mapping = {};
    this.firstRound = true;
    this.nullable = nullable;
    this.isValid = isValid;
    this.loaded = false;

    if( picklist.picklists == null ) {
        // add an onLoad handler if necessary
        picklist.picklists = {};
        var oldOnLoad = window.onload;
        // form a closure
        window.onload = function() {
            picklist.initAll();
            if (oldOnLoad) {
                oldOnLoad();
            }
        }
    }
    picklist.picklists[this.id] = this;
    this.labelEl = null; // to be set later
}

picklist.prototype.filterValues = function(picklist_id, filter) {
    var allVals = pl["vals_" + picklist_id];
    if (filter) {
        var filterVals = pl["filter_" + picklist_id];
        var values = [];
        for (var i = 0; i < allVals.length; i++) {
            if (filter == filterVals[i]) {
                values.push(allVals[i * 2]);
                values.push(allVals[i * 2 + 1]);
            }
        }
        return values;
    } else {
        return allVals;
    }
}


picklist.prototype.onLoad = function()
{
    if( this.loaded ) return;
    this.loaded = true;
    // make sure the controller is loaded first if necessary
    if (picklist.picklists[this.controller_id]) picklist.picklists[this.controller_id].onLoad();

    var me = getElementByIdCS(this.id);

    // setup the controller
    this.container = me.parentNode;
    var controller = null;
    if (this.isDependent()) {
        // check if the controller is on the page
        controller = getElementByIdCS(this.controller_id);
    }
    if (controller) {
        if (controller.dependents)
              controller.dependents.push(this);
        else {
            controller.dependents = [this];
            controller.getControllingValue = picklist.getControllingValue;
            if(controller.type == 'checkbox') {
                controller.dplOldHandler = controller.onclick;
                controller.onclick = picklist.onControllerChange;
            } else {
                controller.dplOldHandler = controller.onchange;
                controller.onchange = picklist.onControllerChange;
            }
        }
        // initial generation
        this.generate(controller.getControllingValue());
    } else {
        this.generate(null);
    }
}

picklist.prototype.isDependent = function()
{
    return this.controller_id != null;
}
picklist.prototype.condRequired = function(e,condOn) {
    if(!e || this.nullable) return;

    var oldStyle = condOn?/requiredInput/:/condRequiredInput/
    var newStyle = condOn?"condRequiredInput":"requiredInput"

    while (e && !oldStyle.test(e.className)){
        e = e.parentNode;
    }
    if(e) {
        e.className = e.className.replace(oldStyle,newStyle);
    }
}

picklist.prototype.addOption = function(list,val,text,idx) {
    var o = new Option(text,val);
    try {
        list.add(o,list.options[idx]);
    } catch(ex) {
        // IE
        list.add(o,idx);
    }
}

picklist.prototype.unescape = function(v) {
    v = v.replace(/\&quot;/g, '"');
    v = v.replace(/\&#39;/g, '\'');
    v = unescapeHTML(v);
    return v;
}

picklist.prototype.generate = function( v ) {
    var me = this.container.firstChild;
    var lastValue = me.value==picklistNAMarker?'':me.value;

    var res = [];

    res.push("<select "+this.attributes+">");
    var map = new Bitset(this.mapping[v]);

    var i = 0;
    var empty = true;
    // generate a string for performance
    var c1 = "<option value=\"";
    var c2 = "\">";
    for( i=0;i<this.values.length;i+=2 ) {
        if( this.isDependent() && !map.testBit(i/2) ) continue;
        empty = false;
        res.push(c1,this.values[i],c2,this.values[i+1]);
    }
    res.push("</select>");

    this.container.innerHTML = res.join('');

    var newMe = this.container.firstChild;

    newMe.value = lastValue;
    var found = (lastValue != '' && newMe.value == lastValue);
    // add a "fake" entry if the page had an initial (now invalid) value
    // except when initialValue is the same as picklistNAMarker (W-1327650)
    if( this.firstRound && !found && this.initialValue[0] != "" && this.initialValue[0] != picklistNAMarker) {
        lastValue = this.unescape(this.initialValue[0]);
        this.addOption(newMe,lastValue,this.unescape(this.initialValue[1]),0);
        newMe.value = lastValue;
        found = (lastValue != '' && newMe.value == lastValue);
    }
    // need to add an "empty" label?
    if( this.isDependent() && empty ) this.addOption(newMe,picklistNAMarker,this.nonelabel,0);
    else if( this.nullable || (newMe.options.length!=1 && !found) ) this.addOption(newMe,'',this.nonelabel,0);

    if(this.isDependent()) {
        this.condRequired(newMe,empty);
        this.condRequired(this.labelEl,empty);
    }

    newMe.selectedIndex = 0; // for FireFox
    newMe.value = lastValue;
    if(newMe.value != lastValue || lastValue == '') newMe.selectedIndex = 0; // for IE

    newMe.dependents = me.dependents;
    newMe.onchange = me.onchange;
    newMe.onclick = me.onclick;
    newMe.getControllingValue = me.getControllingValue;
    newMe.dplOldHandler = me.dplOldHandler;

    if (!this.firstRound && (lastValue != '' || (lastValue == '' && newMe.value != picklistNAMarker)) &&!found) {
        //the only time generation will cause a real value change is if there was something
        //selected before and it couldn't be found now
        if (newMe.dependents) {
            picklist.onControllerChange.apply(newMe);
        } else if (newMe.dplOldHandler) {
            newMe.dplOldHandler();
        }
    }

    if(empty && newMe.options.length <=1) this.disable();
    this.firstRound = false;
}

picklist.prototype.disable = function()
{
    this.container.firstChild.disabled = true;

    // hidden element to post the value
    var val = document.createElement("input"); val.type = "hidden";
    val.name = this.id; val.value = this.isDependent()?picklistNAMarker:'';
    this.container.appendChild(val);
}

function picklistForInlineEditing( id, picklist_id, controller_id, initialValue, attributes, nullable, isValid, filter, onGenerate){
    if(id) {
        if(!this.sanityCheck()) return null;
        this.onGenerate = onGenerate;
        this.setup(id,picklist_id,controller_id,initialValue,attributes,nullable,isValid,filter);

        this.nonelabel = pl.noneLabel;
        this.nalabel = pl.naLabel;

    }
}
picklistForInlineEditing.prototype = new picklist;

picklistForInlineEditing.prototype.generate = function( v ) {
    picklist.prototype.generate.call(this, v);
    if(this.onGenerate && typeof this.onGenerate === 'function'){
        this.onGenerate.apply(this, [this]);
    }
}

function multiPicklist( id, picklist_id, controller_id, initialValue, attributes, title, size, nullable, errorMsg, baseTabIndex )
{
    if(!this.sanityCheck()) return null;

    this.setup(id,picklist_id,controller_id,initialValue,attributes,nullable,errorMsg,null);
    this.selectedLabel = pl.selectedLabel;
    this.availableLabel = pl.availableLabel;
    this.nalabel = pl.naLabel;

    this.size = size;
    // TODO:  W-891374 - temporary isolated workaround until Mozilla fixes this:
    // https://bugzilla.mozilla.org/show_bug.cgi?id=257731
    if (this.size < 4) {
        if (navigator.userAgent.indexOf("Firefox/")!=-1 && navigator.platform.indexOf("Mac")!=-1) {
            this.size = 4;
        }
    }

    this.baseTabIndex = baseTabIndex;
    this.title = title;
}

multiPicklist.prototype = new picklist;

multiPicklist.prototype.getSelectMap = function(values)
{
    var res = {};
    for( var i=0;i<values.length;i+=2 )
       res[values[i]] = values[i+1];
    return res;
}

multiPicklist.prototype.getSelectedValue = function()
{
    if( this.firstRound ) {
        return this.initialValue;
    } else {
        var res = [];
        var selected = getElementByIdCS(this.id+"_selected").options;
        var options = getElementByIdCS(this.id).options;
        for( var i=0;i<selected.length;i++ ) {
            res.push(options[parseInt(selected[i].value)].value.replace(/(["])/g,"&quot;"));
            res.push(selected[i].text);
        }
        return res;
    }
}

multiPicklist.prototype.generate = function(v)
{
    var main = [];
    var selected = this.getSelectedValue();
    var selectMap = this.getSelectMap(selected);
    var notFound = this.getSelectMap(selected);
    var map = new Bitset(this.mapping[v]);

    // do it all in one loop!
    main.push("<select "); main.push(this.attributes); main.push(">");
    main.push(""); // placeholder == 3
    var empty = true;
    for (var i = 0; i < this.values.length; i+=2) {
        var value = this.values[i];
        if( this.isDependent() && !map.testBit(i/2) ) continue;
        main.push("<option value=\"" + value + "\"");
        empty = false;
        if (selectMap[value]) {
            main.push(" selected");
            delete notFound[value];
        }
        main.push(">");
        main.push(this.values[i+1]);
    }
    // do not create "selected" entry if intialValue is the same as picklistNAMarker (W-1327650)
    if(this.isDependent() && empty && this.initialValue[0] != picklistNAMarker) main.push("<option value='"+picklistNAMarker+"' selected>");
    main.push("</select>");
    if( this.firstRound ) {
        var temp = [];
        for( var i in notFound ) {
           temp.push("<option value=\""+i+"\" selected>");
           temp.push(notFound[i]);
        }
        main[3]=temp.join('');
    }

    var oldElement = getElementByIdCS(this.id);
    var lastValue = oldElement.value == picklistNAMarker ? '' : oldElement.value;
    //get onchange from old element
    var oldOnchange = oldElement.onchange;

    var container = oldElement.parentNode;
    container.innerHTML = main.join('');

    var newElem = getElementByIdCS(this.id);
    if (oldOnchange) {
        //write onchange to new element
        newElem.onchange = oldOnchange;
    }

    if(this.isDependent()) {
        this.condRequired(container.firstChild,empty);
        this.condRequired(this.labelEl,empty);
    }

    this.displaySelectElement(map,selectMap,notFound,true,empty,this.baseTabIndex+2);
    this.displaySelectElement(map,selectMap,notFound,false,empty,this.baseTabIndex);
    //MultiSelectPicklist.loadMSP(this.id);

    if (newElem.onchange && this.isDependent() && !this.firstRound && (lastValue != '' || (lastValue == '' && newMe.value != picklistNAMarker)) && newElem.value != lastValue) {
        newElem.onchange();
    }

    this.firstRound = false;
}

multiPicklist.prototype.displaySelectElement = function(map,selectMap,notFound,selected,empty,tabIndex)
{
    var methodName = selected ? "MultiSelectPicklist.handleMSPUnSelect" : "MultiSelectPicklist.handleMSPSelect";
    var label = empty ? this.nalabel : (selected ? this.selectedLabel : this.availableLabel);
    var idString = this.id+(selected ? "_selected" : "_unselected");

    var out = [];

    out.push("<select multiple=\"multiple\" size=\"" + this.size + "\" id=\"" + idString + "\" ");
    if (this.baseTabIndex > -1){
        if(typeof tabIndex == "undefined"){
            tabIndex = this.baseTabIndex;
        }
        out.push(" tabIndex=\"" + tabIndex + "\" ");
    }
    out.push("title=\"" + this.title + " - "  + label + "\" ");
    out.push("ondblclick=\"" + methodName + "('" + this.id + "');\" >");

    out.push("<optgroup style=\"font-size:9px;text-decoration:none;\" label=\"" + label + "\">");
    if( isFirefox ) out.push("</optgroup>");
    var offset = 0;
    if( this.firstRound ) {
        for(var i in notFound) {
        	// skip if notFound is the same as picklistNAMarker (W-1327650)
            if( selected && notFound[i] != picklistNAMarker && typeof notFound[i] != 'function') {
                out.push("<option value=\""+ offset++ +"\">");
                out.push(notFound[i]);
            } else
                offset++;
        }
    }
    for (var i = 0, j=offset-1; i < this.values.length; i+=2) {
        if( this.isDependent() && !map.testBit(i/2) ) continue;
        j++; // this is the index into the main list
        if ((selectMap[this.values[i]]!=undefined) != selected) continue;

        out.push("<option value=\"" + j + "\">");
        out.push(this.values[i+1]);
    }
    if( !isFirefox ) out.push("</optgroup>");
    out.push("</select>");
    getElementByIdCS( idString ).parentNode.innerHTML = out.join('');
}

// statics

picklist.loadFailure = false;
picklist.picklists = null;
picklist.initialized = false;
picklist.initAll = function() {
    if(this.initialized || this.picklists == null) return;
    this.initialized = true;
    var labels = document.getElementsByTagName("label");
    for( var i=0;i<labels.length;i++ ) {
        var pl = this.picklists[labels[i].htmlFor];
        if(pl) pl.labelEl = labels[i];
    }
    for( var i in this.picklists ) {
        if(this.picklists[i].onLoad != null){
            this.picklists[i].onLoad();
        }
    }
}

picklist.getControllingValue = function() {
    return (this.type == 'checkbox'?(this.checked?"1":"0"):this.value);
}
picklist.onControllerChange = function() {
    if(this.dplOldHandler) this.dplOldHandler.apply(this,arguments);
    for (var i=0;i<this.dependents.length;i++) {
        this.dependents[i].generate(this.getControllingValue());
    }
}

/////// simple BASE 64 stuff ///////

function Bitset( str )
{
    if( typeof(str) != "string" ) str = "";
    Bitset.init();
    this.data = str.split('');
    this.trim();
}

// members
Bitset.prototype.testBit = function( n )
{
    var i = Math.floor(n/6);
    if (i >= this.data.length)
        return false;
    else
        return ((Bitset.codes[this.data[i]] & (0x20 >> (n % 6))) != 0);
}
Bitset.prototype.setBit = function(n) {
    var i = Math.floor(n/6);
    this.pad(i);
    this.data[i]=Bitset.alphabet[Bitset.codes[this.data[i]] | (0x20 >> (n % 6))];
}
Bitset.prototype.clearBit = function(n) {
    var i = Math.floor(n/6);
    if(i<this.data.length) {
        this.data[i]=Bitset.alphabet[Bitset.codes[this.data[i]] & (0xff ^ (0x20 >> (n % 6)))];
        this.trim();
    }
}
Bitset.prototype.toString = function() {
    return this.data.join('');
}
// remove trailing 0's
Bitset.prototype.trim = function() {
    for(var i=this.data.length-1;i>=0;i--) {
        if(this.data[i]!=Bitset.alphabet[0]) break;
    }
    this.data.splice(i+1,this.data.length);
}
// pad with leading 0's if necessary
Bitset.prototype.pad = function(n) {
    var size = this.data.length;
    for (var i=0; i<=n-size; i++)
        this.data.push(Bitset.alphabet[0]);
}
Bitset.prototype.length = function() {
    return this.data.length;
}
// statics

Bitset.initialized = false;

Bitset.init = function()
{
    if( !Bitset.initialized ) {
        Bitset.initialized = true;
        Bitset.alphabet = [
          'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P',
          'Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f',
          'g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v',
          'w','x','y','z','0','1','2','3','4','5','6','7','8','9','+','/'
        ];

        Bitset.codes = [];
        for (var i=0; i < Bitset.alphabet.length; i++)
          Bitset.codes[Bitset.alphabet[i]] = i;
    }
}
