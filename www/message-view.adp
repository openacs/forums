<master>
<property name="title">#forums.Forum# @forum.name;noquote@: @message.subject;noquote@</property>
<property name="context">@context;noquote@</property>
<property name="header_stuff">
  <link rel="stylesheet" type="text/css" media="all" href="/resources/forums/forums.css" />
  <script type="text/javascript" src="/resources/forums/forums.js"></script>
@alternate_style_sheet;noquote@
@dynamic_script;noquote@
</property>
<property name="displayed_object_id">@message_id@</property>
<if @display_mode@ eq "dynamic_minimal">
  <iframe style="width:0; height:0; border:0;" id="dynamic" name="dynamic" src="about:blank"></iframe>
</if>


  <if @searchbox_p@ true>
    <div style="float: right;">
      <formtemplate id="search">
        <formwidget id="forum_id">
          #forums.Search_colon#&nbsp;
          <formwidget id="search_text">
      </formtemplate>
    </div>
  </if>
  <ul class="action-links">
    <li><a href="@thread_url@">#forums.Back_to_thread_label#</a></li>
    <if @notification_chunk@ not nil>
      <li>@notification_chunk;noquote@</li>
    </if>
  </ul>

<formtemplate id="display_form"></formtemplate>

<include src="/packages/forums/lib/message/thread-chunk"
         &message="message"
         &forum="forum"
         &permissions="permissions"
         display_mode="@display_mode@">

<ul class="action-links">
  <if @reply_url@ not nil>
    <if @forum.presentation_type@ eq "flat">
      <li><a href="@reply_url@"><b>#forums.Post_a_Reply#</b></a></li>
    </if>
    <else>
      <li><a href="@reply_url@"><b>#forums.Reply_to_first_post_on_page_label#</b></a></li>
    </else>
  </if>
  <li>#forums.Back_to_thread_link#</li>
</ul>
