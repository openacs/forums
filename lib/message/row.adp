<if @preview@ nil>

  <%# ----------------------------------------------------------- %>
  <%# Non-preview                                                 %>
  <%# ----------------------------------------------------------- %>

  <if @message.tree_level@ le @level_exp@>
     <a id="toggle@message.message_id@" href="javascript:void(toggle(@message.message_id@))"><img src="/resources/forums/Collapse16.gif" alt="-" border="0" title="collapse message"/></a>
  </if>
  <else>
    <a id="toggle@message.message_id@" href="javascript:void(toggle(@message.message_id@))"><img src="/resources/forums/Expand16.gif" alt="-" border="0"  title="expand message"/></a>
  </else>



  <div class="level@message.tree_level@">
    <if @message.tree_level@ le @level_exp@>

      <%# ----------------------------------------------------------- %>
      <%# Expanded Message                                            %>
      <%# ----------------------------------------------------------- %>
 
      <div id="content@message.message_id@" class="dynexpanded">
        <div class="subject">

          <div class="left">
            <a href="@message.direct_url@" title="Direct link to this post" class="reference">@message.number@</a>:
            <a class="title" href="message-view?message_id=@message.message_id@" title="Link to this post on a separate page">@message.subject@</a>
            <if @rownum@ > 0>
              <span class="response">(response to <a href="@message.parent_direct_url@" class="reference">@message.parent_number@</a>)</span>
            </if>
          </div>

          <div class="right">
            <if @message.reply_p@ or @moderate_p@>
              <a href="message-post?parent_id=@message.message_id@" class="button">#forums.reply#</a>
              <a href="message-email?message_id=@message.message_id@" class="button">#forums.forward#</a>
            </if>
            <if @own_p@ or @moderate_p@>
              <a href="moderate/message-edit?message_id=$message.message_id" class="button">#forums.edit#</a>
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
        </div>

        <div class="content">
          @message.content;noquote@
          <div class="attachments">
            #forums.Attachments#
            <include src="attachment-list" &message="message">
          </div>
          <div class="attribution">#forums.Posted_by# <a href="user-history?user_id=@message.user_id@">@message.user_name@</a> on <span class="post-date">@message.posting_date_pretty@</span></div>
          <if @message.max_child_sortkey@ ne "">
            <a href="javascript:void(toggleList(replies[@message.message_id@],1))"><img src=/resources/forums/ExpandAll16.gif width=16 height=16 ALT=+ border=0 title="Expand all replies to this post"></a>
            <a href="javascript:void(toggleList(replies[@message.message_id@],0))"><img src=/resources/forums/CollapseAll16.gif ALT=- border=0 title="Collapse all replies to this post"></a>
            <if @message.parent_number@ not nil and @message.tree_level@ eq 0>
              [<a href="@message.parent_root_url@" class="reference">open parent</a>]
            </if>
          </if>
        </div>
      </div>
   </if>

   <else>

     <%# ----------------------------------------------------------- %>
     <%# Collapsed Message                                           %>
     <%# ----------------------------------------------------------- %>

     <div id="content@message.message_id@" class="dyncollapsed">
       <if @display_subject_p@ true>
         <a href="@message.direct_url@" title="Direct link to this post" class="reference">@message.number@</a>:
         <a href="message-view?message_id=@message.message_id@" title="Link to this post on a separate page">@message.subject@</a>
       </if>
       <else>
         <a href="@message.direct_url@" title="Direct link to this post" class="reference">@message.number@</a>
       </else>
     </div>
       <span class="attribution">#forums.Posted_by# <a href="user-history?user_id=@message.user_id@">@message.user_name@</a> on <span class="post-date">@message.posting_date_pretty@</span></span>
       <if @message.parent_number@ not nil>
         <span class="response">(response to <a href="@message.parent_direct_url@" class="reference">@message.parent_number@</a>)</span>
       </if>
     </div>
   </else>


 </div>
</if>


<else>

  <%# ----------------------------------------------------------- %>
  <%# Preview                                                     %>
  <%# ----------------------------------------------------------- %>

  <div class="subject">
    @message.subject@
    <div class="attribution">#forums.Posted_by# <a href="user-history?user_id=@message.user_id@">@message.user_name@</a> on <span class="post-date">@message.posting_date_pretty@</span></div>
  </div>
  <div class="content">
    @message.content;noquote@
  </div>
</else>
