ad_page_contract {

    Subscribe a list of email addresses to a forum (process form)

    @author Jade Rubick (jade@rubick.com)
    @creation-date 2005-04-08
    @cvs-id $Id$

} {
    forum_id:object_type(forums_forum),notnull
    type_id:object_type(notification_type),notnull
    {lines}
    {return_url:localurl "."}
    interval:object_type(notification_interval),notnull
    delivery_method:object_type(notification_delivery_method),notnull
    {emails ""}
    {subscriber_ids:object_type(user),multiple}
    {create_new_users_p:boolean,notnull "f"}
}

# Select the info
set package_id [ad_conn package_id]
forum::get -forum_id $forum_id -array forum

# Proper scoping?
if {$package_id != $forum(package_id)} {
    ns_log Error "Forum Administration: Bad Scoping of Forum #$forum_id in Forum Editing"
    ad_returnredirect -message "Forum Administration: Bad Scoping of Forum #$forum_id in Forum Editing" "./"
    ad_script_abort
}

set pretty_name $forum(name)

# Check that the object can be subscribed to
permission::require_permission -object_id $forum_id -privilege "read"

ns_write "<html><title>Subscribing users</title><body>"

set lines [join $emails "\n"]



db_transaction {

    # Delete all old requests of this type
    foreach request_id [notification::request::request_ids -object_id $forum_id -type_id $type_id] {
	notification::request::delete -request_id $request_id
    }

    foreach subscriber_id $subscriber_ids {
	ns_write "subscribing [party::name -party_id $subscriber_id]<br>"
	notification::request::new \
	    -type_id $type_id \
	    -user_id $subscriber_id \
	    -object_id $forum_id \
	    -interval_id $interval \
	    -delivery_method_id $delivery_method
    }

    foreach line $lines {

	set rows [split $line ","]
	set length [llength $rows]

	set email [lindex $rows 0]
	if {$length > 1} {
	    set fname [lindex $rows 1]
	} else {
	    set fname "(no first name)"
	}

	if {$length > 2} {
	    set lname [lindex $rows 2]
	} else {
	    set lname "(no last name)"
	}

	ns_write "<p>---$email---"

	if {![util_email_valid_p $email]} {
	    set user_id ""
	    ns_write "<br>invalid email address"
	} else {

	    if {[db_0or1row get_party_id {
		select party_id, first_names as fname, last_name as lname
		from   cc_users
		where  lower(email) = lower(:email)
		fetch first 1 rows only
	    }]} {
		set user_id $party_id
		ns_write "<br>account exists"
	    } else {
		set user_id ""
	    }

	}

	ns_write "<br>Name:$fname $lname"


	# user_id is blank if the account doesn't exist or if the
	# email account looks invalid.

	if {$user_id eq ""} {
	    # shall we create the new user?

	    if {[string is true $create_new_users_p]} {

		if {[util_email_valid_p $email]} {
		    ns_write "creating new user: $fname $lname ($email)<br>"

		    # create new user
		    set user_exists_p [db_string user_id {
                        select case when exists
                        (select 1 from parties where email = lower(:email))
                        then 1 else 0 end
                        from dual
                    }]

		    if {!$user_exists_p} {
			set password [ad_generate_random_string]

			array set auth_status_array [auth::create_user -email $email -first_names $fname -last_name $lname -password $password]

			set user_id $auth_status_array(user_id)
		    }
		} else {
		    ns_write "<br>invalid email address: $email"
		}
	    } else {
		ns_write "<br>skipping user (not creating): $fname $lname ($email)"
	    }

	}

	if {$user_id ne ""} {

	    # Check if subscribed
	    set request_id [notification::request::get_request_id -type_id $type_id -object_id $forum_id -user_id $user_id]

	    if {$request_id ne ""} {
		ns_write "<br>already subscribed ($fname $lname ($email)<br />"
	    } else {
		ns_write "subscribing ($fname $lname ($email)<br>"
		notification::request::new \
		    -type_id $type_id \
		    -user_id $user_id \
		    -object_id $forum_id \
		    -interval_id $interval \
		    -delivery_method_id $delivery_method
	    }
	}

    }
}

ns_write "<p>Complete</p>"
ns_write [subst {<a href="[ns_quotehtml $return_url]">return</a>}]

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
