ad_page_contract { 
    this assumes that all fetched messages are under one 
    message root.  it may fail when given differently rooted messages
} {
    cid:integer,multiple
    {op noop}
    sid:integer
    {dynamicmode:integer}
}

forum::message::get -message_id $sid -array root_message
set root_message_id $sid
set forum_id $root_message(forum_id)
forum::get -forum_id $forum_id -array forum

if {$forum(posting_policy) == "moderated"} {
    set forum_moderated_p 1
} else {
    set forum_moderated_p 0
}

set moderate_forum_p [forum::security::can_moderate_forum_p -forum_id $forum_id]
if { $moderate_forum_p } {
    set table_name "forums_messages"
} else {
    set table_name "forums_messages_approved"
}

set message_id_list [db_list select_message_ordering {
    select fma.message_id
    from   forums_messages fm,
           forums_messages_approved fma
    where  fm.message_id = :root_message_id
    and    fma.forum_id = :forum_id
    and    fma.tree_sortkey between fm.tree_sortkey and tree_right(fm.tree_sortkey)
    order  by fma.message_id
}]

set direct_url_base [export_vars -base message-view { { message_id $root_message_id } }]

if {$dynamicmode} {
    set query "
    select message_id,
           (select count(*) from attachments where object_id = message_id) as n_attachments,
           subject,
           content,
           format,
           person__name(user_id) as user_name,
           to_char(posting_date, 'YYYY-MM-DD HH24:MI:SS') as posting_date_ansi,
           tree_level(tree_sortkey) as tree_level,
           state,
           user_id,
           parent_id,
           tree_sortkey,
           open_p,
           max_child_sortkey
    from   $table_name
    where  message_id in ([join $cid ","])
    order  by tree_sortkey
" 
} else {
    set query "
    select message_id,
           (select count(*) from attachments where object_id = message_id) as n_attachments,
           subject,
           format,
           person__name(user_id) as user_name,
           to_char(posting_date, 'YYYY-MM-DD HH24:MI:SS') as posting_date_ansi,
           tree_level(tree_sortkey) as tree_level,
           state,
           user_id,
           parent_id,
           tree_sortkey,
           open_p,
           max_child_sortkey
    from   $table_name
    where  message_id in ([join $cid ","])
    order  by tree_sortkey
" 
}

# convert emoticons to images if the parameter is set
set convert_emoticons_p [string is true [parameter::get -parameter DisplayEmoticonsAsImagesP -default 0]]
db_multirow -extend { reply_p moderate_p posting_date_pretty number parent_number direct_url parent_direct_url htmltext webeq links own_p} message get_messages $query {
    set number [expr [lsearch $message_id_list $message_id] + 1]
    set parent_number [expr [lsearch $message_id_list $parent_id] + 1]
    set posting_date_pretty [lc_time_fmt $posting_date_ansi "%x %X"]
    set direct_url "$direct_url_base\#$message_id"
    set parent_direct_url "$direct_url_base\#$parent_id"
    if {$dynamicmode} { 
        set content [ad_html_text_convert -from $format -to text/html -- $content]

	if { $convert_emoticons_p } {
	    set content [forum::format::emoticons -content $content]
	}

	set links "<a href=\"moderate/message-edit?message_id=$message_id\" class=\"button\">#forums.edit# Text</a>"
	
        set moderate_p [forum::security::can_moderate_message_p -message_id $message_id]
        set reply_p [expr [string equal $open_p "t"] || [string equal $user_id [ad_conn user_id]]]
        set allow_edit_own_p [parameter::get -parameter AllowUsersToEditOwnPostsP -default 0]
        set own_p [expr [string equal $user_id [ad_conn user_id]] && $allow_edit_own_p]
    } else { 
        set moderate_p 0
        set reply_p 0
        set own_p 0
    }
}

set viewer_id [ad_conn user_id]
