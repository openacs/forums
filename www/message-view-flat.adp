<master src="master">
<property name="title">Forum @forum.name@: @message.subject@</property>
<property name="context_bar">@context_bar@</property>

<p>
@notification_chunk@
</p>

<h3>Message</h3>
<blockquote>
<if @message.parent_id@ not nil>
<i>response to <a href="message-view?message_id=@message.root_message_id@">@message.root_subject@</a></i><p>
</if>

<b>@message.subject@</b>

<p>

@message.content@

<p>
-- <a href="user-history?user_id=@message.user_id@">@message.user_name@</a> on <%= [util_AnsiDatetoPrettyDate $message(posting_date)] %><p>

<if @post_p@ eq 1><a href="message-post?parent_id=@message_id@">Respond!</a></if>
&nbsp; | &nbsp;
<a href="message-email?message_id=@message_id@">Email</a>

<if @moderate_p@ eq 1>
<p>
<b>Administration:</b> [@message.state@] [ <a href="moderate/message-delete?message_id=@message_id@">delete</a><if @message.state@ ne approved> | <a href="moderate/message-approve?message_id=@message_id@">approve</a></if><if @message.state@ ne rejected> | <a href="moderate/message-reject?message_id=@message_id@">reject</a></if> | <a href="moderate/message-edit?message_id=@message_id@">edit</a>]
</if>
</blockquote>

<h3>Responses</h3>

<multiple name="responses">
<blockquote>
<if @moderate_p@ eq 1 and @responses.state@ ne approved><b><i>(@responses.state@)</i></b><br></if>
<b>@responses.subject@</b><p>
@responses.content@<p>
-- <a href="user-history?user_id=@responses.user_id@">@responses.user_name@</a> on <%= [util_AnsiDatetoPrettyDate $responses(posting_date)] %><p><hr width=40%><p>
</blockquote>
</multiple>
</ul>
