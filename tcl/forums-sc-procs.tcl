ad_library {

    Forums Library - Search Service Contracts

    @creation-date 2002-08-07
    @author Dave Bauer <dave@thedesignexperience.org>
    @cvs-id $Id: 

}

namespace eval forum::message {

ad_proc datasource { message_id } {
    @param message_id
    @author dave@thedesignexperience.org
    @creation_date 2002-08-07

    returns a datasource for the search package
    this is the content that will be indexed by the full text
    search engine.

    We expect message_id to be a root message of a thread only, 
    and return the text of all the messages below

} {

    # If there is no connection than this proc is called from the
    # search indexer. In that case we set the locale to the
    # system-wide default locale, since locale is needed for some part
    # of the message formatting.
    if { ![ad_conn isconnected] } {
        ad_conn -set locale [lang::system::site_wide_locale]
    }

    forum::message::get -message_id $message_id -array message

    if { ![empty_string_p $message(parent_id)] } {
        ns_log notice "forum::message::datasource was called with a message_id that has a parent - skipping: $message_id"
        set empty(object_id) $message_id
        set empty(title) ""
        set empty(content) ""
        set empty(keywords) ""
        set empty(storage_type) ""
        set empty(mime) ""
        return [array get empty]
    }
    
    set tree_sortkey $message(tree_sortkey)
    set forum_id $message(forum_id)
    set combined_content ""
    set subjects [list]
    lappend subjects $message(subject)

    db_foreach messages "" {

        # include the subject in the text if it is different from the thread's subject
        set root_subject $message(subject)
        regexp {^(?:Re: )+(.*)$} $subject match subject

        if { [string compare $subject $root_subject] != 0 } {
            # different subject
            append combined_content "$subject\n\n"
        }
        
        if  { $html_p } {
            append combined_content [ad_html_to_text -showtags $content]
        } else {
            append combined_content $content
        }

        # In case this text is not only used for indexing but also for display, beautify it
        append combined_content "\n\n"
    }

    set datasource(object_id) $message(message_id)
    set datasource(title) $message(subject)
    set datasource(content) $combined_content
    set datasource(keywords) ""
    set datasource(storage_type) text
    set datasource(mime) "text/plain"
    return [array get datasource]
}

ad_proc url { message_id } {
    @param message_id
    @author dave@thedesignexperience.org
    @creation_date 2002-08-07

    returns a url for a message to the search package

} {
    forum::message::get -message_id $message_id -array message
    set forum_id $message(forum_id)

    return "[ad_url][db_string select_forums_package_url {}]message-view?message_id=$message_id"
}

}
