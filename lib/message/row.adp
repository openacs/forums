<if @rownum@ odd><div id="@message.message_id@" class="odd level@message.tree_level@"></if>
<else><div id="@message.message_id@" class="even level@message.tree_level@"></else>
    <if @preview@ nil>
  <div class="action-list" style="float: right;">
    <ul>
      <li><a href="message-post?parent_id=@message.message_id@" class="button">#forums.reply#</a></li>
      <li><a href="message-email?message_id=@message.message_id@" class="button">#forums.forward#</a></li>
      <if @moderate_p@>
        <li><a href="moderate/message-edit?message_id=@message.message_id@" class="button">#forums.edit#</a></li>
        <li><a href="moderate/message-delete?message_id=@message.message_id@" class="button">#forums.delete#</a></li>
        <if @forum_moderated_p@>
          <if @message.state@ ne approved>
            <li><a href="moderate/message-approve?message_id=@message.message_id@" class="button">#forums.approve#</a></li>
          </if>
          <if @message.state@ ne rejected and @message.max_child_sortkey@ nil>
            <li><a href="moderate/message-reject?message_id=@message.message_id@" class="button">#forums.reject#</a></li>
          </if>
        </if>
      </if>
    </ul>
  </div>
    </if>
    <div class="details">
  <div style="float: left; padding-right: 4px;">
    <a id="toggle@message.message_id@" class="dynexpanded" href="javascript:void(toggle(@message.message_id@))"><img src="/resources/forums/Collapse16.gif" width="16" height="16" alt="+" /></a>
  </div>
  <if @display_subject_p@ true>
    <if @preview@ nil>
      <div class="subject">
        <a href="@message.direct_url@" title="Direct link to this post" class="reference">@message.number@</a>:
        <a href="message-view?message_id=@message.message_id@" title="Link to this post on a separate page" class="alone">@message.subject@</a>
    </if>
    <else>
      <div class="subject">@message.subject@
    </else>
  </if>
  <else>
    <div class="subject"><a href="@message.direct_url@" title="Direct link to this post" class="reference">@message.number@</a>
  </else>
  <if @message.parent_number@ not nil>
    <span class="response">(response to <a href="@message.parent_direct_url@" class="reference">@message.parent_number@</a>)</span>
  </if>
    </div>
    <div class="attribution">#forums.Posted_by# <a href="user-history?user_id=@message.user_id@">@message.user_name@</a> on <span class="post-date">@message.posting_date_pretty@</span></div>
  </div>

  <div class="content">
  <div id="content@message.message_id@" class="dynexpanded">@message.content;noquote@
    <if @message.n_attachments@ not nil and @message.n_attachments@ gt 0>
      <div class="attachments">
        #forums.Attachments#
        <include src="attachment-list" &message="message">
      </div>
    </if>
  </div>
  </div>
</div>
