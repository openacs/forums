<master src="master">
<property name="title">Email Message: @message.forum_name@ - @message.subject@</property>
<property name="context_bar">@context_bar@</property>

<p>Email a copy of the following message:</p>

<include src="message-preview-chunk" bgcolor="#eeeeee" &message="message">

<formtemplate id="message"></formtemplate>
