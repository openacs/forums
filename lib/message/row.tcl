ad_page_contract {
    
    a message chunk to be included in a table listing of messages

    _so that has to be wrapped in a <table>_

    @author yon (yon@openforce.net)
    @author arjun (arjun@openforce.net)
    @creation-date 2002-06-02
    @cvs-id $Id$

}

if {![exists_and_not_null bgcolor]} { 
    set table_bgcolor [parameter::get -parameter table_bgcolor]
} else {
    set table_bgcolor $bgcolor
}

if { [string is false $message(html_p)] } {
    set message(content) [ad_text_to_html -- $message(content)]
}

# convert emoticons to images if the parameter is set
if { [string is true [parameter::get -parameter DisplayEmoticonsAsImagesP -default 0]] } {
    set message(content) [forum::format::emoticons -content $message(content)]
}

# JCD: display subject only if changed from the root subject
if {![info exists root_subject]} {
    set display_subject_p 1
} else {
    regsub {^(Response to |\s*Re:\s*)*} $message(subject) {} subject
    set display_subject_p [expr ![string equal $subject $root_subject]]
}

if {[exists_and_not_null alt_template]} {
  ad_return_template $alt_template
}
