<master>
<property name="title">#forums.Confirm_Delete# @message.subject@</property>
<property name="context">#forums.delete#</property>

<table width="95%">
  
  <#Are_you_sure_you_want_to_delete_lt Are you sure you want to delete this message and <strong>all replies to it</strong>?#>
  <p>
  
  <table style="color: black; background-color: @table_border_color@;" width="100%">
    <include src="../message-chunk" &message="message" preview="1">
  </table>
  
  <p>
  
  <a href="message-delete?@url_vars@&confirm_p=1">#forums.Yes#</a>
  <p>
  <a href="@return_url@?message_id=@message_id@">#forums.No#</a>
  <p>

</table>



