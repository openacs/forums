<?xml version="1.0"?>
<queryset>

<fullquery name="messages_select">
<querytext>
    select message_id, subject, user_id, person.name(user_id) as user_name, posting_date, state
      from forums_messages_approved
      where forum_id = :forum_id
      and parent_id is NULL
    order by posting_date desc
</querytext>
</fullquery>

<fullquery name="messages_select_moderator">
<querytext>
    select message_id, subject, user_id, person.name(user_id) as user_name, posting_date, state
      from forums_messages
      where forum_id = :forum_id
      and parent_id is NULL
    order by posting_date desc
</querytext>
</fullquery>

</queryset>
