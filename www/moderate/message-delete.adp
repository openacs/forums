<master src="../master">
<property name="title">Confirm Delete: @message.subject@</property>
<property name="context_bar"></property>

Are you sure you want to delete this message?
<p>
<b>@message.subject@</b>

<p>

<blockquote>
@message.content@
</blockquote>

<p>

<a href="message-delete?@url_vars@&confirm_p=1">Yes</a>
<p>
<a href="@return_url@?message_id=@message_id@">No</a>
<p>
