ad_library {
    Library of callbacks implementations
    for Forums
    
    Navigation callbacks.

    @author Jeff Davis <davis@xarg.net>
    @creation-date 2005-03-11
    @cvs-id $Id$
}

ad_proc -public -callback navigation::package_admin -impl forums {} {
    return the admin actions for the forum package.
} {
    set actions {}

    # Check for admin on the package...
    if {[permission::permission_p -object_id $package_id -privilege admin -party_id $user_id]} {
        lappend actions [list LINK admin/ [_ acs-kernel.common_Administration] {} [_ forums.Admin_for_all]]

        lappend actions [list LINK \
                             [export_vars -base admin/permissions {{object_id $package_id}}] \
                             [_ acs-kernel.common_Permissions] {} [_ forums.Permissions_for_all]]
        lappend  actions [list LINK admin/forum-new [_ forums.Create_a_New_Forum] {} {}]
    }

    # check for admin on the individual forums.
    db_foreach forums {
        select forum_id, name, enabled_p
        from forums_forums
        where package_id = :package_id
        and exists (select 1 from acs_object_party_privilege_map pm
                    where pm.object_id = forum_id
                    and pm.party_id = :user_id
                    and pm.privilege = 'admin')
    } {
        lappend actions [list SECTION "Forum $name ([ad_decode $enabled_p t [_ forums.enabled] [_ forums.disabled]])" {}]

        lappend actions [list LINK [export_vars -base admin/forum-edit forum_id] \
                             [_ forums.Edit_forum_name] {} {}]
        lappend actions [list LINK [export_vars -base admin/permissions {{object_id $forum_id} return_url}] \
                             [_ forums.Permission_forum_name] {} {}]
    }
    return $actions
}


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
    
    set last_poster [db_list_of_lists sel_poster {*SQL*} ]
    set msg "Last Poster of $last_poster"
    lappend result $msg

    set poster [db_list_of_lists sel_user_id {*SQL*} ]
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
    
    db_dml upd_poster { *SQL* }
    db_dml upd_user_id { *SQL* }

    lappend result "Merge of forums is done"

    return $result
}

#Callbacks for application-track 

ad_proc -callback application-track::getApplicationName -impl forums {} { 
        callback implementation 
    } {
        return "forums"
    }    
    
ad_proc -callback application-track::getGeneralInfo -impl forums {} { 
        callback implementation 
    } {
	db_1row my_query {
    		select count(f.forum_id) as result
		FROM forums_forums f, dotlrn_communities_full com
		WHERE com.community_id=:comm_id
		and apm_package__parent_id(f.package_id) = com.package_id	
	}
	
	return "$result"
    }
    
ad_proc -callback application-track::getSpecificInfo -impl forums {} { 
        callback implementation 
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
