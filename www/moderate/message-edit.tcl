ad_page_contract {
    
    Form to edit a message

    @author Ben Adida (ben@openforce.net)
    @creation-date 2002-05-25
    @cvs-id $Id$

} {
    message_id:integer,notnull
    {return_url "../message-view"}
}

form create message

element create message message_id \
    -label "Message ID" \
    -datatype integer \
    -widget hidden

element create message subject \
    -label Subject \
    -datatype text \
    -widget text \
    -html {size 60} \
    -validate { {expr ![empty_string_p [string trim $value]]} {Please enter a subject} }

element create message content \
    -label Body \
    -datatype text \
    -widget textarea \
    -html {rows 20 cols 60 wrap soft} \
    -validate {
	empty {expr ![empty_string_p [string trim $value]]} {Please enter a message}
	html { expr {( [string match [set l_html_p [ns_queryget html_p f]] "t"] && [empty_string_p [set v_message [ad_html_security_check $value]]] ) || [string match $l_html_p "f"] } }
        {}	
    }

element create message html_p \
    -label Format \
    -datatype text \
    -widget select \
    -options {{text f} {html t}}

if {[form is_valid message]} {
    template::form get_values message message_id subject content html_p

    forum::message::edit \
            -message_id $message_id \
            -subject $subject \
            -content $content \
            -html_p $html_p

    ad_returnredirect "$return_url?message_id=$message_id"
    ad_script_abort
}

forum::message::get -message_id $message_id -array message
forum::get -forum_id $message(forum_id) -array forum

# Prepare the other data 
element set_properties message message_id -value $message_id
element set_properties message subject -value $message(subject)
element set_properties message content -value $message(content)
element set_properties message html_p -value $message(html_p)

set message(subject) [ad_quotehtml $message(subject)]
ad_return_template
