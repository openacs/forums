ad_page_contract {
    
    view a message (and its children)

    @author Ben Adida (ben@openforce.net)
    @creation-date 2002-05-25
    @cvs-id $Id$

} {
    message_id:integer,notnull
}

#######################
#
# First check all reasons why we might abort
#
#######################

# Load up the message information
forum::message::get -message_id $message_id -array message

# Load up the forum information
forum::get -forum_id $message(forum_id) -array forum

# If disabled!
if {$forum(enabled_p) != "t"} {
    ad_returnredirect "./"
    ad_script_abort
}

forum::security::require_read_message -message_id $message_id
forum::security::permissions -forum_id $message(forum_id) permissions

# Check if the user has admin on the message
set permissions(moderate_p) [forum::security::can_moderate_message_p -message_id $message_id]
if {!${permissions(moderate_p)}} {
    set permissions(post_p) [forum::security::can_post_forum_p -forum_id $message(forum_id)]
} else {
    set permissions(post_p) 1
}

# Check if the message is approved
if {!${permissions(moderate_p)} && ![string equal $message(state) approved]} {
    ad_returnredirect "forum-view?forum_id=$message(forum_id)"
    ad_script_abort
}

############################################
#
# Ok we're not aborting so lets do some work
#
############################################

# Create a search form and action when used
set searchbox_p [parameter::get -parameter ForumsSearchBoxP -default 1]
if {$searchbox_p} { 
    form create search -action search
    forums::form::search search

    if {[form is_request search]} {
        element set_properties search forum_id -value $message(forum_id)
    }
}


# If this is a top-level thread, we allow subscriptions here
if { [empty_string_p $message(parent_id)] } {
    set notification_chunk [notification::display::request_widget \
        -type forums_message_notif \
        -object_id $message(message_id) \
        -pretty_name $message(subject) \
        -url [ad_conn url]?message_id=$message(message_id) \
    ]
} else {
    set notification_chunk ""
}

set context [list [list "./forum-view?forum_id=$message(forum_id)" "$message(forum_name)"]]
if {![empty_string_p $message(parent_id)]} {
    lappend context [list "./message-view?message_id=$message(root_message_id)" "[_ forums.Entire_Thread]"]
    lappend context [_ forums.One_Message]
} else {
    lappend context [_ forums.One_Thread]
}

if { $permissions(post_p) || [ad_conn user_id] == 0 } {
    set reply_url [export_vars -base message-post { { parent_id $message(message_id) } }]
}

set thread_url [export_vars -base forum-view { { forum_id $message(forum_id) } }]
