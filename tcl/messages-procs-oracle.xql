<?xml version="1.0"?>
<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="forum::message::get.select_message">
<querytext>
select message_id, forum_id, subject, content, person.name(user_id) as user_name, 
party.email(user_id) as user_email, user_id,
forums_forum.name(forum_id) as forum_name, 
forums_message.root_message_id(forums_messages.message_id) as root_message_id,
(select subject from forums_messages fm2 
where message_id= forums_message.root_message_id(forums_messages.message_id)) as root_subject, 
posting_date, tree_sortkey, parent_id, state, html_p
from forums_messages
where message_id= :message_id
</querytext>
</fullquery>

<fullquery name="forum::message::delete.delete_message">
<querytext>
declare begin
   forums_message.delete_thread(:message_id);
end;
</querytext>
</fullquery>

<fullquery name="forum::message::close.thread_close">
<querytext>
declare begin
forums_message.thread_close(:message_id);
end;
</querytext>
</fullquery>

<fullquery name="forum::message::open.thread_open">
<querytext>
declare begin
forums_message.thread_open(:message_id);
end;
</querytext>
</fullquery>

</queryset>
