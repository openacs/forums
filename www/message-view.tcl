ad_page_contract {
    
    view a message (and its children)

    @author Ben Adida (ben@openforce.net)
    @creation-date 2002-05-25
    @cvs-id $Id$

} {
    message_id:integer,notnull
}

set top_message_id $message_id

forum::security::require_read_message -message_id $message_id

# get the colors from the params
set table_border_color [parameter::get -parameter table_border_color]
set table_bgcolor [parameter::get -parameter table_bgcolor]
set table_other_bgcolor [parameter::get -parameter table_other_bgcolor]

# Load up the message information
forum::message::get -message_id $message_id -array message

set direct_url_base [export_vars -base [ad_conn url] { { message_id $message(root_message_id) } }]
set message(direct_url) "$direct_url_base\#$message_id"

# Check if the user has admin on the message
set moderate_p [forum::security::can_moderate_message_p -message_id $message_id]
if {!${moderate_p}} {
    set post_p [forum::security::can_post_forum_p -forum_id $message(forum_id)]
} else {
    set post_p 1
}

form create search -action search

element create search search_text \
    -label [_ forums.Search] \
    -datatype text \
    -widget text

element create search forum_id \
    -label [_ forums.ForumID] \
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
if { $moderate_p } {
    set table_name "forums_messages"
} else {
    set table_name "forums_messages_approved"
}

#####
#
# Find ordering of messages
#
#####

if { [string equal $forum(presentation_type) flat] } {
    set order_by "fma.posting_date, fma.tree_sortkey"
} else {
    set order_by "fma.tree_sortkey"
}

set forum_id $message(forum_id)
set root_message_id $message(root_message_id)
set message_id_list [db_list select_message_ordering {}]

set message(number) [expr [lsearch $message_id_list $message(message_id)] + 1]
set message(parent_number) {}
if { [exists_and_not_null message(parent_id)] } {
    set message(parent_number) [expr [lsearch $message_id_list $message(parent_id)] + 1]
    set message(parent_direct_url) "$direct_url_base\#$message(parent_id)"
}




#####
#
# Find responses
#
#####

# More Tcl vars (we might as well use them - Ben)
if { [string equal $forum(presentation_type) flat] } {
    set order_by "$table_name.posting_date, tree_sortkey"
} else {
    set order_by "tree_sortkey"
}

set last_message_id $message(message_id)
db_multirow -extend { posting_date_pretty direct_url number parent_number parent_direct_url } responses $query {} {
    set posting_date_pretty [lc_time_fmt $posting_date_ansi "%x %X"]
    set direct_url "$direct_url_base\#$message_id"
    set number [expr [lsearch $message_id_list $message_id] + 1]
    set parent_number [expr [lsearch $message_id_list $parent_id] + 1]
    set parent_direct_url "$direct_url_base\#$parent_id"

    # Note that this variable is purposefully not part of the multirow
    set last_message_id $message_id
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

if { $post_p || [ad_conn user_id] == 0 } {
    set reply_url [export_vars -base message-post { { parent_id $message(message_id) } }]
}

set thread_url [export_vars -base forum-view { { forum_id $message(forum_id) } }]

if {[string equal $forum(presentation_type) flat]} {
    ad_return_template "message-view-flat"
} else {
    ad_return_template
}

