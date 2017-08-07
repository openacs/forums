<master>
<property name="doc(title)">#forums.Post_to_Forum# @forum.name;noquote@</property>
<property name="context">@context;literal@</property>
<property name="focus">message.subject</property>

<include src="/packages/forums/lib/message/post" &="forum_id" 
                             &="parent_message"
                             &="anonymous_allowed_p"
                             &="attachments_enabled_p">

			     
