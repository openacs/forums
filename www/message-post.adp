<master src="master">
<property name="title">Post to Forum: @forum.name@</property>
<property name="context_bar">@context_bar@</property>

<if @parent_id@ ne "">
  <include src="message-preview-chunk" bgcolor="#eeeeee" &message="parent_message">
  <br>
</if>

<formtemplate id="message"></formtemplate>
