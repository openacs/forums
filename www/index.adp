<master src="master">
<property name="title">Forums</property>
<property name="context_bar">@context_bar@</property>

<center>

  <table cellpadding="5" width="95%">

<if @admin_p@>
    <tr>
      <td colspan="3">
        <nobr><small>[ <a href="admin/forum-new">New Forum</a> ]</small></nobr>
      </td>
    </tr>
</if>

  </table>

  <br>

  <table bgcolor="#cccccc" cellpadding="5" width="95%">

    <tr>
      <th align="left" width="70%">Forum Name</th>
      <th align="left" width="10%">Threads</th>
      <th align="left" width="20%">Last Post</th>
    </tr>

<if @forums:rowcount@ gt 0>
<multiple name="forums">

  <if @forums.rownum@ odd>
    <tr bgcolor="#eeeeee">
  </if>
  <else>
    <tr bgcolor="#d9e4f9">
  </else>

      <td>
        <a href="forum-view?forum_id=@forums.forum_id@">@forums.name@</a><br>
        <i>@forums.charter@</i>
      </td>
      <td>@forums.n_threads@</td>
      <td>@forums.last_modified@</td>

    </tr>

</multiple>
</if>
<else>
    <tr bgcolor="#eeeeee">
      <td colspan="3">
        <i>No Forums</i>
      </td>
    </tr>
</else>

  </table>

</center>
