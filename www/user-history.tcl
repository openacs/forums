ad_page_contract {
    
    Posting History for a User

    @author Ben Adida (ben@openforce)
    @creation-date 2002-05-29
    @version $Id$

} {
    user_id:integer,notnull
    {view "date"}
}

set package_id [ad_conn package_id]

# choosing the view
set dimensional_list {
    {
        view "View:" date {
            {date "by Date" {}}
            {forum "by Forum" {}}
        }
    }
}

set query select_messages
if {[string equal $view forum]} {
    set query select_messages_by_forum
}

# Select the postings
db_multirow messages $query {}

# Get user information
oacs::user::get -user_id $user_id -array user

set dimensional_chunk [ad_dimensional $dimensional_list]

set context_bar {{Posting History}}

ad_return_template
