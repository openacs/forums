    <tr bgcolor="@bgcolor@">
      <td colspan="4">
        Attachments:
        <ul>
<% 
    foreach attachment $attachments {
        template::adp_puts "<li><a href=\"[lindex $attachment 2]\">[lindex $attachment 1]</a></li>"
    }
%>
        </ul>
      </td>
    </tr>
