<p>
  #forums.Users_that_wrote_in_the_forum# <b>@name@</b>
</p>


<center>
<table style="color: black; background-color: @table_border_color@;">

    <tr>
      <th align="center">#forums.User#</th>
      <th align="center">#forums.Number_of_Posts#</th>
      <th align="center">#forums.Posted#</th>
    </tr>
<if @persons:rowcount@ gt 0>
<multiple name="persons">

  <if @persons.rownum@ odd>
    <tr style="color: black; background-color: @table_bgcolor@;">
  </if>
  <else>
    <tr style="color: black; background-color: @table_other_bgcolor@;">
  </else>

      <td><a href="user-history?user_id=@persons.user_id@">@persons.first_names@ @persons.last_name@</a></td>
      <td align="center">@persons.num_msg@</td>
      <td align="center">@persons.last_post@</td>

    </tr>

</multiple>
</if>
<else>
    <tr>
      <td colspan="3">
        <i>#forums.No_Postings#</i>
      </td>
    </tr>
</else>

  </table>

</center>
