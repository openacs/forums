<?xml version="1.0"?>
<queryset>

<fullquery name="forum::message::set_html_p.update_message_html_p">
<querytext>
update forums_messages set
html_p= :html_p
where 
message_id= :message_id
</querytext>
</fullquery>

<fullquery name="forum::message::edit.update_message">
<querytext>
update forums_messages set
subject= :subject,
content= :content,
html_p= :html_p
where message_id= :message_id
</querytext>
</fullquery>

<fullquery name="forum::message::set_state.update_message_state">
<querytext>
update forums_messages set
state= :state
where message_id= :message_id
</querytext>
</fullquery>

</queryset>
