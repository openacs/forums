ad_page_contract {

    one forum view

    @author Ben Adida (ben@openforce.net)
    @creation-date 2002-05-24
    @cvs-id $Id$

} -query {
    forum_id:integer,notnull
    {orderby "posting_date,desc"}
}


forum::security::require_read_forum -forum_id $forum_id

# get the colors from the params
set table_border_color [parameter::get -parameter table_border_color]
set table_bgcolor [parameter::get -parameter table_bgcolor]
set table_other_bgcolor [parameter::get -parameter table_other_bgcolor]

set package_id [ad_conn package_id]
set admin_p [forum::security::can_admin_forum_p -forum_id $forum_id]

if { !$admin_p } {
    set moderate_p [forum::security::can_moderate_forum_p -forum_id $forum_id]
    if { !$moderate_p } {
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
    -label [_ forums.Search_1] \
    -datatype text \
    -widget text

element create search forum_id \
    -label [_ forums.ForumID] \
    -datatype text \
    -widget hidden \
    -value $forum_id

# Get forum data
forum::get -forum_id $forum_id -array forum

#it is confusing to provide a moderate link for non-moderated forums.
if { $forum(posting_policy) != "moderated" } {
    set moderate_p 0
}

# If disabled!
if {$forum(enabled_p) != "t"} {
    ad_returnredirect "./"
    ad_script_abort
}

set query messages_select
if {$moderate_p} {
    set query messages_select_moderator
}

set admin_url [export_vars -base "admin/forum-edit" { forum_id {return_url [ad_return_url]}}]
set moderate_url [export_vars -base "moderate/forum" { forum_id }]
set post_url [export_vars -base "message-post" { forum_id }]

template::list::create \
    -name messages \
    -multirow messages \
    -pass_properties { moderate_p } \
    -elements {
        subject {
            label "#forums.Subject#"
            link_url_col message_url
            display_template {
                <if @messages.new_p@><b>@messages.subject@</b></if>
                <else>@messages.subject@</else>
            }
        }
        state_pretty {
            label "\#forums.Moderate\#"
            hide_p {[ad_decode $moderate_p 1 0 1]}
        }
        user_name {
            label "#forums.Author#"
            link_url_col user_url
        }
        n_messages {
            label "#forums.Replies#"
            display_col n_messages_pretty
            html { align right }
        }
        posting_date {
            label "#forums.First_Post#"
            display_col posting_date_pretty
        }
        last_child_post {
            label "#forums.Last_Post#"
            display_col last_child_post_pretty
        }
    } -orderby {
        posting_date {
            label "#forums.First_Post#"
            orderby posting_date
            default_direction desc
        }
        last_child_post {
            label "#forums.Last_Post#"
            orderby last_child_post
            default_direction desc
        }
        subject {
            label "#forums.Subject#"
            orderby upper(subject)
        }
        user_name {
            label "#forums.Author#"
            orderby_asc {upper(user_name) asc, posting_date desc}
            orderby_desc {upper(user_name) desc, posting_date desc}
        }
        n_messages {
            label "#forums.Replies#"
            orderby_asc {n_messages asc, posting_date desc}
            orderby_desc {n_messages desc, posting_date desc}
        }
    } -filters {
        forum_id {}
    }

db_multirow -extend { 
    last_child_post_pretty
    posting_date_pretty
    message_url
    user_url
    n_messages_pretty
    state_pretty
} messages $query {} {
    set last_child_post_ansi [lc_time_system_to_conn $last_child_post_ansi]
    set last_child_post_pretty [lc_time_fmt $last_child_post_ansi "%x %X"]

    set posting_date_ansi [lc_time_system_to_conn $posting_date_ansi]
    set posting_date_pretty [lc_time_fmt $posting_date_ansi "%x %X"]

    set message_url [export_vars -base "message-view" { message_id }]
    set user_url [export_vars -base "user-history" { user_id }]
    set n_messages_pretty [lc_numeric $n_messages]

    switch $state {
        pending {
            set state_pretty [_ forums.Pending]
        }
        rejected {
            set state_pretty [_ forums.Rejected]
        }
        default {
            set state_pretty {}
        }
    }
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
set context [list $forum(name)]



