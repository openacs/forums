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

set user_id [ad_conn user_id]

##############################
# Pull out required forum and parent data and
# perform security checks 
#
if {[empty_string_p $parent_id]} {
    # no parent_id, therefore new thread
    # require thread creation privs
    forum::security::require_post_forum -forum_id $forum_id

    forum::get -forum_id $forum_id -array forum
} else {
    # get the parent message information
    forum::message::get -message_id $parent_id -array parent_message

    # see if they're allowed to add to this thread
    forum::security::require_post_message -message_id $parent_id

    forum::get -forum_id $parent_message(forum_id) -array forum
}

##############################
# Calculate users rights and forums policy
#
set anonymous_allowed_p [expr ([empty_string_p $forum_id] || \
                               [forum::security::can_post_forum_p \
                                  -forum_id $forum_id -user_id 0]) && \
                              ([empty_string_p $parent_id] || \
                               [forum::security::can_post_message_p \
                                  -message_id $parent_id -user_id 0])]

set attachments_enabled_p [forum::attachments_enabled_p]

##############################
# Template variables
#

if {![string equal [template::form::get_button message] "preview"]} {
    set context [list [list "./forum-view?forum_id=$forum_id" [ad_quotehtml $forum(name)]]]

    if {[empty_string_p $parent_id]} {
        lappend context [_ forums.Post_a_Message]
    } else {
        lappend context [list "./message-view?message_id=$parent_message(message_id)" "$parent_message(subject)"]
        lappend context [_ forums.Post_a_Reply]
    }
} else {
    set context [list [list "./forum-view?forum_id=$forum_id" [ad_quotehtml $forum(name)]]]
    lappend context "[_ forums.Post_a_Message]"

    ad_return_template "message-post-confirm"
}
