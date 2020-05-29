ad_library {

    Forums Library - for Messages

    @creation-date 2002-05-20
    @author Ben Adida <ben@openforce.biz>
    @cvs-id $Id$

}

namespace eval forum::message {}

ad_proc -public forum::message::new {
    {-forum_id:required}
    {-message_id ""}
    {-parent_id ""}
    {-subject:required}
    {-content:required}
    {-format "text/plain"}
    {-user_id ""}
    -no_callback:boolean
} {
    Create a new message.
} {
    # If no user_id is provided, we set it
    # to the currently logged-in user
    if {$user_id eq ""} {
        set user_id [ad_conn user_id]
    }

    set original_message_id $message_id

    db_transaction {

        set var_list [list \
            [list forum_id $forum_id] \
            [list message_id $message_id] \
            [list parent_id $parent_id] \
            [list subject $subject] \
            [list content $content] \
            [list format $format] \
            [list user_id $user_id]]


        set message_id [package_instantiate_object -var_list $var_list forums_message]

        forum::message::do_notifications \
            -message_id $message_id -user_id $user_id

    }  on_error {

        db_abort_transaction

        # Check to see if the message with a message_id matching the
        # message_id argument was in the database before calling
        # this procedure.  If so, the error is due to a double click
        # and we should continue without returning an error.

        if {$original_message_id ne ""} {
            # The was a non-null message_id argument
            if {[db_string message_exists_p {}]} {
                return $message_id
            } else {
                # OK - it wasn't a simple double-click, so bomb
                ad_return_error \
                    "OACS Internal Error" \
                    "Error in forum::message::new - $errmsg"
                ad_script_abort
            }
        }
    }

    forum::flush_cache \
        -forum_id $forum_id

    return $message_id
}

ad_proc -public forum::message::do_notifications {
    {-message_id:required}
    {-user_id ""}
} {
    Perform the notifications.
} {
    # Select all the important information
    forum::message::get -message_id $message_id -array message

    set forum_id $message(forum_id)
    set package_id [db_string get_package_id {
        select package_id from forums_forums
        where forum_id = :forum_id}]
    set url [lindex [site_node::get_url_from_object_id -object_id $package_id] 0]
    set url [ad_url]$url

    set message_url ${url}message-view?message_id=$message(root_message_id)
    set forum_url ${url}forum-view?forum_id=$message(forum_id)

    if {$message(state) eq "approved"} {
        forum::message::notify_users \
            -message_array message \
            -forum_url $forum_url \
            -message_url $message_url
    }

    forum::message::notify_moderators \
        -message_array message \
        -forum_url $forum_url \
        -message_url $message_url

    # This computations are not used... just commented for now.
    # if {$useScreenNameP eq 0 && $user_id ne 0} {
    #     if { $user_id eq "" } {
    #         set user_id $message(user_id)
    #     }
    # } else {
    #     set user_id [party::get_by_email \
    #                      -email [ad_host_administrator]]
    # }
    # set notif_user $user_id
}

