ad_page_contract {

    Form to create message and insert it

    @author Ben Adida (ben@openforce.net)
    @creation-date 2002-05-25
    @cvs-id $Id$

} -query {
    {forum_id:object_type(forums_forum) ""}
    {parent_id:object_type(forums_message) ""}
} -validate {
    forum_id_or_parent_id {
        if {$forum_id eq "" && $parent_id eq ""} {
            ad_complain [_ forums.lt_You_either_have_to]
        }
    }
}

if {$parent_id ne ""} {
    forum::message::get -message_id $parent_id -array parent_message
}

if { [ns_queryget formbutton:post] ne "" } {
    set action post
} elseif { [ns_queryget formbutton:preview] ne "" } {
    set action preview
} elseif { [ns_queryget formbutton:edit] ne "" } {
    set action edit
} else {
    set action ""
}

set user_id [auth::refresh_login]

##############################
# Pull out required forum and parent data and
# perform security checks.
#
if {$parent_id eq ""} {
    # No parent_id was specified, therefore, we need the forums info
    # to check permissions ant to check the forums settings, whether
    # new threads are allowed in general.
    forum::get -forum_id $forum_id -array forum

    if { ![permission::permission_p -object_id $forum_id -privilege "forum_moderate"] } {
        forum::security::require_post_forum -forum_id $forum_id
        # check if we can post new threads
        if {!$forum(new_questions_allowed_p)} {
            forum::security::do_abort
        }
    }
} else {
    # get the parent message information
    set parent_message(tree_level) 0

    # see if they're allowed to add to this thread
    if { ![permission::permission_p -object_id $forum_id -privilege "forum_moderate"] } {
        forum::security::require_post_forum -forum_id $parent_message(forum_id)
    }

    forum::get -forum_id $parent_message(forum_id) -array forum
}

##############################
# Calculate users rights and forums policy
#
set anonymous_allowed_p [expr {($forum_id eq ""
                                || [forum::security::can_post_forum_p \
                                        -forum_id $forum_id -user_id 0])
                               && ($parent_id eq ""
                                   || [forum::security::can_post_forum_p \
                                           -forum_id $parent_message(forum_id) -user_id 0])}]
if {$forum_id eq ""} {
    set forum_id $parent_message(forum_id)
}
set attachments_enabled_p [forum::attachments_enabled_p -forum_id $forum_id]

##############################
# Template variables
#

set lang [ad_conn language]
template::head::add_css -href /resources/forums/forums.css -media all -lang $lang
#template::head::add_css -alternate -href /resources/forums/flat.css -media all -lang $lang -title "flat"
#template::head::add_css -alternate -href /resources/forums/flat-collapse.css -media all -lang $lang -title "flat-collapse"
#template::head::add_css -alternate -href /resources/forums/collapse.css -media all -lang $lang -title "collapse"
#template::head::add_css -alternate -href /resources/forums/expand.css -media all -lang $lang -title "expand"

if {[template::form::get_button message] ne "preview" } {
    set context [list [list "./forum-view?forum_id=$forum(forum_id)" $forum(name)]]

    if {$parent_id eq ""} {
        lappend context [_ forums.Post_a_Message]
    } else {
        lappend context [list "./message-view?message_id=$parent_message(message_id)" "$parent_message(subject)"]
        lappend context [_ forums.Post_a_Reply]
    }
} else {
    set context [list [list "./forum-view?forum_id=$forum(forum_id)" $forum(name)]]
    lappend context "[_ forums.Post_a_Message]"

    ad_return_template "message-post-confirm"
}



# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
