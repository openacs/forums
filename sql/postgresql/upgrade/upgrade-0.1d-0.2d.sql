alter table forums_forums add column last_post timestamptz;
alter table forums_messages add column last_child_post timestamptz;



--
-- procedure t/0
--
CREATE OR REPLACE FUNCTION t(

) RETURNS integer AS $$
DECLARE
  v_record record;
  v_timestamp timestamptz; 
BEGIN

  for v_record in select forum_id
                  from forums_forums
  loop

    select last_modified into v_timestamp
    from acs_objects
    where object_id = v_record.forum_id;

    update forums_forums
    set last_post = v_timestamp
    where forum_id = v_record.forum_id;

  end loop;

  for v_record in select message_id
                  from forums_messages
                  where parent_id is null
  loop

    -- forums 0.1d did not properly set the last_modified field of the object
    -- row associated with the root message of a thread, so we need to calculate
    -- it here.

    select max(o.last_modified) into v_timestamp
    from acs_objects o, forums_messages fm
    where forums_message__root_message_id(fm.message_id) = v_record.message_id
      and object_id = fm.message_id;

    update forums_messages
    set last_child_post = v_timestamp
    where message_id = v_record.message_id;

  end loop;

  return 1;

END;
$$ LANGUAGE plpgsql;
    
select t();

drop view forums_messages_approved;
create view forums_messages_approved
as
    select *
    from forums_messages
    where state = 'approved';

drop view forums_messages_pending;
create view forums_messages_pending
as
    select *
    from forums_messages
    where state= 'pending';

drop view forums_forums_enabled;
create view forums_forums_enabled
as
    select *
    from forums_forums
    where enabled_p = 't';



-- added
select define_function_args('forums_message__new','message_id,object_type,forum_id,subject,content,html_p,user_id,posting_date,state,parent_id,creation_date,creation_user,creation_ip,context_id');

--
-- procedure forums_message__new/14
--
CREATE OR REPLACE FUNCTION forums_message__new(
   p_message_id integer,
   p_object_type varchar,
   p_forum_id integer,
   p_subject varchar,
   p_content text,
   p_html_p char,
   p_user_id integer,
   p_posting_date timestamptz,
   p_state varchar,
   p_parent_id integer,
   p_creation_date timestamptz,
   p_creation_user integer,
   p_creation_ip varchar,
   p_context_id integer
) RETURNS integer AS $$
DECLARE
    v_message_id                    integer;
    v_forum_policy                  forums_forums.posting_policy%TYPE;
    v_state                         forums_messages.state%TYPE;
    v_posting_date                  forums_messages.posting_date%TYPE;
BEGIN
    v_message_id := acs_object__new(
        p_message_id,
        p_object_type,
        p_creation_date,
        p_creation_user,
        p_creation_ip,
        coalesce(p_context_id, p_forum_id)
    );

    if p_state is null then
        select posting_policy
        into v_forum_policy
        from forums_forums
        where forum_id = p_forum_id;
             
        if v_forum_policy = 'moderated'
        then v_state := 'pending';
        else v_state := 'approved';
        end if;
    else
        v_state := p_state;
    end if;

    if p_posting_date is null then
        v_posting_date = now();
    else
        v_posting_date = p_posting_date;
    end if;

    insert into forums_messages
    (message_id, forum_id, subject, content, html_p, user_id, posting_date, parent_id, state)
    values
    (v_message_id, p_forum_id, p_subject, p_content, p_html_p, p_user_id, v_posting_date, p_parent_id, v_state);

    update forums_forums
    set last_post = v_posting_date
    where forum_id = p_forum_id;

    update forums_messages
    set last_child_post = v_posting_date
    where message_id = forums_message__root_message_id(v_message_id);
 
    return v_message_id;

END;

$$ LANGUAGE plpgsql;



-- added
select define_function_args('forums_forum__new','forum_id,object_type,name,charter,presentation_type,posting_policy,package_id,creation_date,creation_user,creation_ip,context_id');

--
-- procedure forums_forum__new/11
--
CREATE OR REPLACE FUNCTION forums_forum__new(
   p_forum_id integer,
   p_object_type varchar,
   p_name varchar,
   p_charter varchar,
   p_presentation_type varchar,
   p_posting_policy varchar,
   p_package_id integer,
   p_creation_date timestamptz,
   p_creation_user integer,
   p_creation_ip varchar,
   p_context_id integer
) RETURNS integer AS $$
DECLARE
    v_forum_id                      integer;
BEGIN
    v_forum_id:= acs_object__new(
        p_forum_id,
        p_object_type,
        p_creation_date,
        p_creation_user,
        p_creation_ip,
        coalesce(p_context_id, p_package_id)
    );

    insert into forums_forums
    (forum_id, name, charter, presentation_type, posting_policy, package_id)
    values
    (v_forum_id, p_name, p_charter, p_presentation_type, p_posting_policy, p_package_id);

    return v_forum_id;
END;

$$ LANGUAGE plpgsql;

