ad_page_contract {

    Move a thread to other forum

    @author Natalia Pérez (nperper@it.uc3m.es)
    @creation-date 2005-03-14    

} {
    message_id:naturalnum,notnull
    {return_url:localurl "../message-view"}
    {confirm_p:boolean 0}
}

# Check that the user can moderate the forum
forum::security::require_moderate_message -message_id $message_id

# Select the stuff
forum::message::get -message_id $message_id -array message
set title "#forums.Confirm_Move_to# \"$message(subject)\""

ad_return_template

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
