<master>
  <property name="title">@page_title;noquote@</property>
  <property name="context">@context;noquote@</property>
  <property name="displayed_object_id">@forum_id;noquote@</property>

<if @searchbox_p@ true>
<div style="float: right;">
  <formtemplate id="search">
    <formwidget id="forum_id">
      #forums.Search_colon#&nbsp;
    <formwidget id="search_text">
  </formtemplate>
</div>
</if>

<include src="/packages/forums/lib/message/threads-chunk" forum_id="@forum_id@" &="permissions" moderate_p="@permissions.moderate_p@" orderby="@orderby@" &="page">

<p>
@notification_chunk;noquote@
</p>