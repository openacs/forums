ad_page_contract {

    one forum view

    @author Ben Adida (ben@openforce.net)
    @creation-date 2002-05-24
    @cvs-id $Id$

} -query {
    forum_id:naturalnum,notnull
    {orderby:token,notnull "last_child_post,desc"}
    {flush_p:boolean,notnull 0}
    page:naturalnum,optional,notnull
    page_size:naturalnum,optional,notnull
}

ad_try {
    #
    # Get forum data
    #
    forum::get -forum_id $forum_id -array forum

} trap NOT_FOUND {} {
    ns_returnnotfound
    ad_script_abort

} on error {errMsg} {
    error $errMsg $::errorInfo $::errorCode
}

# If disabled!
if {$forum(enabled_p) != "t"} {
    ad_returnredirect "./"
    ad_script_abort
}

forum::security::require_read_forum -forum_id $forum_id
forum::security::permissions -forum_id $forum_id -- permissions

set admin_url [export_vars -base "admin/forum-edit" { forum_id {return_url [ad_return_url]}}]
set moderate_url [export_vars -base "moderate/forum" { forum_id }]
set post_url [export_vars -base "message-post" { forum_id }]

# Show search box?
set searchbox_p [parameter::get -parameter ForumsSearchBoxP -default 1]

# Show notification controls if the request is not from a bot.
set show_notifications_p [expr {![ad_conn bot_p]}]

set forum_url [ad_conn url]?forum_id=$forum_id
template::head::add_css -href /resources/forums/forums.css -media all

set page_title "[_ forums.Forum_1] $forum(name)"
set context [list $forum(name)]

# Users who subscribed to moderator notifications should be able to
# unsubscribe even after their moderation privileges have been revoked.
set type_id [notification::type::get_type_id -short_name forums_forum_moderator_notif]
set request_id [notification::request::get_request_id -type_id $type_id -object_id $forum_id -user_id [ad_conn user_id]]
set moderator_notifications_p [expr {$request_id ne "" ||
                                     ($forum(posting_policy) eq "moderated" && $permissions(moderate_p))}]

set type_id [notification::type::get_type_id -short_name forums_forum_notif]
set notification_count [notification::request::request_count \
                            -type_id $type_id \
                            -object_id $forum_id]

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
