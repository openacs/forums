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
                   (select count(*)
                    from $forums_table fm1
                    where fm1.forum_id = :forum_id
                    and fm1.tree_sortkey between tree_left(fm.tree_sortkey) and tree_right(fm.tree_sortkey)) as n_messages,
		    to_char(fm.last_child_post, 'Mon DD YYYY HH24:MI:SS') as last_child_post,
                    case when fm.last_child_post > (now() - interval '1') then 't' else 'f' end as new_p
            from forums_messages_approved fm
            where fm.forum_id = :forum_id
            and fm.parent_id is null
            order by fm.posting_date desc
        </querytext>
    </fullquery>

    <partialquery name="messages_select_display_data_partial">
        <querytext>
            select fm.message_id,
                   fm.subject,
                   fm.user_id,
                   person__name(fm.user_id) as user_name,
                   fm.posting_date,
                   fm.state,
                   (select count(*)
                    from $forums_table fm1
                    where fm1.forum_id = :forum_id
                    and fm1.tree_sortkey between tree_left(fm.tree_sortkey) and tree_right(fm.tree_sortkey)) as n_messages,
	            to_char(fm.last_child_post, 'Mon DD YYYY HH24:MI:SS') as last_child_post,
                    case when fm.last_child_post > (now() - interval '1') then 't' else 'f' end as new_p
            from forums_messages fm
            where fm.forum_id = :forum_id
            and fm.parent_id is null
	    and fm.message_id IN (CURRENT_PAGE_SET)
            order by fm.posting_date desc
        </querytext>
    </partialquery>


    <fullquery name="messages_select_latest">
        <querytext>
            select fm.message_id,
                   fm.subject,
                   fm.user_id,
                   person__name(fm.user_id) as user_name,
                   fm.posting_date,
                   fm.state,
                   (select count(*)
                    from $forums_table fm1
                    where fm1.forum_id = :forum_id
                    and fm1.tree_sortkey between tree_left(fm.tree_sortkey) and tree_right(fm.tree_sortkey)) as n_messages,
		    to_char(fm.last_child_post, 'Mon DD YYYY HH24:MI:SS') as last_child_post,
                    case when fm.last_child_post > (now() - interval '1') then 't' else 'f' end as new_p
            from forums_messages_approved fm
            where fm.forum_id = :forum_id
            and fm.parent_id is null
            order by fm.last_child_post desc
        </querytext>
    </fullquery>

    <partialquery name="messages_select_latest_display_data_partial">
        <querytext>
            select fm.message_id,
                   fm.subject,
                   fm.user_id,
                   person__name(fm.user_id) as user_name,
                   fm.posting_date,
                   fm.state,
                   (select count(*)
                    from $forums_table fm1
                    where fm1.forum_id = :forum_id
                    and fm1.tree_sortkey between tree_left(fm.tree_sortkey) and tree_right(fm.tree_sortkey)) as n_messages,
	            to_char(fm.last_child_post, 'Mon DD YYYY HH24:MI:SS') as last_child_post,
                    case when fm.last_child_post > (now() - interval '1') then 't' else 'f' end as new_p
            from forums_messages fm
            where fm.forum_id = :forum_id
            and fm.parent_id is null
	    and fm.message_id IN (CURRENT_PAGE_SET)
            order by fm.last_child_post desc
        </querytext>
    </partialquery>

    <fullquery name="messages_select_unanswered">
        <querytext>
            select fm.message_id,
                   fm.subject,
                   fm.user_id,
                   person__name(fm.user_id) as user_name,
                   fm.posting_date,
                   fm.state,
                   (select count(*)
                    from $forums_table fm1
                    where fm1.forum_id = :forum_id
                    and fm1.tree_sortkey between tree_left(fm.tree_sortkey) and tree_right(fm.tree_sortkey)) as n_messages,
		    to_char(fm.last_child_post, 'Mon DD YYYY HH24:MI:SS') as last_child_post,
                    case when fm.last_child_post > (now() - interval '1') then 't' else 'f' end as new_p
            from forums_messages_approved fm
            where fm.forum_id = :forum_id
            and fm.parent_id is null
	    and fm.max_child_sortkey is null
            order by fm.posting_date desc
        </querytext>
    </fullquery>

    <partialquery name="messages_select_unanswered_display_data_partial">
        <querytext>
            select fm.message_id,
                   fm.subject,
                   fm.user_id,
                   person__name(fm.user_id) as user_name,
                   fm.posting_date,
                   fm.state,
                   (select count(*)
                    from $forums_table fm1
                    where fm1.forum_id = :forum_id
                    and fm1.tree_sortkey between tree_left(fm.tree_sortkey) and tree_right(fm.tree_sortkey)) as n_messages,
	            to_char(fm.last_child_post, 'Mon DD YYYY HH24:MI:SS') as last_child_post,
                    case when fm.last_child_post > (now() - interval '1') then 't' else 'f' end as new_p
            from forums_messages fm
            where fm.forum_id = :forum_id
            and fm.parent_id is null
	    and fm.max_child_sortkey is null
	    and fm.message_id IN (CURRENT_PAGE_SET)
            order by fm.posting_date desc
        </querytext>
    </partialquery>


    <fullquery name="messages_select_sincelastvisit">
        <querytext>
            select fm.message_id,
                   fm.subject,
                   fm.user_id,
                   person__name(fm.user_id) as user_name,
                   fm.posting_date,
                   fm.state,
                   (select count(*)
                    from $forums_table fm1
                    where fm1.forum_id = :forum_id
                    and fm1.tree_sortkey between tree_left(fm.tree_sortkey) and tree_right(fm.tree_sortkey)) as n_messages,
		    to_char(fm.last_child_post, 'Mon DD YYYY HH24:MI:SS') as last_child_post,
                    case when fm.last_child_post > (now() - interval '1') then 't' else 'f' end as new_p
            from forums_messages_approved fm
            where fm.forum_id = :forum_id
            and fm.parent_id is null
	    and fm.last_child_post > :second_to_last_visit
            order by fm.last_child_post desc
        </querytext>
    </fullquery>

    <partialquery name="messages_select_sincelastvisit_display_data_partial">
        <querytext>
            select fm.message_id,
                   fm.subject,
                   fm.user_id,
                   person__name(fm.user_id) as user_name,
                   fm.posting_date,
                   fm.state,
                   (select count(*)
                    from $forums_table fm1
                    where fm1.forum_id = :forum_id
                    and fm1.tree_sortkey between tree_left(fm.tree_sortkey) and tree_right(fm.tree_sortkey)) as n_messages,
	            to_char(fm.last_child_post, 'Mon DD YYYY HH24:MI:SS') as last_child_post,
                    case when fm.last_child_post > (now() - interval '1') then 't' else 'f' end as new_p
            from forums_messages fm
            where fm.forum_id = :forum_id
            and fm.parent_id is null
	    and fm.last_child_post > :second_to_last_visit
	    and fm.message_id IN (CURRENT_PAGE_SET)
            order by fm.last_child_post desc
        </querytext>
    </partialquery>
	
    <fullquery name="get_last_visit">
        <querytext>
	    select second_to_last_visit from cc_users where user_id=:user_id
        </querytext>
    </fullquery>

</queryset>
