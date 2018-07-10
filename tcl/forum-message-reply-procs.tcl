ad_library {

    Forums Library - Reply Handling

    @creation-date 2002-05-17
    @author Ben Adida <ben@openforce.biz>
    @cvs-id $Id$

}

namespace eval forum::message::notification {

    ad_proc -deprecated -public get_url {
        object_id
    } {
        NotificationType.GetURL Service Contract implementation..<br>
        This proc was always empty and is currently not used anywhere
        in upstream code. Is most likely superseded by its
        forum::notification counterpart.

        @see forum::notification::get_url
    } -

    ad_proc -deprecated -public process_reply {
        reply_id
    } {
        NotificationType.ProcessReply Service Contract implementation.<br>
        This proc was always empty and is currently not used anywhere
        in upstream code. Is most likely superseded by its
        forum::notification counterpart.

        @see forum::notification::process_reply
    } -
    
}

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
