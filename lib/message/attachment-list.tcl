ad_page_contract {
    a message attachment chunk to be included to display attachments

    @author ben (ben@openforce.net)
    @creation-date 2002-07-02
    @cvs-id $Id$
}

if {![array exists message]} {
    ad_return_complaint 1 "[_ forums.lt_need_to_provide_a_mes]"
}

if {(![info exists bgcolor] || $bgcolor eq "")} {
    set bgcolor "#ffffff"
}

# get the attachments
template::multirow create attachments url name
foreach attachment [attachments::get_attachments -object_id $message(message_id)] {
    set url [lindex $attachment 2]
    set name [lindex $attachment 1]
    template::multirow append attachments $url $name
}

set attachment_graphic [attachments::graphic_url]

if {([info exists alt_template] && $alt_template ne "")} {
  ad_return_template $alt_template
}
