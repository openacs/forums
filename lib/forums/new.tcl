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

# Check if the attachments package is mounted under the forum package instance
set attachments_p [forum::attachments_enabled_p]

if {[form is_valid forum]} {
    template::form get_values forum \
        forum_id name charter presentation_type posting_policy new_threads_p anonymous_allowed_p

    # Display the option only if the attachments package is mounted
    if {$attachments_p} {
        template::form get_values forum attachments_allowed_p
    } else {
        set attachments_allowed_p t
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
                          -attachments_allowed_p   $attachments_allowed_p]
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
    # Display the option only if the attachments package is mounted
    if {$attachments_p} {
        element set_value forum attachments_allowed_p t
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
