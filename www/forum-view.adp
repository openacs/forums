<master>
  <property name="title">@page_title;noquote@</property>
  <property name="context">@context;noquote@</property>

  <table width="95%">
    <tr>
      <td style="white-space: nowrap; line-height: 150%">
        @notification_chunk;noquote@
      </td>
      <td align="right">
        <formtemplate id="search">
          <formwidget id="forum_id">
          #forums.Search#&nbsp;<formwidget id="search_text">
        </formtemplate>
      </td>
    </tr>
  </table>

<include src="/packages/forums/lib/message/threads-chunk" forum_id="@forum_id@" &="permissions" moderate_p="@permissions.moderate_p@" orderby="@orderby@" &="page">
