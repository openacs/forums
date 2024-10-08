ad_page_contract {

    Move a thread to other forum.

    @author Natalia Pérez (nperper@it.uc3m.es)
    @creation-date 2005-03-14   

} {
    message_id:object_type(forums_message),notnull
    selected_forum:object_type(forums_forum),notnull
    {confirm_p:boolean,notnull 0}
}

set table_border_color [parameter::get -parameter table_border_color]

# Select the stuff
forum::message::get -message_id $message_id -array message

# Check that the user can moderate the forum
forum::security::require_moderate_forum -forum_id $message(forum_id)

#form to confirm if a user want to move the thread
ad_form -name confirmed_move -mode {display} \
    -actions [list [list [_ forums.Yes] yes] [list No no] ] \
    -export { message_id return_url selected_forum} \
    -html {enctype multipart/form-data} -form {
 {data:text(hidden)                     {value 0}}
} 
#get the clicked button
set action [template::form::get_action confirmed_move]

if {$action eq "yes"} {
    set confirm_p 1    
}
if {$action eq "no"} {
    set confirm_p 2    
}

#get the name of forum where the thread will be moved
forum::get -forum_id $selected_forum -array forum
set name $forum(name)

# Confirmed
if {$confirm_p == 1} {    
    
    set forum_id $selected_forum
    
    # update the initial father message: update forum_id and
    # tree_sortkey. If in final forum there is no any thread then
    # tree_sortkey is 0, else tree_sortkey=tree_sortkey+1
    set has_posts_p [db_0or1row forums::move_message::has_posts_p {}]
    if {!$has_posts_p} {
        db_dml forums::move_message::update_msg {}
    } else {
        db_foreach forums::move_message::select_tree_sortkey {} {
	    set max_tree_sortkey $tree_sortkey
	}
        db_dml forums::move_message::update_moved_msg {}
    }    
    
    #get all descendents
    db_0or1row forums::move_message::select_tree_sortkey_new {}
    db_foreach forums::move_message::get_all_child {} {          
	set join_tree_sortkey $message_tree_sortkey
	append join_tree_sortkey $child_tree_sortkey	
	#update children messages: forum_id and tree_sortkey
        db_dml forums::move_message::update_children {}        
    }
        
    # update final forum: increase thread_count, approved_thread_count
    # and max_child_sortkey, update last_post
    forum::get -forum_id $forum_id -array forum
    set max_child_sortkey     $forum(max_child_sortkey)
    set thread_count          $forum(thread_count)
    set approved_thread_count $forum(approved_thread_count)
    db_dml forums::move_message::update_forums_final {}
    
    # update initial forum: decrease thread_count,
    # approved_thread_count and max_child_sortkey, update last_post
    forum::get -forum_id $message(forum_id) -array forum
    set max_child_sortkey     $forum(max_child_sortkey)
    set thread_count          $forum(thread_count)
    set approved_thread_count $forum(approved_thread_count)
    db_dml forums::move_message::update_forum_initial {}

    if { [forum::use_ReadingInfo_p] } {
        ns_log Notice "updating reading info $message_id"
        db_dml forums::move_message::update_reading_info {}
    }
        
    # Redirect to the forum
   
    ad_returnredirect -message [_ forums.message_moved] "../forum-view?forum_id=$forum_id"
    ad_script_abort
}

set message_id $message(message_id)
set return_url "../message-view"

if {$confirm_p == 2} {
   #if confirm_p is no then return to the message view
   ad_returnredirect "../message-view?message_id=$message(message_id)"
}
set url_vars [export_vars {message_id return_url selected_forum}]

if {[info exists alt_template] && $alt_template ne ""} {
  ad_return_template $alt_template
}

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
