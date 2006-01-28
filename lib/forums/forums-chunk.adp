  <table width="95%" style="color: black; background-color: @table_border_color@;">

    <tr>
      <th align="left" width="70%">#forums.Forum_Name#</th>
      <th align="center" width="10%">#forums.Threads#</th>
      <th align="center" width="20%">#forums.Last_Post#</th>
    </tr>

    <if @forums:rowcount@ gt 0>
      <multiple name="forums">
        <if @forums.rownum@ odd>
          <tr style="color: black; background-color: @table_bgcolor@;">
        </if>
        <else>
          <tr style="color: black; background-color: @table_other_bgcolor@;">
        </else>

        <td align="left">
          <if @forums.new_p@ and @forums.n_threads@ gt 0>
            <strong>
          </if>
          <a href="forum-view?forum_id=@forums.forum_id@">@forums.name@</a>
          <if @forums.new_p@ and @forums.n_threads@ gt 0>
            </strong>
          </if>
          <if @forums.charter@ not nil>
            <br><em>@forums.charter;noquote@</em>
          </if>
        </td>
        <td align="center">
          @forums.n_threads@
        </td>
        <td align="center">
          <if @forums.n_threads@ gt 0>
            @forums.last_post_ansi@
          </if><else>&nbsp;</else>
        </td>
          </tr>
      </multiple>
    </if>
    <else>
      <tr style="color: black; background-color: @table_bgcolor@">
        <td colspan="3" align="left">
          <em>#forums.No_Forums#</em>
        </td>
      </tr>
    </else>
  </table>
