<master src="../master">
<property name="title">Edit Forum: @forum.name@</property>
<property name="context">@context@</property>
<property name="focus">forum.name</property>

<if @forum.enabled_p@ eq t>
This forum is <b>enabled</b>. You may <a href="forum-disable?forum_id=@forum.forum_id@">disable it</a>.
</if>
<else>
This forum is <b>disabled</b>. You may <a href="forum-enable?forum_id=@forum.forum_id@">enable it</a>.
</else>
<p>

<formtemplate id="forum"></formtemplate>
