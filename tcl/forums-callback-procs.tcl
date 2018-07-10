ad_library {
    Forum callbacks.
    
    Navigation callbacks.

    @author Jeff Davis <davis@xarg.net>
    @creation-date 2005-03-11
    @cvs-id $Id$
}

#
## Callback hooks
#

ad_proc -public -callback forum::forum_new {
    {-package_id:required}
    {-forum_id:required}
} {
    Append extra logics to forum creation.
} -

ad_proc -public -callback forum::forum_edit {
    {-package_id:required}
    {-forum_id:required}
} {
    Append extra logics to forum editing.
} -

ad_proc -public -callback forum::forum_delete {
    {-package_id:required}
    {-forum_id:required}
} {
    Append extra logics to forum deletion.
} -

ad_proc -public -callback forum::message_new {
    {-package_id:required}
    {-message_id:required}
} {
    Append extra logics to forum message creation.
} -

ad_proc -public -callback forum::message_edit {
    {-package_id:required}
    {-message_id:required}
} {
    Append extra logics to forum message editing.
} -

ad_proc -public -callback forum::message_delete {
    {-package_id:required}
    {-message_id:required}
} {
    Append extra logics to forum message deletion.
} -


#
## Callback implementations
#

# navigation callbacks

ad_proc -public -callback navigation::package_admin -impl forums {} {
    Return the admin actions for the forum package.
} {
    set actions {}

    # Check for admin on the package...
    if {[permission::permission_p -object_id $package_id -privilege admin -party_id $user_id]} {
        lappend actions \
            [list LINK \
                 admin/ \
                 [_ acs-kernel.common_Administration] {} [_ forums.Admin_for_all]] \
            [list LINK \
                 [export_vars -base admin/permissions {{object_id $package_id}}] \
                 [_ acs-kernel.common_Permissions] {} [_ forums.Permissions_for_all]] \
            [list LINK admin/forum-new [_ forums.Create_a_New_Forum] {} {}]
    }

    # check for admin on the individual forums.
    db_foreach forums {
        select forum_id, name, enabled_p
        from forums_forums
        where package_id = :package_id
    } {
        if {[permission::permission_p -object_id $forum_id -privilege admin -party_id $user_id]} {

            lappend actions \
                [list SECTION "Forum $name ([ad_decode $enabled_p t [_ forums.enabled] [_ forums.disabled]])" {}] \
                [list LINK \
                     [export_vars -base admin/forum-edit forum_id] \
                     [_ forums.Edit_forum_name] {} {}] \
                [list LINK \
                     [export_vars -base admin/permissions {{object_id $forum_id} return_url}] \
                     [_ forums.Permission_forum_name] {} {}]
        }
    }
    return $actions
}


# project-manager callbacks

ad_proc -public -callback pm::project_new -impl forums {
    {-package_id:required}
    {-project_id:required}
    {-data:required}
} {
    Create a new forum for each new project.
} {
    set pm_name [pm::project::name -project_item_id $project_id]

    foreach forum_package_id [application_link::get_linked -from_package_id $package_id -to_package_key "forums"] {
	set forum_id [forum::new \
			  -name $pm_name \
			  -package_id $forum_package_id \
			  -no_callback]

	# Automatically allow new threads on this forum
        forum::new_questions_allow -forum_id $forum_id

	application_data_link::new -this_object_id $project_id -target_object_id $forum_id
    }
}


# search callbacks

ad_proc -public -callback search::datasource -impl forums_message {} {

    @author dave@thedesignexperience.org
    @creation-date 2005-06-07

    Returns a datasource for the search package
    this is the content that will be indexed by the full text
    search engine.

    We expect message_id to be a root message of a thread only, 
    and return the text of all the messages below.

} {
    set message_id $object_id
    # If there is no connection than this proc is called from the
    # search indexer. In that case we set the locale to the
    # system-wide default locale, since locale is needed for some part
    # of the message formatting.
    if { ![ad_conn isconnected] } {
        ad_conn -set locale [lang::system::site_wide_locale]
    }

    forum::message::get -message_id $message_id -array message

    if { $message(parent_id) ne "" } {
        ns_log debug "forum::message::datasource was called with a message_id that has a parent - skipping: $message_id"
        set empty(object_id) $message_id
        set empty(title) ""
        set empty(content) ""
        set empty(keywords) ""
        set empty(storage_type) "text"
        set empty(mime) "text/plain"
        return [array get empty]
    }
    set relevant_date $message(posting_date)

    set tree_sortkey $message(tree_sortkey)
    set forum_id $message(forum_id)
    set combined_content ""

    array set forum [forum::get -forum_id $message(forum_id) -array forum]
    set package_id $forum(package_id)

    db_foreach messages "" {

        # include the subject in the text if it is different from the thread's subject
        set root_subject $message(subject)
        regexp {^(?:Re: )+(.*)$} $subject match subject

        if { $subject ne $root_subject  } {
            # different subject
            append combined_content "$subject\n\n"
        }

	#
	# GN: The standard conversion from "text/enhanced" to
	# "text/plain" converts first from "text/enhanced" to
	# "text/html" and then from "text/html" to "text/plain". This
	# can take for large forums posting a long time (e.g a few
	# minutes on openacs.org). Since this function is used just
	# for the summarizer (when listing a short paragraph in the
	# context of the search result), we can live here with a much
	# simpler version, which computes the same in less than one
	# ms.
	#
	if {$message(format) eq "text/enhanced"} {
	    regsub -all {<p>} $content "\n\n" content
	    regsub -all {(<?/[^>]*>)} $content "" content
	} else {
	    set content [ad_html_text_convert -from $format -to text/plain -- $content]
	}
        append combined_content $content

        # In case this text is not only used for indexing but also for display, beautify it
        append combined_content "\n\n"
        set relevant_date $message(posting_date)
    }

    return [list object_id $message(message_id) \
                title $message(subject) \
                content $combined_content \
                relevant_date $relevant_date \
                community_id [db_null] \
                keywords {} \
                storage_type text \
                mime text/plain \
	        package_id $package_id]
}

