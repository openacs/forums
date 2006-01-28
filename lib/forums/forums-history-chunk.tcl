ad_page_contract {
    
    Forums History 

    @author Natalia Pérez (nperper@it.uc3m.es)
    @creation-date 2005-03-17    

}

set package_id [ad_conn package_id]

# get the colors from the params
set table_border_color [parameter::get -parameter table_border_color]
set table_bgcolor [parameter::get -parameter table_bgcolor]
set table_other_bgcolor [parameter::get -parameter table_other_bgcolor]


db_multirow persons select_users_wrote_post {} 

if {[exists_and_not_null alt_template]} {
  ad_return_template $alt_template
}
