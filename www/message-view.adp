<master>
<property name="title">Forum @forum.name@: @message.subject@</property>
<property name="context">@context@</property>

<p>
      @notification_chunk@
</p>


  <include src="message-chunk" 
           bgcolor="@table_bgcolor@" 
           forum_moderated_p=@forum_moderated_p@ 
           moderate_p=@moderate_p@ 
           &message="message">

<if @responses:rowcount@ gt 0>

    <multiple name="responses">
    

            <include src="message-chunk" 
                     bgcolor="@table_other_bgcolor@" 
                     forum_moderated_p=@forum_moderated_p@ 
                     moderate_p=@moderate_p@ 
                     &message="responses">
    </multiple>
  
</if>

<if @reply_url@ not nil>
  <blockquote>
    <a href="@reply_url@"><b>Post a Reply</b></a>
  </blockquote>
</if>
