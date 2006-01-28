<master src="master">
<property name="title">Confirm Post to Forum: @forum.name@</property>
<property name="context_bar"></property>

Please confirm the following post:
<p>
<b>Subject:</b> @subject@<p>
<b>Body:</b><br>
<blockquote>
@content@
</blockquote>
<p>
<FORM ACTION="message-post" METHOD=POST>
<input type="hidden" name="form:id" value="message">
@exported_vars@
<p>
<if @parent_id@ nil>
Would you like to subscribe to responses? 
<INPUT TYPE="radio" name="subscribe_p" value="0" CHECKED> No
<INPUT TYPE="radio" name="subscribe_p" value="1"> Yes
<if @forum_notification_p@ eq 1>
<br>
(Note that you are already subscribed to the forum as a whole. You may get duplicate notifications.)
</if>
<br></if>
<INPUT TYPE="submit" value="confirm">
</FORM>
