<master>
<property name="title">Forum @forum.name@: @message.subject@</property>
<property name="context">@context@</property>

<center>

  <table cellpadding="5" width="95%">
    <tr>
      <td colspan="4">
        <nobr>@notification_chunk@</nobr>
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

<if @responses:rowcount@ gt 0>
  <br>

  <table bgcolor="#cccccc" cellpadding="5" width="95%">

<multiple name="responses">

<if @responses.rownum@ odd>
  <include src="message-chunk" bgcolor="#d9e4f9" moderate_p=@moderate_p@ &message="responses" root_subject="@message.root_subject@">
</if>
<else>
  <include src="message-chunk" bgcolor="#eeeeee" moderate_p=@moderate_p@ &message="responses" root_subject="@message.root_subject@">
</else>

</multiple>

  </table>
</if>

</center>
