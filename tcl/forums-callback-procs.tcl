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

