ad_page_contract {
    
    Search messages for a string

    @author Rob Denison (rob@thaum.net)
    @creation-date 2003-12-08
    @cvs-id $Id$

}

# get the colors from the params
set table_border_color [parameter::get -parameter table_border_color]
set table_bgcolor [parameter::get -parameter table_bgcolor]
set table_other_bgcolor [parameter::get -parameter table_other_bgcolor]

if {[exists_and_not_null alt_template]} {
  ad_return_template $alt_template
}
