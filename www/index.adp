<master src="master">
<property name="title">Forums</property>
<property name="context">@context@</property>

<center>
  <table width="95%">
    <tr>
      <td style="font-size: x-small; white-space: nowrap; align=right;">
        <if @admin_p@>
          [ <a href="admin/forum-new">New Forum</a> | <a href="admin/">Administration</a> ]
        </if>
        <else>
          &nbsp;
        </else>
      </td>
      <td align="right">
        <formtemplate id="search">
          <formwidget id="forum_id">
            Search:&nbsp;
          <formwidget id="search_text">
        </formtemplate>
      </td>
    </tr>

  </table>

  <br>

  <table width="95%" style="color: black; background-color: @table_border_color@;">

    <tr>
      <th align="left" width="70%">Forum Name</th>
      <th align="center" width="10%">Threads</th>
      <th align="center" width="20%">Last Post</th>
    </tr>

    <if @forums:rowcount@ gt 0>
      <multiple name="forums">
        <if @forums.rownum@ odd>
          <tr style="color: black; background-color: @table_bgcolor@;">
        </if>
        <else>
          <tr style="color: black; background-color: @table_other_bgcolor@;">
        </else>

        <td>
          <if @forums.new_p@ and @forums.n_threads@ gt 0>
            <strong>
          </if>
          <a href="forum-view?forum_id=@forums.forum_id@">@forums.name@</a>
          <if @forums.new_p@ and @forums.n_threads@ gt 0>
            </strong>
          </if>
          <if @forums.charter@ not nil>
            <br><em>@forums.charter@</em>
          </if>
        </td>
        <td align="center">
          @forums.n_threads@
        </td>
        <td align="center">
          <if @forums.n_threads@ gt 0>
            @forums.last_modified@
          </if>
        </td>
          </tr>
      </multiple>
    </if>
    <else>
      <tr style="color: black; background-color: @table_bgcolor@">
        <td colspan="3">
          <em>No Forums</em>
        </td>
      </tr>
    </else>
  </table>

</center>
