<master>
<property name="title">#forums.Post_to_Forum# @forum.name;noquote@</property>
<property name="context">@context;noquote@</property>
<property name="focus">message.subject</property>

<if @parent_id@ ne "">
  <table style="color: black; background-color: @table_border_color@;"  width="100%">
    <include src="message-chunk" bgcolor="@table_bgcolor;noquote@" &message="parent_message" preview=1>
  </table>
  <br>
</if>

<formtemplate id="message"></formtemplate>



