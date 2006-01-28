<html>
  <head>
    <title>nan</title>
    <script type="text/javascript" src="/resources/forums/dynamic-comments.js"></script>
    <script language="JavaScript" TYPE="text/javascript">
    <!--
    collapse_symbol = '<img src="/resources/forums/Collapse16.gif" width="16" height="16" ALT="-" border="0" title="collapse message">';
    expand_symbol = '<img src="/resources/forums/Expand16.gif" width="16" height="16" ALT="+" border="0" title="expand message">';
    loading_symbol = '<img src="/resources/forums/dyn_wait.gif" width="12" height="16" ALT="x" border="0">';
    loading_message = '<i>Loading...</i>';
    rootdir = 'messages-get';
    sid = '@sid@';
    //-->
    </script>
  </head>
  <IFRAME WIDTH=0 HEIGHT=0 BORDER=0 STYLE="width:0;height:0;border:0" ID="dynamic" NAME="dynamic" SRC="about:blank"></IFRAME>
  <body onload="copyContent(@sid@,@dynamicmode@)">
    <multiple name="message">
    <div id="@message.message_id@">
    <if @dynamicmode@ eq 1>
      <div class="subject">
      <a href="@message.direct_url@" title="Direct link to this post" class="reference">@message.number@</a>:
      <a href="message-view?message_id=@message.message_id@" title="Link to this post on a separate page">@message.subject@</a>
      <br />
      by <a href="user-history?user_id=@message.user_id@">@message.user_name@</a> on <span class="post-date">@message.posting_date_pretty@</span></span>
      <if @message.message_id@ ne @root_message_id@>
        <span class="response">(response to <a href="@message.parent_direct_url@" class="reference">@message.parent_number@</a>)</span>
      </if>
      </div>
      <div class="content">
            @message.content;noquote@
            <if @message.n_attachments@ not nil and @message.n_attachments@ gt 0>
              <div class="attachments">
          #forums.Attachments#
          <include src="../lib/message/attachment-list" &message="message">
        </div>
      </if>
      <br />
      <if @message.reply_p@ or @moderate_p@>
      <a href="message-post?parent_id=@message.message_id@" class="button">#forums.reply#</a>
      <a href="message-email?message_id=@message.message_id@" class="button">#forums.forward#</a>
      </if>
      <if @message.own_p@ or @moderate_p@>
    	@message.links;noquote@
      </if>
      <if @moderate_forum_p@>
        <a href="moderate/message-delete?message_id=@message.message_id@" class="button">#forums.delete#</a>
        <if @forum_moderated_p@>
          <if @message.state@ ne approved>
            <a href="moderate/message-approve?message_id=@message.message_id@" class="button">#forums.approve#</a>
          </if>
          <if @message.state@ ne rejected and @message.max_child_sortkey@ nil>
            <a href="moderate/message-reject?message_id=@message.message_id@" class="button">#forums.reject#</a>
          </if>
        </if>
        <a href="views?object_id=@message.message_id@" class="button">User Views</a>
      </if>
        <if @message.max_child_sortkey@ ne "">
        <a href="javascript:void(toggleList(replies[@message.message_id@],1))"><img src=/resources/forums/ExpandAll16.gif width=16 height=16 ALT=+ border=0 title="Expand all replies to this post"></a>
        <a href="javascript:void(toggleList(replies[@message.message_id@],0))"><img src=/resources/forums/CollapseAll16.gif ALT=- border=0 title="Collapse all replies to this post"></a>
          <if @message.parent_number@ not nil and @message.tree_level@ eq 0>
        [<a href="@message.parent_root_url@" class="reference">open parent</a>]
          </if>
        </if>
      </div>
    </if>
    <else>
      <a href="@message.direct_url@" title="Direct link to this post" class="reference">@message.number@</a>:
      <a href="message-view?message_id=@message.message_id@" title="Link to this post on a separate page">@message.subject@</a>
      <span class="attribution">#forums.Posted_by# <a href="user-history?user_id=@message.user_id@">@message.user_name@</a> on <span class="post-date">@message.posting_date_pretty@</span></span>
      <if @message.message_id@ ne @root_message_id@>
        <span class="response">(response to <a href="@message.parent_direct_url@" class="reference">@message.parent_number@</a>)</span>
      </if>
      <if @message.open_p@ eq f>
      <img src="/resources/forums/lock.gif" border="0" title="Locked">
      </if>
    </else>
    </div>
    </multiple>
  </body>
</html>
