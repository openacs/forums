<master>
  <property name="title">#forums.Email_Message# @message.forum_name;noquote@ - @message.subject;noquote@</property>
  <property name="context">@context;noquote@</property>
  <property name="header_stuff">
    <link rel="stylesheet" type="text/css" media="all" href="/resources/forums/forums.css" />
    <link rel="alternate stylesheet" type="text/css" media="all" title="flat" href="/resources/forums/flat.css" />
    <link rel="alternate stylesheet" type="text/css" media="all" title="flat-collapse" href="/resources/forums/flat-collapse.css" />
    <link rel="alternate stylesheet" type="text/css" media="all" title="collapse" href="/resources/forums/collapse.css" />
    <link rel="alternate stylesheet" type="text/css" media="all" title="expand" href="/resources/forums/expand.css" />
  </property>

  <p>#forums.lt_Email_a_copy_of_the_f#</p>

  <div id="forum-thread">
    <include src="/packages/forums/lib/message/row" &message="message" preview=1 />
  </div>

  <formtemplate id="message"></formtemplate>
