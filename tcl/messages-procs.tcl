ad_library {

    Forums Library - for Messages

    @creation-date 2002-05-20
    @author Ben Adida <ben@openforce.biz>
    @cvs-id $Id$

}

namespace eval forum::message {

    ad_proc -public new {
        {-forum_id:required}
        {-message_id ""}
        {-parent_id ""}
        {-subject:required}
        {-content:required}
        {-html_p "f"}
        {-user_id ""}
    } {
        create a new message
    } {
        # If no user_id is provided, we set it
        # to the currently logged-in user
        if {[empty_string_p $user_id]} {
            set user_id [ad_conn user_id]
        }

	set original_message_id $message_id
        # Prepare the variables for instantiation
        set extra_vars [ns_set create]
        oacs_util::vars_to_ns_set -ns_set $extra_vars -var_list {forum_id message_id parent_id subject content html_p user_id}

        db_transaction {
            set message_id [package_instantiate_object -extra_vars $extra_vars forums_message]

            get -message_id $message_id -array message
            if {[info exists message(state)] && [string equal $message(state) approved]} {
                do_notifications -message_id $message_id
            }
        }  on_error {

	    db_abort_transaction
	    
	    # Check to see if the message with a message_id matching the
	    # message_id arguement was in the database before calling
	    # this procedure.  If so, the error is due to a double click 
	    # and we should continue without returning an error.
	    
	    if {![empty_string_p $original_message_id]} {
		# The was a non-null message_id arguement
		if {[db_string message_exists_p "
		select count(message_id) 
		from forums_messages 
		where message_id = :message_id"]} {
		    
		    return $message_id
		    
		}
	    }
        }

        return $message_id
    }
    
    ad_proc -public do_notifications {
        {-message_id:required}
    } {
        # Select all the important information
        get -message_id $message_id -array message

        set forum_id $message(forum_id)
        set url "[ad_url][db_string select_forums_package_url {}]"

        set new_content ""
        append new_content "Forum:  <a href=\"${url}forum-view?forum_id=$message(forum_id)\">$message(forum_name)</a><br>\n"
        append new_content "Thread: <a href=\"${url}message-view?message_id=$message(root_message_id)\">$message(root_subject)</a><br>\n"
        append new_content "Author: <a href=\"mailto:$message(user_email)\">$message(user_name)</a><br>\n"
        append new_content "\n<br>\n"
        append new_content $message(content)
	append new_content "<p>-------------------<br>"

        # send text for now.
        set new_content [ad_html_to_text $new_content]
        set html_version $new_content

	set text_version ""
	
        append text_version "Forum: $message(forum_name)
Thread: $message(root_subject)
Author: $message(user_name) ($message(user_email))\n\n"


         if { $message(html_p) } {
             append text_version [ad_html_to_text $message(content)]
         } else {
             append text_version [wrap_string $message(content)]
         }
         append text_version "\n\n-- 
To post a reply to this email or view this message go to: 
${url}message-view?message_id=$message(root_message_id)
"

        set new_content $text_version
        ns_log debug "forums: requesting a notification forum $message(forum_name) subject $message(subject)" 


        # Do the notification for the forum
        notification::new \
            -type_id [notification::type::get_type_id \
            -short_name forums_forum_notif] \
            -object_id $message(forum_id) \
            -response_id $message(message_id) \
            -notif_subject $message(subject) \
            -notif_text $new_content
        
        # Eventually we need notification for the root message too
        notification::new \
            -type_id [notification::type::get_type_id \
            -short_name forums_message_notif] \
            -object_id $message(root_message_id) \
            -response_id $message(message_id) \
            -notif_subject $message(subject) \
            -notif_text $new_content
    }
    
    ad_proc -public edit {
        {-message_id:required}
        {-subject:required}
        {-content:required}
        {-html_p:required}
    } {
        Editing a message. There is no versioning here!
        This means this function is for admins only!
    } {
        # do the update
        db_dml update_message {}
    }

    ad_proc -public set_html_p {
        {-message_id:required}
        {-html_p:required}
    } {
        set whether a message is HTML or not
    } {
        # Straight update to the DB
        db_dml update_message_html_p
    }

    ad_proc -public get {
        {-message_id:required}
        {-array:required}
    } {
        get the fields for a forum
    } {
        # Select the info into the upvar'ed Tcl Array
        upvar $array row

        set query select_message

        if {[ad_conn isconnected] && [forum::attachments_enabled_p]} {
            set query select_message_with_attachment
        }

        db_1row $query {} -column_array row

        # Convert to user's date/time format
        set row(posting_date_pretty) [lc_time_fmt $row(posting_date_ansi) "%x %X"]
    }

    ad_proc -private set_state {
        {-message_id:required}
        {-state:required}
    } {
        Set the new state for a message
        Usually used for approval
    } {
        # simple DB update
        db_dml update_message_state {}
    }

    ad_proc -public reject {
        {-message_id:required}
    } {
        Reject a message
    } {
        set_state -message_id $message_id -state rejected
    }

    ad_proc -public approve {
        {-message_id:required}
    } {
        approve a message
    } {
        db_transaction {
            set_state -message_id $message_id -state approved
            do_notifications -message_id $message_id
        }
    }

    ad_proc -public delete {
        {-message_id:required}
    } {
        delete a message and obviously all of its descendents
    } {
        db_transaction {
            # Remove the notifications
            notification::request::delete_all -object_id $message_id

            # Remove the message
            db_exec_plsql delete_message {}
        }
    }

    ad_proc -public close {
        {-message_id:required}
    } {
        close a thread
        This is not exactly a cheap operation if the thread is long
    } {
        db_exec_plsql thread_close {}
    }

    ad_proc -public open {
        {-message_id:required}
    } {
        reopen a thread
        This is not exactly a cheap operation if the thread is long
    } {
        db_exec_plsql thread_open {}
    }
    
    ad_proc -public get_attachments {
        {-message_id:required}
    } {
        get the attachments for a message
    } {
        # If attachments aren't enabled, then we stop
        if {![forum::attachments_enabled_p]} {
            return [list]
        }

        return [attachments::get_attachments -object_id $message_id]
    }

}



