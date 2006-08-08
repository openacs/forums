<master>
  <property name="title">#forums.Confirm_Delete# @message.subject;noquote@</property>
  <property name="context">#forums.delete#</property>
  <property name="header_stuff">
    <link rel="stylesheet" type="text/css" media="all" href="/resources/forums/forums.css" />
    <script language="JavaScript" type="text/javascript" src="/resources/forums/forums.js"></script>
    <script type="text/javascript"><!--
      collapse_symbol = '<img src="/resources/forums/Collapse16.gif" width="16" height="16" ALT="-" border="0" title="collapse message">';
      expand_symbol = '<img src="/resources/forums/Expand16.gif" width="16" height="16" ALT="+" border="0" title="expand message">';
      loading_symbol = '<img src="/resources/forums/dyn_wait.gif" width="12" height="16" ALT="x" border="0">';
      loading_message = '<i>Loading...</i>';
      rootdir = 'messages-get';
      sid = '5999';
      //-->
  </script></property>

  <include src="/packages/forums/lib/message/delete" &message="message" confirm_p="@confirm_p@" return_url="@return_url@" />
