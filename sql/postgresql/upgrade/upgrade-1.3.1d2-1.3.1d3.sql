begin;

-- As it comes out, forums has some embedded views counter
-- feature. This is not used upstream, but it is in some local
-- installations we know of. As on these table forums_reading_info can
-- grow very large, there were reports of bad performances. This
-- update has the goal to optimize and streamline current reading
-- count implementation. During this, some inconsistency between
-- oracle and postgres and duplication was found and addressed.

-- data model

drop table if exists forums_reading_info_user;

alter table forums_reading_info
      add column forum_id integer
                    constraint forum_read_forum_id_fk
                    references forums_forums (forum_id)
                    on delete cascade;

-- populate reference to forum in table
update forums_reading_info i set forum_id = (
       select forum_id
         from forums_messages
        where message_id = i.root_message_id);

create index forums_reading_info_forum_forum_index on forums_reading_info (forum_id);

alter table forums_reading_info alter column forum_id set not null;

-- this was a sort of materialized view, but consistency checks made
-- code complicated. Redefined as a view
create or replace view forums_reading_info_user as
   select forum_id,
          user_id,
          count(*) as threads_read
     from forums_reading_info
    group by forum_id, user_id;


-- functions

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


--
-- procedure forums_reading_info__user_add_forum/2
--
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


-- These functions were defined with a name not conformant with
-- package notation used to mimic oracle. They resulted also
-- redundant once we eliminated the forums_reading_info_users table

drop function forums_message__move_update_reading_info(integer, integer, integer);
delete from acs_function_args
 where function = upper('forums_message__move_update_reading_info');

delete from acs_function_args
 where function = upper('forums_message__move_thread_update_reading_info');
drop function forums_message__move_thread_update_reading_info(integer, integer, integer);

drop function forums_message__move_thread_thread_update_reading_info(integer, integer, integer);
delete from acs_function_args
 where function = upper('forums_message__move_thread_thread_update_reading_info');


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
BEGIN
   -- for all users that have read target, but not the source, remove
   -- target_info
   delete from forums_reading_info i
    where root_message_id = p_target_message_id
      and not exists (select 1 from forums_reading_info
                       where root_message_id = p_source_message_id
                         and user_id = i.user_id);
                         
   -- for all users that have read source, remove reading info four
   -- source message since it no longer is root_message_id
   delete from forums_reading_info
    where root_message_id = p_source_message_id;
    
    return 1;
END;
$$ LANGUAGE plpgsql;


drop function forums_message__repair_reading_info();
delete from acs_function_args
 where function = upper('forums_message__repair_reading_info');

end;
