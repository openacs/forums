ad_page_contract {
    
    a message chunk to be included in a table listing of messages

    _so that has to be wrapped in a <table>_

    @author yon (yon@openforce.net)
    @author arjun (arjun@openforce.net)
    @creation-date 2002-06-02
    @cvs-id $Id$

}

if {![array exists message]} {
    ad_return_complaint 1 "Need to provide a message to display."
}

if {![exists_and_not_null bgcolor]} { 
    set table_bgcolor [parameter::get -parameter table_bgcolor]
} else {
    set table_bgcolor $bgcolor
}

if {![exists_and_not_null moderate_p]} { set moderate_p 0 }
if {![exists_and_not_null forum_moderated_p]} {set forum_moderated_p 0}

# JCD: display subject only if changed from the root subject
if {![info exists root_subject]} {
    set display_subject_p 1
} else {
    regsub {^(Response to |\s*Re:\s*)*} $message(subject) {} subject
    set display_subject_p [expr ![string equal $subject $root_subject]]
}
