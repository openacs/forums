ad_page_contract {

    one forum view

    @author Ben Adida (ben@openforce.net)
    @creation-date 2002-05-24
    @cvs-id $Id$

} -query {
    forum_id:integer,notnull
}


forum::security::require_read_forum -forum_id $forum_id

# get the colors from the params
set table_border_color [parameter::get -parameter table_border_color]
set table_bgcolor [parameter::get -parameter table_bgcolor]
set table_other_bgcolor [parameter::get -parameter table_other_bgcolor]

set package_id [ad_conn package_id]
set user_id [ad_verify_and_get_user_id]
set admin_p [forum::security::can_admin_forum_p -forum_id $forum_id]

if {!${admin_p}} {
    set moderate_p [forum::security::can_moderate_forum_p -forum_id $forum_id]
    if {!${moderate_p}} {
        set post_p [forum::security::can_post_forum_p -forum_id $forum_id]
    } else {
        set post_p 1
    }
} else {
    set moderate_p 1
    set post_p 1
}

form create search -action search

element create search search_text \
    -label Search \
    -datatype text \
    -widget text

element create search forum_id \
    -label ForumID \
    -datatype text \
    -widget hidden \
    -value $forum_id

# Get forum data
forum::get -forum_id $forum_id -array forum

# If disabled!
if {$forum(enabled_p) != "t"} {
    ad_returnredirect "./"
    ad_script_abort
}

set query messages_select
if {$moderate_p} {
    set query messages_select_moderator
}

db_multirow messages $query {}

set notification_chunk [notification::display::request_widget \
    -type forums_forum_notif \
    -object_id $forum_id \
    -pretty_name $forum(name) \
    -url [ad_conn url]?forum_id=$forum_id \
]

set context [list $forum(name)]

ad_return_template
