ad_library {

    Forums Library

    @creation-date 2002-05-17
    @author Ben Adida <ben@openforce.biz>
    @cvs-id $Id$

}

namespace eval forum {}


ad_proc -public forum::new {
    {-forum_id ""}
    {-name:required}
    {-charter ""}
    {-presentation_type flat}
    {-posting_policy open}
    {-package_id:required}
} {
    create a new forum
} {
    set var_list [list \
        [list forum_id $forum_id] \
        [list name $name] \
        [list charter $charter] \
        [list presentation_type $presentation_type] \
        [list posting_policy $posting_policy] \
        [list package_id $package_id]]
    return [package_instantiate_object -var_list $var_list forums_forum]
}

ad_proc -public forum::edit {
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
    db_dml update_forum_object {}
}

ad_proc -public forum::attachments_enabled_p {} {
    if {[string eq forums [ad_conn package_key]]} { 
	set package_id [site_node_apm_integration::child_package_exists_p \
			    -package_key attachments
		       ]
    } else { 
	return 0
    }
}

ad_proc -public forum::list_forums {
    {-package_id:required}
} {
    List all forums in a package
} {
    return [db_list_of_ns_sets select_forums {}]
}

ad_proc -public forum::get {
    {-forum_id:required}
    {-array:required}
} {
    get the fields for a forum
    
    @return 
} {
    # Select the info into the upvar'ed Tcl Array
    upvar $array row
    if {![db_0or1row select_forum {} -column_array row]} {
        error "Forum $forum_id not found" {} NOT_FOUND
    }
}

ad_proc -public forum::posting_policy_set {
    {-posting_policy:required}
    {-forum_id:required}
} { 
    # JCD: this is potentially bad since we are 
    # just assuming registered_users is the 
    # right group to be granting write to.

    if {![string equal closed $posting_policy]} { 
        permission::grant -object_id $forum_id \
            -party_id [acs_magic_object registered_users] \
            -privilege write 
    } else { 
        permission::revoke -object_id $forum_id \
            -party_id [acs_magic_object registered_users] \
            -privilege write 
    }

} 

ad_proc -public forum::new_questions_allow {
    {-forum_id:required}
    {-party_id ""}
} {
    if { [empty_string_p $party_id] } {
        set party_id [acs_magic_object registered_users]
    }
    # Give the public the right to ask new questions
    permission::grant -object_id $forum_id \
            -party_id $party_id \
            -privilege create
    util_memoize_flush_regexp  $forum_id
}

ad_proc -public forum::new_questions_deny {
    {-forum_id:required}
    {-party_id ""}
} {
    if { [empty_string_p $party_id] } {
        set party_id [acs_magic_object registered_users]
    }
    # Revoke the right from the public to ask new questions
    permission::revoke -object_id $forum_id \
            -party_id $party_id \
            -privilege create
    util_memoize_flush_regexp  $forum_id
}

ad_proc -public forum::new_questions_allowed_p {
    {-forum_id:required}
    {-party_id ""}
} {
    if { [empty_string_p $party_id] } {
        set party_id [acs_magic_object registered_users]
    }
    permission::permission_p -object_id $forum_id \
            -party_id $party_id \
            -privilege create
}

ad_proc -public forum::enable {
    {-forum_id:required}
} {
    # Enable the forum, no big deal
    db_dml update_forum_enabled_p {}
}

ad_proc -public forum::disable {
    {-forum_id:required}
} {
    db_dml update_forum_disabled_p {}
}

ad_proc forum::get_forum_package {
    {-community_id}
} {
    if {[info exist community_id] == 0} {
        set community_id [dotlrn_community::get_community_id]        
    }

    db_1row get_forum_package_id {}

    return $package_id    
}
