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
#
# Can the user detach?
#
# Only if the user can edit a message, which currently requires admin privileges
#
set detach_p [permission::permission_p -object_id $message(message_id) -privilege admin]
set detach_icon "/resources/acs-subsite/Delete16.gif"
#
# Get the attachments
#
template::multirow create attachments url name content_size_pretty icon detach_url
foreach attachment [attachments::get_attachments -object_id $message(message_id)] {
    set id      [lindex $attachment 0]
    set name    [lindex $attachment 1]
    set url     [lindex $attachment 2]

    set content_size_pretty ""
    if {[content::extlink::is_extlink -item_id $id]} {
        #
        # URL
        #
        set icon "/resources/acs-subsite/url-button.gif"
        #
        # Avoid redirecting to external hosts made by "go-to-attachment" by just linking the original URL
        #
        set url [db_string url {select url from cr_extlinks where extlink_id = :id} -default ""]
    } else {
        #
        # Not a link, let's try to get the size, in case it is a 'content_item',
        # a 'content_revision' or a subtype of them.
        #
        set object_type [acs_object_type $id]
        set icon "/resources/acs-subsite/attach.png"
        if {[content::item::is_subclass \
                -object_type $object_type \
                -supertype "content_item"]} {
            #
            # Content item, or subtype
            #
            set revision [content::item::get_best_revision -item_id $id]
            set content_size [db_string size {select content_length from cr_revisions where revision_id = :revision} -default ""]
            set content_size_pretty "([lc_content_size_pretty -size $content_size])"

        } elseif {[content::item::is_subclass \
                    -object_type $object_type \
                    -supertype "content_revision"]} {
            #
            # Content revision, or subtype
            #
            set content_size [db_string size {select content_length from cr_revisions where revision_id = :id} -default ""]
            set content_size_pretty "([lc_content_size_pretty -size $content_size])"
        }
    }
    #
    # Detach URL
    #
    set detach_url "[attachments::get_url]/detach?object_id=$message(message_id)&attachment_id=$id&return_url=[ns_urlencode [ad_return_url]]"
    #
    # Add to multirow
    #
    template::multirow append attachments $url $name $content_size_pretty $icon $detach_url
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
