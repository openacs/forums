ad_page_contract {

    top level list of forums

    @author Ben Adida (ben@openforce.net)
    @creation-date 2002-05-24
    @cvs-id $Id$

}

set package_id [ad_conn package_id]
set user_id [ad_verify_and_get_user_id]
set admin_p [permission::permission_p -party_id $user_id -object_id $package_id -privilege admin]

# Create a search form and action when used
form create search -action search
forums::form::search search

set context {}

ad_return_template
