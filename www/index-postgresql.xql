<?xml version="1.0"?>

<queryset>
    <rdbms><type>postgresql</type><version>7.1</version></rdbms>

    <fullquery name="select_forums">
        <querytext>
            select forums_forums_enabled.*,
                   (select count(*)
                    from forums_messages
                    where forums_messages.forum_id = forums_forums_enabled.forum_id
                    and 1 = tree_level(forums_messages.tree_sortkey)) as n_threads,
                   to_char(acs_objects.last_modified, 'YYYY-MM-DD HH24:MI:SS') as last_modified_ansi,
                   case when last_modified > (now() - 1) then 't' else 'f' end as new_p
            from forums_forums_enabled,
                 acs_objects
            where forums_forums_enabled.package_id = :package_id
            and (
                    forums_forums_enabled.posting_policy = 'open'
                 or forums_forums_enabled.posting_policy = 'moderated'
                 or 't' = acs_permission__permission_p(:user_id, forums_forums_enabled.forum_id, 'forum_read')
                )
            and forums_forums_enabled.forum_id = acs_objects.object_id
            order by forums_forums_enabled.name
        </querytext>
    </fullquery>

</queryset>
