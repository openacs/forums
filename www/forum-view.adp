<master src="master">
<property name="title">Forum: @forum.name@</property>
<property name="context_bar">@context_bar@</property>

<if @admin_p@ eq 1>
[<a href="admin/forum-edit?forum_id=@forum_id@">Administer this Forum</a>] &nbsp;
</if>
<if @moderate_p@ eq 1>
[<a href="moderate/forum?forum_id=@forum_id@">Manage/Moderate this Forum</a>]
</if>

<p>
@notification_chunk@
</p>

<ul>
<if @post_p@ eq 1><li> <a href="message-post?forum_id=@forum_id@">Post a New Message</a><p></if>
<multiple name="messages">
<li> <if @moderate_p@ eq 1 and @messages.state@ ne approved><b><i>(@messages.state@)</i></b> &nbsp;</if> <a href="message-view?message_id=@messages.message_id@">@messages.subject@</a>, by <a href="user-history?user_id=@messages.user_id@">@messages.user_name@</a> on <%= [util_AnsiDatetoPrettyDate $messages(posting_date)] %>
</multiple>
</ul>
