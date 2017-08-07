
--
-- The Forums Package
--
-- @author gwong@orchardlabs.com,ben@openforce.biz
-- @creation-date 2002-05-16
-- @cvs-id $Id$
--
-- The Package for Messages
--
-- This code is newly concocted by Ben, but with heavy concepts and heavy code
-- chunks lifted from Gilbert. Thanks Orchard Labs!
--

select define_function_args ('forums_message__new', 'message_id,object_type;forums_message,forum_id,subject,content,format,user_id,state,parent_id,creation_date,creation_user,creation_ip,context_id');

-- Get rid of the old version so we'll throw an error if the admin forgets to reboot
-- OpenACS after the upgrade (package_instantiate_object caches param lists)


--
-- procedure forums_message__new/13
--
CREATE OR REPLACE FUNCTION forums_message__new(
   p_message_id integer,
   p_object_type varchar, -- default 'forums_message'
   p_forum_id integer,
   p_subject varchar,
   p_content text,
   p_format char,
   p_user_id integer,
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
    v_package_id                    acs_objects.package_id%TYPE;
BEGIN

    select package_id into v_package_id from forums_forums where forum_id = p_forum_id;

    if v_package_id is null then
        raise exception 'forums_message__new: forum_id % not found', p_forum_id;
    end if;

    v_message_id := acs_object__new(
        p_message_id,
        p_object_type,
        p_creation_date,
        p_creation_user,
        p_creation_ip,
        coalesce(p_context_id, p_forum_id),
        't',
        p_subject,
        v_package_id
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

    insert into forums_messages
    (message_id, forum_id, subject, content, format, user_id, parent_id, state, last_child_post, last_poster)
    values
    (v_message_id, p_forum_id, p_subject, p_content, p_format, p_user_id, p_parent_id,
     v_state, current_timestamp, p_user_id);

    update forums_forums
    set last_post = current_timestamp
    where forum_id = p_forum_id;

    if p_parent_id is null then
      if v_state = 'approved' then
        update forums_forums
        set thread_count = thread_count + 1,
          approved_thread_count = approved_thread_count + 1
        where forum_id=p_forum_id;
      else
        update forums_forums
        set thread_count = thread_count + 1
        where forum_id=p_forum_id;
      end if;
    else
      if v_state = 'approved' then
        update forums_messages
        set approved_reply_count = approved_reply_count + 1,
          reply_count = reply_count + 1,
          last_poster = p_user_id,
          last_child_post = current_timestamp
        where message_id = forums_message__root_message_id(v_message_id);
      else
        -- dont update last_poster, last_child_post when not approved
        update forums_messages
        set reply_count = reply_count + 1
        where message_id = forums_message__root_message_id(v_message_id);
      end if;
    end if;

    return v_message_id;

END;
$$ LANGUAGE plpgsql;

select define_function_args ('forums_message__root_message_id', 'message_id');



--
-- procedure forums_message__root_message_id/1
--
CREATE OR REPLACE FUNCTION forums_message__root_message_id(
   p_message_id integer
) RETURNS integer AS $$
DECLARE
    v_message_id                    forums_messages.message_id%TYPE;
    v_forum_id                      forums_messages.forum_id%TYPE;
    v_sortkey                       forums_messages.tree_sortkey%TYPE;
BEGIN
    select forum_id, tree_sortkey
    into v_forum_id, v_sortkey
    from forums_messages
    where message_id = p_message_id;

    select message_id
    into v_message_id
    from forums_messages
    where forum_id = v_forum_id
    and tree_sortkey = tree_ancestor_key(v_sortkey, 1);

    return v_message_id;
END;

$$ LANGUAGE plpgsql stable strict;

select define_function_args ('forums_message__thread_open', 'message_id');



--
-- procedure forums_message__thread_open/1
--
CREATE OR REPLACE FUNCTION forums_message__thread_open(
   p_message_id integer
) RETURNS integer AS $$
DECLARE
    v_forum_id                      forums_messages.forum_id%TYPE;
    v_sortkey                       forums_messages.tree_sortkey%TYPE;
BEGIN
    select forum_id, tree_sortkey
    into v_forum_id, v_sortkey
    from forums_messages
    where message_id = p_message_id;

    update forums_messages
    set open_p = true
    where tree_sortkey between tree_left(v_sortkey) and tree_right(v_sortkey)
    and forum_id = v_forum_id;

    update forums_messages
    set open_p = true
    where message_id = p_message_id;

    return 0;
END;

$$ LANGUAGE plpgsql;

select define_function_args ('forums_message__thread_close', 'message_id');



--
-- procedure forums_message__thread_close/1
--
CREATE OR REPLACE FUNCTION forums_message__thread_close(
   p_message_id integer
) RETURNS integer AS $$
DECLARE
    v_forum_id                      forums_messages.forum_id%TYPE;
    v_sortkey                       forums_messages.tree_sortkey%TYPE;
BEGIN
    select forum_id, tree_sortkey
    into v_forum_id, v_sortkey
    from forums_messages
    where message_id = p_message_id;

    update forums_messages
    set open_p = false
    where tree_sortkey between tree_left(v_sortkey) and tree_right(v_sortkey)
    and forum_id = v_forum_id;

    update forums_messages
    set open_p = false
    where message_id = p_message_id;

    return 0;
END;

$$ LANGUAGE plpgsql;

select define_function_args ('forums_message__set_state', 'message_id,state');



--
-- procedure forums_message__set_state/2
--
CREATE OR REPLACE FUNCTION forums_message__set_state(
   p_message_id integer,
   p_state varchar
) RETURNS integer AS $$
DECLARE
  v_cur             record;
BEGIN

  select into v_cur *
  from forums_messages
  where message_id = p_message_id;

  if v_cur.parent_id is null then
    if p_state = 'approved' and v_cur.state <> 'approved' then
      update forums_forums
      set approved_thread_count = approved_thread_count + 1
      where forum_id=v_cur.forum_id;
    elsif p_state <> 'approved' and v_cur.state = 'approved' then
      update forums_forums
      set approved_thread_count = approved_thread_count - 1
      where forum_id=v_cur.forum_id;
    end if;
  else
    if p_state = 'approved' and v_cur.state <> 'approved' then
      update forums_messages
      set approved_reply_count = approved_reply_count + 1, 
        last_poster = (case when v_cur.posting_date > last_child_post then v_cur.user_id else last_poster end),
        last_child_post = (case when v_cur.posting_date > last_child_post then v_cur.posting_date else last_child_post end)
      where message_id = forums_message__root_message_id(v_cur.message_id);
    elsif p_state <> 'approved' and v_cur.state = 'approved' then
      update forums_messages
      set approved_reply_count = approved_reply_count - 1
      where message_id = forums_message__root_message_id(v_cur.message_id);
    end if;
  end if;

  update forums_messages
  set state = p_state
  where message_id = p_message_id;

  return 0;

END;
$$ LANGUAGE plpgsql;

select define_function_args ('forums_message__delete', 'message_id');



--
-- procedure forums_message__delete/1
--
CREATE OR REPLACE FUNCTION forums_message__delete(
   p_message_id integer
) RETURNS integer AS $$
DECLARE
  v_cur             record;
BEGIN

  -- Maintain the forum thread counts

  select into v_cur *
  from forums_messages
  where message_id = p_message_id;

  if v_cur.parent_id is null then
    if v_cur.state = 'approved' then
      update forums_forums
      set thread_count = thread_count - 1,
        approved_thread_count = approved_thread_count - 1
      where forum_id=v_cur.forum_id;
    else
      update forums_forums
      set thread_count = thread_count - 1
      where forum_id=v_cur.forum_id;
    end if;
  elsif v_cur.state = 'approved' then
    update forums_messages
    set approved_reply_count = approved_reply_count - 1,
      reply_count = reply_count - 1
    where message_id = forums_message__root_message_id(v_cur.message_id);
  else
    update forums_messages
    set reply_count = reply_count - 1
    where message_id = forums_message__root_message_id(v_cur.message_id);
  end if;

  perform acs_object__delete(p_message_id);
  return 0;
END;
$$ LANGUAGE plpgsql;

select define_function_args ('forums_message__delete_thread', 'message_id');



--
-- procedure forums_message__delete_thread/1
--
CREATE OR REPLACE FUNCTION forums_message__delete_thread(
   p_message_id integer
) RETURNS integer AS $$
DECLARE
    v_forum_id                      forums_messages.forum_id%TYPE;
    v_sortkey                       forums_messages.tree_sortkey%TYPE;
    v_message                       RECORD;
BEGIN
    select forum_id, tree_sortkey
    into v_forum_id, v_sortkey
    from forums_messages
    where message_id = p_message_id;

    -- if it is already deleted
    if v_forum_id is null
    then return 0;
    end if;

    -- delete all children
    -- order by tree_sortkey desc to guarantee
    -- that we never delete a parent before its child
    -- sortkeys are beautiful
    for v_message in select *
                     from forums_messages
                     where forum_id = v_forum_id
                     and tree_sortkey between tree_left(v_sortkey) and tree_right(v_sortkey)
                     order by tree_sortkey desc
    loop
        -- Avoid the count bookkeeping down in forums_message__delete
        perform forums_message__delete(v_message.message_id);
    end loop;

    -- delete the message itself
    perform forums_message__delete(p_message_id);

    return 0;
END;
$$ LANGUAGE plpgsql;


select define_function_args('forums_message__name','message_id');



--
-- procedure forums_message__name/1
--
CREATE OR REPLACE FUNCTION forums_message__name(
   p_message_id integer
) RETURNS varchar AS $$
DECLARE
BEGIN
    return subject from forums_messages where message_id = p_message_id;
END;

$$ LANGUAGE plpgsql;
