alter table forums_messages add format varchar(30);
alter table forums_messages alter column format set default 'text/plain';
alter table forums_messages add constraint forums_mess_format_ck check (format in ('text/enhanced', 'text/plain', 'text/fixed-width', 'text/html'));

update forums_messages
set format = 'text/html'
where html_p = 't';
update forums_messages
set format = 'text/plain'
where html_p = 'f';

alter table forums_messages drop column html_p cascade;

-- recreate the views 
create or replace view forums_messages_approved
as
    select *
    from forums_messages
    where state = 'approved';

create or replace view forums_messages_pending
as
    select *
    from forums_messages
    where state= 'pending';


-- taken from forums-messages-package-create.sql

select define_function_args ('forums_message__new', 'message_id,object_type;forums_message,forum_id,subject,content,format,user_id,posting_date,state,parent_id,creation_date,creation_user,creation_ip,context_id');



--
-- procedure forums_message__new/14
--
CREATE OR REPLACE FUNCTION forums_message__new(
   p_message_id integer,
   p_object_type varchar, -- default 'forums_message'
   p_forum_id integer,
   p_subject varchar,
   p_content text,
   p_format char,
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
    (message_id, forum_id, subject, content, format, user_id, posting_date, parent_id, state)
    values
    (v_message_id, p_forum_id, p_subject, p_content, p_format, p_user_id, v_posting_date, p_parent_id, v_state);

    update forums_forums
    set last_post = v_posting_date
    where forum_id = p_forum_id;

    update forums_messages
    set last_child_post = v_posting_date
    where message_id = forums_message__root_message_id(v_message_id);
 
    return v_message_id;

END;

$$ LANGUAGE plpgsql;
