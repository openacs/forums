ad_library {

    Forums Library

    @creation-date 2002-05-17
    @author Ben Adida <ben@openforce.biz>
    @cvs-id $Id$

}

namespace eval forum {

    ad_proc -public new {
        {-forum_id ""}
        {-name:required}
        {-charter ""}
        {-presentation_type flat}
        {-posting_policy open}
        {-package_id:required}
    } {
        create a new forum
    } {
        # Prepare the variables for instantiation
        set extra_vars [ns_set create]
        oacs_util::vars_to_ns_set -ns_set $extra_vars -var_list {forum_id name charter presentation_type posting_policy package_id}

        # Instantiate the forum
        return [package_instantiate_object -extra_vars $extra_vars forums_forum]
    }

    ad_proc -public edit {
        {-forum_id:required}
        {-name:required}
        {-charter ""}
        {-presentation_type flat}
        {-posting_policy open}
    } {
        edit a forum
    } {
        # This is a straight DB update
        db_dml update_forum {}
    }

    ad_proc -public attachments_enabled_p {} {
        set package_id [site_node_apm_integration::child_package_exists_p \
            -package_key attachments
        ]
    }

    ad_proc -public list_forums {
        {-package_id:required}
    } {
        List all forums in a package
    } {
        return [db_list_of_ns_sets select_forums {}]
    }
    
    ad_proc -public get {
        {-forum_id:required}
        {-array:required}
    } {
        get the fields for a forum
    } {
        # Select the info into the upvar'ed Tcl Array
        upvar $array row
        db_1row select_forum {} -column_array row
    }

    ad_proc -public posting_policy_set {
        {-posting_policy:required}
        {-forum_id:required}
    } { 
        # JCD: this is potentially bad since we are 
        # just assuming registered_users is the 
        # right group to be granting forum_write to.

        if {![string equal closed $posting_policy]} { 
            permission::grant -object_id $forum_id \
                -party_id [acs_magic_object registered_users] \
                -privilege forum_write 
        } else { 
            permission::revoke -object_id $forum_id \
                -party_id [acs_magic_object registered_users] \
                -privilege forum_write 
        }

    } 

    ad_proc -public new_questions_allow {
        {-forum_id:required}
    } {
        # Give the public the right to ask new questions
        permission::grant -object_id $forum_id \
                -party_id [acs_magic_object registered_users] \
                -privilege forum_create
    }

    ad_proc -public new_questions_deny {
        {-forum_id:required}
    } {
        # Revoke the right from the public to ask new questions
        permission::revoke -object_id $forum_id \
                -party_id [acs_magic_object registered_users] \
                -privilege forum_create
    }

    ad_proc -public new_questions_allowed_p {
        {-forum_id:required}
    } {
        permission::permission_p -object_id $forum_id \
                -party_id [acs_magic_object registered_users] \
                -privilege forum_create
    }

    ad_proc -public enable {
        {-forum_id:required}
    } {
        # Enable the forum, no big deal
        db_dml update_forum_enabled_p {}
    }

    ad_proc -public disable {
        {-forum_id:required}
    } {
        db_dml update_forum_disabled_p {}
    }

}
