<master>
<property name="title">#forums.Search_Forums#</property>
<property name="context">@context@</property>

<center>

  <table cellpadding="5" width="95%">

    <tr>
      <td align="right">
<formtemplate id="search">
        #forums.Search#&nbsp;<formwidget id="search_text">
</formtemplate>
      </td>
    </tr>

  </table>

  <br>

  <table bgcolor="#cccccc" cellpadding="5" width="95%">

    <tr>
      <th align="left" width="60%">#forums.Subject#</th>
      <th align="left" width="20%">#forums.Author#</th>
      <th align="center" width="20%">#forums.Posting_Date#</th>
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
        <a href="message-view?message_id=@messages.message_id@">@messages.subject@</a>
      </td>
      <td><a href="user-history?user_id=@messages.user_id@">@messages.user_name@</a></td>
      <td align="center">@messages.posting_date@</td>
    </tr>

</multiple>
</if>
<else>
    <tr bgcolor="#eeeeee">
      <td colspan="3">
        <i>#forums.No_Messages#</i>
      </td>
    </tr>
</else>

  </table>

</center>



