ad_page_contract {
    
    Form to create message and insert it

    @author Ben Adida (ben@openforce.net)
    @creation-date 2003-12-09
    @cvs-id $Id$

}

set user_id [ad_conn user_id]

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
form create message \
    -edit_buttons [list [list [_ forums.Post] post] \
                        [list [_ forums.Preview] preview]]

element create message message_id \
    -label [_ forums.Message_ID] \
    -datatype integer \
    -widget hidden

forums::form::message message

forums::form::post_message \
    -show_anonymous_p [expr {$user_id != 0 && $anonymous_allowed_p}] \
    -show_attachments_p $attachments_enabled_p \
    message

element create message confirm_p \
    -label [_ forums.Confirm] \
    -datatype text \
    -widget hidden

if {[form is_request message]} {
    ##############################
    # Form initialisation
    #
    array set init_msg [list]

    set init_msg(message_id) [db_nextval acs_object_id_seq]

    if {[empty_string_p $parent_id]} {
        forum::message::initial_message \
            -forum_id $forum_id \
            -message init_msg
    } else {
        forum::message::initial_message \
            -parent parent_message \
            -message init_msg
    }

    set init_msg(confirm_p) 0
    set init_msg(subscribe_p) 0
    set init_msg(anonymous_p) 0
    set init_msg(attach_p) 0

    form set_values message init_msg
    
} elseif {[form is_valid message]} {

    ##############################
    # Form processing
    #
    form get_values message \
        message_id \
        forum_id \
        parent_id \
        subject \
        message_body \
        confirm_p \
        subscribe_p \
        anonymous_p \
        attach_p

        ns_log notice "
DB --------------------------------------------------------------------------------
DB DAVE debugging /var/lib/aolserver/openacs-5-1/packages/forums/lib/message/post.tcl
DB --------------------------------------------------------------------------------
DB message_body = '${message_body}'
DB --------------------------------------------------------------------------------"
    
    if { [empty_string_p $anonymous_p] } { set anonymous_p 0 }

    set action [template::form::get_button message]
    set displayed_user_id [ad_decode \
        [expr {$anonymous_allowed_p && $anonymous_p}] \
            0 $user_id \
            0]

    if { [string equal $action "preview"] } {

        set confirm_p 1
        set subject.spellcheck ":nospell:"
        set content.spellcheck ":nospell:"
        set content [template::util::richtext::get_property content $message_body]
        set format [template::util::richtext::get_property format $message_body]

        set exported_vars [export_vars -form {message_id forum_id parent_id subject {message_body $content} format confirm_p subject.spellcheck content.spellcheck anonymous_p attach_p}]
        
        set message(format) $format
        set message(subject) $subject
        set message(content) $content
        set message(user_id) $displayed_user_id
        set message(user_name) [db_string select_name {}]
        set message(posting_date_ansi) [db_string select_date {}]
        set message(posting_date_pretty) [lc_time_fmt $message(posting_date_ansi) "%x %X"]

        # Let's check if this person is subscribed to the forum
        # in case we might want to subscribe them to the thread
        if {[empty_string_p $parent_id]} {
            if {![empty_string_p [notification::request::get_request_id \
                    -type_id [notification::type::get_type_id -short_name forums_forum_notif] \
                    -object_id $forum_id \
                    -user_id [ad_conn user_id]]]} {
                set forum_notification_p 1
            } else {
                set forum_notification_p 0
            }
        }

        ad_return_template "/packages/forums/lib/message/post-confirm"
        return
    }

    if { [string equal $action "post"] } {
        ns_log notice "
DB --------------------------------------------------------------------------------
DB DAVE debugging /var/lib/aolserver/openacs-5-1/packages/forums/lib/message/post.tcl
DB --------------------------------------------------------------------------------
DB message_body = '${message_body}'
DB --------------------------------------------------------------------------------"
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

      # DRB: Black magic cache flush call which will disappear when list builder is
      # rewritten to paginate internally rather than use the template paginator.
      cache flush "messages,forum_id=$forum_id*"

      if {[empty_string_p $parent_id]} {
          set redirect_url "[ad_conn package_url]message-view?message_id=$message_id"
      } else {
          set redirect_url "[ad_conn package_url]message-view?message_id=$parent_id"
      }

      # Wrap the notifications URL
      if {![empty_string_p $subscribe_p] && $subscribe_p && [empty_string_p $parent_id]} {
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
          if { ![empty_string_p $attach_p] && $attach_p} {
              set redirect_url [attachments::add_attachment_url -object_id $message_id -return_url $redirect_url -pretty_name "[_ forums.Forum_Posting] \"$subject\""]
          }
      }
      
      # Do the redirection
      ad_returnredirect $redirect_url
      ad_script_abort
    }
}

if {[exists_and_not_null alt_template]} {
  ad_return_template $alt_template
}
