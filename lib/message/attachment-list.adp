  <ul>
    <multiple name="attachments">
      <li>
        <if @preview;literal@ true>
          <adp:icon name="@attachments.icon@" title="#attachments.Attachment#"> @attachments.name@ @attachments.content_size_pretty@
        </if>
        <else>
          <adp:icon name="@attachments.icon@" title="#attachments.Attachment#"> <a href="@attachments.url@">@attachments.name@</a> @attachments.content_size_pretty@
          <if @detach_p;literal@ true>
              <a href="@detach_url@"><adp:icon name='@detach_icon;literal@'></a>
          </if>
        </else>
      </li>
    </multiple>
  </ul>
