<master src="master">
<property name="title">Forum @forum.name@: @message.subject@</property>
<property name="context_bar">@context_bar@</property>

<p>
@notification_chunk@
</p>

<if @message.parent_id@ not nil>
<i>response to <a href="message-view?message_id=@message.root_message_id@">@message.root_subject@</a></i><p>
</if>

<b>@message.subject@</b>

<p>

<blockquote>
@message.content@
</blockquote>

<p>
<if @post_p@ eq 1><a href="message-post?parent_id=@message_id@">Respond!</a></if>
&nbsp; | &nbsp;
<a href="message-email?message_id=@message_id@">Email</a>

<if @moderate_p@ eq 1>
<p>
<b>Administration:</b> [@message.state@] [ <a href="moderate/message-delete?message_id=@message_id@">delete</a><if @message.state@ ne approved> | <a href="moderate/message-approve?message_id=@message_id@">approve</a></if><if @message.state@ ne rejected> | <a href="moderate/message-reject?message_id=@message_id@">reject</a></if> | <a href="moderate/message-edit?message_id=@message_id@">edit</a>]
</if>

<h3>Responses</h3>

<ul>
<multiple name="responses">
<li> <if @moderate_p@ eq 1 and @responses.state@ ne approved><b><i>(@responses.state@)</i></b> &nbsp;</if> @responses.tree_level@ <a href="message-view?message_id=@responses.message_id@">@responses.subject@</a>, by <a href="user-history?user_id=@responses.user_id@">@responses.user_name@</a> on @responses.posting_date@
</multiple>
</ul>
