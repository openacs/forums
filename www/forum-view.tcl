
ad_page_contract {

    One Forum View

    @author Ben Adida (ben@openforce)
    @creation-date 2002-05-24
    @cvs-id $Id$
} {
    forum_id:integer,notnull
}

# Security Check
forum::security::require_read_forum -forum_id $forum_id

set package_id [ad_conn package_id]

set user_id [ad_verify_and_get_user_id]
set admin_p [forum::security::can_admin_forum_p -forum_id $forum_id]
set moderate_p [forum::security::can_moderate_forum_p -forum_id $forum_id]

# Get forum data
forum::get -forum_id $forum_id -array forum

if {!$moderate_p} {
    # Normal select
    db_multirow messages messages_select {}
} else {
    # Moderator select!
    db_multirow messages messages_select_moderator {}
}

set post_p [forum::security::can_post_forum_p -forum_id $forum_id]

set notification_chunk [notification::display::request_widget -type forums_forum_notif -object_id $forum_id -pretty_name $forum(name) -url [ad_conn url]?forum_id=$forum_id]

set context_bar [list $forum(name)]

ad_return_template
