<master>
<property name="title">#forums.Forums#</property>
<property name="context">@context;noquote@</property>

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

<include src="/packages/forums/lib/forums/forums-chunk">
