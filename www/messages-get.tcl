ad_page_contract {
} {
    cid:object_type(forums_message)
    {op noop}
    {sid nosid}
    {dynamicmode:integer}
}

if {$dynamicmode} {
    forum::message::get -message_id $cid -array message
    forum::security::require_read_forum -forum_id $message(forum_id)
    set message(content) [ad_html_text_convert -from $message(format) -to text/html -- $message(content)]
} else {
    set message(content) {}
}

template::add_body_handler -event "load" -script [subst {
    copyContent('$cid','$dynamicmode');
}]

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
