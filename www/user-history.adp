<master src="master">
<property name="title">Forums: Posting History for @user.full_name@</property>
<property name="context_bar">@context_bar@</property>

<center>
@dimensional_chunk@
</center>
<p>

<ul>

<if @view@ eq date>
<multiple name="messages">
<li> <a href="forum-view?forum_id=@messages.forum_id@">@messages.forum_name@</a> - <a href="message-view?message_id=@messages.message_id@">@messages.subject@</a> on <%= [util_AnsiDatetoPrettyDate $messages(posting_date)] %>
</multiple>
</if>

<if @view@ eq forum>
<multiple name="messages">
<h3>Forum: @messages.forum_name@</h3>
<group column="forum_name">
<li> <a href="message-view?message_id=@messages.message_id@">@messages.subject@</a> on <%= [util_AnsiDatetoPrettyDate $messages(posting_date)] %>
</group>
</multiple>
</if>

</ul>
