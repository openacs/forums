ad_page_contract {
    
    view a message (and its children)

    @author Ben Adida (ben@openforce.net)
    @creation-date 2002-05-25
    @version $Id$

} {
    message_id:integer,notnull
}

forum::security::require_read_message -message_id $message_id

# Check if the user has admin on the message
set moderate_p [forum::security::can_moderate_message_p -message_id $message_id]
if {!${moderate_p}} {
    set post_p [forum::security::can_post_message_p -message_id $message_id]
} else {
    set post_p 1
}

# Load up the message information
forum::message::get -message_id $message_id -array message

# Check if the message is approved
if {!${moderate_p} && ![string equal $message(state) approved]} {
    ad_returnredirect "forum-view?forum_id=$message(forum_id)"
    ad_script_abort
}

# Load up the forum information
forum::get -forum_id $message(forum_id) -array forum

# Check preferences for user

# Set some variables for easy SQL access
set forum_id $message(forum_id)
set tree_sortkey $message(tree_sortkey)

set query select_message_responses
if {$moderate_p} {
    set query select_message_responses_moderator
}

if {[string equal $forum(presentation_type) flat]} {
    append query "_flat"
}

db_multirow responses $query {}

# If this is a top-level thread, we allow subscriptions here
if {[empty_string_p $message(parent_id)]} {
    set notification_chunk [notification::display::request_widget \
        -type forums_message_notif \
        -object_id $message_id \
        -pretty_name $message(subject) \
        -url [ad_conn url]?message_id=$message_id \
    ]
    append notification_chunk "<br><br>"
} else {
    set notification_chunk ""
}

set context_bar [list [list "./forum-view?forum_id=$message(forum_id)" "$message(forum_name)"]]
if {![empty_string_p $message(parent_id)]} {
    lappend context_bar [list "./message-view?message_id=$message(root_message_id)" "Entire Thread"]
}
lappend context_bar {One Message}

if {[string equal $forum(presentation_type) flat]} {
    ad_return_template "message-view-flat"
} else {
    ad_return_template
}
