<?xml version="1.0"?>
<queryset>
    <rdbms><type>postgresql</type><version>7.1</version></rdbms>

    <fullquery name="messages_select">
        <querytext>
            select fm.message_id,
                   fm.subject,
                   fm.user_id,
                   person__name(fm.user_id) as user_name,
                   fm.posting_date,
                   fm.state,
                   (select count(fm1.*)
                    from forums_messages_approved fm1
                    where fm1.tree_sortkey between tree__left(fm.tree_sortkey) and tree__right(fm.tree_sortkey)) as n_messages,
                   to_char(acs_objects.last_modified, 'Mon DD YYYY HH24:MI:SS') as last_modified
            from forums_messages_approved fm,
                 acs_objects
            where fm.forum_id = :forum_id
            and fm.parent_id is null
            and fm.message_id = acs_objects.object_id
            order by fm.posting_date desc
        </querytext>
    </fullquery>

    <fullquery name="messages_select_moderator">
        <querytext>
            select fm.message_id,
                   fm.subject,
                   fm.user_id,
                   person__name(fm.user_id) as user_name,
                   fm.posting_date,
                   fm.state,
                   (select count(fm1.*)
                    from forums_messages fm1
                    where fm1.tree_sortkey between tree__left(fm.tree_sortkey) and tree__right(fm.tree_sortkey)) as n_messages,
                   to_char(acs_objects.last_modified, 'Mon DD YYYY HH24:MI:SS') as last_modified
            from forums_messages fm,
                 acs_objects
            where fm.forum_id = :forum_id
            and fm.parent_id is null
            and fm.message_id = acs_objects.object_id
            order by fm.posting_date desc
        </querytext>
    </fullquery>

</queryset>
