ad_library {

    Forums Library - Search Service Contracts

    This library is DEPRECATED and NOT USED. search is implemented using
    callbacks now. See forums-callback-procs.tcl
    This library will be definitely removed in 5.5

    @creation-date 2002-08-07
    @author Dave Bauer <dave@thedesignexperience.org>
    @cvs-id $Id$
}

namespace eval forum::message {}

ad_proc -private -deprecated forum::message::datasource { message_id } {
    @param message_id
    @author dave@thedesignexperience.org
    @creation-date 2002-08-07

    returns a datasource for the search package
    this is the content that will be indexed by the full text
    search engine.

    We expect message_id to be a root message of a thread only,
    and return the text of all the messages below

    DEPRECATED: search is implemented using callbacks now.

    @see forums-callback-procs.tcl
} {

    # If there is no connection than this proc is called from the
    # search indexer. In that case we set the locale to the
    # system-wide default locale, since locale is needed for some part
    # of the message formatting.
    if { ![ns_conn isconnected] } {
        ad_conn -set locale [lang::system::site_wide_locale]
    }
    forum::message::get -message_id $message_id -array message

    if { $message(parent_id) ne "" } {
        ns_log Notice "forum::message::datasource was called with a message_id that has a parent - skipping: $message_id"
        return {object_id {} name {} charter {} mime {} storage_type {}}
    }

    set tree_sortkey $message(tree_sortkey)
    set forum_id $message(forum_id)
    set combined_content ""
    set subjects [list]
    lappend subjects $message(subject)

    db_foreach messages {} {

        # include the subject in the text if it is different from the thread's subject
        set root_subject $message(subject)
        regexp {^(?:Re: )+(.*)$} $subject match subject

        if { $subject ne $root_subject  } {
            # different subject
            append combined_content "$subject\n\n"
        }

        append combined_content [ad_html_text_convert -from $format -to text/plain -- $content]

        # In case this text is not only used for indexing but also for display, beautify it
        append combined_content "\n\n"
    }

    return [list object_id $message(message_id) \
                title $message(subject) \
                content $combined_content \
                keywords {} \
                storage_type text \
                mime text/plain ]
    ns_log Notice "forum::message::datasource end"
}

ad_proc -private -deprecated forum::message::url { message_id } {
    @param message_id
    @author dave@thedesignexperience.org
    @creation-date 2002-08-07

    returns a URL for a message to the search package

    DEPRECATED: search is implemented using callbacks now.

    @see forums-callback-procs.tcl
} {
    forum::message::get -message_id $message_id -array message
    set forum_id $message(forum_id)


     return "[db_string select_forums_package_url {}]message-view?message_id=$message_id"
}



namespace eval forum::forum {}

ad_proc -private -deprecated forum::forum::datasource {
    forum_id
} {
    Datasource for the FtsContentProvider contract.

    @param forum_id

    @author Jeff Davis davis@xarg.net
    @creation-date 2004-04-01

    DEPRECATED: search is implemented using callbacks now.

    @see forums-callback-procs.tcl
} {
    if {![db_0or1row datasource {
        select
          forum_id as object_id,
          name as title,
          charter as content,
          'text/plain' as mime,
          'text' as storage_type,
          '' as keywords
        from forums_forums
        where forum_id = :forum_id
    } -column_array datasource]} {
        return {object_id {} name {} charter {} mime {} storage_type {}}
    }

    return [array get datasource]
}

ad_proc -private -deprecated forum::forum::url {
    forum_id
} {
    url method for the FtsContentProvider contract

    @param forum_id

    @author Jeff Davis davis@xarg.net
    @creation-date 2004-04-01

    DEPRECATED: search is implemented using callbacks now.

    @see forums-callback-procs.tcl
} {

     return "[db_string select_forums_package_url {}]forum-view?forum_id=$forum_id"
}


namespace eval forum::sc {}

ad_proc -private -deprecated forum::sc::register_implementations {} {
    Register the forum_forum and forum_message content type fts contract

    DEPRECATED: search is implemented using callbacks now.

    @see forums-callback-procs.tcl
} {
    db_transaction {
        forum::sc::register_forum_fts_impl
        forum::sc::register_message_fts_impl
    }
}

ad_proc -private forum::sc::unregister_implementations {} {
    This proc is de-facto deprecated, as search is implemented using
    callbacks now, but we still need it to be there to support
    upgrades from older versions.

    @see forums-callback-procs.tcl
} {
    db_transaction {
        acs_sc::impl::delete -contract_name FtsContentProvider -impl_name forums_message
        acs_sc::impl::delete -contract_name FtsContentProvider -impl_name forums_forum
    }
}

ad_proc -private -deprecated forum::sc::register_forum_fts_impl {} {
    DEPRECATED: search is implemented using callbacks now.

    @see forums-callback-procs.tcl
} {
    set spec {
        name "forums_forum"
        aliases {
            datasource forum::forum::datasource
            url forum::forum::url
        }
        contract_name FtsContentProvider
        owner forums
    }

    acs_sc::impl::new_from_spec -spec $spec
}


ad_proc -private -deprecated forum::sc::register_message_fts_impl {} {
    DEPRECATED: search is implemented using callbacks now.

    @see forums-callback-procs.tcl
} {
    set spec {
        name "forums_message"
        aliases {
            datasource forum::message::datasource
            url forum::message::url
        }
        contract_name FtsContentProvider
        owner forums
    }

    acs_sc::impl::new_from_spec -spec $spec
}


# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
