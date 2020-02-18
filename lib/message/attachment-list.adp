  <ul>
    <multiple name="attachments">
      <li>
        <if @preview;literal@ true>
          <img src="@attachments.icon@" alt="#attachments.Attachment#"/> @attachments.name@ @attachments.content_size_pretty@
        </if>
        <else>
          <img src="@attachments.icon@" alt="#attachments.Attachment#"/> <a href="@attachments.url@">@attachments.name@</a> @attachments.content_size_pretty@
          <if @detach_p;literal@ true>
              <a href="@detach_url@"><img src=@detach_icon@ /></a>
          </if>
        </else>
      </li>
    </multiple>
  </ul>
