<master>
  <property name="title">@page_title;noquote@</property>
  <property name="context">@context;noquote@</property>

  <table width="95%">
    <tr>
      <td style="white-space: nowrap; line-height: 150%">
        @notification_chunk;noquote@
      </td>
      <td width=10%></td>
      <td align="right">
        <div align="right"><formtemplate id="search">
          <formwidget id="forum_id">
          #forums.Search#&nbsp;<formwidget id="search_text">
        </formtemplate>
      </div>
      </td>
    </tr>
    <if @display_charter_p@>
    <tr>
	<td></td>
      <td width=10%></td>
	<td align="right">
	<b><a href="@charter_url@">#forums.Charter#</a></b>
        </td>
    </tr>
    </if>
  </table>

<include src="/packages/forums/lib/message/threads-chunk" forum_id="@forum_id@" &="permissions" moderate_p="@permissions.moderate_p@" orderby="@orderby@" &="page">

#forums.Subscriptions_to_forum# @notification_count;noquote@