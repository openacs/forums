<?xml version="1.0"?>
<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="select_messages">
<querytext>
select message_id, subject, posting_date, forums_forums.forum_id, forums_forums.name as forum_name
from forums_messages, forums_forums
where forums_messages.forum_id = forums_forums.forum_id
and user_id= :user_id
and package_id = :package_id
$sql_order_by
</querytext>
</fullquery>

</queryset>
