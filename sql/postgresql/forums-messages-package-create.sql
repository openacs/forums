
--
-- The Forums Package
--
-- @author gwong@orchardlabs.com,ben@openforce.biz
-- @creation-date 2002-05-16
--
-- The Package for Messages
--
-- This code is newly concocted by Ben, but with heavy concepts and heavy code
-- chunks lifted from Gilbert. Thanks Orchard Labs!
--

select define_function_args ('forums_message__new', 'message_id,object_type;forums_message,forum_id,subject,content,html_p,user_id,posting_date,state,parent_id,creation_date,creation_user,creation_ip,context_id');

create function forums_message__new (integer,varchar,integer,varchar,text,char,integer,timestamp,varchar,integer,timestamp,integer,varchar,integer)
returns integer as '
declare
    p_message_id                    alias for $1;
    p_object_type                   alias for $2;
    p_forum_id                      alias for $3;
    p_subject                       alias for $4;
    p_content                       alias for $5;
    p_html_p                        alias for $6;
    p_user_id                       alias for $7;
    p_posting_date                  alias for $8;
    p_state                         alias for $9;
    p_parent_id                     alias for $10;
    p_creation_date                 alias for $11;
    p_creation_user                 alias for $12;
    p_creation_ip                   alias for $13;
    p_context_id                    alias for $14;
    v_message_id                    integer;
    v_forum_policy                  forums_forums.posting_policy%TYPE;
    v_state                         forums_messages.state%TYPE;
    v_posting_date                  forums_messages.posting_date%TYPE;
begin
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
             
        if v_forum_policy = ''moderated''
        then v_state := ''pending'';
        else v_state := ''approved'';
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

end;
' language 'plpgsql';

select define_function_args ('forums_message__root_message_id', 'message_id');

create function forums_message__root_message_id (integer)
returns integer as '
declare
    p_message_id                    alias for $1;
    v_message_id                    forums_messages.message_id%TYPE;
    v_forum_id                      forums_messages.forum_id%TYPE;
    v_sortkey                       forums_messages.tree_sortkey%TYPE;
begin
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
end;
' language 'plpgsql';

select define_function_args ('forums_message__thread_open', 'message_id');

create function forums_message__thread_open (integer)
returns integer as '
declare
    p_message_id                    alias for $1;
    v_forum_id                      forums_messages.forum_id%TYPE;
    v_sortkey                       forums_messages.tree_sortkey%TYPE;
begin
    select forum_id, tree_sortkey
    into v_forum_id, v_sortkey
    from forums_messages
    where message_id = p_message_id;

    update forums_messages
    set open_p = ''t''
    where tree_sortkey between tree_left(v_sortkey) and tree_right(v_sortkey)
    and forum_id = v_forum_id;

    update forums_messages
    set open_p = ''t''
    where message_id = p_message_id;

    return 0;
end;
' language 'plpgsql';

select define_function_args ('forums_message__thread_close', 'message_id');

create function forums_message__thread_close (integer)
returns integer as '
declare
    p_message_id                    alias for $1;
    v_forum_id                      forums_messages.forum_id%TYPE;
    v_sortkey                       forums_messages.tree_sortkey%TYPE;
begin
    select forum_id, tree_sortkey
    into v_forum_id, v_sortkey
    from forums_messages
    where message_id = p_message_id;

    update forums_messages
    set open_p = ''f''
    where tree_sortkey between tree_left(v_sortkey) and tree_right(v_sortkey)
    and forum_id = v_forum_id;

    update forums_messages
    set open_p = ''f''
    where message_id = p_message_id;

    return 0;
end;
' language 'plpgsql';

select define_function_args ('forums_message__delete', 'message_id');

create function forums_message__delete (integer)
returns integer as '
declare
    p_message_id                    alias for $1;    
begin
    perform acs_object__delete(p_message_id);
    return 0;    
end;
' language 'plpgsql';

select define_function_args ('forums_message__delete_thread', 'message_id');

create function forums_message__delete_thread (integer)
returns integer as '
declare
    p_message_id                    alias for $1;
    v_forum_id                      forums_messages.forum_id%TYPE;
    v_sortkey                       forums_messages.tree_sortkey%TYPE;
    v_message                       RECORD;
begin
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
        perform forums_message__delete(v_message.message_id);
    end loop;

    -- delete the message itself
    perform forums_message__delete(p_message_id);

    return 0;
end;
' language 'plpgsql';

select define_function_args('forums_message__name','message_id');

create function forums_message__name (integer)
returns varchar as '
declare
    p_message_id                    alias for $1;
begin
    return subject from forums_messages where message_id = p_message_id;
end;
' language 'plpgsql';
