<master src="master">
<property name="title">Post to Forum: @forum.name@</property>
<property name="context_bar">@context_bar@</property>

<if @parent_id@ ne "">
  <table style="color: black; background-color: @table_border_color@;"  width="100%">
    <include src="message-chunk" bgcolor="@table_bgcolor@" &message="parent_message" preview=1>
  </table>
  <br>
</if>

<formtemplate id="message"></formtemplate>
