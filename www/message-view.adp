<master>
<property name="title">#forums.Forum# @forum.name;noquote@: @message.subject;noquote@</property>
<property name="context">@context;noquote@</property>

<br>

<center>

<table width="95%">
  <tr style="white-space: normal">
    <td align=left>
      <a href="@thread_url@" class="action">#forums.Back_to_thread_label#</a>
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

<include src="/packages/forums/lib/message/thread-chunk"
         &message="message"
         &forum="forum"
         &permissions="permissions">

</center>

<if @reply_url@ not nil>
  <blockquote>
    <if @forum.presentation_type@ eq "flat">
      <a href="@reply_url@"><b>#forums.Post_a_Reply#</b></a>
    </if>
    <else>
      <a href="@reply_url@"><b>#forums.Reply_to_first_post_on_page_label#</b></a>
    </else>
  </blockquote>
</if>

<blockquote>
  #forums.Back_to_thread_link#
</blockquote>
