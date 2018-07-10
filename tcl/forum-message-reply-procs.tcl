ad_library {

    Forums Library - Reply Handling

    @creation-date 2002-05-17
    @author Ben Adida <ben@openforce.biz>
    @cvs-id $Id$

}

namespace eval forum::message::notification {

    ad_proc -public get_url {
        object_id
    } {
        NotificationType.GetURL Service Contract implementation.
    } -

    ad_proc -public process_reply {
        reply_id
    } {
        NotificationType.ProcessReply Service Contract implementation.
    } -
    
}

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
