<?xml version="1.0"?>

<queryset>
    <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

    <fullquery name="select_forums">
        <querytext>
            select forums_forums_enabled.*,
                   (select count(*)
                    from forums_messages
                    where forums_messages.forum_id = forums_forums_enabled.forum_id
                    and 1 = tree.tree_level(forums_messages.tree_sortkey)) as n_threads,
                   to_char(acs_objects.last_modified, 'Mon DD YYYY HH24:MI:SS') as last_modified,
                   case when last_modified > (sysdate - 1) then 't' else 'f' end as new_p
            from forums_forums_enabled,
                 acs_objects
            where forums_forums_enabled.package_id = :package_id
            and (
                    forums_forums_enabled.posting_policy = 'open'
                 or forums_forums_enabled.posting_policy = 'moderated'
                 or 't' = acs_permission.permission_p(:user_id, forums_forums_enabled.forum_id, 'forum_read')
                )
            and forums_forums_enabled.forum_id = acs_objects.object_id
            order by forums_forums_enabled.name
        </querytext>
    </fullquery>

</queryset>
