ad_page_contract {

    Reject a Message

    @author Ben Adida (ben@openforce.net)
    @creation-date 2002-05-24
    @cvs-id $Id$

} {
    message_id:object_type(forums_message),notnull
    {return_url:localurl "../message-view"}
}

# Check that the user can moderate the forum
forum::message::get -message_id $message_id -array message
forum::security::require_moderate_forum -forum_id $message(forum_id)

# Reject the message
forum::message::reject -message_id $message_id

ad_returnredirect "$return_url?message_id=$message_id"
ad_script_abort

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
