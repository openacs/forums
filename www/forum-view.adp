<master src="master">
<property name="title">Forum: @forum.name@</property>
<property name="context_bar">@context_bar@</property>

<center>

  <table cellpadding="5" width="95%">

<if @moderate_p@>
    <tr>
      <td colspan="4">
        <nobr><small>[
</if>

<if @admin_p@>
          <a href="admin/forum-edit?forum_id=@forum_id@">Administer</a> | 
</if>

<if @moderate_p@>
          <a href="moderate/forum?forum_id=@forum_id@">Manage/Moderate</a>
</if>

<if @moderate_p@>
        ]</small></nobr>
        <br><br>
      </td>
    </tr>
</if>

    <tr>
      <td colspan="4">
        @notification_chunk@
        <br><br>
        <if @post_p@>
          <nobr><small>[ <a href="message-post?forum_id=@forum_id@">Post a New Message</a> ]</small></nobr>
        </if>
      </td>
    </tr>

  </table>

  <br>

  <table bgcolor="#cccccc" cellpadding="5" width="95%">

    <tr>
      <th align="left" width="55%">Subject</th>
      <th align="left" width="20%">Author</th>
      <th align="center" width="5%">Replies</th>
      <th align="center" width="20%">Last Post</th>
    </tr>

<if @messages:rowcount@ gt 0>
<multiple name="messages">

  <if @messages.rownum@ odd>
    <tr bgcolor="#eeeeee">
  </if>
  <else>
    <tr bgcolor="#d9e4f9">
  </else>

      <td>
        <if @message_id.new_p@><b></if>
        <a href="message-view?message_id=@messages.message_id@">@messages.subject@</a> 
        <if @message_id.new_p@></b></if>
<if @moderate_p@ and @messages.state@ ne approved>
        <small>(@messages.state@)</small>
</if>
      </td>
      <td><a href="user-history?user_id=@messages.user_id@">@messages.user_name@</a></td>
      <td align="center">@messages.n_messages@</td>
      <td align="center">@messages.last_modified@</td>
    </tr>

</multiple>
</if>
<else>
    <tr bgcolor="#eeeeee">
      <td colspan="4">
        <i>No Messages</i>
      </td>
    </tr>
</else>

  </table>

</center>
