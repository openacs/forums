<master>
<property name="title">#forums.Forum# @forum.name@: @message.subject@</property>
<property name="context">@context@</property>

<center>

  <table cellpadding="5" width="95%">
    <tr>
      <td colspan="4">
        <nobr>@notification_chunk@</nobr>
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

<if @reply_url@ not nil>
  <blockquote>
    <a href="@reply_url@"><b>#forums.Post_a_Reply#</b></a>
  </blockquote>
</if>
