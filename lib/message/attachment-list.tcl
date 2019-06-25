ad_page_contract {
    a message attachment chunk to be included to display attachments

    @author ben (ben@openforce.net)
    @creation-date 2002-07-02
    @cvs-id $Id$
}

if {![array exists message]} {
    ad_return_complaint 1 "[_ forums.lt_need_to_provide_a_mes]"
    ad_script_abort
}

if {(![info exists bgcolor] || $bgcolor eq "")} {
    set bgcolor "#ffffff"
}

# get the attachments
template::multirow create attachments url name content_size_pretty icon
foreach attachment [attachments::get_attachments -object_id $message(message_id)] {
    set id      [lindex $attachment 0]
    set name    [lindex $attachment 1]
    set url     [lindex $attachment 2]

    set content_type [content::item::get_content_type -item_id $id]

    if {$content_type ne "content_extlink"} {
        #
        # File
        #
        set content_size [db_string size {select content_length from cr_revisions where item_id = :id} -default ""]
        set content_size_pretty "([util::content_size_pretty -size $content_size])"
        set icon "/resources/acs-subsite/attach.png"
    } else {
        #
        # URL
        #
        set content_size_pretty ""
        set icon "/resources/acs-subsite/url-button.gif"
        #
        # Avoid redirecting to external hosts made by "go-to-attachment" by just linking the original URL
        #
        set url [db_string url {select url from cr_extlinks where extlink_id = :id} -default ""]
    }

    template::multirow append attachments $url $name $content_size_pretty $icon
}

set attachment_graphic [attachments::graphic_url]

if {[info exists alt_template] && $alt_template ne ""} {
  ad_return_template $alt_template
}

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
