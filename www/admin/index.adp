<master>
<property name="title">#forums.lt_Forums_Administration#</property>
<property name="context"></property>

<h3>#forums.Forums#</h3>
<ul>
<li> <a href="forum-new">#forums.Create_a_New_Forum#</a> </li>
<li> <a href="@parameters_url@">#forums.Parameters#</a> </li>

<p>

<multiple name="forums">

  <if @forums.enabled_p@ eq t><h3>#forums.Active_Forums#</h3></if>
  <else><h3>#forums.Disabled_Forums#</h3></else>

  <group column="enabled_p">
    <li> 
      [
        <if @forums.enabled_p@ eq t><a href="forum-disable?forum_id=@forums.forum_id@">#forums.disable#</a></if>
        <else><a href="forum-enable?forum_id=@forums.forum_id@">#forums.enable#</a></else>
      ]
      <a href="forum-edit?forum_id=@forums.forum_id@">@forums.name@</a>
      (<a href="../forum-view?forum_id=@forums.forum_id@">View</a>)
      (<a href="permissions?object_id=@forums.forum_id@">Permissions</a>)
    </li>
  </group>

</multiple>
</ul>
