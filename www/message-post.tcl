ad_page_contract {
    
    Form to create message and insert it

    @author Ben Adida (ben@openforce.net)
    @creation-date 2002-05-25
    @cvs-id $Id$

} -query {
    {forum_id ""}
    {parent_id ""}
    {html_p "f"}
} -validate {
    forum_id_or_parent_id {
        if {[empty_string_p $forum_id] && [empty_string_p $parent_id]} {
            ad_complain [_ forums.lt_You_either_have_to]
        }
    }
}

if { ![empty_string_p [ns_queryget formbutton:post]] } {
    set action post
} elseif { ![empty_string_p [ns_queryget formbutton:preview]] } {
    set action preview
} elseif { ![empty_string_p [ns_queryget formbutton:edit]] } {
    set action edit
} else {
    set action ""
}

set user_id [auth::refresh_login]

# get the colors from the params
set table_border_color [parameter::get -parameter table_border_color]
set table_bgcolor [parameter::get -parameter table_bgcolor]

form create message -edit_buttons [list [list [_ forums.Post] post] [list [_ forums.Preview] preview]]

element create message message_id \
    -label [_ forums.Message_ID] \
    -datatype integer \
    -widget hidden

element create message subject \
    -label [_ forums.Subject] \
    -datatype text \
    -widget text \
    -html {size 60} \
    -validate { {expr ![empty_string_p [string trim $value]]} "[_ forums.lt_Please_enter_a_subjec]" }

# we use ns_queryget to get the value of html_p because it won't be defined
# until the next element -DaveB

element create message content \
    -label [_ forums.Body] \
    -datatype text \
    -widget textarea \
    -html {rows 20 cols 60 wrap soft} \
    -validate {
        empty {expr ![empty_string_p [string trim $value]]} { [_ forums.lt_Please_enter_a_messag] }
	html { expr {( [string match [set l_html_p [ns_queryget html_p f]] "t"] && [empty_string_p [set v_message [ad_quotehtml [ad_html_security_check $value]]]] ) || [string match $l_html_p "f"] } }
	     {}	
    }


element create message html_p \
    -label [_ forums.Format] \
    -datatype text \
    -widget radio \
    -options [list [list [_ forums.text] f] [list [_ forums.html] t]] \
    -value f

element create message parent_id \
    -label [_ forums.parent_ID] \
    -datatype integer \
    -widget hidden \
    -optional

element create message forum_id \
    -label [_ forums.forum_ID] \
    -datatype integer \
    -widget hidden

element create message confirm_p \
    -label [_ forums.Confirm] \
    -datatype text \
    -widget hidden

element create message subscribe_p \
    -label [_ forums.Subscribe] \
    -datatype text \
    -widget hidden \
    -optional

# We show the anonymous checkbox if you're logged in, and user_id 0 is allowed to post
set anonymous_allowed_p [expr [ad_conn user_id] != 0 && \
                             ([empty_string_p $forum_id] || \
                                  [forum::security::can_post_forum_p -forum_id $forum_id -user_id 0]) && \
                             ([empty_string_p $parent_id] || \
                                  [forum::security::can_post_message_p -message_id $parent_id -user_id 0])]

element create message anonymous_p \
    -label "Anonymous" \
    -datatype integer \
    -widget [ad_decode $anonymous_allowed_p 0 "hidden" "checkbox"] \
    -options { { "Post anonymously" "1" } } \
    -optional

set attachments_enabled_p [forum::attachments_enabled_p]

if {$attachments_enabled_p} {
    element create message attach_p \
            -label [_ forums.Attach] \
            -datatype text \
            -widget radio \
            -value 0 \
            -options [list [list [_ forums.No] 0] [list [_ forums.Yes] 1]]
}

if {[form is_valid message]} {
    form get_values message \
        message_id forum_id parent_id subject content html_p confirm_p subscribe_p anonymous_p 
    if {$attachments_enabled_p} {
	form get_values message attach_p    
    }
    if { !$anonymous_allowed_p } {
        set anonymous_p 0
    }
    
    if { [string equal $action "preview"] } {
        forum::get -forum_id $forum_id -array forum

        set confirm_p 1
	set subject.spellcheck ":nospell:"
	set content.spellcheck ":nospell:"
        set content [string trimright $content]

        set exported_vars [export_form_vars message_id forum_id parent_id subject content html_p confirm_p subject.spellcheck content.spellcheck anonymous_p attach_p]
        
        set message(html_p) $html_p
        set message(subject) $subject
        set message(content) $content
        if { [template::util::is_true $anonymous_p] } {
            set user_id 0
        }
        set message(user_id) $user_id
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


        set context [list [list "./forum-view?forum_id=$forum_id" [ad_quotehtml $forum(name)]]]
        lappend context "[_ forums.Post_a_Message]"

        ad_return_template message-post-confirm
        return
    }

    if { [string equal $action "post"] } {
        if { [empty_string_p $anonymous_p] } {
          set anonymous_p 0
      }
      if { $anonymous_p } {
          set post_as_user_id 0
      } else {
          set post_as_user_id $user_id
      }
      
      forum::message::new \
          -forum_id $forum_id \
          -message_id $message_id \
          -parent_id $parent_id \
          -subject $subject \
          -content $content \
          -html_p $html_p \
          -user_id $post_as_user_id

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
              -user_id [ad_conn user_id] \
          ]

          # redirect to notification stuff
          set redirect_url $notification_url
      }

      # Wrap the attachments URL
      if {$attachments_enabled_p} {
          form get_values message attach_p

          if { ![empty_string_p $attach_p] && $attach_p} {
              set redirect_url [attachments::add_attachment_url -object_id $message_id -return_url $redirect_url -pretty_name "[_ forums.Forum_Posting] \"$subject\""]
          }
      }
      
      # Do the redirection
      ad_returnredirect $redirect_url

      ad_script_abort
    }
}

set message_id [db_nextval acs_object_id_seq]
#set subject ""

if { ![empty_string_p $parent_id] } {
    # get the parent message information
    forum::message::get -message_id $parent_id -array parent_message
    set forum_id $parent_message(forum_id)
    if { [form is_request message] } {
        set subject "[_ forums.Re] $parent_message(subject)"
        
        # trim multiple leading Re:
        regsub {^(\s*Re:\s*)*} $subject {Re: } subject
    }
    
    # see if they're allowed to add to this thread
    forum::security::require_post_message -message_id $parent_id
} else {
    # no parent_id, therefore new thread
    # require thread creation privs
        forum::security::require_post_forum -forum_id $forum_id
}

forum::get -forum_id $forum_id -array forum

# Prepare the other data 
element set_properties message forum_id -value $forum_id
element set_properties message parent_id -value $parent_id
element set_properties message message_id -value $message_id
# only set subject is this is a reply to a previous message
if {[info exists subject]} {
    element set_properties message subject -value $subject
}
element set_properties message confirm_p -value 0
element set_properties message subscribe_p -value 0

set context [list [list "./forum-view?forum_id=$forum_id" [ad_quotehtml $forum(name)]]]
if {![empty_string_p $parent_id]} {
    lappend context [list "./message-view?message_id=$parent_message(message_id)" "$parent_message(subject)"]
    lappend context [_ forums.Post_a_Reply]
} else {
    lappend context [_ forums.Post_a_Message]
}
