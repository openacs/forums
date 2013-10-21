ad_page_contract {
    
    Posting History for a User

    @author Ben Adida (ben@openforce.net)
    @creation-date 2002-05-29
    @cvs-id $Id$

} {
    groupby:optional
}

set package_id [ad_conn package_id]

# provide screen_name functionality
set useScreenNameP [parameter::get -parameter "UseScreenNameP" -default 0]

if {$useScreenNameP} {

   acs_user::get -user_id $viewer_id -array user_info
   set message(screen_name) $user_info(screen_name)

} else {
   set message(screen_name) ""
}
set user_link [acs_community_member_link -user_id $user_id]


# choosing the view
set dimensional_list "
    {
        view \"[_ forums.View]:\" date {
            {date \"[_ forums.by_Date]\" {}}
            {forum \"[_ forums.by_Forum]\" {}}
        }
    }
"

set query select_messages
if {$view eq "forum"} {
    set query select_messages_by_forum
    template::list::create \
        -html {style "width: 50%; text-align: center; margin: auto"} \
        -name messages \
        -multirow messages \
        -no_data "#forums.No_Postings#" \
        -key message_id \
        -elements {
            forum_name {
                label "\#forums.Forum\#"
                hide_p t
                html {align left}
                display_template {<a href=\"forum-view?forum_id=@messages.forum_id@\" title="#forums.go_to_forum# @messages.forum_name@">@messages.forum_name@</a>}
            }   
            subject {
                label "\#forums.Subject\#"
                html {align left}
                display_template {<a href="message-view?message_id=@messages.message_id@" title="#forums.view_message# @messages.subject@">@messages.subject@</a>}
            }
            posting_date_pretty {
                label "\#forums.Posted\#"
                html {align right}
            }
        } -groupby {
            label "\#forums.Forum\#"
            values { "\#forums.Forum\#" {{groupby forum_name} {orderby forum_name,desc}}}
        }
} else {
    template::list::create \
        -html {style "width: 50%; text-align: center; margin: auto"} \
        -name messages \
        -multirow messages \
        -no_data "#forums.No_Postings#" \
        -key message_id \
        -elements {
            forum_name {
                label "\#forums.Forum\#"
                html {align left}
                display_template {<a href=\"forum-view?forum_id=@messages.forum_id@\">@messages.forum_name@</a>}
            }   
            subject {
                label "\#forums.Subject\#"
                html {align left}
                display_template {<a href="message-view?message_id=@messages.message_id@">@messages.subject@</a>}
            }
            posting_date_pretty {
                label "\#forums.Posted\#"
                html {align right}
            }
        }
}


# Select the postings
db_multirow -extend { posting_date_pretty } messages $query {} {
    set posting_date_pretty [lc_time_fmt $posting_date_ansi "%x %X"]
}

template::list::create \
    -name posts \
    -html {style "width: 50%; text-align: center; margin: auto"} \
    -multirow posts \
    -no_data "#forums.No_Postings#" \
    -key message_id \
    -elements {
        name {
            label "\#forums.Forum\#"
            html {align left}
            display_template {<a href="forum-view?forum_id=@posts.forum_id@">@posts.name@</a>}
        }
        num_msg {
            label "\#forums.Number_of_Posts\#"
            html {align left}
        }
        posting_date_pretty {
            label "\#forums.Posted\#"
            html {align right}
        }
    }

# select number of post from this user
db_multirow -extend { posting_date_pretty } posts select_num_post {} {
    set posting_date_pretty [lc_time_fmt $last_post "%x %X"]
} 

set dimensional_chunk [ad_dimensional $dimensional_list]

if {([info exists alt_template] && $alt_template ne "")} {
    ad_return_template $alt_template
}
