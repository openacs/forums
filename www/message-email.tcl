ad_page_contract {
    
    Forward a message to a friend

    @author Ben Adida (ben@openforce)
    @creation-date 2002-05-28
    @version $Id$

} {
    message_id:integer,notnull
}

forum::security::require_read_message -message_id $message_id

form create message

element create message message_id \
    -label "Message ID" \
    -datatype integer \
    -widget hidden

element create message to_email \
    -label Email \
    -datatype text \
    -widget text \
    -html {size 60}

element create message subject \
    -label Subject \
    -datatype text \
    -widget text \
    -html {size 80}

element create message pre_body \
    -label "Your Note" \
    -datatype text \
    -widget textarea \
    -html {cols 80 rows 10 wrap hard}


if {[form is_valid message]} {
    template::form get_values message message_id to_email subject pre_body

    # Get the data
    forum::message::get -message_id $message_id -array message

    set new_body "$pre_body"
    append new_body "\n\n===================================\n\n"
    append new_body "On $message(posting_date), $message(user_name) wrote:\n\n"
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

element set_properties message subject -value "\[Fwd: $message(subject)\]"
element set_properties message message_id -value $message_id

set context_bar [list [list "./forum-view?forum_id=$message(forum_id)" "$message(forum_name)"]]
if {![empty_string_p $message(parent_id)]} {
    lappend context_bar [list "./message-view?message_id=$message(root_message_id)" "Entire Thread"]
}
lappend context_bar [list "./message-view?message_id=$message(message_id)" "$message(subject)"]
lappend context_bar {Email to a friend}

ad_return_template
