ad_include_contract {

    A message chunk to be included in a table listing of messages

    @author yon (yon@openforce.net)
    @author arjun (arjun@openforce.net)
    @creation-date 2002-06-02
    @cvs-id $Id$

} {
    {rownum:integer 1}
    {presentation_type:word ""}
    {forum_moderated_p:boolean 0}
    {moderate_p:boolean 0}
    {preview:boolean 0}
    {alt_template:token ""}
    {permissions}
    {message}
}

set viewer_id [ad_conn user_id]
set useScreenNameP [parameter::get -parameter "UseScreenNameP" -default 0]

if {0 && [info exists message(message_id)]} {
    set message(content) [::util::disk_cache_eval \
                          -call [list ad_html_text_convert -from $message(format) -to text/html -- $message(content)] \
                          -key fragments \
                          -id $message(message_id)]
} else {
    set message(content) [ad_html_text_convert -from $message(format) -to text/html -- $message(content)]
}

if {$useScreenNameP} {
    acs_user::get -user_id $viewer_id -array user_info
    set message(screen_name) $user_info(screen_name)
} else {
    set message(screen_name) ""
}


# convert emoticons to images if the parameter is set
if { [string is true [parameter::get -parameter DisplayEmoticonsAsImagesP -default 0]] } {
    set message(content) [forum::format::emoticons -content $message(content)]
}

set display_subject_p 1

if {$alt_template ne ""} {
  ad_return_template $alt_template
}
if {![info exists message(message_id)]} {
    set message(message_id) none
}
if {![info exists message(tree_level)] || $presentation_type eq "flat"} {
    set message(tree_level) 0
}

set allow_edit_own_p [parameter::get -parameter AllowUsersToEditOwnPostsP -default 0]
set own_p [expr {$message(user_id) eq $viewer_id && $allow_edit_own_p}]

if { $preview } {
    set any_action_p 0
} else {
    set notflat_p [expr {$presentation_type ne "flat"}]
    set post_and_notflat_p [expr {$permissions(post_p) && $notflat_p}]
    set any_action_p [expr { $post_and_notflat_p || $viewer_id || $moderate_p }]
}

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
