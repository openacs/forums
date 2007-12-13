<master>
  <property name="title">@page_title;noquote@</property>
  <property name="context">@context;noquote@</property>
  <property name="displayed_object_id">@message_id@</property>

<h1>@page_title;noquote@</h1>
  <iframe width="0" height="0" border="0" style="width:0; height:0; border:0;" id="dynamic" name="dynamic" src="about:blank" title=""></iframe>

  <if @searchbox_p@ true>
    <div style="float: right;">
      <formtemplate id="search">
        <formwidget id="forum_id">
          <label for="search_text">#forums.Search_colon#&nbsp;
          <formwidget id="search_text">
	  </label>
      </formtemplate>
    </div>
  </if>
  <div class="displayLinks" style="float: right;"> 
    #forums.display_as# <a href="#" onclick="setActiveStyleSheet('collapse'); return false;" title="#forums.just_display_subjects#" class="button">#forums.collapse#</a>
    <a href="#" onclick="setActiveStyleSheet('expand'); return false;" title="'#forums.display_full_posts#" class="button">#forums.expand#</a>
    <a href="#" onclick="setActiveStyleSheet('print'); return false;" title="#forums.printable_view#" class="button">#forums.print#</a>
  </div>
  <ul class="action-links">
    <li><a href="@thread_url@" title="#forums.Back_to_thread_label#">#forums.Back_to_thread_label#</a></li>
  </ul>

  <p>@notification_chunk;noquote@</p>

  <include src="/packages/forums/lib/message/thread-chunk"
    &message="message"
    &forum="forum"
    &permissions="permissions">

    <if @reply_url@ not nil>
      <if @forum.presentation_type@ eq "flat">
        <a href="@reply_url@" title="#forums.Post_a_Reply#"><b>#forums.Post_a_Reply#</b></a>
      </if>
      <else>
        <a href="@reply_url@" title="#forums.Reply_to_first_post_on_page_label#"><b>#forums.Reply_to_first_post_on_page_label#</b></a>
      </else>
    </if>

    <ul class="action-links">
      <li><a href="@thread_url@" title="#forums.Back_to_thread_label#">#forums.Back_to_thread_label#</a></li>
    </ul>
