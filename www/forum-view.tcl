ad_page_contract {

    one forum view

    @author Ben Adida (ben@openforce.net)
    @author Paginator stuff added by Roberto Mello (rmello@fslc.usu.edu)
    @creation-date 2002-05-24
    @version $Id$

} -query {
    {page 1}
    forum_id:integer,notnull
    {mode ""}
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
        set post_p [expr { [ad_conn user_id] == 0 || [forum::security::can_post_forum_p -forum_id $forum_id] }]
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

#set query messages_select

# sort by latest reply
# lets make this the default
#if {[string equal $mode latest]} {
    set query messages_select_latest
#}

# just unanswered questions
if {[string equal $mode unanswered]} {
    set query messages_select_unanswered
}

# since last visit
if {![string equal $user_id 0] && [string equal $mode sincelastvisit]} {
    set query messages_select_sincelastvisit
    set second_to_last_visit [db_string get_last_visit ""]
}

set forums_table forums_messages_approved
if {$moderate_p} {
#    set query messages_select_moderator
    set forums_table forums_messages
}
set paginator_name paginated_messages$forum_id$mode

# paginator stuff
paginator create $query $paginator_name "" -pagesize 30 -groupsize 10 -contextual

paginator get_data ${query}_display_data $paginator_name messages "" message_id $page

paginator get_display_info $paginator_name info $page

set group [paginator get_group $paginator_name $page]

paginator get_context $paginator_name pages [paginator get_pages $paginator_name $group]
paginator get_context $paginator_name groups [paginator get_groups $paginator_name $group 10]

set notification_chunk [notification::display::request_widget \
    -type forums_forum_notif \
    -object_id $forum_id \
    -pretty_name $forum(name) \
    -url [ad_conn url]?forum_id=$forum_id \
]
template::util::multirow_quote_html messages subject
set context [list $forum(name)]
