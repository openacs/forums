ad_page_contract {

    one forum view

    @author Ben Adida (ben@openforce.net)
    @creation-date 2002-05-24
    @cvs-id $Id$

} -query {
    forum_id:integer,notnull
    {orderby "last_child_post,desc"}
    page:optional
}

# Get forum data
forum::get -forum_id $forum_id -array forum

# If disabled!
if {$forum(enabled_p) != "t"} {
    ad_returnredirect "./"
    ad_script_abort
}

forum::security::require_read_forum -forum_id $forum_id
forum::security::permissions -forum_id $forum_id permissions

#it is confusing to provide a moderate link for non-moderated forums.
if { $forum(posting_policy) != "moderated" } {
    set permissions(moderate_p) 0
}

# get the colors from the params
set table_border_color [parameter::get -parameter table_border_color]
set table_bgcolor [parameter::get -parameter table_bgcolor]
set table_other_bgcolor [parameter::get -parameter table_other_bgcolor]

set admin_url [export_vars -base "admin/forum-edit" { forum_id {return_url [ad_return_url]}}]
set moderate_url [export_vars -base "moderate/forum" { forum_id }]
set post_url [export_vars -base "message-post" { forum_id }]

# Create a search form and action when used
form create search -action search
forums::form::search search

if {[form is_request search]} {
  element set_properties search forum_id -value $forum_id
}

# Need to quote forum(name) since it is noquoted on display as part of an 
# HTML fragment.
set notification_chunk [notification::display::request_widget \
    -type forums_forum_notif \
    -object_id $forum_id \
    -pretty_name $forum(name) \
    -url [ad_conn url]?forum_id=$forum_id \
]

set page_title "[_ forums.Forum_1] $forum(name)"
set context [list [ad_quotehtml $forum(name)]]
