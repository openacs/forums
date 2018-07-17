<ul>
<if @pending_threads:rowcount;literal@ eq 0>
<em>#forums.None#</em>
</if>
<else>
<multiple name="pending_threads">
<li><strong><a href="../message-view?message_id=@pending_threads.message_id@">@pending_threads.subject@</a></strong>
</multiple>
</else>
</ul>
