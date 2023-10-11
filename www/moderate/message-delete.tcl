ad_page_contract {

    Delete a Message

    @author Ben Adida (ben@openforce.net)
    @creation-date 2002-05-24
    @cvs-id $Id$

} {
    message_id:object_type(forums_message),verify,notnull
    {return_url:localurl "../message-view"}
    {confirm_p:boolean,notnull 0}
}

#
# Select the forums message into the Tcl array (including message_id)
#
forum::message::get -message_id $message_id -array message

# Check that the user can moderate the forum
forum::security::require_moderate_forum -forum_id $message(forum_id)

# stylesheets
template::head::add_css -href /resources/forums/forums.css -media all -lang [ad_conn language]

# js scripts
template::head::add_script -type "text/javascript" -src "/resources/forums/forums.js"

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
