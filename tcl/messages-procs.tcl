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

        # Prepare the variables for instantiation
        set extra_vars [ns_set create]
        oacs_util::vars_to_ns_set -ns_set $extra_vars -var_list {forum_id message_id parent_id subject content html_p user_id}

        db_transaction {
            # Instantiate the message
            set message_id [package_instantiate_object -extra_vars $extra_vars forums_message]

            do_notifications -message_id $message_id
        }

        return $message_id
    }
    
    ad_proc -public do_notifications {
        {-message_id:required}
    } {
        # Select all the important information
        get -message_id $message_id -array message

        set new_content "$message(user_name) ($message(user_email)) posted on [util_AnsiDatetoPrettyDate $message(posting_date)]:"
        append new_content "\n\n"
        append new_content $message(content)

        # Do the notification for the forum
        notification::new -type_id [notification::type::get_type_id -short_name forums_forum_notif] \
                -object_id $message(forum_id) -response_id $message(message_id) -notif_subject $message(subject) -notif_text $new_content
        
        # Eventually we need notification for the root message too
        # FIXME
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
        db_1row select_message {} -column_array row
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
        set_state -message_id $message_id -state approved
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
}
