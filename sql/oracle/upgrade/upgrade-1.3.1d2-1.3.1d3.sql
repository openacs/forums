begin;

-- As it comes out, forums has some embedded views counter
-- feature. This is not used upstream, but it is in some local
-- installations we know of. As on these table forums_reading_info can
-- grow very large, there were reports of bad performances. This
-- update has the goal to optimize and streamline current reading
-- count implementation. During this, some inconsistency between
-- oracle and postgres and duplication was found and addressed.

-- data model

drop table forums_reading_info_user;

alter table forums_reading_info
      add forum_id integer
                    constraint forum_read_forum_id_fk
                    references forums_forums (forum_id)
                    on delete cascade;

-- populate reference to forum in table
update forums_reading_info i set forum_id = (
       select forum_id
         from forums_messages
        where message_id = i.root_message_id);

create index forums_reading_info_forum_forum_index on forums_reading_info (forum_id);

ALTER TABLE forums_reading_info ( forum_id NOT NULL);

-- this was a sort of materialized view, but consistency checks made
-- code complicated. Redefined as a view
create or replace view forums_reading_info_user as
   select forum_id,
          user_id,
          count(*) as threads_read
     from forums_reading_info
    group by forum_id, user_id;


-- functions

create or replace package forum_reading_info
as
-- remove reading_info for thread (upon new message, upon message deletion, or state change)
	procedure remove_msg (
	        p_message_id in forums_messages.message_id%TYPE
	);

-- mark_all_read
	procedure user_add_forum (
		p_forum_id in forums_forums.forum_id%TYPE,
		p_user_id in users.user_id%TYPE 
	);

-- mark message read for user
	procedure user_add_msg (
		p_root_message_id in forums_messages.message_id%TYPE,
		p_user_id in users.user_id%TYPE
	);

-- move message to other thread
	procedure move_thread_update (
		p_source_message_id in forums_messages.message_id%TYPE,
		p_target_message_id in forums_messages.message_id%TYPE
	);

end forum_reading_info;
/
show errors



create or replace package body forum_reading_info
as
-- remove reading_info for thread (upon new message, upon message deletion, or state change)
	procedure remove_msg (
	        p_message_id in forums_messages.message_id%TYPE
	) 
	is
		v_forum_id	forums_messages.forum_id%TYPE;
		cursor c_reading is select user_id from forums_reading_info where root_message_id = p_message_id;

	begin

        --Exception no_data_found if select into hasn't rows
        begin 
        	    select forum_id into v_forum_id from forums_messages where message_id = p_message_id;
                exception
                when no_data_found then
                     v_forum_id := null;
        end;

	    for v_reading in c_reading
	    loop

		  delete from forums_reading_info 
	          where root_message_id = p_message_id and
              		user_id = v_reading.user_id;

	    end loop;


	end remove_msg;

-- mark_all_read:

        procedure user_add_forum (
                p_forum_id in forums_forums.forum_id%TYPE,
                p_user_id in users.user_id%TYPE
        )
        is
                v_message forums_messages_approved%ROWTYPE;
                v_read_p integer;
        begin

            for v_message in (select message_id
                        from forums_messages_approved
                        where forum_id = p_forum_id
                        and parent_id is null)
            loop
                 select count(*) into v_read_p from forums_reading_info where user_id = p_user_id and root_message_id  = v_message.message_id;
                 
                 if v_read_p = 0 then 
                    insert into forums_reading_info
                    (root_message_id,user_id,forum_id)
                    values
                    (v_message.message_id,p_user_id,p_forum_id);
                 end if;
            end loop;
                
        end user_add_forum;


-- mark message read for user
        procedure user_add_msg (
                p_root_message_id in forums_messages.message_id%TYPE,
                p_user_id in users.user_id%TYPE
        )
        is
                v_forum_id integer;
                v_read_p integer;
        begin
                begin
                        select forum_id into v_forum_id from forums_messages where message_id = p_root_message_id;
                exception               
                when no_data_found then
                     v_forum_id := null;
                end;

                select count(*) into v_read_p from forums_reading_info where user_id = p_user_id and root_message_id = p_root_message_id;

                 if v_read_p = 0 then

                        insert into forums_reading_info (root_message_id,user_id,forum_id)
                          values (p_root_message_id,p_user_id,v_forum_id);

                 end if;

        end user_add_msg;

-- move message to other thread
	procedure move_thread_update (
		p_source_message_id in forums_messages.message_id%TYPE,
		p_target_message_id in forums_messages.message_id%TYPE
	) is
		v_target_forum_id 			forums_forums.forum_id%TYPE;
		v_users             			forums_reading_info%ROWTYPE;
	begin
            begin
                select forum_id into v_target_forum_id from forums_messages where message_id = p_target_message_id;
            exception
                when no_data_found then
                     v_target_forum_id := null;
            end;


		for v_users in (select user_id from forums_reading_info fri where root_message_id  = p_target_message_id and not exists(select 1 from forums_reading_info where root_message_id = p_source_old_root_message_id and user_id = fri.user_id))
		loop

			delete from forums_reading_info where root_message_id = p_target_message_id and user_id = v_users.user_id;
			-- down the number of threads read in target forum
		end loop;

	end move_thread_update;

end forum_reading_info;
/
show errors


end;
