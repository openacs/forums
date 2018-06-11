<?xml version="1.0"?>
<queryset>

  <fullquery name="messages_select_paginate">
    <querytext>
            select fm.message_id,
                   fm.subject,
                   $replies as n_messages
            from forums_messages_approved fm
            where fm.forum_id = :forum_id
            and fm.parent_id is null
            [template::list::orderby_clause -orderby -name messages]
    </querytext>
  </fullquery>

  <fullquery name="messages_select">
    <querytext>
            select fm.message_id,
                   fm.subject,
                   fm.last_poster as user_id,
                   to_char(fm.posting_date, 'YYYY-MM-DD HH24:MI:SS') as posting_date_ansi,
                   fm.state,
                   $replies as n_messages,
                   to_char(fm.last_child_post, 'YYYY-MM-DD HH24:MI:SS') as last_child_post_ansi,
		   $unread_or_new_query_clause
            from   forums_messages_approved fm $unread_join
            where fm.forum_id = :forum_id
            and fm.parent_id is null
            [template::list::page_where_clause -and -name messages -key fm.message_id]
            [template::list::orderby_clause -orderby -name messages]
    </querytext>
  </fullquery>

  <partialquery name="unread_query">
    <querytext>
      case when fi.reading_date is null then 't' else 'f' end as unread_p
    </querytext>
  </partialquery>

  <partialquery name="unread_join">
    <querytext>
      left join forums_reading_info fi on fm.message_id=fi.root_message_id and fi.user_id = :user_id
    </querytext>
  </partialquery>

  <partialquery name="new_query">
    <querytext>
      case when fm.last_child_post > current_timestamp - interval '1' day then 't' else 'f' end as new_p
    </querytext>
  </partialquery>

</queryset>