ad_proc -private forum::message::notify_users {
    -message_array:required
    -forum_url:required
    -message_url:required
} {
    Notify users of a new approved forum message.

    @param message_array name of message array of forum info in the caller scope
} {
    upvar 1 $message_array message

    set useScreenNameP [parameter::get -parameter "UseScreenNameP" -default 0]

    set attachments [attachments::get_attachments -object_id $message(message_id)]

    set message_text [ad_html_text_convert -from $message(format) -to text/plain -- $message(content)]
    set message_html [ad_html_text_convert -from $message(format) -to text/html -- $message(content)]

    set SecureOutboundP [parameter::get -parameter "SecureOutboundP" -default 0]
    if { $SecureOutboundP && [ns_conn isconnected] && [security::secure_conn_p] } {
        set href [ns_quotehtml $message_url]
        set message_html "<p>#forums.Message_content_withheld# #forums.To_view_message_follow_link# <a href=\"$href\">$href</a></p>"
        set message_text [ad_html_text_convert -from text/html -to text/plain -- $message_html]
    } else {
        #
        # The resulting HTML messages is sent in total by
        # notifications::send through [lang::util::localize...].  In case
        # a forums message contains something looking like a localized
        # message key, it will be substituted. One rough attempt is to add
        # a zero width space after the "#" signs to make the regular
        # expression searching for the message keys fail....
        #
        regsub -all "#" $message_html "#\\&#8203;" message_html
    }

    set html_version ""
    append html_version "#forums.Forum#:  <a href=\"$forum_url\">$message(forum_name)</a><br>\n"
    append html_version "#forums.Thread#: <a href=\"$message_url\">$message(root_subject)</a><br>\n"
    if {$useScreenNameP == 0} {
        append html_version "#forums.Author#: <a href=\"mailto:$message(user_email)\">$message(user_name)</a><br>\n"
    } else {
        append html_version "#forums.Author#: $message(screen_name)<br>\n"
    }
    append html_version "#forums.Posted#: $message(posting_date)<br>"
    append html_version "\n<br>\n"

    append html_version $message_html
    append html_version "<p>   "

    if {[llength $attachments] > 0} {
        append html_version "#forums.Attachments#:
                            <ul> "

        foreach attachment $attachments {
            append html_version "<li><a href=\"[lindex $attachment 2]\">[lindex $attachment 1]</a></li>"
        }
        append html_version "</ul>"
    }

    set html_version $html_version

    set text_version ""
    append text_version "
#forums.Forum#: $message(forum_name)
#forums.Thread#: $message(root_subject)\n"
    if {$useScreenNameP == 0} {
	append text_version "#forums.Author#: $message(user_name)"
    } else {
	append text_version "#forums.Author#: $message(screen_name)"
    }
    append text_version "
#forums.Posted#: $message(posting_date)
-----------------------------------------
$message_text
-----------------------------------------
#forums.To_post_a_reply_to_this_email_or_view_this_message_go_to#
$message_url

#forums.To_view_Forum_forum_name_go_to#
$forum_url
"
    # Do the notification for the forum
    notification::new \
        -type_id [notification::type::get_type_id \
        -short_name forums_forum_notif] \
        -object_id $message(forum_id) \
        -response_id $message(message_id) \
        -notif_subject "\[$message(forum_name)\] $message(subject)" \
        -notif_text $text_version \
        -notif_html $html_version


    # Eventually we need notification for the root message too
    notification::new \
        -type_id [notification::type::get_type_id \
        -short_name forums_message_notif] \
        -object_id $message(root_message_id) \
        -response_id $message(message_id) \
        -notif_subject "\[$message(forum_name)\] $message(subject)" \
        -notif_text $text_version \
        -notif_html $html_version
}

ad_proc -private forum::message::notify_moderators {
    -message_array:required
    -forum_url:required
    -message_url:required
} {
    Notify moderators of a new forum message

    @param message_array name of message array of forum info in the caller scope
} {
    upvar 1 $message_array message

    set useScreenNameP [parameter::get -parameter "UseScreenNameP" -default 0]

    # Moderated messages are never notified in full, as they might
    # contain unsuitable content by definition.
    set href [ns_quotehtml $message_url]
    set message_html "<p>#forums.Message_content_withheld# #forums.To_view_message_follow_link# <a href=\"$href\">$href</a></p>"
    set message_text [ad_html_text_convert -from text/html -to text/plain -- $message_html]

    set html_version ""
    append html_version "#forums.Forum#:  <a href=\"$forum_url\">$message(forum_name)</a><br>\n"
    append html_version "#forums.Thread#: <a href=\"$message_url\">$message(root_subject)</a><br>\n"
    if {$useScreenNameP == 0} {
        append html_version "#forums.Author#: <a href=\"mailto:$message(user_email)\">$message(user_name)</a><br>\n"
    } else {
        append html_version "#forums.Author#: $message(screen_name)<br>\n"
    }
    append html_version "#forums.Posted#: $message(posting_date)<br>"
    append html_version "\n<br>\n"

    append html_version $message_html
    append html_version "<p>   "

    set text_version ""
    append text_version "
#forums.Forum#: $message(forum_name)
#forums.Thread#: $message(root_subject)\n"
    if {$useScreenNameP == 0} {
	append text_version "#forums.Author#: $message(user_name)"
    } else {
	append text_version "#forums.Author#: $message(screen_name)"
    }
    append text_version "
#forums.Posted#: $message(posting_date)
-----------------------------------------
$message_text
-----------------------------------------
#forums.To_post_a_reply_to_this_email_or_view_this_message_go_to#
$message_url

#forums.To_view_Forum_forum_name_go_to#
$forum_url
"
    # Do the notification for the forum
    notification::new \
        -type_id [notification::type::get_type_id \
        -short_name forums_forum_moderator_notif] \
        -object_id $message(forum_id) \
        -response_id $message(message_id) \
        -notif_subject "\[$message(forum_name)\] $message(subject) (#forums.moderated#)" \
        -notif_text $text_version \
        -notif_html $html_version

    # Eventually we need notification for the root message too
    notification::new \
        -type_id [notification::type::get_type_id \
        -short_name forums_message_moderator_notif] \
        -object_id $message(root_message_id) \
        -response_id $message(message_id) \
        -notif_subject "\[$message(forum_name)\] $message(subject) (#forums.moderated#)" \
        -notif_text $text_version \
        -notif_html $html_version
}

