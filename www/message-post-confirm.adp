<master>
<property name="title">Confirm Post to Forum: @forum.name@</property>
<property name="context">@context@</property>

<p>Please confirm the following post:</p>

<% set table_border_color [parameter::get -parameter table_border_color] %>

<center>
  <table style="color: black; background-color: @table_border_color@ ;" width="95%">
    <include src="message-chunk" &message="message" preview=1>
  </table>
</center>

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
