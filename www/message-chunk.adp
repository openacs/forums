
<tr style="color: black; background-color: @table_bgcolor@;">
<if @display_subject_p@>
  <td align=left style="padding-left: 1em">
    <strong>
      <if @preview@ nil>
        <a href="message-view?message_id=@message.message_id@">@message.subject@</a>
      </if>
      <else>
        @message.subject@
      </else>
    </strong>  
  </td>
</if>
  <td align=center>
    <a href="user-history?user_id=@message.user_id@">@message.user_name@</a></td>
  <td align=center>@message.posting_date_pretty@</td>

  <if @preview@ nil>
  
    <td align=right style="padding-right: 1em; padding-left: 1em;">
      <div style="white-space: nowrap; font-size: x-small">
        [ <a href="message-post?parent_id=@message.message_id@">#forums.reply#</a>
        | <a href="message-email?message_id=@message.message_id@">#forums.email#</a>
        ]
        <if @moderate_p@>
          <br>
          [ <a href="moderate/message-edit?message_id=@message.message_id@">#forums.edit#</a>
          | <a href="moderate/message-delete?message_id=@message.message_id@">#forums.delete#</a>
          
          <if @forum_moderated_p@>
            <if @message.state@ ne approved>
              | <a href="moderate/message-approve?message_id=@message.message_id@">#forums.approve#</a>
            </if>
            <if @message.state@ ne rejected and @message.max_child_sortkey@ nil>
              | <a href="moderate/message-reject?message_id=@message.message_id@">#forums.reject#</a>
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
    <td colspan="3" align="left" style="padding: 1em">  
  </else>

    <if @message.html_p@ false>
    <div align="left">
      @message.content;noquote@
    </div>
    </if>
    <else>
      @message.content;noquote@
    </else>
  </td>
</tr>

<if @message.n_attachments@ not nil and @message.n_attachments@ gt 0>
  <include src="message-attachment-chunk" &message="message" bgcolor=@table_bgcolor;noquote@>
</if>
