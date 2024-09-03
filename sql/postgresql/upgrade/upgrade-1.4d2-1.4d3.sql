
-- New index on the forums_reading_info table
create index if not exists forums_reading_info_user_id_root_message_id_idx on forums_reading_info(user_id,root_message_id);
