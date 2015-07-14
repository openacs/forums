<div id="forum-thread">
  <include src="row"
    rownum=0
    forum_moderated_p="@forum_moderated_p;literal@"
    moderate_p="@permissions.moderate_p;literal@"
    presentation_type="@forum.presentation_type;literal@"
    &permissions="permissions"
    &message="message">
    <if @responses:rowcount@ gt 0>
      <multiple name="responses">
        <include src="row"
          rownum="@responses.rownum;literal@"
          forum_moderated_p="@forum_moderated_p;literal@"
          moderate_p="@permissions.moderate_p;literal@"
	  presentation_type="@forum.presentation_type;literal@"
          &permissions="permissions"
          &message="responses">
      </multiple>
    </if>
</div>
@response_arrays_stub;noquote@
