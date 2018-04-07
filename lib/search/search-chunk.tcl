ad_page_contract {

    @author yon@openforce.net
    @creation-date 2002-07-01
    @cvs-id $Id$

}
set package_id [ad_conn package_id]
set useScreenNameP [parameter::get -parameter "UseScreenNameP" -default 0]

set searchbox_p [parameter::get -parameter ForumsSearchBoxP -package_id $package_id -default 1]
if {$searchbox_p} {
    form create search -has_submit 1
    forums::form::search search

    if {[form is_valid search]} {
        form get_values search search_text forum_id

        # remove any special characters from the search text so we
        # don't crash interMedia
        regsub -all {[^[:alnum:]_[:blank:]]} $search_text {} search_text

        # replace subsequent spaces
        regsub -all {\s+} $search_text " " search_text
        set search_text [string trim $search_text]

        # don't search for empty search strings
        if {[string length $search_text] < 3} {
            set name search_text
            set min_length 3
            set actual_length [string length $search_text]
            ad_page_contract_handle_datasource_error [_ acs-tcl.lt_name_is_too_short__Pl]
            ad_script_abort
        }

        set query search_all_forums
        if {$forum_id ne ""} {
            set query search_one_forum
	    if {![string is integer -strict $forum_id]} {
		ns_log warning "forum_id <$forum_id> is not an integer: probably a security check or an attempted injection"
		set name forum_id
                ad_page_contract_handle_datasource_error [_ acs-tcl.lt_name_is_not_an_intege]
                ad_script_abort
	    }
        }
        
        if { [parameter::get -parameter UseIntermediaForSearchP -default 0] } {
            append query "_intermedia"
        }

        set search_pattern "%${search_text}%"
        db_multirow -extend { author posting_date_pretty} messages $query {} {
            set posting_date_pretty [lc_time_fmt $posting_date_ansi "%x %X"]
            if { $useScreenNameP } {
                set author [db_string select_screen_name {select screen_name from users where user_id = :user_id}]
            } else {
                set author $user_name
            }
        }
    } else {
        set messages:rowcount 0
    }

    if {[info exists alt_template] && $alt_template ne ""} {
        ad_return_template $alt_template
    }
}

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
