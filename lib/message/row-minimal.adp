<div class="level@message.tree_level@">
  <div id="content@message.message_id@">

    <if @rownum@ eq 0>
      <div class="subject">
    </if>

    <div style="left">
      <if @display_subject_p@ true>
        <if @preview@ nil>
          <a href="@message.direct_url@" title="Direct link to this post" class="reference">@message.number@</a>:
          <a class="title" href="message-view?message_id=@message.message_id@" title="Link to this post on a separate page">@message.subject@</a>
        </if>
        <else>
          @message.subject@
        </else>
      </if>
      <else>
        <a href="@message.direct_url@" title="Direct link to this post" class="reference">@message.number@</a>
      </else>

      <if @message.parent_number@ not nil>
        <span class="response">(response to <a href="@message.parent_direct_url@" class="reference">@message.parent_number@</a>)</span>
      </if>
    </div>

    <div style="right">
      <if @message.reply_p@ or @moderate_p@>
        <a href="message-post?parent_id=@message.message_id@" class="button">#forums.reply#</a>
        <a href="message-email?message_id=@message.message_id@" class="button">#forums.forward#</a>
      </if>

      <if @own_p@ or @moderate_p@>
        @links;noquote@
      </if>

      <if @moderate_p@>
        <a href="moderate/message-delete?message_id=@message.message_id@" class="button">#forums.delete#</a>
        <if @forum_moderated_p@>
          <if @message.state@ ne approved>
            <a href="moderate/message-approve?message_id=@message.message_id@" class="button">#forums.approve#</a>
          </if>
          <if @message.state@ ne rejected and @message.max_child_sortkey@ nil>
            <a href="moderate/message-reject?message_id=@message.message_id@" class="button">#forums.reject#</a>
          </if>
        </if>
      </if>
    </div>
    <div style="clear:both;"></div>

    <if @rownum@ eq 0>
  </div>
  </if>    
  <div class="content">
    @message.content;noquote@
    <if @message.n_attachments@ not nil and @message.n_attachments@ gt 0>
      <div class="attachments">
        #forums.Attachments#
        <include src="/packages/forums/lib/message/attachment-list" &message="message">
      </div>
    </if>

    <div class="attribution">#forums.Posted_by# <a href="user-history?user_id=@message.user_id@">@message.user_name@</a> on <span class="post-date">@message.posting_date_pretty@</span></div>

  </div>
</div>
