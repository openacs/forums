ad_library {
    Automated tests.
    @author Gustaf Neumann

    @creation-date 24 July 2018
}

namespace eval forums::test {

    ad_proc -private new {
	{-presentation_type flat}
	{-posting_policy open}
	{-user_id 0}
	name
    } {
        Create a new forum via the web interface.
    } {

	# Get the forums admin page url
        #
	set forums_page [aa_get_first_url -package_key forums]

        #
        # Get Data and check status code
        #
        set d [acs::test::http -user_id $user_id $forums_page/admin/forum-new]
        aa_equals "Status code valid" [dict get $d status] 200

        #
        # Get the form specific data (action, method and provided form-fields)
        #
        set form_data [::acs::test::get_form [dict get $d body] {//form[@id="forum"]}]
        
        #
        # Fill in a few values into the form
        #
        set d [::acs::test::form_reply \
                   -user_id $user_id \
                   -url [dict get $form_data @action] \
                   -update [subst {
                       name             "$name"
                       charter          "bla [ad_generate_random_string] bla [ad_generate_random_string]"
                       charter.format    text/plain
                       presentation_type $presentation_type
                       posting_policy    $posting_policy
                   }] \
                   [dict get $form_data fields]]
        set reply [dict get $d body]

        #
        # Check, if the form was correctly validated.
        #
        aa_false  "Reply contains form-error" [string match *form-error* $reply]
        aa_equals "Status code valid" [dict get $d status] 302

	return [dict get $form_data fields forum_id]
    }

    ad_proc -private view {
	{-user_id 0}
	{-forum_id 0}
	{-name ""}
    } {
        View a forum via the web interface.
    } {
	set forums_page [aa_get_first_url -package_key forums]

	if {$name ne ""} {
	    #
	    # Call to the forums page
	    #
	    set d [::acs::test::http -user_id $user_id $forums_page]
	    aa_equals "Status code valid" [dict get $d status] 200
	    
	    #
	    # Follow the link with the provided link label
	    #
	    set d [::acs::test::follow_link \
		       -user_id $user_id \
		       -base $forums_page \
		       -label $name \
		       -html [dict get $d body]]
	    aa_equals "Status code valid" [dict get $d status] 200
	}

	#
	# Check via the forum_id, when provided
	#
	if {$forum_id != 0} {
	    aa_log "check via forum_id"
	    set d [::acs::test::http \
		       -user_id $user_id \
		       $forums_page/forum-view?forum_id=$forum_id]
	    aa_equals "Status code valid" [dict get $d status] 200
	}
	return $d
    }
    
    ad_proc -private edit {
	{-user_id 0}
	{-forum_id 0}
    } {
        Edit a forum via the web interface.
    } {
	set forums_page [aa_get_first_url -package_key forums]

	set d [acs::test::http \
		   -user_id $user_id \
		   $forums_page/admin/forum-edit?forum_id=$forum_id]
	aa_equals "Status code valid" [dict get $d status] 200

        #
        # Get the form specific data (action, method and provided form-fields)
        #
        set form_data [::acs::test::get_form [dict get $d body] {//form[@id="forum"]}]

        #
        # Fill in a few values into the form
        #
	set old_name [dict get $form_data fields name]
	set old_charter [dict get $form_data fields name]
	set new_name    "Edited $old_name"
	set new_charter "Edited $old_charter"
        set d [::acs::test::form_reply \
                   -user_id $user_id \
                   -url [dict get $form_data @action] \
                   -update [subst {
                       name             "$new_name"
                       charter          "$new_charter"
                   }] \
                   [dict get $form_data fields]]
        set reply [dict get $d body]
        aa_false  "Reply contains form-error" [string match *form-error* $reply]
	if {[string match *form-error* $reply]} {
	    #set F [open $::acs::rootdir/packages/forums/www/REPLY.html w]; puts $F [dict get $d body]; close $F
	} else {
	    set d [acs::test::http -user_id $user_id $forums_page]
	    aa_true "Overview page contains edited name '$new_name'" [string match *$new_name* [dict get $d body]]
	    aa_true "Overview page contains edited charter" [string match *$new_charter* [dict get $d body]]	
	}
    }

}
