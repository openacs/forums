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
                   to_char(last_post, 'Mon DD YYYY HH24:MI:SS') as last_post,
                   case when last_post > (now() - 1) then 't' else 'f' end as new_p
            from forums_forums_enabled
            where forums_forums_enabled.package_id = :package_id
            and (
                    forums_forums_enabled.posting_policy = 'open'
                 or forums_forums_enabled.posting_policy = 'moderated'
                 or 't' = acs_permission__permission_p(forums_forums_enabled.forum_id, :user_id,'forum_read')
                )
            order by forums_forums_enabled.name
        </querytext>
    </fullquery>

</queryset>