ad_proc -public -callback search::url -impl forums_message {} {

    @author dave@thedesignexperience.org
    @creation-date 2005-06-08

    Returns a URL for a message to the search package.

} {
    set message_id $object_id
    forum::message::get -message_id $message_id -array message
    set forum_id $message(forum_id)

    return "[ad_url][db_string select_forums_package_url {}]message-view?message_id=$message_id"
}

ad_proc -public -callback search::datasource -impl forums_forum {} {

    Returns a datasource for the search package
    this is the content that will be indexed by the full text
    search engine.

    @author Jeff Davis davis@xarg.net
    @creation-date 2004-04-01
} {

    set forum_id $object_id

    if {![db_0or1row datasource {} -column_array datasource]} {
        return {object_id {} name {} charter {} mime {} storage_type {}}
    }

    return [array get datasource]
}

ad_proc -public -callback search::url -impl forums_forum {} {

    Returns a URL for a forum to the search package.

    @author Jeff Davis davis@xarg.net
    @creation-date 2004-04-01

} {
    set forum_id $object_id
    return "[ad_url][db_string select_forums_package_url {}]forum-view?forum_id=$forum_id"
}


# merge callbacks

ad_proc -callback merge::MergeShowUserInfo -impl forums {
    -user_id:required
} {
    Merge the *forums* of two users.
    The from_user_id is the user_id of the user
    that will be deleted and all the *forums*
    of this user will be mapped to the to_user_id.
    
} {
    set msg "Forums items of $user_id"
    ns_log Notice $msg
    set result [list $msg]
    
    set last_poster [db_list_of_lists sel_poster {} ]
    set msg "Last Poster of $last_poster"
    lappend result $msg

    set poster [db_list_of_lists sel_user_id {} ]
    set msg "Poster of $poster"
    lappend result $msg

    return $result
}

ad_proc -callback merge::MergePackageUser -impl forums {
    -from_user_id:required
    -to_user_id:required
} {
    Merge the *forums* of two users.
    The from_user_id is the user_id of the user
    that will be deleted and all the *forums*
    of this user will be mapped to the to_user_id.
    
} {
    set msg "Merging forums" 
    ns_log Notice $msg
    set result [list $msg]
    
    db_dml upd_poster {}
    db_dml upd_user_id {}

    lappend result "Merge of forums is done"

    return $result
}


# application-track callbacks

ad_proc -callback application-track::getApplicationName -impl forums {} { 
    Callback implementation.
} {
    return "forums"
}    
    
ad_proc -callback application-track::getGeneralInfo -impl forums {} { 
    Callback implementation.
} {
    db_1row my_query {
    		select count(f.forum_id) as result
		FROM forums_forums f, dotlrn_communities_full com
		WHERE com.community_id=:comm_id
		and apm_package__parent_id(f.package_id) = com.package_id	
    }
    
    return $result
}
    
ad_proc -callback application-track::getSpecificInfo -impl forums {} { 
    Callback implementation.
} {
    
    upvar $query_name my_query
    upvar $elements_name my_elements

    set my_query {
		SELECT 	f.name as name,f.thread_count as threads,
			f.last_post, 
		       	to_char(o.creation_date, 'YYYY-MM-DD HH24:MI:SS') as creation_date
		FROM forums_forums f,dotlrn_communities_full com,acs_objects o
		WHERE com.community_id=:class_instance_id
		and f.forum_id = o.object_id
		and apm_package__parent_id(f.package_id) = com.package_id
    }
    
    set my_elements {
        name {
            label "Name"
            display_col name	                        
            html {align center}	 	    
            
        }
        threads {
            label "Threads"
            display_col threads 	      	              
            html {align center}	 	               
        }
        creation_date {
            label "creation_date"
            display_col creation_date 	      	               
            html {align center}	 	              
        }
        last_post  {
            label "last_post"
            display_col last_post 	      	               
            html {align center}	 	              
        }	        
    }

    return "OK"
}

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
