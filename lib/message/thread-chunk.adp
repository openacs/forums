<div id="forum-thread">
<include src="row"
    rownum=0 
    forum_id=@forum_id@
    forum_moderated_p=@forum_moderated_p;noquote@ 
    moderate_p=@permissions.moderate_p;noquote@ 
    &message="message"
    presentation_type=@forum.presentation_type;noquote@
    display_mode="@display_mode@">

<if @responses:rowcount@ gt 0>
<multiple name="responses">
              <include src="row" 
          rownum=@responses.rownum@
          forum_id=@forum_id@
          forum_moderated_p=@forum_moderated_p;noquote@ 
          moderate_p=@permissions.moderate_p;noquote@ 
          &message="responses"
          display_mode="@display_mode@">
          </multiple>
</if>
</div>
@response_arrays_stub;noquote@
