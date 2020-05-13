<master>
  <property name="doc(title)">@page_title;literal@</property>
  <property name="context">@context;literal@</property>
  <property name="displayed_object_id">@forum_id;literal@</property>

<h1>@page_title@</h1>
<if @searchbox_p;literal@ true>
  <include src="/packages/forums/lib/search/search-form" &="forum_id">
</if>

<p>
  <if @moderator_notifications_p;literal@ true>
    <include src="/packages/notifications/lib/notification-widget" type="forums_forum_moderator_notif"
	     object_id="@forum_id;literal@"
	     pretty_name="@forum.name;literal@ (#forums.moderated#)"
             show_subscribers_p="false"
	     url="@forum_url;literal@">
  </if>
<include src="/packages/notifications/lib/notification-widget" type="forums_forum_notif"
	 object_id="@forum_id;literal@"
	 pretty_name="@forum.name;literal@"
	 url="@forum_url;literal@" >
</p>
<include src="/packages/forums/lib/message/threads-chunk"
	 &="forum_id"
	 &="flush_p"
	 &="permissions"
	 moderate_p="@permissions.moderate_p;literal@"
	 &="orderby"
	 &="page"
 	 &="page_size"
	 admin_p="@permissions.admin_p;literal@" >
