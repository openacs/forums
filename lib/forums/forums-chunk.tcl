ad_page_contract {

    top level list of forums

    @author Ben Adida (ben@openforce.net)
    @creation-date 2002-05-24
    @cvs-id $Id$

}

set package_id [ad_conn package_id]
set user_id [ad_verify_and_get_user_id]

# get the colors from the params
set table_border_color [parameter::get -parameter table_border_color]
set table_bgcolor [parameter::get -parameter table_bgcolor]
set table_other_bgcolor [parameter::get -parameter table_other_bgcolor]

db_multirow -extend { last_modified_pretty } forums select_forums {} {
    set last_modified_pretty [lc_time_fmt $last_post_ansi "%x %X"]
}

if {[exists_and_not_null alt_template]} {
  ad_return_template $alt_template
}
