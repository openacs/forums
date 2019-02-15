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
    {post_p:boolean 0}
    {preview:boolean 0}
    {alt_template:token ""}
    {message}
}

set viewer_id [ad_conn user_id]
set useScreenNameP [parameter::get -parameter "UseScreenNameP" -default 0]

set message(content) [ad_html_text_convert -from $message(format) -to text/html -- $message(content)]

if {$message(user_id) > 0} {
    set message(user_name) [acs_user::get_element \
                                -user_id $message(user_id) \
                                -element [expr {$useScreenNameP ? "screen_name" : "name"}]]
    set message(user_url) user-history?user_id=$message(user_id)
} else {    
    set message(user_name) [_ acs-kernel.Unregistered_Visitor]
    set message(user_url)  ""
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
    set notflat_p          [expr {$presentation_type ne "flat"}]
    set post_and_notflat_p [expr {$post_p && $notflat_p}]
    set any_action_p       [expr {$post_and_notflat_p || $viewer_id || $moderate_p}]

    set delete_url [export_vars -base "moderate/message-delete" {
        {message_id:sign(csrf) $message(message_id)}
    }]
}

template::add_body_script -script [subst {
    document.getElementById('toggle$message(message_id)').addEventListener('click', function (event) {
        event.preventDefault();
        forums_toggle('$message(message_id)');
        return false;
    }, false);
}]


# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
