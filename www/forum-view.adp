<master>
<property name="title">#forums.Forum_1# @forum.name;noquote@</property>
<property name="context">@context;noquote@</property>

<center>

  <table width="95%">
    <tr>
      <td style="white-space: nowrap; font-size: x-small; line-height: 150%">
        <if @moderate_p@>
        [
          <if @admin_p@>
            <a href="admin/forum-edit?forum_id=@forum_id@">#forums.Administer#</a> |
          </if>
          <a href="moderate/forum?forum_id=@forum_id@">#forums.ManageModerate#</a>
        ]       
        </if>

        <br>
  
        @notification_chunk;noquote@
  
        <br>
  
        <if @post_p@>
          [ <a href="message-post?forum_id=@forum_id@">#forums.Post_a_New_Message#</a> ]
        </if>

        <br>
        <br>
        
        Sort by: [ @sort_filter;noquote@ ]

      </td>
      <td align="right">
        <formtemplate id="search">
          <formwidget id="forum_id">
            #forums.Search#&nbsp;<formwidget id="search_text">
          </formtemplate>
      </td>
    </tr>
  
    </table>
  
    <br>
  
    <table style="color: black; background-color: @table_border_color@;" width="95%">
  
      <tr>
        <th align="left" width="55%">#forums.Subject#</th>
        <th align="left" width="20%">#forums.Author#</th>
        <th align="center" width="5%">#forums.Replies#</th>
        <th align="center" width="20%">#forums.Last_Post#</th>
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
          <td align="center" style="padding: 4px;">@messages.last_child_post_pretty@</td>
          
            </tr>
        </multiple>
      </if>
      <else>
        <tr bgcolor="@table_bgcolor@">
          <td colspan="4"><strong>#forums.No_Messages#</strong></td>
        </tr>
      </else>
  
    </table>

</center>
