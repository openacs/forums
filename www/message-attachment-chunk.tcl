ad_page_contract {
    a message attachment chunk to be included to display attachments

    @author ben (ben@openforce)
    @creation-date 2002-07-02
    @version $Id$
}

if {![array exists message]} {
    ad_return_complaint 1 "need to provide a message to display attachments!"
}

# get the attachments
set attachments [attachments::get_attachments -object_id $message(message_id)]

set attachment_graphic [attachments::graphic_url]

ad_return_template
