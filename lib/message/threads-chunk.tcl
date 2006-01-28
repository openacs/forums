ad_page_contract {

    one forum view

    @author Ben Adida (ben@openforce.net)
    @creation-date 2002-05-24
    @cvs-id $Id$

}

# Get forum data
forum::get -forum_id $forum_id -array forum

set query messages_select
if {$moderate_p} {
    set query messages_select_moderator
}

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
            orderby_asc_name "orderby_user_name_asc"
            orderby_desc_name "orderby_user_name_desc"
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

if {[exists_and_not_null alt_template]} {
  ad_return_template $alt_template
}
