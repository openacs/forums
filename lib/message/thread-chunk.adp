<div id="forum-thread">
  <include src="row"
    rownum=0
    forum_moderated_p=@forum_moderated_p;noquote@
    moderate_p=@permissions.moderate_p;noquote@
    &message="message">
    <if @responses:rowcount@ gt 0>
      <multiple name="responses">
        <include src="row"
          rownum=@responses.rownum@
          forum_moderated_p=@forum_moderated_p;noquote@
          moderate_p=@permissions.moderate_p;noquote@
          &message="responses">
      </multiple>
    </if>
</div>
@response_arrays_stub;noquote@
