ad_page_contract {

    Delete a Message

    @author Ben Adida (ben@openforce.net)
    @creation-date 2002-05-24
    @cvs-id $Id$

} {
    message_id:integer,notnull
    {return_url ""}
    {confirm_p 0}
}

set table_border_color [parameter::get -parameter table_border_color]

# Check that the user can moderate the forum
forum::security::require_moderate_message -message_id $message_id

# Select the stuff
forum::message::get -message_id $message_id -array message

# Confirm?
if {!$confirm_p} {
    set url_vars [export_url_vars message_id return_url]
    ad_return_template
} else {
    # Delete the message and all children
    forum::message::delete -message_id $message_id
    
    # Redirect to the forum
    ad_returnredirect "../forum-view?forum_id=$message(forum_id)"
}
