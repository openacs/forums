<master>
<property name="title">Forum @forum.name@: @message.subject@</property>
<property name="context">@context@</property>

<p>@notification_chunk@</p>

<div class="forum_thread">
<include src="message-chunk" bgcolor="#eeeeee" moderate_p=@moderate_p@ &message="message">

<if @responses:rowcount@ gt 0>
  <br>

<multiple name="responses">
<include src="message-chunk" bgcolor="#eeeeee" moderate_p=@moderate_p@ &message="responses" root_subject="@message.root_subject@">
</multiple>

</if>


<if @reply_url@ not nil>
  <blockquote>
    <a href="@reply_url@"><b>Post a Reply</b></a>
  </blockquote>
</if>
</div>
