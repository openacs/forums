<?xml version="1.0"?>
<queryset>

    <fullquery name="callback::MergePackageUser::impl::forums.upd_poster">
        <querytext>	
	update forums_messages
	set last_poster = :to_user_id
	where last_poster = :from_user_id
        </querytext>
    </fullquery>

    <fullquery name="callback::MergePackageUser::impl::forums.upd_user_id">
        <querytext>	
        update forums_messages
	set user_id = :to_user_id
	where user_id = :from_user_id
        </querytext>
    </fullquery>

    <fullquery name="callback::MergeShowUserInfo::impl::forums.sel_user_id">
        <querytext>	
        select message_id, subject
	from forums_messages
	where user_id = :user_id
        </querytext>
    </fullquery>

    <fullquery name="callback::MergeShowUserInfo::impl::forums.sel_poster">
        <querytext>	
        select message_id, subject
	from forums_messages
	where last_poster = :user_id
        </querytext>
    </fullquery>
 
<fullquery name="callback::datamanager::move_forum::impl::datamanager.update_forums">
<querytext>
        update forums_forums
	set package_id = (select package_id 
	from dotlrn_community_applets
	where community_id = :selected_community and applet_id = (
	    select applet_id from dotlrn_applets where applet_key = 'dotlrn_forums'
	))
	where forum_id = :object_id

</querytext>
</fullquery>

<fullquery name="callback::datamanager::move_forum::impl::datamanager.update_forums_acs_objects">
<querytext>
update acs_objects
    set package_id = (select package_id from dotlrn_community_applets where community_id = :selected_community and applet_id = (select applet_id from dotlrn_applets where applet_key = 'dotlrn_forums')),context_id = (select package_id from dotlrn_community_applets where community_id = :selected_community and applet_id = (select applet_id from dotlrn_applets where applet_key = 'dotlrn_forums'))
    where object_id = :object_id

</querytext>
</fullquery>


</queryset>
