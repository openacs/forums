ad_include_contract {

    Create a Forum
    By default redirects to the level above as that is prolly where the index page is

    @author Ben Adida (ben@openforce.net)
    @creation-date 2002-05-25
    @cvs-id $Id$

} {
    {name ""}
}

set package_id [ad_conn package_id]

form create forum

element create forum forum_id \
    -label [_ forums.Forum_ID] \
    -datatype integer \
    -widget hidden

forums::form::forum forum

# Check availability of each attachment interface
set attachments_p [forum::attachments_enabled_p]
set image_paste_p [forum::image_paste_enabled_p]

if {[form is_valid forum]} {
    template::form get_values forum \
        forum_id name charter presentation_type posting_policy new_threads_p anonymous_allowed_p

    # Only read fields that were included in the form
    if {$attachments_p} {
        template::form get_values forum attachments_allowed_p
    } else {
        set attachments_allowed_p f
    }

    if {$image_paste_p} {
        template::form get_values forum image_paste_allowed_p
    } else {
        set image_paste_allowed_p f
    }

    # Users can create new threads?
    set new_questions_allowed_p [expr {$new_threads_p && $posting_policy ne "closed" ? t : f}]

    db_transaction {
        set forum_id [forum::new -forum_id $forum_id \
                          -name                    $name \
                          -charter                 [template::util::richtext::get_property contents $charter] \
                          -presentation_type       $presentation_type \
                          -posting_policy          $posting_policy \
                          -package_id              $package_id \
                          -new_questions_allowed_p $new_questions_allowed_p \
                          -anonymous_allowed_p     $anonymous_allowed_p \
                          -attachments_allowed_p   $attachments_allowed_p \
                          -image_paste_allowed_p   $image_paste_allowed_p]
    }

    ad_returnredirect $return_url
    ad_script_abort
}

if { [form is_request forum] } {
    # Pre-fetch the forum_id
    set forum_id [db_nextval acs_object_id_seq]
    element set_properties forum forum_id -value $forum_id
    element set_value forum new_threads_p t
    element set_value forum anonymous_allowed_p f
    element set_value forum name $name
    # Only read fields that were included in the form
    if {$attachments_p} {
        element set_value forum attachments_allowed_p f
    }
    if {$image_paste_p} {
        element set_value forum image_paste_allowed_p f
    }
}

if {[info exists alt_template] && $alt_template ne ""} {
    ad_return_template $alt_template
}

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
