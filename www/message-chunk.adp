<div class="forum_message">
<if @display_subject_p@>
    <span class="fmessagetitle">
      <if @preview@ nil>
        <a href="message-view?message_id=@message.message_id@">@message.subject@</a>
      </if>
      <else>
        @message.subject@
      </else>
    </span>
</if>

  <if @preview@ nil>

  </if>
  <else>

  </else>

    <if @message.html_p@ false>
    <div align="left">
      <%= [ad_text_to_html --  "$message(content)"] %>
    </div>
    </if>
    <else>
      @message.content@
    </else>


<p class="fmessageauthor"> -- <a href="user-history?user_id=@message.user_id@">@message.user_name@</a> @message.posting_date@

  <if @preview@ nil>
  



        [ <a href="message-email?message_id=@message.message_id@">Forward</a>
        ]
        <if @moderate_p@>
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

  </if>

</p>

<if @message.n_attachments@ not nil and @message.n_attachments@ gt 0>
  <include src="message-attachment-chunk" &message="message" bgcolor=@table_bgcolor@>
</if>
<hr />
</div>
