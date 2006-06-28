<master>
<property name="title">#forums.Forums#</property>
<property name="context">@context;noquote@</property>

<if @searchbox_p@ true>
<div style="float: right;">
  <formtemplate id="search">
    <formwidget id="forum_id">
      #forums.Search_colon#&nbsp;
    <formwidget id="search_text">
  </formtemplate>
</div>
</if>

<include src="/packages/forums/lib/forums/forums-chunk">
