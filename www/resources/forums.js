var collapse_symbol = '<img src="/resources/forums/Collapse16.gif" width="16" height="16" ALT="-" border="0">';var expand_symbol = '<img src="/resources/forums/Expand16.gif" width="16" height="16" ALT="+" border="0">';var replies = new Array();// toggle visibilityfunction getid(id) {       if(document.getElementById)		return document.getElementById(id);       else if(document.all)		return document.all(id);	return false;}function toggle( targetId, state ){        var symbol;  		var content = getid( 'content'+targetId );  		var link = getid( 'toggle'+targetId );        if(!link || !content) return;        var s;    	if(state != null)	    	s = state;        else if (content.className == "dynexpanded")            s = 0;        else            s = 1;        alert(targetId + content + link + s);        if (s) {            content.className = "dynexpanded";            symbol = collapse_symbol;        } else {            content.className = "dyncollapsed";            symbol = expand_symbol;        }        if(link.innerHTML)            link.innerHTML = symbol;        else if(link.appendChild) {            while(link.hasChildNodes())                link.removeChild(link.firstChild);            link.appendChild(document.createTextNode(symbol));	    }}function toggleList(a,state) {	if(!a.length) return;	for(var i = 0; i < a.length; ++i) {        toggle(a[i], state);	}}// switch stylesfunction setActiveStyleSheet(title) {  var i, a, main;  for (i=0; (a = document.getElementsByTagName("link")[i]); i++) {    if (a.getAttribute("rel") &&        a.getAttribute("rel").indexOf("style") != -1 &&        a.getAttribute("title")) {      a.disabled = true;      if(a.getAttribute("title") == title) a.disabled = false;    }  }  switch (title) {  case 'expand':	a = document.getElementById('expand');	if (a) {a.style.display = 'none';}	a = document.getElementById('collapse');	if (a) {a.style.display = 'inline';}	break;  case 'collapse':	a = document.getElementById('expand');	if (a) {a.style.display = 'inline';}	a = document.getElementById('collapse');	if (a) {a.style.display = 'none';}        break;  }}function getActiveStyleSheet() {  var i, a;  for (i=0; (a = document.getElementsByTagName("link")[i]); i++) {    if (a.getAttribute("rel") &&        a.getAttribute("rel").indexOf("style") != -1 &&        a.getAttribute("title") &&        !a.disabled        ) return a.getAttribute("title");  }  return null;}function getPreferredStyleSheet() {  var i, a;  for (i=0; (a = document.getElementsByTagName("link")[i]); i++) {    if (a.getAttribute("rel") &&        a.getAttribute("rel").indexOf("style") != -1 &&        a.getAttribute("rel").indexOf("alt") == -1 &&        a.getAttribute("title")        ) return a.getAttribute("title");  }  return null;}function createCookie(name,value,days) {  if (days) {    var date = new Date();    date.setTime(date.getTime()+(days*24*60*60*1000));    var expires = "; expires="+date.toGMTString();  }  else expires = "";  document.cookie = name+"="+value+expires+"; path=/";}function readCookie(name) {  var nameEQ = name + "=";  var ca = document.cookie.split(';');  for(var i=0;i < ca.length;i++) {    var c = ca[i];    while (c.charAt(0)==' ') c = c.substring(1,c.length);    if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);  }  return null;}window.onload = function(e) {  var cookie = readCookie("style");  var title = cookie ? cookie : getPreferredStyleSheet();  setActiveStyleSheet(title);}window.onunload = function(e) {  var title = getActiveStyleSheet();  createCookie("style", title, 365);}var cookie = readCookie("style");var title = cookie ? cookie : getPreferredStyleSheet();setActiveStyleSheet(title);