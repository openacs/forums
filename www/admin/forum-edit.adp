<master>
<property name="doc(title)">Edit Forum: @forum.name;noquote@</property>
<property name="context">@context;literal@</property>
<property name="focus">forum.name</property>

<if @forum.enabled_p;literal@ true>
#forums.This_forum_is# <strong>#forums.enabled#</strong>. #forums.You_may# <a href="forum-disable?forum_id=@forum.forum_id@">#forums.disable_it#</a>.
</if>
<else>
#forums.This_forum_is# <strong>#forums.disabled#</strong>. #forums.You_may# <a href="forum-enable?forum_id=@forum.forum_id@">#forums.enable_it#</a>.
</else>
<p>

<include src="/packages/forums/lib/forums/edit" &forum="forum" return_url="@return_url;literal@">
