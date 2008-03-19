var collapse_symbol = '<img src="/resources/forums/Collapse16.gif" width="16" height="16" ALT="-" border="0">';
var expand_symbol = '<img src="/resources/forums/Expand16.gif" width="16" height="16" ALT="+" border="0">';
var replies = new Array();

// toggle visibility

function getid(id) {
       if(document.getElementById)
		return document.getElementById(id);
       else if(document.all)
		return document.all(id);
	return false;
}

function toggle( targetId, state ){
        var symbol;
  		var content = getid( 'content'+targetId );
  		var link = getid( 'toggle'+targetId );
        if(!link || !content) return;

        var s;
    	if(state != null)
	    	s = state;
        else if (content.className == "dynexpanded") {
            s = 0;
	} else {
            s = 1;
	}
        if (s) {
            content.className = "dynexpanded";
            symbol = collapse_symbol;
        } else {
            content.className = "dyncollapsed";
            symbol = expand_symbol;
        }

        if(link.innerHTML)
            link.innerHTML = symbol;
        else if(link.appendChild) {
            while(link.hasChildNodes())
                link.removeChild(link.firstChild);
            link.appendChild(document.createTextNode(symbol));
	    }
}

function toggleList(a,state) {
	if(!a.length) return;
	for(var i = 0; i < a.length; ++i) {
        toggle(a[i], state);
	}
}
 
