ad_page_contract {
    
    Form to edit a message

    @author Ben Adida (ben@openforce.net)
    @creation-date 2003-12-09
    @cvs-id $Id$

}

form create message

element create message message_id \
    -label [_ forums.Message_ID] \
    -datatype integer \
    -widget hidden

forums::form::message message

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

# Prepare the other data 
element set_properties message message_id -value $message(message_id)
element set_properties message subject -value $message(subject)
element set_properties message content -value $message(content)
element set_properties message html_p -value $message(html_p)

if {[info exists alt_template]} {
  ad_return_template $alt_template
}
