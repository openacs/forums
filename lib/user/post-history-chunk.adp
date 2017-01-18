<div style="text-align: center; margin: auto;">

<p>
  #forums.Posting_history_for#
  <strong>
    <if @useScreenNameP;literal@ true>@message.screen_name@</if>
    <else>@user_link;noquote@</else>
  </strong>
</p>

<div>@dimensional_chunk;noquote@</div>
<listtemplate name="messages"></listtemplate>

<p>#forums.Summary_Posting_history_for#</p>
<listtemplate name="posts"></listtemplate>

</div>
