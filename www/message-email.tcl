
ad_page_contract {
    
    Forward a message to a friend

    @author Ben Adida (ben@openforce)
    @creation-date 2002-05-28
    @cvs-id $id: Exp $
} {
    message_id:integer,notnull
}

form create message

element create message message_id \
        -label "Message ID" -datatype integer -widget hidden

element create message to_email \
        -label "Email" -datatype text -widget text -html {size 60}

element create message subject \
        -label "Subject" -datatype text -widget text -html {size 80}

element create message pre_body \
        -label "Your Note" -datatype text -widget textarea -html {cols 80 rows 10 wrap hard}


if {[form is_valid message]} {
    template::form get_values message message_id to_email subject pre_body

    # Get the data
    forum::message::get -message_id $message_id -array message

    set new_body "$pre_body"
    append new_body "\n\n===================================\n\n"
    append new_body "$message(user_name) wrote, on [util_AnsiDatetoPrettyDate $message(posting_date)]:\n"
    append new_body "Subject: $message(subject)\n\n"
    append new_body "$message(content)\n"

    # Send the email
    acs_mail_lite::send -to_addr $to_email \
            -from_addr [cc_email_from_party [ad_conn user_id]] \
            -subject $subject \
            -body $new_body

    ad_returnredirect "message-view?message_id=$message_id"
    ad_script_abort
}

# Get the message information
forum::message::get -message_id $message_id -array message

element set_properties message subject -value "\[Fwd from $message(user_name): $message(subject)\]"
element set_properties message message_id -value $message_id

ad_return_template