ad_proc -public forum::message::edit {
    {-message_id:required}
    {-subject:required}
    {-content:required}
    {-format:required}
    -no_callback:boolean
} {
    Editing a message. There is no versioning here!
    This means this function is for admins only!
} {
    # do the update
    db_dml update_message {}
    db_dml update_message_title {}

    if {!$no_callback_p} {
	callback forum::message_edit -package_id [ad_conn package_id] -message_id $message_id
    }
}

ad_proc -public forum::message::set_format {
    {-message_id:required}
    {-format:required}
} {
    Set whether a message is HTML or not.
} {
    # Straight update to the DB
    db_dml update_message_format {}
}

ad_proc -public forum::message::get {
    {-message_id:required}
    {-array:required}
} {
    Get the fields for a message.
} {
    # Select the info into the upvar'ed Tcl Array
    upvar $array row

    # make sure array is empty
    array unset row

    set attachments_sql [expr {[ad_conn isconnected] && [forum::attachments_enabled_p] ? {
        (select count(*) from attachments
         where object_id = m.message_id) as n_attachments,
    } : ""}]

    set sql [subst -nocommands {
        with recursive message_hierarchy as (
           select 1 as level, message_id, parent_id
             from forums_messages
            where message_id = :message_id

           union all

           select h.level + 1, m.message_id, m.parent_id
             from forums_messages m,
                  message_hierarchy h
            where m.message_id = h.parent_id
       )
       select m.*,
              $attachments_sql
              root.level as tree_level,
              root.message_id as root_message_id,
              (select subject from forums_messages
                where message_id = root.message_id) as root_subject,
              to_char(m.posting_date, 'YYYY-MM-DD HH24:MI:SS') as posting_date_ansi,
              (select name from forums_forums
                where forum_id = m.forum_id) as forum_name
        from forums_messages m,
             (select level, message_id
              from message_hierarchy
              where parent_id is null) as root
       where m.message_id = :message_id
    }]
    if {[db_0or1row select_message $sql -column_array row]} {
        set user [acs_user::get -user_id $row(user_id)]
        set row(user_name)   [dict get $user name]
        set row(user_email)  [dict get $user email]
        set row(screen_name) [dict get $user screen_name]

        # Convert to user's date/time format
        set row(posting_date_ansi) [lc_time_system_to_conn $row(posting_date_ansi)]
        set row(posting_date_pretty) [lc_time_fmt $row(posting_date_ansi) "%x %X"]
    }
}

ad_proc -private forum::message::set_state {
    {-message_id:required}
    {-state:required}
} {
    Set the new state for a message.<br>
    Usually used for approval.
} {
    set var_list [list \
        [list message_id $message_id] \
        [list state $state]]
    package_exec_plsql -var_list $var_list forums_message set_state
    # flush the forum cache to update the thread count
    forum::flush_cache -forum_id [db_string get_forum {
        select forum_id from forums_messages where message_id = :message_id
    }]
}

ad_proc -public forum::message::reject {
    {-message_id:required}
} {
    Reject a message.
} {
    forum::message::set_state -message_id $message_id -state rejected
}

ad_proc -public forum::message::approve {
    {-message_id:required}
} {
    Approve a message.
} {
    db_transaction {
        forum::message::set_state -message_id $message_id -state approved
        forum::message::do_notifications -message_id $message_id
    }
}

