<master src="master">
<property name="title">Forum @forum.name@: @message.subject@</property>
<property name="context_bar">@context_bar@</property>

<center>

  <table cellpadding="4" width="95%">
    <tr>
      <td colspan="4">
        @notification_chunk@
<if @post_p@>
        <nobr><small>[
          <a href="message-post?forum_id=@forum_id@">Post a New Message</a>
        ]</nobr></small>
</if>
      </td>
      <td align="right">
<formtemplate id="search">
        <formwidget id="forum_id">
        Search:&nbsp;<formwidget id="search_text">
</formtemplate>
      </td>
    </tr>
  </table>

  <br>

  <table bgcolor="#cccccc" cellpadding="5" width="95%">
<include src="message-chunk" bgcolor="#eeeeee" forum_moderated_p=@forum_moderated_p@ moderate_p=@moderate_p@ &message="message">
  </table>

<if @responses:rowcount@ gt 0>
  <br>

  <table cellpadding="5" width="96%">

<multiple name="responses">

<% set width [expr 100 - $responses(tree_level) * 3] %>

    <tr>
      <td>
        <table align="right" bgcolor="#cccccc" cellpadding="5" width="@width@%">
<if @responses.rownum@ odd>
  <include src="message-chunk" bgcolor="#d9e4f9" forum_moderated_p=@forum_moderated_p@ moderate_p=@moderate_p@ &message="responses">
</if>
<else>
  <include src="message-chunk" bgcolor="#eeeeee" forum_moderated_p=@forum_moderated_p@ moderate_p=@moderate_p@ &message="responses">
</else>
        </table>
      </td>
    </tr>

</multiple>

  </table>
</if>

</center>
