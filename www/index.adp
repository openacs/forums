<master src="master">
<property name="title">Forums</property>
<property name="context_bar">@context_bar@</property>

<ul>
<if @admin_p@ eq 1>
<li> <a href="admin/forum-new">Create New Forum</a><p>
</if>
<multiple name="forums">
<li> <a href="forum-view?forum_id=@forums.forum_id@">@forums.name@</a>
</multiple>
</ul>
