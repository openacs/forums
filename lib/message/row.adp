<if @rownum;literal@ odd><div id="msg_@message.message_id@" class="odd level@message.tree_level@"></if>
<else><div id="msg_@message.message_id@" class="even level@message.tree_level@"></else>
    <div class="details">
  <div style="float: left; padding-right: 4px;">
    <a id="toggle@message.message_id@" class="dynexpanded" href="#" title="#forums.collapse_message#"><img src="/resources/forums/Collapse16.gif" width="16" height="16" alt="#forums.collapse#"></a>
  </div>
  <if @display_subject_p;literal@ true>
    <if @preview;literal@ false>
      <div class="subject">
        <a href="@message.direct_url@" title="#forums.Direct_link_to_this_post#" class="reference">@message.number@</a>:
        <a href="message-view?message_id=@message.message_id@" title="#forums.link_on_separate_page#" class="alone">@message.subject;noi18n@</a>
    </if>
    <else>
      <div class="subject">@message.subject;noi18n@
    </else>
  </if>
  <else>
    <div class="subject"><a href="@message.direct_url@" title="#forums.Direct_link_to_this_post#" class="reference">@message.number@</a>
  </else>
  <if @message.parent_number@ not nil>
    <span class="response">(#forums.response_to# <a href="@message.parent_direct_url@" class="reference" title="#forums.Direct_link_to_this_post#">@message.parent_number@</a>)</span>
  </if>
    </div>
    <div class="attribution">
	#forums.Posted_by# 
	<if @useScreenNameP;literal@ true>
      	  @message.user_name@
	</if>
	<else>
	  <if @message.user_id;literal@ ne 0>
              <a href="user-history?user_id=@message.user_id@" title="#forums.show_posting_history_message_username#"></if>
	    @message.user_name@
	  <if @message.user_id;literal@ ne 0></a></if>
	</else> #forums.on# <span class="post-date">@message.posting_date_pretty@</span>
  </div>
  </div>

  <div class="content">
  <div id="content@message.message_id@" class="dynexpanded">@message.content;literal@
    <if @message.n_attachments@ not nil and @message.n_attachments@ gt 0>
      <div class="attachments">
        #forums.Attachments#
        <include src="attachment-list" &message="message">
      </div>
    </if>
  </div>
  </div>
    <if @preview;literal@ false and @any_action_p;literal@ true>
    <if @post_p;literal@ true or @moderate_p;literal@ true or @viewer_id;literal@ ne "0">
    <div class="action-list">
    <ul>
      <if @post_p;literal@ true>
        <if @presentation_type;literal@ ne "flat"><li><a href="message-post?parent_id=@message.message_id@" class="button" title="#forums.reply#">#forums.reply#</a></li></if>
      </if>
      <if @viewer_id;literal@ ne "0">
         <li><a href="message-email?message_id=@message.message_id@" class="button" title="#forums.forward#">#forums.forward#</a></li>
      </if>
      <if @moderate_p;literal@ true>
        <li><a href="moderate/message-edit?message_id=@message.message_id@" class="button" title="#forums.edit#">#forums.edit#</a></li>
        <li><a href="@delete_url@" class="button" title="#forums.delete#">#forums.delete#</a></li>	
	<if @message.parent_id@ nil>
	  <li><a href="moderate/thread-move?message_id=@message.message_id@" class="button" title="#forums.Move_thread_to_other_forum#">#forums.Move_thread_to_other_forum#</a></li>
	  <li><a href="moderate/thread-move-thread?message_id=@message.message_id@" class="button" title="#forums.Move_thread_to_other_thread#">#forums.Move_thread_to_other_thread#</a></li>
	</if>
	<else>
	  <li><a href="moderate/message-move?message_id=@message.message_id@" class="button" title="#forums.Move_to_other_thread#">#forums.Move_to_other_thread#</a></li>
	</else>
        <if @forum_moderated_p;literal@ true>
          <if @message.state;literal@ ne approved>
            <li><a href="moderate/message-approve?message_id=@message.message_id@" class="button" title="#forums.approve#">#forums.approve#</a></li>
          </if>
          <if @message.state;literal@ ne rejected and @message.max_child_sortkey@ nil>
            <li><a href="moderate/message-reject?message_id=@message.message_id@" class="button" title="#forums.reject#">#forums.reject#</a></li>
          </if>
        </if>
      </if>
    </ul>
    </div>
    </if>
    </if>    
</div>
