
ad_page_contract {

    Moderate a Forum

    @author Ben Adida (ben@openforce)
    @creation-date 2002-05-24
    @cvs-id $Id$
} {
    forum_id:integer,notnull
}

# Check that the user can moderate the forum
forum::security::require_moderate_forum -forum_id $forum_id

# Get forum data
forum::get -forum_id $forum_id -array forum

# Get the threads that need approval
db_multirow pending_threads select_pending_threads {}

ad_return_template
