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
	acs::test::reply_contains_no $d form-error
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
	
	if {[acs::test::reply_contains_no $d form-error]} {
	    set d [acs::test::http -user_id $user_id $forums_page]
	    acs::test::reply_contains -prefix "Overview page" $d $new_name
	    acs::test::reply_contains -prefix "Overview page" $d $new_charter	    
	}
    }

    ad_proc -private new_postings {
	{-user_id 0}
	{-forum_id 0}
    } {
	Add a posting to the provided forum via the web interface.

	@return message_id
    } {
	set message_id 0
	set forums_page [aa_get_first_url -package_key forums]

	set d [acs::test::http \
		   -user_id $user_id \
		   $forums_page/message-post?forum_id=$forum_id]
	aa_equals "Edit Message: Status code valid" [dict get $d status] 200

	#
	# Get form data from
	#
	set form_data [::acs::test::get_form [dict get $d body] {//form[@id="message"]}]
	aa_true "Found form on reply page" {[llength $form_data] > 0}

	#
	# Build reply
	#
	set subject      "subject [ad_generate_random_string]"
	set message_body "body [ad_generate_random_string 20]"

	set d [::acs::test::form_reply \
		   -user_id $user_id \
		   -url [dict get $form_data @action] \
		   -update [subst {
		       subject          "$subject"
		       message_body     "$message_body"
		       message_body.format text/plain
		   }] \
		   [dict get $form_data fields]]

	acs::test::reply_contains_no $d form-error
	aa_equals "Updated message: Status code valid" [dict get $d status] 302

	aa_log [dict get $form_data fields]
	set message_id [dict get $form_data fields message_id]

	#
	# Check on the forums overview page, if we find the new subject
	#
	set d [acs::test::http -user_id $user_id $forums_page/forum-view?forum_id=$forum_id]
	aa_equals "View Forum: Status code valid" [dict get $d status] 200

	acs::test::reply_contains $d $subject

	#
	# Check on the forums view page, if we find the new subject and the new body
	#
	set d [acs::test::http -user_id $user_id $forums_page/message-view?message_id=$message_id]
	aa_equals "View Message: Status code valid" [dict get $d status] 200

	acs::test::reply_contains $d $subject
	acs::test::reply_contains $d $message_body

	#
	# Post a reply to the last message
	#
	set d [acs::test::http -user_id $user_id $forums_page/message-post?parent_id=$message_id]
	set form_data [::acs::test::get_form [dict get $d body] {//form[@id="message"]}]
	aa_true "Found form on edit page for posting reply" {[llength $form_data] > 0}
	set reply_message_id [dict get $form_data fields message_id]

	set d [::acs::test::form_reply \
		   -user_id $user_id \
		   -url [dict get $form_data @action] \
		   -update [subst {
		       message_body        "REPLY $message_body"
		       message_body.format text/plain
		   }] \
		   [dict get $form_data fields]]
	acs::test::reply_contains_no $d form-error
	aa_equals "Entered forums reply: Status code valid" [dict get $d status] 302

	#
	# The reply should show up on the forums thread page
	#
	set d [acs::test::http -user_id $user_id $forums_page/message-view?message_id=$message_id]
	aa_equals "Message overview: Status code valid" [dict get $d status] 200
	acs::test::reply_contains $d "REPLY $message_body"

	#
	# Edit the reply
	#
	set d [acs::test::http -user_id $user_id $forums_page/moderate/message-edit?message_id=$reply_message_id]
	set form_data [::acs::test::get_form [dict get $d body] {//form[@id="message"]}]
	aa_true "Found form on edit page for editing reply" {[llength $form_data] > 0}
	set old_reply_message_body [dict get $form_data fields message_body]
	set new_reply_message_body "$old_reply_message_body EDITED"
	aa_true "old message_body contains REPLY" [string match "*REPLY*" $old_reply_message_body]

	set d [::acs::test::form_reply \
		   -user_id $user_id \
		   -url [dict get $form_data @action] \
		   -update [subst {
		       message_body        "$new_reply_message_body"
		   }] \
		   [dict get $form_data fields]]
	acs::test::reply_contains_no $d form-error
	aa_equals "Entered forums reply: Status code valid" [dict get $d status] 302

	#
	# The edited reply should show up on the forums thread page
	#
	set d [acs::test::http -user_id $user_id $forums_page/message-view?message_id=$message_id]
	aa_equals "Message overview: Status code valid" [dict get $d status] 200
	acs::test::reply_contains $d "$new_reply_message_body"

	#
	# Delete the reply
	#
	set d [acs::test::http -user_id $user_id $forums_page/moderate/message-delete?message_id=$reply_message_id]
	aa_equals "Message overview: Status code valid" [dict get $d status] 200
	acs::test::reply_contains $d message-delete?confirm_p

	set d [::acs::test::follow_link \
		   -user_id $user_id \
		   -base $forums_page/moderate \
		   -label Yes \
		   -html [dict get $d body]]
	aa_equals "Message overview: Status code valid" [dict get $d status] 302

	#
	# The edited reply should no show up up on the forums thread page
	#
	set d [acs::test::http -user_id $user_id $forums_page/message-view?message_id=$message_id]
	aa_equals "Message overview: Status code valid" [dict get $d status] 200
	acs::test::reply_contains_no $d "$new_reply_message_body"

	return $message_id
    }

}
