<master src="master">
<property name="title">Confirm Post to Forum: @forum.name@</property>
<property name="context_bar">@context_bar@</property>

<p>Please confirm the following post:</p>

<include src="message-preview-chunk" bgcolor="#cccccc" &message="message">

<form action="message-post" method="post">
  <input type="hidden" name="form:id" value="message">
  @exported_vars@

  <br>

  <if @parent_id@ nil>
    Would you like to subscribe to responses? 
    <input type="radio" name="subscribe_p" value="0" checked>No</input>
    <input type="radio" name="subscribe_p" value="1">Yes</input>

    <if @forum_notification_p@>
      <br><small>(Note that you are already subscribed to the forum as a whole. You may get duplicate notifications.)</small>
    </if>

    <br>
  </if>

  <if @attachments_enabled_p@ eq 1>
  Would you like to attach a file to this message?
    <input type="radio" name="attach_p" value="0" checked>No</input>
    <input type="radio" name="attach_p" value="1">Yes</input>
<br>  
  </if>

  <input type="submit" value="confirm">
</form>
