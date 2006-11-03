<if @searchbox_p@ true>
  <table cellpadding="5" width="95%">
    <tr>
      <td align="right">
<formtemplate id="search">
        <label for="search_text">#forums.Search#&nbsp;<formwidget id="search_text"></label>
</formtemplate>
      </td>
    </tr>
  </table>

  <br>

  <include src="../message/messages-table" &messages="messages">
</if>
