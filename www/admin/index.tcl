ad_page_contract {

    Forums Administration

    @author Ben Adida (ben@openforce.net)
    @creation-date 2002-05-24
    @cvs-id $Id$

}

set parameters_url [export_vars -base "/shared/parameters" { { return_url [ad_return_url] } { package_id {[ad_conn package_id]} } }]
set permissions_url [export_vars -base "permissions" { { object_id {[ad_conn package_id]} } }]
