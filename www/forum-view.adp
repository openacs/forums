<master>
<property name="title">Forum: @forum.name@</property>
<property name="context">@context@</property>

<center>

  <table width="95%">
    <tr>
      <td style="white-space: nowrap; font-size: x-small; line-height: 150%">
        <if @moderate_p@>
        [
          <if @admin_p@>
            <a href="admin/forum-edit?forum_id=@forum_id@">Administer</a> |
          </if>
          <a href="moderate/forum?forum_id=@forum_id@">Manage/Moderate</a>
        ]       
        </if>

        <br>
  
        @notification_chunk@
  
        <br>
  
        <if @post_p@>
          [ <a href="message-post?forum_id=@forum_id@">Post a New Message</a> ]
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
  
    <table style="color: black; background-color: @table_border_color@;" width="95%">
  
      <tr>
        <th align="left" width="55%">Subject</th>
        <th align="left" width="20%">Author</th>
        <th align="center" width="5%">Replies</th>
        <th align="center" width="20%">Last Post</th>
      </tr>
  
      <if @messages:rowcount@ gt 0>
        <multiple name="messages">
          <if @messages.rownum@ odd>
            <tr style="color: black; background-color: @table_bgcolor@;" >
          </if>
          <else>
            <tr style="color: black; background-color: @table_other_bgcolor@;">
          </else>
  
          <td style="padding: 4px;">
            <if @messages.new_p@>
              <strong>
            </if>
              <a href="message-view?message_id=@messages.message_id@">@messages.subject@</a> 
            <if @messages.new_p@>
              </strong>
            </if>
            <if @moderate_p@ and @messages.state@ ne approved>
              <small>(@messages.state@)</small>
            </if>
          </td>
          <td style="padding: 4px;"><a href="user-history?user_id=@messages.user_id@">@messages.user_name@</a></td>
          <td align="center" style="padding: 4px;">@messages.n_messages@</td>
          <td align="center" style="padding: 4px;">@messages.last_modified@</td>
          
            </tr>
        </multiple>
      </if>
      <else>
        <tr bgcolor="@table_bgcolor@">
          <td colspan="4"><strong>No Messages</strong></td>
        </tr>
      </else>
  
    </table>

</center>
