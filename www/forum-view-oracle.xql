<?xml version="1.0"?>
<queryset>
    <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

    <fullquery name="messages_select">
        <querytext>
            select fm.message_id,
                   fm.subject,
                   fm.user_id,
                   person.name(fm.user_id) as user_name,
                   fm.posting_date,
                   fm.state,
                   (select count(*)
                    from forums_messages_approved fm1
                    where fm1.forum_id = :forum_id
                    and fm1.tree_sortkey between tree.left(fm.tree_sortkey) and tree.right(fm.tree_sortkey)) as n_messages,
                   to_char(acs_objects.last_modified, 'YYYY-MM-DD HH24:MI:SS') as last_modified_ansi,
                   case when acs_objects.last_modified > (sysdate - 1) then 't' else 'f' end as new_p                   
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
                   person.name(fm.user_id) as user_name,
                   fm.posting_date,
                   fm.state,
                   (select count(*)
                    from forums_messages fm1
                    where fm1.forum_id = :forum_id
                    and fm1.tree_sortkey between tree.left(fm.tree_sortkey) and tree.right(fm.tree_sortkey)) as n_messages,
                   to_char(acs_objects.last_modified, 'YYYY-MM-DD HH24:MI:SS') as last_modified_ansi,
                   case when acs_objects.last_modified > (sysdate - 1) then 't' else 'f' end as new_p                   
            from forums_messages fm,
                 acs_objects
            where fm.forum_id = :forum_id
            and fm.parent_id is null
            and fm.message_id = acs_objects.object_id
            order by fm.posting_date desc
        </querytext>
    </fullquery>

</queryset>
