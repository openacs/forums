
<!--<li><a href="random-message?rowcount=@responses:rowcount@&forum_id=@forum_id@&message_id=@message.message_id@">Create a random list of messages</a></li>-->
<!--<br>
<br>
<br>-->
<div id="forum-thread">
<if @ajax_effects@ eq 1>
  <include src="row2"
    rownum=0
    forum_moderated_p=@forum_moderated_p;noquote@
    moderate_p=@permissions.moderate_p;noquote@               
    forum_id=@forum_id;noquote@
    root_message_id=@root_message_id;noquote@
    main_message_id=@main_message_id;noquote@
    table_name=@table_name;noquote@   
    total_number_messages=@responses:rowcount;noquote@
    &message="message">         
    <if @responses:rowcount@ gt 0>      
      <multiple name="responses">               
        <include src="row2"
          rownum=@responses.rownum@          
          forum_id=@forum_id;noquote@
          main_message_id=@main_message_id;noquote@          
          table_name=@table_name;noquote@                                 
          forum_moderated_p=@forum_moderated_p;noquote@
          total_number_messages=@responses:rowcount;noquote@
          root_message_id=@root_message_id;noquote@
          moderate_p=@permissions.moderate_p;noquote@                              
          &message="responses">         
      </multiple>
    </if>
</if>
<else>
 <include src="row"
    rownum=0
    forum_moderated_p=@forum_moderated_p;noquote@
    moderate_p=@permissions.moderate_p;noquote@
    forum_id=@forum_id;noquote@
    &message="message">
    <if @responses:rowcount@ gt 0>
      <multiple name="responses">
        <include src="row"
          rownum=@responses.rownum@
          forum_id=@forum_id;noquote@
          forum_moderated_p=@forum_moderated_p;noquote@         
          moderate_p=@permissions.moderate_p;noquote@
          &message="responses">
      </multiple>
    </if>
</else>
</div> 
@response_arrays_stub;noquote@
