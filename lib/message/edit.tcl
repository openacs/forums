ad_page_contract {
    
    Form to edit a message

    @author Ben Adida (ben@openforce.net)
    @creation-date 2003-12-09
    @cvs-id $Id$

}

form create message

element create message message_id \
    -label [_ forums.Message_ID] \
    -datatype integer \
    -widget hidden

forums::form::message message

set upload_url ""
if {[forum::image_paste_enabled_p -forum_id $message(forum_id)]
    && [permission::permission_p -object_id $message(forum_id) -privilege forum_moderate]} {
    set upload_url [forum::markdown_image::upload_url $message(forum_id) $message(message_id) edit]
    if {$upload_url ne ""} {
        element set_properties message message_body -options [list image_upload_url $upload_url]
    }
}

if {[form is_valid message]} {
    template::form get_values message message_id subject message_body
    set content [string trimright [template::util::richtext::get_property contents $message_body]]
    set format [string trimright [template::util::richtext::get_property format $message_body]]

    try {
        set inline_images [forum::markdown_image::drafts $message(forum_id) $message_id $content $format]
    } trap {FORUM IMAGE UNAVAILABLE} {error_message} {
        template::form::set_error message message_body $error_message
    }

    if {[info exists inline_images]} {
        set save_message [list forum::message::edit \
                              -message_id $message_id \
                              -subject $subject \
                              -content $content \
                              -format $format]
        if {[dict size $inline_images] == 0} {
            {*}$save_message
        } else {
            if {$message_id ne $message(message_id)} {
                forum::security::do_abort
            }
            forum::security::require_moderate_forum -forum_id $message(forum_id)
            db_transaction {
                {*}$save_message
                forum::markdown_image::attach $message(forum_id) $message_id $inline_images
            }
        }
        ad_returnredirect "$return_url?message_id=$message_id"
        ad_script_abort
    }
}

# Prepare the other data 
element set_properties message message_id -value $message(message_id)
if {![info exists error_message]} {
    element set_properties message subject -value $message(subject)
    element set_properties message message_body -value [list $message(content) $message(format)]
}

if {[info exists alt_template]} {
  ad_return_template $alt_template
}

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
