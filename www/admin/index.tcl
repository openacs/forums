ad_page_contract {

    Forums Administration

    @author Ben Adida (ben@openforce.net)
    @creation-date 2002-05-24
    @cvs-id $Id$

}

# scoping 
set package_id [ad_conn package_id]

# List of forums
db_multirow forums select_forums {}

ad_return_template
