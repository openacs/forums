
ad_page_contract {

    a message chunk to be included in a table listing of messages

    @author yon (yon@openforce.net)
    @author arjun (arjun@openforce.net)
    @creation-date 2002-06-02
    @cvs-id $Id$

}

set viewer_id [ad_conn user_id]

if {![info exists rownum] || $rownum eq ""} { 
    set rownum 1
}

set message(content) [ad_html_text_convert -from $message(format) -to text/html -- $message(content)]

# convert emoticons to images if the parameter is set
if { [string is true [parameter::get -parameter DisplayEmoticonsAsImagesP -default 0]] } {
    set message(content) [forum::format::emoticons -content $message(content)]}

# JCD: display subject only if changed from the root subject
if {![info exists root_subject]} {
    set display_subject_p 1
} else {
    regsub {^(Response to |\s*Re:\s*)*} $message(subject) {} subject
    set display_subject_p [expr {$subject ne $root_subject }] 
}

if {[info exists alt_template] && $alt_template ne ""} {
    ad_return_template $alt_template
}
if {![info exists message(message_id)]} {
    set message(message_id) none
}
if {![info exists message(tree_level)]} {
    set message(tree_level) 0
}

## New ## 

set max_number_messages [parameter::get -parameter max_number_messages_with_effects -default 120]

set parent_message_id  $message(message_id)
set direct_children_list [db_list children_list_name "select message_id from $table_name \
	where  message_id = :parent_message_id or parent_id = :parent_message_id order by message_id"]
set message_children_list [db_list select_message_children " SELECT fma.message_id \
        FROM   forums_messages_approved fma \
        WHERE  fma.forum_id = $forum_id \
          and    fma.tree_sortkey between (select fm.tree_sortkey from forums_messages fm where fm.message_id = :parent_message_id) \
          and    (select tree_right(fm.tree_sortkey) from forums_messages fm where fm.message_id = :parent_message_id) \
        ORDER  BY fma.message_id "]

# List of all the children given a message_id
if {[llength $message_children_list] == 0 } {
    set children_string "null"
} else {
    set children_string $message_children_list
}

# List of the direct children of a message
if {[llength $direct_children_list] == 0} {
    set children_direct_list "null"
} else {
    set children_direct_list "$direct_children_list"
}


# Gets all the direct children of the main message
set childs [db_list get_children "select message_id from $table_name \
	where  parent_id = :parent_message_id or message_id = $parent_message_id  order by message_id"]

set is_direct_children [lsearch $childs $parent_message_id]
if {$is_direct_children == -1 } {
    set is_direct_child 0
} else {
    set is_direct_child 1
}

## Ends New ##
set allow_edit_own_p [parameter::get -parameter AllowUsersToEditOwnPostsP -default 0]
set own_p [expr {$message(user_id) eq $viewer_id && $allow_edit_own_p}]

template::add_event_listener -id "toggle$message(message_id)" -script [subst {
    dynamicExpand('$message(message_id)');
}]
if {$total_number_messages <= $max_number_messages} {

    template::add_event_listener -id "expand-direct-$message(message_id)" -script [subst {
        expandChilds('$message(message_id)','$children_direct_list');
    }]
    template::add_event_listener -id "expand-all-$message(message_id)" -script [subst {
        expandChilds('$message(message_id)','$children_string');
    }]
    template::add_event_listener -id "collapse-all-$message(message_id)" -script [subst {
        collapseChilds('$message(message_id)','$children_string');
    }]
}


# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
