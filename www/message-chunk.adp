    <tr bgcolor="@bgcolor@">
      <td><b><a href="message-view?message_id=@message.message_id@">@message.subject@</a></b></td>
      <td width="15%"><a href="user-history?user_id=@message.user_id@">@message.user_name@</a></td>
      <td align="center" width="20%">@message.posting_date@</td>
      <td align="right" width="25%">
        <nobr><small>
          [
            <a href="message-post?parent_id=@message.message_id@">reply</a>
            | <a href="message-email?message_id=@message.message_id@">email</a>
          ]
        </small></nobr>
<if @moderate_p@>
        <br>
        <nobr><small>
          [
            <a href="moderate/message-edit?message_id=@message.message_id@">edit</a>
            | <a href="moderate/message-delete?message_id=@message.message_id@">delete</a>
<if @message.state@ ne approved>
            | <a href="moderate/message-approve?message_id=@message.message_id@">approve</a>
</if>
<if @message.state@ ne rejected and @message.max_child_sortkey@ nil>
            | <a href="moderate/message-reject?message_id=@message.message_id@">reject</a>
</if>
          ]
        </small></nobr>
</if>
      </td>
    </tr>
    <tr bgcolor="@bgcolor@">
      <td colspan="4"><blockquote>@message.content@</blockquote></td>
    </tr>
