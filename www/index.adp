<master>
<property name="doc(title)">#forums.Forums#</property>
<property name="context">@context;literal@</property>

<if @searchbox_p;literal@ true>
  <include src="/packages/forums/lib/search/search-form">
</if>

<include src="/packages/forums/lib/forums/forums-chunk">
