ad_library {
    Forum callbacks.

    @author Jeff Davis <davis@xarg.net>
    @creation-date 2005-03-11
    @cvs-id $Id$
}

ad_proc -public -callback navigation::package_admin -impl forums {} {
    return the admin actions for the forum package.
} {
    set actions {}

    # Check for admin on the package...
    if {[permission::permission_p -object_id $package_id -privilege admin -party_id $user_id]} {
        lappend actions [list LINK admin/ [_ acs-kernel.common_Administration] {} [_ forums.Admin_for_all]]

        lappend actions [list LINK \
                             [export_vars -base admin/permissions {{object_id $package_id}}] \
                             [_ acs-kernel.common_Permissions] {} [_ forums.Permissions_for_all]]
        lappend  actions [list LINK admin/forum-new [_ forums.Create_a_New_Forum] {} {}]
    }

    # check for admin on the individual forums.
    db_foreach forums {
        select forum_id, name, enabled_p
        from forums_forums
        where package_id = :package_id
        and exists (select 1 from acs_object_party_privilege_map pm
                    where pm.object_id = forum_id
                    and pm.party_id = :user_id
                    and pm.privilege = 'admin')
    } {
        lappend actions [list SECTION "Forum $name ([ad_decode $enabled_p t [_ forums.enabled] [_ forums.disabled]])" {}]

        lappend actions [list LINK [export_vars -base admin/forum-edit forum_id] \
                             [_ forums.Edit_forum_name] {} {}]
        lappend actions [list LINK [export_vars -base admin/permissions {{object_id $forum_id} return_url}] \
                             [_ forums.Permission_forum_name] {} {}]
    }
    return $actions
}

ad_proc -public -callback forum::forum_new {
    {-package_id:required}
    {-forum_id:required}
} {
}

ad_proc -public -callback forum::forum_edit {
    {-package_id:required}
    {-forum_id:required}
} {
}

ad_proc -public -callback forum::forum_delete {
    {-package_id:required}
    {-forum_id:required}
} {
}

ad_proc -public -callback forum::message_new {
    {-package_id:required}
    {-message_id:required}
} {
}

ad_proc -public -callback forum::message_edit {
    {-package_id:required}
    {-message_id:required}
} {
}

ad_proc -public -callback forum::message_delete {
    {-package_id:required}
    {-message_id:required}
} {
}

ad_proc -public -callback pm::project_new -impl forums {
    {-package_id:required}
    {-project_id:required}
    {-data:required}
} {
    create a new forum for each new project
} {
    set pm_name [pm::project::name -project_item_id $project_id]

    foreach forum_package_id [application_link::get_linked -from_package_id $package_id -to_package_key "forums"] {
	set forum_id [forum::new \
			  -name $pm_name \
			  -package_id $forum_package_id \
			  -no_callback]

	# Automatically allow new threads on this forum
        forum::new_questions_allow -forum_id $forum_id

	application_data_link::new -this_object_id $project_id -target_object_id $forum_id
    }
}

ad_proc -public -callback search::datasource -impl forums_message {} {

    @author dave@thedesignexperience.org
    @creation_date 2005-06-07

    returns a datasource for the search package
    this is the content that will be indexed by the full text
    search engine.

    We expect message_id to be a root message of a thread only, 
    and return the text of all the messages below

} {
    set message_id $object_id
    # If there is no connection than this proc is called from the
    # search indexer. In that case we set the locale to the
    # system-wide default locale, since locale is needed for some part
    # of the message formatting.
    if { ![ad_conn isconnected] } {
        ad_conn -set locale [lang::system::site_wide_locale]
    }

    forum::message::get -message_id $message_id -array message

    if { ![empty_string_p $message(parent_id)] } {
        ns_log debug "forum::message::datasource was called with a message_id that has a parent - skipping: $message_id"
        set empty(object_id) $message_id
        set empty(title) ""
        set empty(content) ""
        set empty(keywords) ""
        set empty(storage_type) "text"
        set empty(mime) "text/plain"
        return [array get empty]
    }
    set relevant_date $message(posting_date)
    ns_log debig "DIRK1 -${message(posting_date)}-"

    set tree_sortkey $message(tree_sortkey)
    set forum_id $message(forum_id)
    set combined_content ""
    set subjects [list]
    lappend subjects $message(subject)
    array set forum [forum::get -forum_id $message(forum_id) -array forum]
    set package_id $forum(package_id)
    db_foreach messages "" {

        # include the subject in the text if it is different from the thread's subject
        set root_subject $message(subject)
        regexp {^(?:Re: )+(.*)$} $subject match subject

        if { [string compare $subject $root_subject] != 0 } {
            # different subject
            append combined_content "$subject\n\n"
        }

        append combined_content [ad_html_text_convert -from $format -to text/plain -- $content]

        # In case this text is not only used for indexing but also for display, beautify it
        append combined_content "\n\n"
        set relevant_date $message(posting_date)
        ns_log debug "DIRK2 -${message(posting_date)}-"
    }

    return [list object_id $message(message_id) \
                title $message(subject) \
                content $combined_content \
                relevant_date $relevant_date \
                community_id [db_null] \
                keywords {} \
                storage_type text \
                mime text/plain \
	        package_id $package_id]
}

ad_proc -public -callback search::url -impl forums_message {} {

    @author dave@thedesignexperience.org
    @creation_date 2005-06-08

    returns a url for a message to the search package

} {
    set message_id $object_id
    forum::message::get -message_id $message_id -array message
    set forum_id $message(forum_id)

    return "[ad_url][db_string select_forums_package_url {}]message-view?message_id=$message_id"
}
