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
    {-new_questions_allowed_p t}
    {-anonymous_allowed_p f}
    {-attachments_allowed_p t}
    -no_callback:boolean
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

    set forum_id [package_instantiate_object -var_list $var_list forums_forum]

    db_dml update_extra_cols {
        update forums_forums set
           new_questions_allowed_p = :new_questions_allowed_p,
           anonymous_allowed_p     = :anonymous_allowed_p,
           attachments_allowed_p   = :attachments_allowed_p
        where forum_id = :forum_id
    }

    if {!$no_callback_p} {
        callback forum::forum_new -package_id $package_id -forum_id $forum_id
    }

    forum::flush_templating_cache \
        -forum_id $forum_id

    return $forum_id
}

ad_proc -public forum::delete {
    {-forum_id ""}
} {
    delete a forum
} {
    db_exec_plsql forum_delete {}
}

ad_proc -public forum::edit {
    {-forum_id:required}
    -name
    -charter
    -presentation_type
    -posting_policy
    -new_questions_allowed_p
    -anonymous_allowed_p
    -attachments_allowed_p
    -no_callback:boolean
} {
    Edit a forum
} {
    forum::get -forum_id $forum_id -array forum
    foreach var {
        name charter presentation_type posting_policy
        new_questions_allowed_p anonymous_allowed_p attachments_allowed_p} {
        if {![info exists $var]} {
            set $var $forum($var)
        }
    }

    # This is a straight DB update
    db_dml update_forum {}
    db_dml update_forum_object {}

    if {!$no_callback_p} {
        callback forum::forum_edit -package_id [ad_conn package_id] -forum_id $forum_id
    }

    forum::flush_cache \
        -forum_id $forum_id
}

ad_proc -public forum::attachments_enabled_p {
    {-forum_id ""}
} {
    Check if attachments are enabled in forums.

    If 'forum_id' is not passed, check only if the attachments package is
    mounted as a child of the current forums package instance.

    Otherwise, check also if a particular forum's 'attachments_allowed_p' option
    is true. In case the package is mounted and the option enabled, return 1.

    @return 1 if the attachments are enabled in the forums, 0 otherwise.
} {
    if {$forum_id ne ""} {
        #
        # A forum was provided
        #
        forum::get -forum_id $forum_id -array forum

        if {!$forum(attachments_allowed_p)} {
            #
            # Forum does not allow attachments. Exit immediately.
            #
            return 0
        }

        #
        # We get the package from the forum
        #
        set package_id $forum(package_id)

    } elseif {"forums" eq [ad_conn package_key]} {
        #
        # No forum provided, but the connection context tells us this
        # is a forum package. We use the connection package_id.
        #
        set package_id [ad_conn package_id]
    } else {
        #
        # No forum and no connection context to help us determine the
        # package. Exit immediately.
        #
        ad_log warning "Cannot determine package_id. Returning 0"
        return 0
    }

    #
    # See if an instance of the attachments package is mounted
    # underneath this forums instance.
    #
    return [site_node_apm_integration::child_package_exists_p \
                -package_id $package_id -package_key attachments]
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

    set global_varname ::forum_${forum_id}

    if {[info exists $global_varname]} {
        array set row [array get $global_varname]
    } else {
        if {![db_0or1row select_forum {} -column_array row]} {
            error "Forum $forum_id not found" {} NOT_FOUND
        }
        array set $global_varname [array get row]
    }
}

ad_proc -public forum::flush_cache {
    {-forum_id:required}
} {
    Flushes all the forum caches.
} {
    forum::flush_templating_cache -forum_id $forum_id
    forum::flush_namespaced_cache -forum_id $forum_id
}

ad_proc -public forum::flush_templating_cache {
    {-forum_id:required}
} {
    Flushes forum templating cache, created by template::paginator
} {
    # DRB: Black magic cache flush call which will disappear when list builder is
    # rewritten to paginate internally rather than use the template paginator.
    template::cache flush "messages,forum_id=$forum_id*"
}

