ad_page_contract {
    
    Posting History for a User

    @author Ben Adida (ben@openforce.net)
    @creation-date 2002-05-29
    @cvs-id $Id$

} {
    user_id:integer,notnull
    {view "date"}
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
}

# Select the postings
db_multirow -extend { posting_date_pretty } messages $query {} {
    set posting_date_pretty [lc_time_fmt $posting_date_ansi "%x %X"]
}

# Get user information
oacs::user::get -user_id $user_id -array user

set dimensional_chunk [ad_dimensional $dimensional_list]

set context [list [_ forums.Posting_History]]

ad_return_template



