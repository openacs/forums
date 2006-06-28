<master>
<property name="title">#forums.Post_to_Forum# @forum.name;noquote@</property>
<property name="context">@context;noquote@</property>
<property name="focus">message.subject</property>
  <property name="header_stuff">
    <link rel="stylesheet" type="text/css" media="all" href="/resources/forums/forums.css" />
    <link rel="alternate stylesheet" type="text/css" media="all" title="flat" href="/resources/forums/flat.css" />
    <link rel="alternate stylesheet" type="text/css" media="all" title="flat-collapse" href="/resources/forums/flat-collapse.css" />
    <link rel="alternate stylesheet" type="text/css" media="all" title="collapse" href="/resources/forums/collapse.css" />
    <link rel="alternate stylesheet" type="text/css" media="all" title="expand" href="/resources/forums/expand.css" />
    <script language="JavaScript" type="text/javascript" src="/resources/forums/cop.js"></script>
  </property>

<include src="/packages/forums/lib/message/post" forum_id="@forum_id@" 
                             &parent_message="parent_message"
                             anonymous_allowed_p="@anonymous_allowed_p@"
                             attachments_enabled_p="@attachments_enabled_p@">
