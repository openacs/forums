<?xml version="1.0"?>
<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="select_message_responses">
<querytext>
select message_id, subject, content, party__name(user_id) as user_name, posting_date from forums_messages
where parent_id= :message_id order by posting_date
</querytext>
</fullquery>

</queryset>
