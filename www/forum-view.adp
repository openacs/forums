<master>
  <property name="title">@page_title;noquote@</property>
  <property name="context">@context;noquote@</property>

  <table width="95%">
    <tr>
      <td style="white-space: nowrap; line-height: 150%">
        @notification_chunk;noquote@
  
        <if @permissions.post_p@ true>
          <p>
            <b>&raquo;</b> <a href="@post_url@">#forums.Post_a_New_Message#</a>
          </p>
        </if>

      </td>
      <td align="right">
        <formtemplate id="search">
          <formwidget id="forum_id">
            #forums.Search#&nbsp;<formwidget id="search_text">
          </formtemplate>
        <if @permissions.moderate_p@ true or @permissions.admin_p@ true>
          <br>
        [
          <if @permissions.admin_p@ true>
            <a href="@admin_url@">#forums.Administer#</a>
            <if @permissions.moderate_p@ true>|</if>
          </if>
          <if @permissions.moderate_p@ true>
            <a href="@moderate_url@">#forums.ManageModerate#</a>
          </if>
        ] <br>
        </if>
      </td>
    </tr>
  
    </table>

<p><include src="/packages/forums/lib/message/threads-chunk" forum_id="@forum_id@" moderate_p="@permissions.moderate_p@" orderby="@orderby@"></p>
