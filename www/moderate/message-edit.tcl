
ad_page_contract {
    
    Form to edit a message

    @author Ben Adida (ben@openforce)
    @creation-date 2002-05-25
    @cvs-id $id: Exp $
} {
    message_id:integer,notnull
    {return_url "../message-view"}
}

# We would use the nice ad_form construct if we could
form create message

element create message message_id \
        -label "Message ID" -datatype integer -widget hidden

element create message subject \
        -label "Subject" -datatype text -widget text -html {size 60}

element create message content \
        -label "Body" -datatype text -widget textarea -html {rows 30 cols 60 wrap soft}

element create message html_p \
        -label "Format" -datatype text -widget select -options {{text f} {html t}}

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

ad_return_template
