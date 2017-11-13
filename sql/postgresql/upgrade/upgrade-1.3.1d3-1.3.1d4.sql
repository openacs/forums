begin;

--
-- procedure forums_reading_info__move_thread_update/2
--
CREATE OR REPLACE FUNCTION forums_reading_info__move_thread_update(
   p_source_message_id integer,
   p_target_message_id integer
) RETURNS integer AS $$
DECLARE
   v_source_root_message_id integer;
BEGIN
   select root_message_id from forums_forums
    where forum_id = (select forum_id from forums_messages
                       where message_id = p_source_message_id) into v_source_root_message_id;
   
   -- for all users that have read target, but not the source, remove
   -- target_info
   delete from forums_reading_info i
    where root_message_id = p_target_message_id
      and not exists (select 1 from forums_reading_info
                       where root_message_id = v_source_root_message_id
                         and user_id = i.user_id);
                         
   -- for all users that have read source, remove reading info four
   -- source message since it no longer is root_message_id
   delete from forums_reading_info
    where root_message_id = p_source_message_id;
    
    return 1;
END;
$$ LANGUAGE plpgsql;

end;
