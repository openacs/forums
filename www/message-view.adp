<master>
  <property name="&doc">doc</property>
  <property name="context">@context;literal@</property>
  <property name="displayed_object_id">@message_id;literal@</property>

<h1>@doc.title@</h1>

  <if @searchbox_p@ true>
    <include src="/packages/forums/lib/search/search-form" forum_id="@message.forum_id;literal@">
  </if>

  <ul class="action-links">
    <li><a href="@thread_url;noi18n@" title="#forums.Back_to_thread_label#">#forums.Back_to_thread_label#</a></li>
  </ul>

<if @message_url@ not nil>
<p>
<include src="/packages/notifications/lib/notification-widget" type="forums_message_notif"
	 object_id="@message.message_id;literal@"
	 pretty_name="@message.subject@"
	 url="@message_url;literal@" >
</if>

<include src="/packages/forums/lib/message/thread-chunk"
      &message="message"
      &forum="forum"
      &permissions="permissions" >

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
