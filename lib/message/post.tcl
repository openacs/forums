ad_page_contract {

    Form to create message and insert it

    @author Ben Adida (ben@openforce.net)
    @creation-date 2003-12-09
    @cvs-id $Id$

}

set user_id [ad_conn user_id]
set screen_name [acs_user::get_user_info -user_id $user_id -element screen_name]

set useScreenNameP [parameter::get -parameter "UseScreenNameP" -default 0]
set pvt_home [ad_pvt_home]

if {[array exists parent_message]} {
    set parent_id $parent_message(message_id)
} else {
    set parent_id ""
}

set table_border_color [parameter::get -parameter table_border_color]
set table_bgcolor [parameter::get -parameter table_bgcolor]


##############################
# Form definition
#

set edit_buttons [list [list [_ forums.Post] post] \
                      [list [_ forums.Preview] preview]]

# maybe we could get this value from information_schema...
set max_subject_chars 200

set form_elements {
    {message_id:key}
    {subject:text(text)
        {html {maxlength $max_subject_chars size 60}}
        {label "[_ forums.Subject]"}
    }
    {message_body:richtext(richtext)
        {html {rows 20 cols 60}}
        {label "[_ forums.Body]"}
    }
    {forum_id:integer(hidden)
    }
    {parent_id:integer(hidden),optional
    }
    {subscribe_p:text(hidden),optional
    }
    {confirm_p:text(hidden),optional
    }
}

# Deal with anonymous postings
if {$user_id != 0 && $anonymous_allowed_p} {
    append form_elements {
        {anonymous_p:integer(checkbox),optional
            {options {{"[_ forums.post_anonymously]" 1}}}
            {label "[_ forums.Anonymous]"}
        }
    }
} else {
    append form_elements {
        {anonymous_p:integer(hidden),optional
        }
    }
}

# Attachments
if {$user_id != 0 & $attachments_enabled_p} {
    append form_elements {
        {attach_p:integer(radio),optional
            {options {{[_ acs-kernel.common_No] 0} {[_ acs-kernel.common_Yes] 1}}}
            {label "[_ forums.Attach]"}
        }
    }
} else {
    append form_elements {
        {attach_p:integer(hidden),optional
        }
    }
}

ad_form -html {enctype multipart/form-data} \
    -name message \
    -edit_buttons $edit_buttons \
    -form $form_elements \
    -new_request {
        ##############################
        # Form initialization
        #
        if {$parent_id eq ""} {
            set parent_id ""
        } else {
            set forum_id $parent_message(forum_id)
            set subject [forum::format::reply_subject $parent_message(subject)]
        }

        set confirm_p 0
        set subscribe_p 0
        set anonymous_p 0
        set attach_p 0
    } -on_submit {

        ##############################
        # Form processing
        #

        # UI should prevent this from triggering, but we check anyway
        if {[string length $subject] > $max_subject_chars} {
            set name          [_ forums.Subject]
            set max_length    $max_subject_chars
            set actual_length [string length $subject]
            template::form::set_error message subject [_ acs-tcl.lt_name_is_too_long__Ple]
            break
        }

        if { $anonymous_p eq "" } {
            set anonymous_p 0
        }
        set action [template::form::get_button message]

        # Make post the default action
        if {$action eq ""} {
            set action preview
        }

        set displayed_user_id [expr {$anonymous_allowed_p && $anonymous_p ? 0 : $user_id}]

        if {$action eq "preview"} {

            set confirm_p 1
            set subject.spellcheck ":nospell:"
            set content.spellcheck ":nospell:"
            set content [template::util::richtext::get_property content $message_body]
            set format [template::util::richtext::get_property format $message_body]

            set exported_vars [export_vars -form {message_id forum_id parent_id subject {message_body $content} {message_body.format $format} confirm_p subject.spellcheck content.spellcheck anonymous_p attach_p}]

            set message(format) $format
            set message(subject) $subject
            set message(content) $content
            set message(user_id) $displayed_user_id
            set message(user_name) [person::name -person_id $user_id]
            set message(screen_name) $screen_name
            set message(posting_date_ansi) [clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"]
            set message(posting_date_pretty) [lc_time_fmt $message(posting_date_ansi) "%x %X"]

            # Let's check if this person is subscribed to the forum
            # in case we might want to subscribe them to the thread
            if {$parent_id eq ""} {
                if {[notification::request::get_request_id \
                         -type_id [notification::type::get_type_id \
                                       -short_name forums_forum_notif] \
                         -object_id $forum_id \
                         -user_id   $user_id] ne ""} {
                    set forum_notification_p 1
                } else {
                    set forum_notification_p 0
                }
            }

            ad_return_template "/packages/forums/lib/message/post-confirm"
        }

        if {$action eq "post"} {
            set content [template::util::richtext::get_property content $message_body]
            set format [template::util::richtext::get_property format $message_body]
            
            forum::message::new \
                -forum_id $forum_id \
                -message_id $message_id \
                -parent_id $parent_id \
                -subject $subject \
                -content $content \
                -format $format \
                -user_id $displayed_user_id

            if { [forum::use_ReadingInfo_p] } {
                # remove reading info for this thread for all users (mark it unread)
                set db_antwort [db_exec_plsql forums_reading_info__remove_msg {}]
            }

            set permissions(moderate_p) [permission::permission_p -object_id $forum_id -privilege "forum_moderate"]

            db_transaction {
                if { $permissions(moderate_p) } {
                    forum::message::set_state -message_id $message_id -state "approved"
                }
            }

            # VGUERRA Redirecting to the first message ALWAYS
            forum::message::get -message_id $message_id -array msg
            set redirect_url "[ad_conn package_url]message-view?message_id=$msg(root_message_id)"

            # Wrap the notifications URL
            if {$subscribe_p ne "" && $subscribe_p && $parent_id eq ""} {
                set notification_url [notification::display::subscribe_url \
                                          -type forums_message_notif \
                                          -object_id $message_id \
                                          -url $redirect_url \
                                          -user_id $user_id]

                # redirect to notification stuff
                set redirect_url $notification_url
            }

            # Wrap the attachments URL
            if {$attachments_enabled_p} {
                if { $attach_p ne "" && $attach_p} {
                    set redirect_url [attachments::add_attachment_url -object_id $message_id -return_url $redirect_url -pretty_name "[_ forums.Forum_Posting] \"$subject\""]
                }
            }

            # Do the redirection
            if { !$permissions(moderate_p) } {
                forum::get -forum_id $forum_id -array forum
                if { $forum(posting_policy) eq "moderated" } {
                    # if the forum is moderated, give some feedback to the user
                    # to inform that the message has been sent and is pending
                    set feedback_msg [_ forums.Message_sent_to_moderator]
                    ad_returnredirect -message $feedback_msg -- $redirect_url
                    ad_script_abort
                }
            }

            ad_returnredirect $redirect_url
            ad_script_abort
        }
    }


if {[info exists alt_template] && $alt_template ne ""} {
    ad_return_template $alt_template
}

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
