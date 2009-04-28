ad_page_contract {

    one forum view

    @author Ben Adida (ben@openforce.net)
    @creation-date 2002-05-24
    @cvs-id $Id$

} -query {
    forum_id:integer,notnull
    {orderby "last_child_post,desc"}
		{flush_p 0}
    page:optional
}


# Get forum data
if {[catch {forum::get -forum_id $forum_id -array forum} errMsg]} {
    if {$::errorCode eq "NOT_FOUND"} {
        ns_returnnotfound
        ad_script_abort
    }
    error $errMsg $::errorInfo $::errorCode
}

# If disabled!
if {$forum(enabled_p) ne "t"} {
    ad_returnredirect "./"
    ad_script_abort
}

forum::security::require_read_forum -forum_id $forum_id
forum::security::permissions -forum_id $forum_id -- permissions

#it is confusing to provide a moderate link for non-moderated forums.
if { $forum(posting_policy) ne "moderated" } {
    set permissions(moderate_p) 0
}

set admin_url [export_vars -base "admin/forum-edit" { forum_id {return_url [ad_return_url]}}]
set moderate_url [export_vars -base "moderate/forum" { forum_id }]
set post_url [export_vars -base "message-post" { forum_id }]

# Show search box?
set searchbox_p [parameter::get -parameter ForumsSearchBoxP -default 1]

# Need to quote forum(name) since it is noquoted on display as part of an 
# HTML fragment.
set notification_chunk [notification::display::request_widget \
    -type forums_forum_notif \
    -object_id $forum_id \
    -pretty_name $forum(name) \
    -url [ad_conn url]?forum_id=$forum_id \
]

template::head::add_css -href /resources/forums/forums.css -media all
template::head::add_css -href /resources/forums/print.css -media print

set page_title "[_ forums.Forum_1] $forum(name)"
set context [list $forum(name)]

set type_id [notification::type::get_type_id -short_name forums_forum_notif]
set notification_count [notification::request::request_count \
			    -type_id $type_id \
			    -object_id $forum_id]
