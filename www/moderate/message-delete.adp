<master>
  <property name="title">#forums.Confirm_Delete# @message.subject;noquote@</property>
  <property name="context">#forums.delete#</property>
  <property name="header_stuff">
    <link rel="stylesheet" type="text/css" media="all" href="/resources/forums/forums.css">
    <script language="JavaScript" type="text/javascript" src="/resources/forums/forums.js"></script>
    <script type="text/javascript">@dynamic_script;noquote@</script>
  </property>

<if @link:rowcount@ not nil><property name="&link">link</property></if>
<if @script:rowcount@ not nil><property name="&script">script</property></if>

  <include src="/packages/forums/lib/message/delete" &message="message" confirm_p="@confirm_p@" return_url="@return_url@" />
