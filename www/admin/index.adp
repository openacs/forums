<master src="../master">
<property name="title">Forums Administration</property>
<property name="context_bar"></property>

<h3>Forums</h3>
<ul>
<li> <a href="forum-new">Create a New Forum</a>
<p>
<multiple name="forums">

<if @forums.enabled_p@ eq t><h3>Active Forums</h3></if>
<else><h3>Disabled Forums</h3></else>

<group column="enabled_p">
<li> [<if @forums.enabled_p@ eq t><a href="forum-disable?forum_id=@forums.forum_id@">disable</a></if>
<else><a href="forum-enable?forum_id=@forums.forum_id@">enable</a></else>]
<a href="forum-edit?forum_id=@forums.forum_id@">@forums.name@</a>
</group>

</multiple>
</ul>
