<master src="../master">
<property name="title">Manage Forum: @forum.name@</property>
<property name="context">Manage</property>

<h3>Pending Threads</h3>

<ul>
<if @pending_threads:rowcount@ eq 0>
<i>None</i>
</if>
<else>
<multiple name="pending_threads">
<li> @pending_threads.tree_level@ <b><a href="../message-view?message_id=@pending_threads.message_id@">@pending_threads.subject@</a></b>
</multiple>
</else>
</ul>
