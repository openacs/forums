ad_page_contract {
    
    view a message (and its children)

    @author Ben Adida (ben@openforce.net)
    @creation-date 2002-05-25
    @cvs-id $Id$

} {
    message_id:integer,notnull
    {display_mode ""}
}

#######################
#
# First check all reasons why we might abort
#
#######################

# Load up the message information
forum::message::get -message_id $message_id -array message

# Load up the forum information
forum::get -forum_id $message(forum_id) -array forum

# If disabled!
if {$forum(enabled_p) != "t"} {
    ad_returnredirect "./"
    ad_script_abort
}

forum::security::require_read_message -message_id $message_id
forum::security::permissions -forum_id $message(forum_id) permissions

# Check if the user has admin on the message
set permissions(moderate_p) [forum::security::can_moderate_message_p -message_id $message_id]
if {!${permissions(moderate_p)}} {
    set permissions(post_p) [forum::security::can_post_forum_p -forum_id $message(forum_id)]
} else {
    set permissions(post_p) 1
}

# Check if the message is approved
if {!${permissions(moderate_p)} && ![string equal $message(state) approved]} {
    ad_returnredirect "forum-view?forum_id=$message(forum_id)"
    ad_script_abort
}

############################################
#
# Ok we're not aborting so lets do some work
#
############################################

# Create a search form and action when used
set searchbox_p [parameter::get -parameter ForumsSearchBoxP -default 1]
if {$searchbox_p} { 
    form create search -action search
    forums::form::search search

    if {[form is_request search]} {
        element set_properties search forum_id -value $message(forum_id)
    }
}


# If this is a top-level thread, we allow subscriptions here
if { [empty_string_p $message(parent_id)] } {
    set notification_chunk [notification::display::request_widget \
        -type forums_message_notif \
        -object_id $message(message_id) \
        -pretty_name $message(subject) \
        -url [ad_conn url]?message_id=$message(message_id) \
    ]
} else {
    set notification_chunk ""
}

set context [list [list "./forum-view?forum_id=$message(forum_id)" "$message(forum_name)"]]
if {![empty_string_p $message(parent_id)]} {
    lappend context [list "./message-view?message_id=$message(root_message_id)" "$message(subject)"]
    lappend context [_ forums.One_Message]
} else {
    lappend context "$message(subject)"
}

if { $permissions(post_p) || [ad_conn user_id] == 0 } {
    set reply_url [export_vars -base message-post { { parent_id $message(message_id) } }]
}

set thread_url [export_vars -base forum-view { { forum_id $message(forum_id) } }]

if {[empty_string_p $display_mode]} {
    # user doesn't set display so let's get cookie
    set display_mode [ad_get_cookie forums_display_mode dynamic_minimal]
} else {
    # user desires a new look so store it too
    # half a year should be fine for now
    ad_set_cookie -replace t -max_age 15768000 forums_display_mode $display_mode
}

set alternate_style_p 0

if {[string equal $display_mode flat]} {
    set alternate_style_p 1
    set display_stylesheet "flat.css"
} elseif {[string equal $display_mode nested] || [string equal $display_mode minimal] || [string equal $display_mode threaded]} {
} else {
    set display_mode dynamic_minimal
}

if {$alternate_style_p} {
    set alternate_style_sheet "<link rel=\"stylesheet\" type=\"text/css\" media=\"all\" href=\"/resources/forums/$display_stylesheet\" />"
} else {
    set alternate_style_sheet ""
}

if {[string equal $display_mode "dynamic_minimal"]} {
    set dynamic_script "
  <script type=\"text/javascript\" src=\"/resources/forums/dynamic-comments.js\"></script>
  <script type=\"text/javascript\">
  <!--
  collapse_symbol = '<img src=\"/resources/forums/Collapse16.gif\" width=\"16\" height=\"16\" ALT=\"-\" border=\"0\" title=\"collapse message\">';
  expand_symbol = '<img src=\"/resources/forums/Expand16.gif\" width=\"16\" height=\"16\" ALT=\"+\" border=\"0\" title=\"expand message\">';
  loading_symbol = '<img src=\"/resources/forums/dyn_wait.gif\" width=\"12\" height=\"16\" ALT=\"x\" border=\"0\">';
  loading_message = '<i>Loading...</i>';
  rootdir = 'messages-get';
  sid = '$message(root_message_id)';
  //-->
  </script>
"
} else {
    set dynamic_script ""
}

set display_options_list {{Flat flat} {Nested nested} {Threaded threaded} {Minimal minimal} {"Dynamic Minimal" dynamic_minimal}}
#set display_options_list {{Flat flat} {Nested nested} {"Dynamic" dynamic_minimal}}
ad_form \
    -name display_form \
    -method post \
    -has_submit 1 \
    -form {
        {message_id:text(hidden) {value $message_id}}
        {display_mode:text(radio),optional
            {label "Display:"}
            {options $display_options_list}
            {value $display_mode}
            {html {onChange "this.form.submit();"}}
        }
    } \
    -after_submit {
    }
