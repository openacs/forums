<master>
  <property name="title">@page_title;noquote@</property>
  <property name="context">@context;noquote@</property>

  <table width="95%">
    <tr>
      <td style="white-space: nowrap; line-height: 150%">
        @notification_chunk;noquote@
  
        <if @post_p@ true>
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
        <if @moderate_p@ true or @admin_p@ true>
          <br>
        [
          <if @admin_p@ true>
            <a href="@admin_url@">#forums.Administer#</a>
            <if @moderate_p@ true>|</if>
          </if>
          <if @moderate_p@ true>
            <a href="@moderate_url@">#forums.ManageModerate#</a>
          </if>
        ] <br>
        </if>
      </td>
    </tr>
  
    </table>

<p><listtemplate name="messages"></listtemplate></p>

