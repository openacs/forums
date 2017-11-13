create table forums_reading_info (
    root_message_id integer
                    constraint forum_read_parent_id_fk
                    references forums_messages (message_id)
                    on delete cascade,
    user_id         integer
                    constraint forums_read_user_id_fk
                    references users(user_id)
                    constraint forums_read_user_id_nn
                    not null,
    reading_date    timestamp
                    default current_timestamp
                    constraint forum_read_datetime_nn
                    not null,
    forum_id        integer
                    constraint forum_read_forum_id_fk
                    references forums_forums (forum_id)
                    on delete cascade                    
                    constraint forums_read_forum_id_nn
                    not null,
    constraint forums_reading_info_pk primary key (root_message_id,user_id)
);

create index forums_reading_info_user_index on forums_reading_info (user_id);
create index forums_reading_info_forum_message_index on forums_reading_info (root_message_id);
create index forums_reading_info_forum_forum_index on forums_reading_info (forum_id);

create or replace view forums_reading_info_user as
   select forum_id,
          user_id,
          count(*) as threads_read
     from forums_reading_info
    group by forum_id, user_id;


-- mark message as unread

-- added
select define_function_args('forums_reading_info__remove_msg','message_id');

--
-- procedure forums_reading_info__remove_msg/1
--
CREATE OR REPLACE FUNCTION forums_reading_info__remove_msg(
   p_message_id integer
) RETURNS integer AS $$
DECLARE
BEGIN
    delete from forums_reading_info 
     where root_message_id = p_message_id;
    return 0;
END;
$$ LANGUAGE plpgsql;


-- mark all messages in forum as read

-- added
select define_function_args('forums_reading_info__user_add_forum','forum_id,user_id');

--
-- procedure forums_reading_info__user_add_forum/2
--
CREATE OR REPLACE FUNCTION forums_reading_info__user_add_forum(
   p_forum_id integer,
   p_user_id integer
) RETURNS integer AS $$
DECLARE
   v_message_id integer;
BEGIN
    for v_message_id in 
     select message_id
       from forums_messages_approved m
      where forum_id = p_forum_id
        and parent_id is null
        and not exists (select 1 from forums_reading_info
                                where user_id = p_user_id
                                  and root_message_id = m.message_id) loop
        insert into forums_reading_info (
               root_message_id,
               user_id,
               forum_id
              ) values (
               v_message_id,
               p_user_id,
               p_forum_id
              );
    end loop;
    return 0;
END;
$$ LANGUAGE plpgsql;


-- mark single message as read by user

-- added
select define_function_args('forums_reading_info__user_add_msg','root_message_id,user_id');

--
-- procedure forums_reading_info__user_add_msg/2
--
CREATE OR REPLACE FUNCTION forums_reading_info__user_add_msg(
   p_root_message_id integer,
   p_user_id integer
) RETURNS integer AS $$
DECLARE
   v_forum_id integer;
BEGIN
   if NOT exists (select 1 from forums_reading_info
                   where user_id = p_user_id
                     and root_message_id = p_root_message_id) then

       insert into forums_reading_info (
                root_message_id,
                user_id,
                forum_id
             ) values (
                p_root_message_id,
                p_user_id,
                (select forum_id from forums_messages
                  where message_id = p_root_message_id)
             );   
    end if;

    return 0;
END;
$$ LANGUAGE plpgsql;


-- move thread to other thread

-- added
select define_function_args('forums_reading_info__move_thread_update','source_message_id,target_message_id');

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

