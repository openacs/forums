<master>
<property name="title">Email Message: @message.forum_name@ - @message.subject@</property>
<property name="context">@context@</property>

<p>Email a copy of the following message:</p>

<table width="100%">
<include src="message-chunk" bgcolor="#eeeeee" &message="message" preview=1>
</table>

<formtemplate id="message"></formtemplate>
