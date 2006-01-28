<if @forum.presentation_type@ eq "flat">
<table bgcolor="@table_border_color@" cellpadding="5" width="95%">
</if>
<else>
<table bgcolor="@table_border_color@" width="95%">
</else>
  <include src="row"
           bgcolor="@table_bgcolor;noquote@" 
           forum_moderated_p=@forum_moderated_p;noquote@ 
           moderate_p=@permissions.moderate_p;noquote@ 
           &message="message">
</table>

<if @responses:rowcount@ gt 0>

  <if @forum.presentation_type@ eq "flat">
  <table bgcolor="@table_border_color@" cellpadding="5" width="95%">
  </if>
  <else>
  <table width="95%">
  </if>

    <multiple name="responses">
    
    <if @forum.presentation_type@ ne "flat">
    <% set width [expr 100 - [expr $responses(tree_level) - 1] * 1] %>
    <tr style="padding-top: 1em">
      <td align="left">
        <table align="right" bgcolor="@table_border_color@" width="@width@%">
    </if>
          <if @responses.rownum@ odd>
            <include src="row" 
                     bgcolor="@table_other_bgcolor;noquote@" 
                     forum_moderated_p=@forum_moderated_p;noquote@ 
                     moderate_p=@permissions.moderate_p;noquote@ 
                     &message="responses">
          </if>
          <else>
            <include src="row" 
                     bgcolor="@table_bgcolor;noquote@"
                     forum_moderated_p=@forum_moderated_p;noquote@
                     moderate_p=@permissions.moderate_p;noquote@
                     &message="responses">
          </else>
    <if @forum.presentation_type@ ne "flat">
        </table>
      </td>
    </tr>
    </if>

    </multiple>
  
  </table>
</if>
