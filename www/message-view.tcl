ad_page_contract {
    
    view a message (and its children)

    @author Ben Adida (ben@openforce.net)
    @creation-date 2002-05-25
    @cvs-id $Id$

} {
    message_id:integer,notnull
}

forum::security::require_read_message -message_id $message_id

# get the colors from the params
set table_border_color [parameter::get -parameter table_border_color]
set table_bgcolor [parameter::get -parameter table_bgcolor]
set table_other_bgcolor [parameter::get -parameter table_other_bgcolor]

# Check if the user has admin on the message
set moderate_p [forum::security::can_moderate_message_p -message_id $message_id]
if {!${moderate_p}} {
    set post_p [forum::security::can_post_message_p -message_id $message_id]
} else {
    set post_p 1
}

# Load up the message information
forum::message::get -message_id $message_id -array message

form create search -action search

element create search search_text \
    -label Search \
    -datatype text \
    -widget text

element create search forum_id \
    -label ForumID \
    -datatype text \
    -widget hidden \
    -value $message(forum_id)

# Check if the message is approved
if {!${moderate_p} && ![string equal $message(state) approved]} {
    ad_returnredirect "forum-view?forum_id=$message(forum_id)"
    ad_script_abort
}

# Load up the forum information
forum::get -forum_id $message(forum_id) -array forum

# If disabled!
if {$forum(enabled_p) != "t"} {
    ad_returnredirect "./"
    ad_script_abort
}

if {$forum(posting_policy) == "moderated"} {
    set forum_moderated_p 1
} else {
    set forum_moderated_p 0
}

# Check preferences for user

# Set some variables for easy SQL access
set forum_id $message(forum_id)
set tree_sortkey $message(tree_sortkey)

if {[forum::attachments_enabled_p]} {
    set query select_message_responses_attachments
} else {
    set query select_message_responses
}

# We set a Tcl variable for moderation now (Ben)
if {$moderate_p} {
    set table_name "forums_messages"
} else {
    set table_name "forums_messages_approved"
}

# More Tcl vars (we might as well use them - Ben)
if {[string equal $forum(presentation_type) flat]} {
    set order_by "posting_date, tree_sortkey"
} else {
    set order_by "tree_sortkey"
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
} else {
    set notification_chunk ""
}

set context [list [list "./forum-view?forum_id=$message(forum_id)" "$message(forum_name)"]]
if {![empty_string_p $message(parent_id)]} {
    lappend context [list "./message-view?message_id=$message(root_message_id)" "Entire Thread"]
    lappend context {One Message}
} else {
    lappend context {One Thread}
}

if {[string equal $forum(presentation_type) flat]} {
    ad_return_template "message-view-flat"
} else {
    ad_return_template
}