ad_proc -public forum::message::delete {
    {-message_id:required}
    -no_callback:boolean
} {
    Delete a message and obviously all of its descendents.
} {
    db_transaction {
	if {!$no_callback_p} {
	    callback forum::message_delete -package_id [ad_conn package_id] -message_id $message_id
	}

        forum::message::get -message_id $message_id -array msg
        set forum_id  $msg(forum_id)

        # Remove the notifications
        notification::request::delete_all -object_id $message_id

        # Remove the message
        set var_list [list [list message_id $message_id]]
        package_exec_plsql -var_list $var_list forums_message delete_thread

        # flush the forum cache to update the thread count
        forum::flush_cache -forum_id $forum_id
    }
}

ad_proc -public forum::message::close {
    {-message_id:required}
} {
    Close a thread.<br>
    This is not exactly a cheap operation if the thread is long.
} {
    db_dml close_thread {
        update forums_messages set
           open_p = 'f'
        where message_id in (
           with recursive message_hierarchy as (
              select message_id
                from forums_messages
               where message_id = :message_id

              union all

              select m.message_id
                from forums_messages m,
                     message_hierarchy h
               where m.parent_id = h.message_id
           )
           select message_id
             from message_hierarchy
        )
    }
}

ad_proc -public forum::message::open {
    {-message_id:required}
} {
    Reopen a thread.<br>
    This is not exactly a cheap operation if the thread is long.
} {
    db_dml close_thread {
        update forums_messages set
           open_p = 't'
        where message_id in (
           with recursive message_hierarchy as (
              select message_id
                from forums_messages
               where message_id = :message_id

              union all

              select m.message_id
                from forums_messages m,
                     message_hierarchy h
               where m.parent_id = h.message_id
           )
           select message_id
             from message_hierarchy
        )
    }
}

ad_proc -public forum::message::get_attachments {
    {-message_id:required}
} {
    Get the attachments for a message.
} {
    # If attachments aren't enabled, then we stop
    if {![forum::attachments_enabled_p]} {
        return [list]
    }

    return [attachments::get_attachments -object_id $message_id]
}

ad_proc -deprecated forum::message::subject_sort_filter {
    -forum_id:required
    -order_by:required
} {
    @return A piece of HTML for toggling the sort order of threads (subjects)
            in a forum. The user can either sort by the first postings in
            subjects (the creation date of the subjects) or the last one.

    DEPRECATED: this proc is not mentioned anywhere in current
                upstream codebase. Furthermore, it refers to a very
                specific UI (e.g. sorting properties, styling...) and
                does therefore provide little value in general.

    @see idioms in the specific UI

    @author Peter Marklund
} {
    set subject_label [_ forums.lt_First_post_in_subject]
    set child_label [_ forums.Last_post_in_subject]
    set new_order_by [expr {$order_by eq "posting_date" ? "last_child_post" : "posting_date"}]

    set toggle_url [export_vars -base [ad_conn url] -override {{order_by $new_order_by}} {order_by forum_id}]
    if {$order_by eq "posting_date"} {
        # subject selected
        set subject_link "<b>$subject_label</b>"
        set child_link "<a href=\"[ns_quotehtml $toggle_url]\">$child_label</a>"
    } else {
        # child selected
        set subject_link "<a href=\"[ns_quotehtml $toggle_url]\">$subject_label</a>"
        set child_link "<b>$child_label</b>"
    }
    set sort_filter "$subject_link | $child_link"

    return $sort_filter
}

ad_proc -deprecated forum::message::initial_message {
    {-forum_id {}}
    {-parent {}}
    {-message:required}
} {
    Create an array with values initialized for a new message.

    DEPRECATED: this proc is not used in current upstream code, its
                upvar juggling is questionable and most of the data
                returned is already provided from the start.

    @see direct idioms on the api used in here
    @see forum::format::reply_subject
} {
    upvar $message init_msg

    if { $forum_id eq "" && $parent eq "" } {
        return -code error [_ forums.lt_You_either_have_to]
    }

    if { $parent ne "" } {
        upvar $parent parent_msg

        set init_msg(parent_id) $parent_msg(message_id)
        set init_msg(forum_id) $parent_msg(forum_id)
        set init_msg(subject) \
            [forum::format::reply_subject $parent_msg(subject)]
    } else {
        set init_msg(forum_id) $forum_id
        set init_msg(parent_id) ""
    }
}

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
