ad_page_contract {
    
    Posting History for a User

    @author Ben Adida (ben@openforce.net)
    @creation-date 2002-05-29
    @cvs-id $Id$

} {
    groupby:optional
}

set package_id [ad_conn package_id]

# get the colors from the params
set table_border_color [parameter::get -parameter table_border_color]
set table_bgcolor [parameter::get -parameter table_bgcolor]
set table_other_bgcolor [parameter::get -parameter table_other_bgcolor]

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
if {[string equal $view forum]} {
    set query select_messages_by_forum
    template::list::create \
	-html {width 50%} \
	-name messages \
	-multirow messages \
	-key message_id \
	-elements {
	    forum_name {
		label "\#forums.Forum\#"
		hide_p t
		html {align left}
		display_template {<a href=\"forum-view?forum_id=@messages.forum_id@\">@messages.forum_name@</if>}
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
	} -groupby {
	    label "\#forums.Forum\#"
	    values { "\#forums.Forum\#" {{groupby forum_name} {orderby forum_name,desc}}}
	}
} else {
    template::list::create \
	-html {width 50%} \
	-name messages \
	-multirow messages \
	-key message_id \
	-elements {
	    forum_name {
		label "\#forums.Forum\#"
		html {align left}
		display_template {<a href=\"forum-view?forum_id=@messages.forum_id@\">@messages.forum_name@</if>}
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
    -multirow posts \
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

if {[exists_and_not_null alt_template]} {
  ad_return_template $alt_template
}
