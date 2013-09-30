ad_page_contract {
    
    Search messages for a string

    @author Rob Denison (rob@thaum.net)
    @creation-date 2003-12-08
    @cvs-id $Id$

}

set useScreenNameP [parameter::get -parameter "UseScreenNameP" -default 0]

template::list::create -name results -multirow messages -no_data "#forums.No_Messages#" -elements {
    subject {
        label "#forums.Subject#"
        display_template {
            <a href="message-view?message_id=@messages.message_id@">@messages.subject@</a>
        }
    }
    author {
        label "#forums.Author#"
        display_template {
            <a href="user-history?user_id=@messages.user_id@">@messages.author@</a>
        }
    }
    posting_date_pretty {
        label "#forums.Posting_Date#"
    }
}

if {([info exists alt_template] && $alt_template ne "")} {
  ad_return_template $alt_template
}
