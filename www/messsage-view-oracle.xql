<?xml version="1.0"?>
<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="select_message_responses">
<querytext>
select message_id, subject, content, party.name(user_id) as user_name, posting_date from forums_messages
where parent_id= :message_id order by posting_date
</querytext>
</fullquery>

</queryset>
