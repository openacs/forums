ad_page_contract {

    Delete a Message

    @author Ben Adida (ben@openforce.net)
    @creation-date 2002-05-24
    @cvs-id $Id$

} {
    message_id:integer,notnull
    {return_url "../message-view"}
    {confirm_p 0}
}

# Check that the user can moderate the forum
forum::security::require_moderate_message -message_id $message_id

# Select the stuff
forum::message::get -message_id $message_id -array message

set dynamic_script "
  <!--
  collapse_symbol = '<img src=\"/resources/forums/Collapse16.gif\" width=\"16\" height=\"16\" ALT=\"collapse message\" border=\"0\" title=\"collapse message\">';
  expand_symbol = '<img src=\"/resources/forums/Expand16.gif\" width=\"16\" height=\"16\" ALT=\"expand message\" border=\"0\" title=\"expand message\">';
  loading_symbol = '<img src=\"/resources/forums/dyn_wait.gif\" width=\"12\" height=\"16\" ALT=\"x\" border=\"0\">';
  loading_message = '<i>Loading...</i>';
  rootdir = 'messages-get';
  sid = '$message(root_message_id)';
  //-->
"
# stylesheets
if {![template::multirow exists link]} {
    template::multirow create link rel type href title lang media
}

template::multirow append link \
    stylesheet \
    text/css \
    /resources/forums/forums.css \
    "" \
    [ad_conn language] \
    all

# js scripts
if {![template::multirow exists script]} {
    template::multirow create script type src charset defer content
}

template::multirow append script \
    "text/javascript" \
    "/resources/forums/forums.js"

template::multirow append script \
    "text/javascript" \
    "" \
    "" \
    "" \
    $dynamic_script

ad_return_template
