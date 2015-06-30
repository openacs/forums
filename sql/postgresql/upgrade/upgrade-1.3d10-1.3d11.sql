
select define_function_args('forums_forum__delete','forum_id');
select define_function_args('forums_forum__name','forum_id');
select define_function_args('forums_forum__new','forum_id,object_type;forums_forum,name,charter,presentation_type,posting_policy,package_id,creation_date,creation_user,creation_ip,context_id');

select define_function_args('forums_message__delete', 'message_id');
select define_function_args('forums_message__delete_thread', 'message_id');
select define_function_args('forums_message__move_thread_thread_update_reading_info','source_message_id,source_forum_id,target_message_id');
select define_function_args('forums_message__move_thread_update_reading_info','source_message_id,source_old_root_message_id,target_message_id');
select define_function_args('forums_message__move_update_reading_info','message_id,old_forum_id,new_forum_id');
select define_function_args('forums_message__name','message_id');
select define_function_args('forums_message__new', 'message_id,object_type;forums_message,forum_id,subject,content,format,user_id,state,parent_id,creation_date,creation_user,creation_ip,context_id');
select define_function_args('forums_message__root_message_id', 'message_id');
select define_function_args('forums_message__set_state', 'message_id,state');
select define_function_args('forums_message__thread_close', 'message_id');
select define_function_args('forums_message__thread_open', 'message_id');

select define_function_args('forums_reading_info__remove_msg','message_id');
select define_function_args('forums_reading_info__user_add_forum','forum_id,user_id');
select define_function_args('forums_reading_info__user_add_msg','root_message_id,user_id');

