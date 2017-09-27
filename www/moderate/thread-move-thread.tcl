ad_page_contract {

    Move a thread to other thread

    @author Natalia Pérez (nperper@it.uc3m.es)
    @creation-date 2005-03-14    

} {
    message_id:naturalnum,notnull
    {return_url:localurl "../message-view"}
    {confirm_p:boolean 0}
}

# Select the stuff
forum::message::get -message_id $message_id -array message

# Check that the user can moderate the forum
forum::security::require_moderate_forum -forum_id $message(forum_id)

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
