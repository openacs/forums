<master>
<property name="title">#forums.Post_to_Forum# @forum.name@</property>
<property name="context">@context@</property>
<property name="focus">message.subject</property>

<if @parent_id@ ne "">
  <table style="color: black; background-color: @table_border_color@;"  width="100%">
    <include src="message-chunk" bgcolor="@table_bgcolor@" &message="parent_message" preview=1>
  </table>
  <br>
</if>

<formtemplate id="message"></formtemplate>



