<master>
<property name="title">#forums.Confirm_Post_to_Forum# @forum.name@</property>
<property name="context">@context@</property>

<p>#forums.lt_Please_confirm_the_fo#</p>

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
    #forums.lt_Would_you_like_to_sub# 
    <input type="radio" name="subscribe_p" value="0" checked>#forums.No#</input>
    <input type="radio" name="subscribe_p" value="1">#forums.Yes#</input>

    <if @forum_notification_p@>
      <br><small>#forums.lt_Note_that_you_are_alr#</small>
    </if>

    <br>
  </if>

  <if @attachments_enabled_p@ eq 1>
  #forums.lt_Would_you_like_to_att#
    <input type="radio" name="attach_p" value="0" checked>#forums.No#</input>
    <input type="radio" name="attach_p" value="1">#forums.Yes#</input>
<br>  
  </if>

  <input type="submit" value="confirm">
</form>



