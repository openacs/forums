<master>
<property name="title">#forums.Forum# @forum.name;noquote@: @message.subject;noquote@</property>
<property name="context">@context;noquote@</property>

<center>

  <table cellpadding="5" width="95%">
    <tr>
      <td colspan="4">
        <nobr>@notification_chunk;noquote@</nobr>
      </td>
    </tr>
  </table>

  <br>

  <table bgcolor="#cccccc" cellpadding="5" width="95%">
<include src="message-chunk" bgcolor="#eeeeee" moderate_p=@moderate_p;noquote@ &message="message">
  </table>

<if @responses:rowcount@ gt 0>
  <br>

  <table bgcolor="#cccccc" cellpadding="5" width="95%">

<multiple name="responses">

<if @responses.rownum@ odd>
  <include src="message-chunk" bgcolor="#d9e4f9" moderate_p=@moderate_p;noquote@ &message="responses" root_subject="@message.root_subject;noquote@">
</if>
<else>
  <include src="message-chunk" bgcolor="#eeeeee" moderate_p=@moderate_p;noquote@ &message="responses" root_subject="@message.root_subject;noquote@">
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
