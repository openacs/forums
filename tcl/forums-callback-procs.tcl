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


ad_proc -public -callback datamanager::move_forum -impl datamanager {
     -object_id:required
     -selected_community:required
} {
    Move a forum to another class or community
} {

#get the new_package_id
set new_package_id [forum::get_forum_package -community_id $selected_community]   

#update forums_forums table
db_dml update_forums {}
#update acs_objects table (because data redundancy)
db_dml update_forums_acs_objects {}
}


ad_proc -public -callback datamanager::delete_forum -impl datamanager {
     -object_id:required
} {
    Move a forum to the trash
} {

#get trash_id
set trash_package_id [datamanager::get_trash_package_id]    


#update forums_forums table
db_dml del_update_forums {}
#update acs_objects table (because data redundancy)
db_dml del_update_forums_acs_objects {}
}


ad_proc -public -callback datamanager::copy_forum -impl datamanager {
     -object_id:required
     -selected_community:required
     {-mode: "empty"}
} {
    Copy a forum to another class or community
} {
#get forum's data
    set forum_id [db_nextval acs_object_id_seq]   
    set package_id [forum::get_forum_package -community_id $selected_community]
    db_1row get_forum_data {}
    
#create the new forums
    set forum_id [forum::new -forum_id $forum_id \
        -name $name \
        -charter $charter \
        -presentation_type $presentation_type \
        -posting_policy $posting_policy \
        -package_id $package_id \
    ]

#copy the messages??
    switch $mode {
        empty {
           set first_messages 0
           set all_messages 0
        }
        threads {
           set first_messages 1
           set all_messages 0
        }
        all {
           set first_messages 1
           set all_messages 1
        }
        default {
           set first_messages 0
           set all_messages 0
        }
    }

   if { $first_messages == 1 } {
#copy the first message of the threads
       set first_messages_list [db_list_of_lists get_first_messages_list {}]      
       set first_messages_number [llength $first_messages_list]
       
       for {set i 0} {$i < $first_messages_number} {incr i} {
        #code for copying a messages
           set message_id  [db_nextval acs_object_id_seq]
           set subject [lindex [lindex $first_messages_list $i] 0]
           set content [lindex [lindex $first_messages_list $i] 1]
           set user_id [lindex [lindex $first_messages_list $i] 2]
           set formato [lindex [lindex $first_messages_list $i] 3]
           set parent_id [lindex [lindex $first_messages_list $i] 4]


           set message_id [forum::message::new \
               -forum_id $forum_id \
               -message_id $message_id \
               -parent_id $parent_id\
               -subject $subject\
               -content $content\
               -format $formato\
               -user_id $user_id ] 
       }
   
       if { $all_messages == 1 } {
#copy all the messages of the threads
           set all_messages_list [db_list_of_lists get_all_messages_list {}]      
           set all_messages_number [llength $all_messages_list]
           
           for {set i 0} {$i < $all_messages_number} {incr i} {
               
           set message_id  [db_nextval acs_object_id_seq]
           set subject [lindex [lindex $all_messages_list $i] 0]
           set content [lindex [lindex $all_messages_list $i] 1]
           set user_id [lindex [lindex $all_messages_list $i] 2]
           set formato [lindex [lindex $all_messages_list $i] 3]
           set parent_id [lindex [lindex $all_messages_list $i] 4]

               set message_id [forum::message::new \
                   -forum_id $forum_id \
                   -message_id $message_id \
                   -parent_id $parent_id\
                   -subject $subject\
                   -content $content\
                   -format $formato\                   
                   -user_id $user_id ]           
           }
       }
   }
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
    