<master>
<property name="title">#forums.Forum# @forum.name;noquote@: @message.subject;noquote@</property>
<property name="context">@context;noquote@</property>

<br>

<center>

<table width="95%">
  <tr style="white-space: normal">
    <td align=left>
      #forums.Back_to_thread_link#
    </td>
    <td>
       &nbsp;
    </td>
  </tr>
  <tr style="white-space: normal">
    <td align=left>
      @notification_chunk;noquote@
    </td>
    <td align=right>
      <formtemplate id="search">
        <formwidget id="forum_id">
        #forums.Search#&nbsp;<formwidget id="search_text">
      </formtemplate>
    </td>
  </tr>
</table>

<br>

<table bgcolor="@table_border_color@" width="95%">
  <include src="message-chunk" l
           bgcolor="@table_bgcolor;noquote@" 
           forum_moderated_p=@forum_moderated_p;noquote@ 
           moderate_p=@moderate_p;noquote@ 
           &message="message">
</table>

<if @responses:rowcount@ gt 0>

  <table width="95%">

    <multiple name="responses">
    
    <% set width [expr 100 - [expr $responses(tree_level) - 1] * 1] %>

    <tr style="padding-top: 1em">
      <td alighn="left">
        <table align="right" bgcolor="@table_border_color@" width="@width@%">
          <if @responses.rownum@ odd>
            <include src="message-chunk" 
                     bgcolor="@table_other_bgcolor;noquote@" 
                     forum_moderated_p=@forum_moderated_p;noquote@ 
                     moderate_p=@moderate_p;noquote@ 
                     &message="responses">
          </if>
          <else>
            <include src="message-chunk" 
                     bgcolor="@table_bgcolor;noquote@"
                     forum_moderated_p=@forum_moderated_p;noquote@
                     moderate_p=@moderate_p;noquote@
                     &message="responses">
          </else>
        </table>
      </td>
    </tr>

    </multiple>
  
  </table>
</if>

</center>

<if @reply_url@ not nil>
  <blockquote>
    <a href="@reply_url@"><b>#forums.Post_a_Reply#</b></a>
  </blockquote>
</if>

<blockquote>
  #forums.Back_to_thread_link#
</blockquote>
