<master>
<property name="title">#forums.Manage_Forum# @forum.name;noquote@</property>
<property name="context">#forums.Manage#</property>

<h3>#forums.Pending_Threads#</h3>

<ul>
<if @pending_threads:rowcount@ eq 0>
<i>#forums.None#</i>
</if>
<else>
<multiple name="pending_threads">
<li> @pending_threads.tree_level@ <b><a href="../message-view?message_id=@pending_threads.message_id@">@pending_threads.subject@</a></b>
</multiple>
</else>
</ul>



