<?xml version="1.0"?>
<queryset>

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
