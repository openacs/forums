
ad_page_contract {
    
    View a message (and its children)

    @author Ben Adida (ben@openforce)
    @creation-date 2002-05-25
    @cvs-id $id: Exp $
} {
    message_id:integer,notnull
}

# Security
forum::security::require_read_message -message_id $message_id

# Check if the user has admin on the message
set moderate_p [forum::security::can_moderate_message_p -message_id $message_id]
set post_p [forum::security::can_post_message_p -message_id $message_id]

# Load up the message information
forum::message::get -message_id $message_id -array message

# Check if the message is approved
if {!$moderate_p && $message(state) != "approved"} {
    ad_returnredirect "forum-view?forum_id=$message(forum_id)"
    ad_script_abort
}

# Load up the forum information
forum::get -forum_id $message(forum_id) -array forum

# Check preferences for user

# Set some variables for easy SQL access
set forum_id $message(forum_id)
set tree_sortkey $message(tree_sortkey)

if {!$moderate_p} {
    # Select publicly viewable items
    db_multirow responses select_message_responses {}
} else {
    # Select all items
    db_multirow responses select_message_responses_moderator {}
}

# If this is a top-level thread, we allow subscriptions here
if {[empty_string_p $message(parent_id)]} {
    set notification_chunk [notification::display::request_widget -type forums_message_notif -object_id $message_id -pretty_name $message(subject) -url [ad_conn url]?message_id=$message_id]
} else {
    set notification_chunk ""
}

set context_bar [list [list "./forum-view?forum_id=$message(forum_id)" "$message(forum_name)"] {One Message}]

if {$forum(presentation_type) == "flat"} {
    ad_return_template message-view-flat
} else {
    ad_return_template
}


    
