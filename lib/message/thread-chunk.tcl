ad_page_contract {
    
    view a message (and its children)

    @author Ben Adida (ben@openforce.net)
    @creation-date 2002-05-25
    @cvs-id $Id$

}

if {$forum(posting_policy) == "moderated"} {
    set forum_moderated_p 1
} else {
    set forum_moderated_p 0
}

# get the colors from the params
set table_border_color [parameter::get -parameter table_border_color]
set table_bgcolor [parameter::get -parameter table_bgcolor]
set table_other_bgcolor [parameter::get -parameter table_other_bgcolor]

# Check preferences for user

# Set some variables for easy SQL access
set forum_id $message(forum_id)
set tree_sortkey $message(tree_sortkey)

if {[forum::attachments_enabled_p]} {
    set query select_message_responses_attachments
} else {
    set query select_message_responses
}

# We set a Tcl variable for moderation now (Ben)
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

if { [string equal $forum(presentation_type) flat] } {
    set order_by "fma.posting_date, fma.tree_sortkey"
} else {
    set order_by "fma.tree_sortkey"
}

set root_message_id $message(root_message_id)
set message_id_list [db_list select_message_ordering {}]

set direct_url_base [export_vars -base [ad_conn url] { { message_id $message(root_message_id) } }]
set message(direct_url) "$direct_url_base\#$message(message_id)"

set message(number) [expr [lsearch $message_id_list $message(message_id)] + 1]
set message(parent_number) {}
if { [exists_and_not_null message(parent_id)] } {
    set message(parent_number) [expr [lsearch $message_id_list $message(parent_id)] + 1]
    set message(parent_direct_url) "$direct_url_base\#$message(parent_id)"
}

#####
#
# Find responses
#
#####

# More Tcl vars (we might as well use them - Ben)
if { [string equal $forum(presentation_type) flat] } {
    set order_by "$table_name.posting_date, tree_sortkey"
} else {
    set order_by "tree_sortkey"
}

db_multirow -extend { posting_date_pretty direct_url number parent_number parent_direct_url } responses $query {} {
    set posting_date_pretty [lc_time_fmt $posting_date_ansi "%x %X"]
    set direct_url "$direct_url_base\#$message(message_id)"
    set number [expr [lsearch $message_id_list $message(message_id)] + 1]
    set parent_number [expr [lsearch $message_id_list $parent_id] + 1]
    set parent_direct_url "$direct_url_base\#$parent_id"
}

if {[exists_and_not_null alt_template]} {
  ad_return_template $alt_template
}
