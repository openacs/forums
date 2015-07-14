<master>
<property name="doc(title)">#forums.Confirm_Move_to# @message.subject;noquote@</property>
<property name="context">#forums.Move_to#</property>

<include src="/packages/forums/lib/message/choose-thread-move" &message="message" confirm_p="@confirm_p;literal@" return_url="@return_url;literal@">