ad_proc -public forum::flush_namespaced_cache {
    {-forum_id:required}
} {
    Unsets namespaced thread variable holding the forum cache
} {
    unset -nocomplain ::forum_${forum_id}
}

ad_proc -deprecated -public forum::posting_policy_set {
    {-posting_policy:required}
    {-forum_id:required}
} {
    Set the posting policy. This used to happen by setting permissions
    on the registered_users group, but was reformed to be just a flag
    on the forum itself in order to support subsite
    installation. Please use forum::edit instead.

    @see forum::edit
} {
    forum::edit -forum_id $forum_id \
        -posting_policy $posting_policy
    # # JCD: this is potentially bad since we are
    # # just assuming registered_users is the
    # # right group to be granting write to.

    # if {"closed" ne $posting_policy } {
    #     permission::grant -object_id $forum_id \
    #         -party_id [acs_magic_object registered_users] \
    #         -privilege write
    # } else {
    #     permission::revoke -object_id $forum_id \
    #         -party_id [acs_magic_object registered_users] \
    #         -privilege write
    # }
}

ad_proc -public forum::new_questions_allow {
    {-forum_id:required}
    {-party_id ""}
} {
    Allow the users to create new threads in the forum
} {
    if { $party_id ne "" } {
        ad_log warning "Attribute party_id is deprecated and was ignored."
    }

    db_dml query {
        update forums_forums set
        new_questions_allowed_p = true
        where forum_id = :forum_id
    }
}

ad_proc -public forum::new_questions_deny {
    {-forum_id:required}
    {-party_id ""}
} {
    Deny the users to create new threads in the forum
} {
    if { $party_id ne "" } {
        ad_log warning "Attribute party_id is deprecated and was ignored."
    }

    db_dml query {
        update forums_forums set
        new_questions_allowed_p = false
        where forum_id = :forum_id
    }
}

ad_proc -deprecated forum::new_questions_allowed_p {
    {-forum_id:required}
    {-party_id ""}
} {
    Check if the users can create new threads in the forum

    DEPRECATED: the forum::get api already retrieves this information
                and there is normally no need to invoke this api
                specifically.

    @see forum::get
} {
    if { $party_id ne "" } {
        ad_log warning "Attribute party_id is deprecated and was ignored."
    }

    forum::get -forum_id $forum_id -array forum
    return $forum(new_questions_allowed_p)
}

ad_proc -public forum::enable {
    {-forum_id:required}
} {
    Enable a forum
} {
    # Enable the forum, no big deal
    db_dml update_forum_enabled_p {}
}

ad_proc -public forum::disable {
    {-forum_id:required}
} {
    Disable a forum
} {
    db_dml update_forum_disabled_p {}
}

ad_proc -public forum::use_ReadingInfo_p {{-package_id ""}} {
    @return 1 if the UseReadingInfo package parameter is true, 0 otherwise.
} {
    if {$package_id eq ""} {
        if {[ns_conn isconnected]} {
            set package_id [ad_conn package_id]
        } else {
            set package_id [lindex [apm_package_ids_from_key -package_key forums -mounted] 0]
        }
    }
    return [string is true -strict [parameter::get \
                                        -package_id $package_id \
                                        -parameter UseReadingInfo \
                                        -default f]]
}

ad_proc forum::valid_forum_id_p {
    {-forum_id:required}
    {-package_id}
} {
    checks forum_id
} {
    if {[info exists package_id] && [db_0or1row check_forum_id {
        select forum_id from forums_forums where forum_id = :forum_id and package_id = :package_id
    }]} {
        set result true
    } elseif {![info exists package_id] && [db_0or1row check_forum_id {
        select forum_id from forums_forums where forum_id = :forum_id
    }]} {
        set result true
    } else {
        set result false
    }

    return $result
}

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
