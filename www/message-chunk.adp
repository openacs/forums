
<tr style="color: black; background-color: @table_bgcolor@;">
  <td align=left style="padding-left: 1em">

  <strong>
    <if @preview@ nil>
      <a href="message-view?message_id=@message.message_id@">@message.subject@</a>
    </if>
    <else>
      @message.subject@
    </else>
  </strong>  

  <td align=center>
    <a href="user-history?user_id=@message.user_id@">@message.user_name@</a></td>
  <td align=center>@message.posting_date@</td>

  <if @preview@ nil>
  
    <td align=right style="padding-right: 1em; padding-left: 1em;">
      <div style="white-space: nowrap; font-size: x-small">
        [ <a href="message-post?parent_id=@message.message_id@">reply</a>
        | <a href="message-email?message_id=@message.message_id@">email</a>
        ]
        <if @moderate_p@>
          <br>
          [ <a href="moderate/message-edit?message_id=@message.message_id@">edit</a>
          | <a href="moderate/message-delete?message_id=@message.message_id@">delete</a>
          
          <if @forum_moderated_p@>
            <if @message.state@ ne approved>
              | <a href="moderate/message-approve?message_id=@message.message_id@">approve</a>
            </if>
            <if @message.state@ ne rejected and @message.max_child_sortkey@ nil>
              | <a href="moderate/message-reject?message_id=@message.message_id@">reject</a>
            </if>
          </if>
          ]
        </if>
      </div>
    </td>

  </if>

</tr>

<tr style="color: black; background-color: @table_bgcolor@">
  <if @preview@ nil>
    <td colspan="4" style="padding: 1em">
  </if>
  <else>
    <td colspan="3" style="padding: 1em">  
  </else>

    <if @message.html_p@ false>
      <div style="font-family: monospace">
        <%= [ad_text_to_html --  "$message(content)"] %>
      </div>
    </if>
    <else>
      @message.content@
    </else>
  </td>
</tr>

<if @message.n_attachments@ not nil and @message.n_attachments@ gt 0>
  <include src="message-attachment-chunk" &message="message" bgcolor=@table_bgcolor@>
</if>
