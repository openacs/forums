
ad_page_contract {
    
    Form to create message and insert it

    @author Ben Adida (ben@openforce)
    @creation-date 2002-05-25
    @cvs-id $id: Exp $
} {
    {forum_id ""}
    {parent_id ""}
}

# Either forum_id or parent_id has to be non-null
if {[empty_string_p $forum_id] && [empty_string_p $parent_id]} {
    ns_log Notice "BMA: both are null!"
    # error!
    return -code error
}

# We would use the nice ad_form construct if we could
form create message

element create message message_id \
        -label "Message ID" -datatype integer -widget hidden

element create message subject \
        -label "Subject" -datatype text -widget text -html {size 60}

element create message content \
        -label "Body" -datatype text -widget textarea -html {rows 30 cols 60 wrap soft}

element create message parent_id \
        -label "parent ID" -datatype integer -widget hidden -optional

element create message forum_id \
        -label "forum ID" -datatype integer -widget hidden

element create message html_p \
        -label "Format" -datatype text -widget select -options {{text f} {html t}}

element create message confirm_p \
        -label "Confirm?" -datatype text -widget hidden

element create message subscribe_p \
        -label "Subscribe?" -datatype text -widget hidden -optional

if {[form is_valid message]} {
    template::form get_values message message_id forum_id parent_id subject content html_p confirm_p subscribe_p

    if {!$confirm_p} {
        forum::get -forum_id $forum_id -array forum

        set confirm_p 1
        set exported_vars [export_form_vars message_id forum_id parent_id subject content html_p confirm_p]
        
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

        ad_return_template message-post-confirm
        return
    }

    forum::message::new -forum_id $forum_id \
            -message_id $message_id \
            -parent_id $parent_id \
            -subject $subject \
            -content $content \
            -html_p $html_p

    set message_view_url "[ad_conn package_url]message-view?message_id=$message_id"

    if {![empty_string_p $subscribe_p] && $subscribe_p && [empty_string_p $parent_id]} {
        set notification_url [notification::display::subscribe_url -type forums_message_notif -object_id $message_id -url $message_view_url -user_id [ad_conn user_id]]

        # redirect to notification stuff
        ad_returnredirect $notification_url
    } else {
        # redirect to viewing the message
        ad_returnredirect $message_view_url
    }

    ad_script_abort
}

set message_id [db_nextval acs_object_id_seq]

if {[empty_string_p $forum_id]} {
    # get the parent message information
    forum::message::get -message_id $parent_id -array parent_message
    set forum_id $parent_message(forum_id)
}

forum::get -forum_id $forum_id -array forum

# Prepare the other data 
element set_properties message forum_id -value $forum_id
element set_properties message parent_id -value $parent_id
element set_properties message message_id -value $message_id
element set_properties message confirm_p -value 0
element set_properties message subscribe_p -value 0

ad_return_template
