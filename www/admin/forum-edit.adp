<master>
<property name="title">Edit Forum: @forum.name@</property>
<property name="context">@context@</property>
<property name="focus">forum.name</property>

<if @forum.enabled_p@ eq t>
#forums.This_forum_is# <b>#forums.enabled#</b>. #forums.You_may# <a href="forum-disable?forum_id=@forum.forum_id@">#forums.disable_it#</a>.
</if>
<else>
#forums.This_forum_is# <b>#forums.disabled#</b>. #forums.You_may# <a href="forum-enable?forum_id=@forum.forum_id@">#forums.enable_it#</a>.
</else>
<p>

<formtemplate id="forum"></formtemplate>


