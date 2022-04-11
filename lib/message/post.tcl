ad_include_contract {

    Form to create message and insert it

    @author Ben Adida (ben@openforce.net)
    @creation-date 2003-12-09
    @cvs-id $Id$

} {
    message_id:object_id,optional
    forum_id:object_id,notnull
    {parent_id:object_id ""}
    {subject ""}
    {message_body ""}
    {message_body.format:token ""}
    {confirm_p:boolean ""}
    {subject.spellcheck:token ""}
    {content.spellcheck:token ""}
    {anonymous_p:boolean ""}
    {attach_p:boolean ""}
    {attachments:multiple ""}
    {attachment_cleanup_list:tmpfile ""}
}
#
# 'Simple' or 'Complex' (legacy) attachment style
#
# - Simple (default): just allow one to attach new files to a message using the file
#   widget during post, and using the attachments package API to 'attach' them
#   to the message.
#
# - Complex (legacy): attach URLs, new or already existing files, browse
#   through folders and choose where to upload the files in the file storage,
#   using the attachments package 'attach' pages.
#
set complex_attachments_p false
set attachmentStyle [parameter::get -parameter "AttachmentStyle" -default "simple"]
if {$attachmentStyle eq "complex"} {
    set complex_attachments_p true
}

set peeraddr   [ad_conn peeraddr]
set user_id    [ad_conn user_id]
set package_id [ad_conn package_id]

set screen_name     [acs_user::get_user_info -user_id $user_id -element screen_name]
set useScreenNameP  [parameter::get -parameter "UseScreenNameP" -default 0]
set pvt_home        [ad_pvt_home]

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
#
# Attachments
#
if {$complex_attachments_p} {
    #
    # Legacy 'complex' attachments
    #
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
} else {
    #
    # New 'simple' attachments
    #
    if {$user_id != 0 & $attachments_enabled_p} {
        append form_elements {
            {attachments:file(file),multiple,optional
                {label "[_ forums.Attach]"}
            }
            {attachment_cleanup_list:text(hidden),optional
            }
        }
    } else {
        append form_elements {
            {attach_p:integer(hidden),optional
            }
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
        set attachments [list]
        set attachment_cleanup_list [list]
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
            #
            # Attachments during the 'preview' action:
            #
            # 1) Create a multirow to show the files during the preview.
            #
            # 2) As the temporal files are deleted on submit, we need to
            #    preserve them. We copy and delete them after the insertion into
            #    the content repository.
            #
            if {$attachments ne ""} {
                set attachment_list [list]
                foreach attachment_file $attachments {
                    set attachment_data [dict create]
                    dict set attachment_data name [lindex $attachment_file 0]
                    dict set attachment_data file [lindex $attachment_file 1]
                    dict set attachment_data type [lindex $attachment_file 2]
                    lappend attachment_list $attachment_data
                    #
                    # Replace tmpfile with the new one
                    #
                    set new_file [ad_tmpnam]
                    set old_file [dict get $attachment_data file]
                    file copy -- $old_file $new_file
                    set attachments [regsub " $old_file " $attachments " $new_file "]
                    lappend attachment_cleanup_list $new_file
                }

                template::util::list_to_multirow attachment_multi $attachment_list
            }
            #
            # Export vars
            #
            set exported_vars [export_vars -form -sign {
                message_id
                forum_id
                parent_id
                subject
                {message_body $content}
                {message_body.format $format}
                confirm_p
                subject.spellcheck
                content.spellcheck
                anonymous_p
                attach_p
                attachments:multiple
                attachment_cleanup_list
            }]

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

            if { $permissions(moderate_p) } {
                db_transaction {
                    forum::message::set_state \
                        -message_id $message_id \
                        -state "approved"
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

            if {$attachments_enabled_p} {
                if {$complex_attachments_p} {
                    #
                    # Wrap the attachments URL
                    #
                    if { $attach_p ne "" && $attach_p} {
                        set redirect_url [attachments::add_attachment_url \
                                            -object_id $message_id \
                                            -return_url $redirect_url \
                                            -pretty_name "[_ forums.Forum_Posting] \"$subject\""]
                    }
                } else {
                    #
                    # Create and attach the new items (we assume we have the
                    # right permissions, as we were able to create the message)
                    #
                    # Root folder
                    #
                    set root_folder_id [content::item::get_id \
                                            -root_folder_id $forum_id \
                                            -item_path "attachments"]
                    if {$root_folder_id eq ""} {
                        set root_folder_id [content::item::new \
                                                -parent_id $forum_id \
                                                -name "attachments"]
                    }
                    #
                    # Create revision and attach
                    #
                    foreach attachment $attachments {
                        set name $message_id-[clock clicks -microseconds]
                        set item_id [content::item::new \
                                         -name            $name \
                                         -parent_id       $root_folder_id \
                                         -context_id      $message_id \
                                         -creation_user   $user_id \
                                         -creation_ip     $peeraddr \
                                         -item_subtype    "content_item" \
                                         -storage_type    "file" \
                                         -package_id      $package_id]

                        #
                        # Create a revision for the fresh content_item
                        #
                        set revision_id [db_nextval acs_object_id_seq]
                        content::revision::new \
                            -revision_id     $revision_id \
                            -item_id         $item_id \
                            -title           [lindex $attachment 0] \
                            -is_live         t \
                            -creation_user   $user_id \
                            -creation_ip     $peeraddr \
                            -content_type    "content_revision" \
                            -package_id      $package_id \
                            -tmp_filename    [lindex $attachment 1] \
                            -mime_type       [lindex $attachment 2]

                        #
                        # Attach the file to the object via the attachments API
                        #
                        attachments::attach \
                            -object_id $message_id \
                            -attachment_id $item_id
                    }
                    #
                    # Cleanup the possible attachment temporal files that still
                    # exist, created during the 'preview' action.
                    #
                    if {$attachment_cleanup_list ne ""} {
                        file delete -- {*}$attachment_cleanup_list
                    }
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
