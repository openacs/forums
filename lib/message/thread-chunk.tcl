ad_page_contract {

    view a message (and its children)

    @author Ben Adida (ben@openforce.net)
    @creation-date 2002-05-25
    @cvs-id $Id$

}

set forum_moderated_p [expr {$forum(posting_policy) eq "moderated"}]

# get the colors from the params
set table_border_color [parameter::get -parameter table_border_color]
set table_bgcolor [parameter::get -parameter table_bgcolor]
set table_other_bgcolor [parameter::get -parameter table_other_bgcolor]

# Check preferences for user

# Set some variables for easy SQL access
set forum_id $message(forum_id)
set tree_sortkey $message(tree_sortkey)

if {[forum::attachments_enabled_p -forum_id $forum_id]} {
    set query select_message_responses_attachments
} else {
    set query select_message_responses
}

# Set the table_name depending on moderation
if { $permissions(moderate_p) } {
    set table_name "forums_messages"
} else {
    set table_name "forums_messages_approved"
}

#####
#
# Find ordering of messages
#
#####

set root_message_id $message(root_message_id)
set message_id_list [db_list select_message_ordering {}]

set direct_url_base [export_vars -base [ad_conn url] { { message_id $message(root_message_id) } }]
set message(direct_url) "$direct_url_base\#msg_$message(message_id)"

set message(number) [expr {[lsearch $message_id_list $message(message_id)] + 1}]
set message(parent_number) {}
set message(parent_direct_url) ""
if { [info exists message(parent_id)] && $message(parent_id) ne "" } {
    set message(parent_number) [expr {[lsearch $message_id_list $message(parent_id)] + 1}]
    set message(parent_direct_url) "$direct_url_base\#msg_$message(parent_id)"
    set message(parent_root_url) [export_vars -base [ad_conn url] { { message_id $message(parent_id) } }]
}

set message(reply_p) [expr {$message(user_id) == [ad_conn user_id]}]
set message(tree_level) 0


#####
#
# Find responses
#
#####

# More Tcl vars (we might as well use them - Ben)
if {$forum(presentation_type) eq "flat"} {
    set order_by "t.posting_date, tree_sortkey"
} else {
    set order_by "tree_sortkey"
}

set old_tree_level 0
set old_message_id 0
set message_ids {}

db_multirow -extend {
    posting_date_pretty
    direct_url
    number
    parent_number
    parent_direct_url
    reply_p
    viewed_p
} responses $query {} {
    set tree_level [expr {min($tree_level - $message(tree_level), 10)}]
    set posting_date_ansi [lc_time_system_to_conn $posting_date_ansi]
    set posting_date_pretty [lc_time_fmt $posting_date_ansi "%x %X"]
    set direct_url "$direct_url_base\#msg_$message_id"
    set number [expr {[lsearch $message_id_list $message_id] + 1}]
    set parent_number [expr {[lsearch $message_id_list $parent_id] + 1}]
    set parent_direct_url "$direct_url_base\#msg_$parent_id"
    set parent_root_url [export_vars -base [ad_conn url] {{message_id $parent_id}}]
    set reply_p [expr {$user_id == [ad_conn user_id]}]

    # DEDS: get the response ids the Tcl way or else we need to hit
    # the db for each response to count its children
    if {$tree_level == 1} {
        # leftmost so this is a new parent. truncate the list of ids.
        set message_ids {}
    } else {
        if {$tree_level > $old_tree_level} {
            # increase in level. previous id is a parent too.
            lappend message_ids $old_message_id
            foreach one_parent_id $message_ids {
                lappend parent_message($one_parent_id) $message_id
            }
        } elseif {$tree_level < $old_tree_level} {
            # decrease in level. let us pop the last id.
            set message_ids_last [expr {[llength $message_ids] - 1}]
            set message_ids [lreplace $message_ids $message_ids_last $message_ids_last]
        } else {
            foreach one_parent_id $message_ids {
                lappend parent_message($one_parent_id) $message_id
            }
        }
    }
    # keep track of what level and message we are in
    set old_tree_level $tree_level
    set old_message_id $message_id

    # make sure we also populate the original message id
    lappend parent_message($message(message_id)) $message_id
}

set message(tree_level) 0

if {[info exists alt_template] && $alt_template ne ""} {
    ad_return_template $alt_template
}

set response_arrays_stub ""
foreach one_parent_id [array names parent_message] {
    set one_children_list $parent_message($one_parent_id)
    if {[llength $one_children_list] == 1} {
        # this is needed to make the JavaScript work
        lappend one_children_list "null"
    }
    append response_arrays_stub "  forums_replies\[$one_parent_id\] = new Array([join $one_children_list ","]);\n"
}
if {$response_arrays_stub ne ""} {
    template::add_body_script -script $response_arrays_stub
}

set return_url [ad_return_url]

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
