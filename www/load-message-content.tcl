ad_page_contract {

    Update the content of a specified message, for preloading purposes

    @author Veronica De La Cruz (veronica@viaro.net)
    @creation-date 2006-04-21

} {
    message_id:object_type(forums_message),notnull
}


# Get the message information
forum::message::get -message_id $message_id -array message

set message(content) [ad_html_text_convert \
                          -from $message(format) \
                          -to text/html -- $message(content)]

# convert emoticons to images if the parameter is set
if { [string is true [parameter::get -parameter DisplayEmoticonsAsImagesP -default 0]] } {
    set message(content) [forum::format::emoticons \
                              -content $message(content)]
}

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
