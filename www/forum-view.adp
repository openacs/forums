<master>
<property name="title">Forum: @forum.name@</property>
<property name="context">@context@</property>

<center>

  <table width="95%">
    <tr>
      <td style="white-space: nowrap; line-height: 150%">
        <if @moderate_p@>
        
          <if @admin_p@>
            <a href="admin/forum-edit?forum_id=@forum_id@">Administer</a> |
          </if>
          <a href="moderate/forum?forum_id=@forum_id@">Manage/Moderate</a>
               
        </if>

        <br>
  
        @notification_chunk@
  
        <br>
	<if @post_p@>	
	  <strong><a href="message-post?forum_id=@forum_id@">Post a New Message</a></strong>
	</if>	  
      </td>
      <td align="right">
	 <if @mode@ ne "unanswered"><br /><a href="forum-view?forum_id=@forum_id@&mode=unanswered">View unanswered posts</a></if><if @user_id@ ne 0><if @mode@ ne "sincelastvisit"><br /><a href="forum-view?forum_id=@forum_id@&mode=sincelastvisit">New posts since your last visit</a></if></if></td>
    </tr>
  
    </table>
  
    <br>
 
    <!-- pagination context bar -->
    <table cellpadding=4 cellspacing=0 border=0 width="95%">
    <tr>
      <td align="left">
        <if @info.previous_group@ not nil>
	<a href="forum-view?forum_id=@forum_id@&page=@info.previous_group@"><img src="/templates/images/nav_previous_group.jpg" border="0" align="center"></a>
&nbsp;<b><a href="forum-view?forum_id=@forum_id@&page=@info.previous_group@">Previous 10</a></b>
        </if>

      </td>
    
      <td align=center>
        <if @info.previous_page@ gt 0>
          <a href="forum-view?forum_id=@forum_id@&page=@info.previous_page@">
                        <img src="/templates/images/nav_previous.jpg" border="0" alt="Previous Page" width="11" height="20" align="center"></a> <a href="forum-view?forum_id=@forum_id@&page=@info.previous_page@"><b>Previous</b></a>
          &nbsp;
        </if>
        <else>&nbsp;</else>
      <multiple name=pages>
        <if @page@ ne @pages.page@>
          <a href="forum-view?forum_id=@forum_id@&page=@pages.page@">@pages.page@</a>
        </if>
        <else>
          @page@
        </else>
      </multiple>
        <if @page@ lt @info.page_count@>
          &nbsp; <a href="forum-view?forum_id=@forum_id@&page=@info.next_page@">
            <b>Next</b></a> <a href="forum-view?forum_id=@forum_id@&page=@info.next_page@">
            <img src="/templates/images/nav_next.jpg" border="0" alt="Next Page" width="11" height="20" align="center"></a>
            <br>
        </if>
        <else>&nbsp;</else>
      </td>

      <td align="right">


        <if @info.next_group@ not nil>

          <a href="forum-view?forum_id=@forum_id@&page=@info.next_group@">
            <b>Next 10</b></a>&nbsp;<a href="forum-view?forum_id=@forum_id@&page=@info.next_group@"><img src="/templates/images/nav_next_group.jpg" border="0" align="center"></a>
        </if>
      </td>
    </tr>
    </table>
    <!-- end pagination -->
 
    <table style="color: black; <if @background-color@ not nil>background-color: @table_border_color@;</if>" width="95%">
  
      <tr>
	<th align="left"></th>
        <th align="left" width="55%">Subject</th>
        <th align="left" width="20%">Author</th>
        <th align="center" width="5%">Replies</th>
        <th align="center" width="20%">Last Post</th>
      </tr>

     <if @messages:rowcount@ gt 0>
  
        <multiple name="messages">
          <if @messages.rownum@ odd>
            <tr style="color: black; <if @table_bgcolor@ not nil>background-color: @table_bgcolor@;</if>" >
          </if>
          <else>
            <tr style="color: black; <if @table_other_bgcolor@ not nil>background-color: @table_other_bgcolor@;</if>">
          </else>
	<td>
            <if @messages.new_p@>
	<img src="/graphics/new.gif" width="30" height="12" alt="New">
            </if>
	</td>  
          <td style="padding: 4px;">

              <a href="message-view?message_id=@messages.message_id@">@messages.subject@</a> 

            <if @moderate_p@ and @messages.state@ ne approved>
              <small>(@messages.state@)</small>
            </if>
          </td>
          <td style="padding: 4px;"><a href="user-history?user_id=@messages.user_id@">@messages.user_name@</a></td>
          <td align="center" style="padding: 4px;">@messages.n_messages@</td>
          <td align="center" style="padding: 4px;">@messages.last_child_post@</td>
          
            </tr>
        </multiple>
      </if>
      <else>
        <tr bgcolor="@table_bgcolor@">
          <td colspan="4"><strong>No Messages</strong></td>
        </tr>
      </else>
  
    </table>
  
    <br>

    <!-- pagination context bar -->
    <table cellpadding=4 cellspacing=0 border=0 width="95%">
    <tr>
      <td align="left">

        <if @info.previous_group@ not nil>
	<a href="forum-view?forum_id=@forum_id@&page=@info.previous_group@"><img src="/templates/images/nav_previous_group.jpg" border="0" align="center"></a>
&nbsp;<b><a href="forum-view?forum_id=@forum_id@&page=@info.previous_group@">Previous 10</a></b>
        </if>
      </td>
    
      <td align=center>
        <if @info.previous_page@ gt 0>
          <a href="forum-view?forum_id=@forum_id@&page=@info.previous_page@">
                        <img src="/templates/images/nav_previous.jpg" border="0" alt="Previous Page" width="11" height="20" align="center"></a> <a href="forum-view?forum_id=@forum_id@&page=@info.previous_page@"><b>Previous</b></a>
          &nbsp;
        </if>
        <else>&nbsp;</else>
      <multiple name=pages>
        <if @page@ ne @pages.page@>
          <a href="forum-view?forum_id=@forum_id@&page=@pages.page@">@pages.page@</a>
        </if>
        <else>
          @page@
        </else>
      </multiple>
        <if @page@ lt @info.page_count@>
          &nbsp; <a href="forum-view?forum_id=@forum_id@&page=@info.next_page@">
            <b>Next</b></a> <a href="forum-view?forum_id=@forum_id@&page=@info.next_page@">
            <img src="/templates/images/nav_next.jpg" border="0" alt="Next Page" width="11" height="20" align="center"></a>
            <br>
        </if>
        <else>&nbsp;</else>
      </td>

      <td align="right">


        <if @info.next_group@ not nil>
          &nbsp;&nbsp;
          <a href="forum-view?forum_id=@forum_id@&page=@info.next_group@">
            <b>Next 10</b></a>&nbsp;<a href="forum-view?forum_id=@forum_id@&page=@info.next_group@"><img src="/templates/images/nav_next_group.jpg" border="0" align="center"></a>
        </if>
      </td>
    </tr>
    </table>
    <!-- end pagination -->

</center>
