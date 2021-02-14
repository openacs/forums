ad_page_contract {

    view a message (and its children)

    @author Ben Adida (ben@openforce.net)
    @creation-date 2002-05-25
    @cvs-id $Id$

} {
    message_id:naturalnum,notnull
    {display_mode:word ""}
} -validate {
    valid_message_id -requires {message_id:naturalnum} {
        # Load up the message information
        forum::message::get -message_id $message_id -array message
        if {![array exists message]} {
            ad_complain "Invalid message_id"
        }
    }
}

#######################
#
# First check all reasons why we might abort
#
#######################


# Load up the forum information
forum::get -forum_id $message(forum_id) -array forum

# If disabled!
if {$forum(enabled_p) != "t"} {
    ad_returnredirect "./"
    ad_script_abort
}

set user_id [ad_conn user_id]
forum::security::require_read_forum -forum_id $message(forum_id)
forum::security::permissions -forum_id $message(forum_id) -- permissions

# Check if the message is approved
if {!$permissions(moderate_p) && $message(state) ne "approved" } {
    ad_returnredirect "forum-view?forum_id=$message(forum_id)"
    ad_script_abort
}

############################################
#
# Ok we're not aborting so let's do some work
#
############################################

# Users who subscribed to moderator notifications should be able to
# unsubscribe even after their moderation privileges have been revoked.
set type_id [notification::type::get_type_id -short_name forums_message_moderator_notif]
set request_id [notification::request::get_request_id -type_id $type_id -object_id $message(message_id) -user_id $user_id]
set moderator_notifications_p [expr {$request_id ne "" ||
                                     ($forum(posting_policy) eq "moderated" && $permissions(moderate_p))}]

# Show search box?
set searchbox_p [parameter::get -parameter ForumsSearchBoxP -default 1]

# Show notification controls if the request is not from a bot.
set show_notifications_p [expr {![ad_conn bot_p]}]

# If this is a top-level thread, we allow subscriptions here
if { $message(parent_id) eq "" } {
    set message_url [export_vars -base [ad_conn url] {message_id $message(message_id)}]
}

if { [forum::use_ReadingInfo_p] && $message(state) eq "approved" } {
    set msg_id $message(root_message_id)
    set db_antwort [db_exec_plsql forums_reading_info__user_add_msg {}]
}

set context [list [list "./forum-view?forum_id=$message(forum_id)" "$message(forum_name)"]]
if {$message(parent_id) ne ""} {
    lappend context [list "./message-view?message_id=$message(root_message_id)" "$message(root_subject)"]
    lappend context [_ forums.One_Message]
} else {
    lappend context "$message(subject)"
}

if { $permissions(post_p) } {
    set reply_url [export_vars -base message-post { { parent_id $message(message_id) } }]
}

set thread_url [export_vars -base forum-view { { forum_id $message(forum_id) } }]

if {$forum(presentation_type) eq "flat"} {
    set display_mode flat
}

# stylesheets
set lang [ad_conn language]
template::head::add_css -href /resources/forums/forums.css -media all -lang $lang

# set vars for i18n
template::head::add_script -type "text/javascript" -script [subst {
    var collapse_alt_text='[_ forums.collapse]';
    var expand_alt_text='[_ forums.expand]';
    var collapse_link_title='[_ forums.collapse_message]';
    var expand_link_title='[_ forums.expand_message]';}] -order 1

# js scripts
template::head::add_script -type "text/javascript" -src "/resources/forums/forums.js" -order 2

set doc(title) [_ forums.Thread_title]

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
