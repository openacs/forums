<master>
<property name="doc(title)">#forums.Post_to_Forum# @forum.name;literal@</property>
<property name="context">@context;literal@</property>
<property name="focus">message.subject</property>
<property name="displayed_object_id">@forum_id;literal@</property>

<include src="/packages/forums/lib/message/post" &="forum_id" 
                             &="parent_message"
                             &="anonymous_allowed_p"
                             &="attachments_enabled_p">

			     
