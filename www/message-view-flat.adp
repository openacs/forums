<master src="master">
<property name="title">Forum @forum.name@: @message.subject@</property>
<property name="context_bar">@context_bar@</property>

<center>

  <table cellpadding="5" width="95%">
    <tr>
      <td colspan="4">
        @notification_chunk@
<if @post_p@>
        <nobr><small>[
          <a href="message-post?forum_id=@forum_id@">Post a New Message</a>
        ]</nobr></small>
</if>
      </td>
    </tr>
  </table>

  <br>

  <table bgcolor="#cccccc" cellpadding="5" width="95%">
<include src="message-chunk" bgcolor="#eeeeee" moderate_p=@moderate_p@ &message="message">
  </table>

  <br>

  <table bgcolor="#cccccc" cellpadding="5" width="95%">

<multiple name="responses">

<if @responses.rownum@ odd>
  <include src="message-chunk" bgcolor="#d9e4f9" moderate_p=@moderate_p@ &message="responses">
</if>
<else>
  <include src="message-chunk" bgcolor="#eeeeee" moderate_p=@moderate_p@ &message="responses">
</else>

</multiple>

  </table>

</center>
