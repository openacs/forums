<p>
  #forums.Posting_history_for#
  <b>
    <%
        if {![permission::permission_p -object_id [acs_magic_object security_context_root] -privilege admin]} {
            adp_puts [acs_community_member_link -user_id $user_id]
        } else {
            adp_puts [acs_community_member_admin_link -user_id $user_id]
        }
    %>
  </b>
</p>

<p>
<center>
@dimensional_chunk;noquote@
</center>
</p>

<center>

<if @view@ eq "date">

  <table width="95%" style="color: black; background-color: @table_border_color@;">

    <tr>
      <th align="left" width="30%">#forums.Forum#</th>
      <th align="left">#forums.Subject#</th>
      <th align="center" width="20%">#forums.Posted#</th>
    </tr>

<if @messages:rowcount@ gt 0>
<multiple name="messages">

  <if @messages.rownum@ odd>
    <tr style="color: black; background-color: @table_bgcolor@;">
  </if>
  <else>
    <tr style="color: black; background-color: @table_other_bgcolor@;">
  </else>

      <td><a href="forum-view?forum_id=@messages.forum_id@">@messages.forum_name@</a></td>
      <td><a href="message-view?message_id=@messages.message_id@">@messages.subject@</a></td>
      <td align="center">@messages.posting_date_pretty@</td>

    </tr>

</multiple>
</if>
<else>
    <tr>
      <td colspan="3">
        <i>#forums.No_Postings#</i>
      </td>
    </tr>
</else>

  </table>

</if>

<if @view@ eq forum>

<multiple name="messages">

  <table width="95%" style="color: black; background-color: @table_border_color@;">

    <tr bgcolor="#eeeeee">
      <th align="left" colspan="2">@messages.forum_name@<br><br></th>
    </tr>

    <tr>
      <th align="left">#forums.Subject#</th>
      <th align="center" width="20%">#forums.Posted#</th>
    </tr>

<group column="forum_name">

  <if @messages.rownum@ odd>
    <tr style="color: black; background-color: @table_bgcolor@;">
  </if>
  <else>
    <tr style="color: black; background-color: @table_other_bgcolor@;">
  </else>

      <td><a href="message-view?message_id=@messages.message_id@">@messages.subject@</a></td>
      <td align="center">@messages.posting_date_pretty@</td>

    </tr>

</group>

  </table>
  <br>

</multiple>

</if>

</center>