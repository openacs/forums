<if @parent_id@ ne "">
  <table style="color: black; background-color: @table_border_color@;"  width="100%">
    <include src="row" bgcolor="@table_bgcolor;noquote@" &message="parent_message" preview=1>
  </table>
  <br>
</if>

<formtemplate id="message"></formtemplate>
