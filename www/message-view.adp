<master>
<property name="title">#forums.Forum# @forum.name;noquote@: @message.subject;noquote@</property>
<property name="context">@context;noquote@</property>
<property name="displayed_object_id">@message_id@</property>

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
  </ul>

<p>@notification_chunk;noquote@</p>

<include src="/packages/forums/lib/message/thread-chunk"
         &message="message"
         &forum="forum"
         &permissions="permissions">

</center>

<if @reply_url@ not nil>
  <blockquote>
    <if @forum.presentation_type@ eq "flat">
      <a href="@reply_url@"><b>#forums.Post_a_Reply#</b></a>
    </if>
    <else>
      <a href="@reply_url@"><b>#forums.Reply_to_first_post_on_page_label#</b></a>
    </else>
  </blockquote>
</if>

<blockquote>
  #forums.Back_to_thread_link#
</blockquote>
