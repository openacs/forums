ad_page_contract {

    Edit a Forum

    @author Ben Adida (ben@openforce.net)
    @creation-date 2002-05-25
    @cvs-id $Id$

} {
}

form create forum

element create forum return_url \
        -datatype text -widget hidden -optional

element create forum forum_id \
        -label [_ forums.Forum_ID] -datatype integer -widget hidden

forums::form::forum forum

# Check if the attachments package is mounted under the forum package instance
set attachments_p [forum::attachments_enabled_p]

if {[form is_valid forum]} {
    template::form get_values forum return_url forum_id \
        name charter presentation_type posting_policy new_threads_p anonymous_allowed_p

    # Display the option only if the attachments package is mounted
    if {$attachments_p} {
        template::form get_values forum attachments_allowed_p
    } else {
        set attachments_allowed_p [db_string att_p {select attachments_allowed_p from forums_forums where forum_id=:forum_id}]
    }

    # Users can create new threads?
    set new_questions_allowed_p [expr { $new_threads_p && $posting_policy ne "closed" ? t : f}]

    db_transaction {
        forum::edit -forum_id $forum_id \
            -name                    $name \
            -charter                 [template::util::richtext::get_property contents $charter] \
            -presentation_type       $presentation_type \
            -posting_policy          $posting_policy \
            -new_questions_allowed_p $new_questions_allowed_p \
            -anonymous_allowed_p     $anonymous_allowed_p \
            -attachments_allowed_p   $attachments_allowed_p
    }

    ad_returnredirect $return_url
    ad_script_abort
}

if { [form is_request forum] } {
    element set_properties forum return_url \
        -value $return_url
    element set_properties forum forum_id \
        -value $forum(forum_id)
    element set_properties forum name \
        -value $forum(name)
    element set_properties forum charter \
        -value [template::util::richtext create $forum(charter) "text/html"]
    element set_properties forum presentation_type \
        -value $forum(presentation_type)
    element set_properties forum posting_policy \
        -value $forum(posting_policy)
    element set_properties forum new_threads_p \
        -value $forum(new_questions_allowed_p)
    element set_properties forum anonymous_allowed_p \
        -value $forum(anonymous_allowed_p)
    # Display the option only if the attachments package is mounted
    if {$attachments_p} {
        element set_properties forum attachments_allowed_p \
            -value $forum(attachments_allowed_p)
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
