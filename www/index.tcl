ad_page_contract {

    top level list of forums

    @author Ben Adida (ben@openforce.net)
    @creation-date 2002-05-24
    @version $Id$

}

set package_id [ad_conn package_id]
set user_id [ad_verify_and_get_user_id]
set admin_p [permission::permission_p -party_id $user_id -object_id $package_id -privilege admin]

# get the colors from the params
set table_border_color [parameter::get -parameter table_border_color]
set table_bgcolor [parameter::get -parameter table_bgcolor]
set table_other_bgcolor [parameter::get -parameter table_other_bgcolor]

form create search -action search

element create search search_text \
    -label Search \
    -datatype text \
    -widget text

element create search forum_id \
    -label ForumID \
    -datatype text \
    -widget hidden \
    -value ""

db_multirow forums select_forums {}

set context_bar {}

ad_return_template
