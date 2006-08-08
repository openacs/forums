<master>
  <property name="title">#forums.Thread_title#</property>
  <property name="context">@context;noquote@</property>
  <property name="displayed_object_id">@message_id@</property>

  <property name="header_stuff">
    <link rel="stylesheet" type="text/css" media="all" href="/resources/forums/forums.css" />
    <link rel="stylesheet" type="text/css" media="print" href="/resources/forums/print.css" />
    <link rel="alternate stylesheet" type="text/css" media="all" title="flat" href="/resources/forums/flat.css" />
    <link rel="alternate stylesheet" type="text/css" media="all" title="flat-collapse" href="/resources/forums/flat-collapse.css" />
    <link rel="alternate stylesheet" type="text/css" media="all" title="collapse" href="/resources/forums/collapse.css" />
    <link rel="alternate stylesheet" type="text/css" media="all" title="expand" href="/resources/forums/expand.css" />
    <link rel="alternate stylesheet" type="text/css" media="all" title="print" href="/resources/forums/print.css" />
    <script type="text/javascript" src="/resources/forums/forums.js"></script>
    @dynamic_script;noquote@
  </property>
  <iframe width="0" height="0" border="0" style="width:0; height:0; border:0;" id="dynamic" name="dynamic" src="about:blank"></iframe>

  <if @searchbox_p@ true>
    <div style="float: right;">
      <formtemplate id="search">
        <formwidget id="forum_id">
          #forums.Search_colon#&nbsp;
          <formwidget id="search_text">
      </formtemplate>
    </div>
  </if>
<if @forum.presentation_type@ ne "flat">
  <div class="displayLinks" style="float: right;"> 
    Display as: <a href="#" onclick="setActiveStyleSheet('flat'); return false;" title="No indentation for replies" class="button">Flat</a>
    <a href="#" onclick="setActiveStyleSheet('default'); return false;" title="With indentation of replies" class="button">Nested</a>
    <a href="#" onclick="setActiveStyleSheet('collapse'); return false;" title="Just display subjects" class="button">Collapse</a>
    <a href="#" onclick="setActiveStyleSheet('expand'); return false;" title="Display full posts" class="button">Expand</a>
    <a href="#" onclick="setActiveStyleSheet('print'); return false;" title="Printable view" class="button">Print</a>
  </div>
</if>
  <ul class="action-links">
    <li><a href="@thread_url@">#forums.Back_to_thread_label#</a></li>
  </ul>

  <p>@notification_chunk;noquote@</p>

  <include src="/packages/forums/lib/message/thread-chunk"
    &message="message"
    &forum="forum"
    &permissions="permissions">

    <if @reply_url@ not nil>
      <if @forum.presentation_type@ eq "flat">
        <a href="@reply_url@"><b>#forums.Post_a_Reply#</b></a>
      </if>
      <else>
        <a href="@reply_url@"><b>#forums.Reply_to_first_post_on_page_label#</b></a>
      </else>
    </if>

    <ul class="action-links">
      <li><a href="@thread_url@">#forums.Back_to_thread_label#</a></li>
    </ul>
