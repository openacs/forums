<?xml version="1.0"?>
<queryset>
    <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

    <fullquery name="messages_select">
        <querytext>
            select fm.message_id,
                   fm.subject,
                   fm.user_id,
                   person.name(fm.user_id) as user_name,
                   to_char(fm.posting_date, 'YYYY-MM-DD HH24:MI:SS') as posting_date_ansi,
                   fm.state,
                   (select count(*)
                    from forums_messages_approved fm1
                    where fm1.forum_id = :forum_id
                    and fm1.tree_sortkey between tree.left(fm.tree_sortkey) and tree.right(fm.tree_sortkey)) as n_messages,
                   to_char(fm.last_child_post, 'YYYY-MM-DD HH24:MI:SS') as last_child_post_ansi,
                   case when fm.last_child_post > (sysdate - 1) then 't' else 'f' end as new_p                   
            from forums_messages_approved fm
            where fm.forum_id = :forum_id
            and fm.parent_id is null
            [template::list::orderby_clause -orderby -name "messages"]
        </querytext>
    </fullquery>

    <fullquery name="messages_select_moderator">
        <querytext>
            select fm.message_id,
                   fm.subject,
                   fm.user_id,
                   person.name(fm.user_id) as user_name,
                   to_char(fm.posting_date, 'YYYY-MM-DD HH24:MI:SS') as posting_date_ansi,
                   fm.state,
                   (select count(*)
                    from forums_messages fm1
                    where fm1.forum_id = :forum_id
                    and fm1.tree_sortkey between tree.left(fm.tree_sortkey) and tree.right(fm.tree_sortkey)) as n_messages,
                   to_char(fm.last_child_post, 'YYYY-MM-DD HH24:MI:SS') as last_child_post_ansi,
                   case when fm.last_child_post > (sysdate - 1) then 't' else 'f' end as new_p                   
            from forums_messages fm
            where fm.forum_id = :forum_id
            and fm.parent_id is null
            [template::list::orderby_clause -orderby -name "messages"]
        </querytext>
    </fullquery>

    <partialquery name="orderby_user_name_desc">
        <querytext>
      user_name desc
        </querytext>
    </partialquery>
    <partialquery name="orderby_user_name_asc">
        <querytext>
      user_name asc
        </querytext>
    </partialquery>

</queryset>
