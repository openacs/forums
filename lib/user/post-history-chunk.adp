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

<if @messages:rowcount@ gt 0>
<listtemplate name="messages"></listtemplate>
</if>
<else>
    <tr>
      <td colspan="3">
        <i>#forums.No_Postings#</i>
      </td>
    </tr>
</else>

<hr>
  <p>#forums.Summary_Posting_history_for#</p>

<p></p>
<if @posts:rowcount@ gt 0>
  <listtemplate name="posts"></listtemplate>
</if>
<else>
    <tr>
      <td colspan="3">
        <i>#forums.No_Postings#</i>
      </td>
    </tr>
</else>
</if>

</center>
