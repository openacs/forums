ad_page_contract {
    
    Form to edit a message

    @author Ben Adida (ben@openforce.net)
    @creation-date 2002-05-25
    @cvs-id $Id$

} {
    message_id:object_type(forums_message),notnull
    {return_url:localurl "../message-view"}
}

forum::message::get -message_id $message_id -array message
forum::get -forum_id $message(forum_id) -array forum

ad_return_template

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
