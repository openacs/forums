<master>
<property name="title">#forums.Forums#</property>
<property name="context">@context;noquote@</property>

<center>
  <table width="95%">
    <tr>
      <td style="font-size: x-small; white-space: nowrap; align=right;">
        <if @admin_p@>
          [ <a href="admin/forum-new">#forums.New_Forum#</a> | <a href="admin/">#forums.Administration#</a> ]
        </if>
        <else>
          &nbsp;
        </else>
      </td>
      <td align="right">
        <formtemplate id="search">
          <formwidget id="forum_id">
            #forums.Search_colon#&nbsp;
          <formwidget id="search_text">
        </formtemplate>
      </td>
    </tr>

  </table>

  <br>

  <include src="/packages/forums/lib/forums/forums-chunk">

</center>
