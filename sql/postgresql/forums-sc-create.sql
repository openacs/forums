-- forums service contracts for Search package
-- dave bauer <dave@thedesignexperience.org>
-- August 7, 2002

-- jcd: 2004-04-01 moved the sc create to the tcl callbacks, and added one for forum_forum objtype
-- TODO-JCD: trigger for forums_forums

-- til: only indexing full threads. changes to child messages will be treated as 
-- change to the thread.

CREATE OR REPLACE FUNCTION forums_message_search__itrg () RETURNS trigger AS $$
DECLARE
    v_root_message_id forums_messages.message_id%TYPE;
    v_is_approved     boolean;
BEGIN
    if new.parent_id is null and new.state = 'approved' then
        -- New threads are indexed only if they are approved.
        perform search_observer__enqueue(new.message_id,'INSERT');
    else
        -- Non-root messages trigger the indexing of the whole thread,
        -- but only if the thread (the root message) has been
        -- approved.
        -- We do not care about the approval of the message itself in
        -- this case, as the datasource callback will take care of not
        -- rendering any unapproved non-root message.
        v_root_message_id := forums_message__root_message_id(new.parent_id);

        select state = 'approved' into v_is_approved
          from forums_messages
         where message_id = v_root_message_id;

        if v_is_approved then
            perform search_observer__enqueue(v_root_message_id,'UPDATE');
        end if;
    end if;
    return new;
END;
$$ LANGUAGE plpgsql;



--
-- procedure forums_message_search__dtrg/0
--
CREATE OR REPLACE FUNCTION forums_message_search__dtrg(

) RETURNS trigger AS $$
DECLARE
    v_root_message_id forums_messages.message_id%TYPE;
    v_is_approved     boolean;
BEGIN
    -- if the deleted msg has a parent then its an UPDATE to a thread, otherwise a DELETE.

    if old.parent_id is null then
        perform search_observer__enqueue(old.message_id,'DELETE');
    else
        -- Deleting non-root messages triggers the indexing of the
        -- whole thread, but only if the thread (the root message) has
        -- been approved.
        -- We do not care about the approval of the message itself in
        -- this case, as the datasource callback will take care of not
        -- rendering any unapproved non-root message.
        v_root_message_id := forums_message__root_message_id(new.parent_id);

        select state = 'approved' into v_is_approved
          from forums_messages
         where message_id = v_root_message_id;

        if v_is_approved then
            perform search_observer__enqueue(v_root_message_id,'UPDATE');
        end if;
    end if;

    return old;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION forums_message_search__utrg () RETURNS trigger AS $$
DECLARE
    v_root_message_id forums_messages.message_id%TYPE;
    v_is_approved     boolean;
BEGIN
    if old.parent_id is null and new.state <> 'approved' then
         -- New threads that have been revoked approval should be
         -- removed from the search results.
         perform search_observer__enqueue(old.message_id,'DELETE');
    else
        -- Non-root messages trigger the indexing of the whole thread,
        -- but only if the thread (the root message) has been
        -- approved.
        -- We do not care about the approval of the message itself in
        -- this case, as the datasource callback will take care of not
        -- rendering any unapproved non-root message.
        v_root_message_id := forums_message__root_message_id(new.parent_id);

        select state = 'approved' into v_is_approved
          from forums_messages
         where message_id = v_root_message_id;

        if v_is_approved then
            perform search_observer__enqueue(v_root_message_id,'UPDATE');
        end if;
    end if;
    return old;
END;
$$ LANGUAGE plpgsql;


create trigger forums_message_search__itrg after insert on forums_messages
for each row execute procedure forums_message_search__itrg (); 

create trigger forums_message_search__dtrg after delete on forums_messages
for each row execute procedure forums_message_search__dtrg (); 

create trigger forums_message_search__utrg after update on forums_messages
for each row execute procedure forums_message_search__utrg (); 



-- forums_forums indexing trigger
CREATE OR REPLACE FUNCTION forums_forums_search__itrg () RETURNS trigger AS $$
BEGIN
    perform search_observer__enqueue(new.forum_id,'INSERT');

    return new;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION forums_forums_search__utrg () RETURNS trigger AS $$
BEGIN
    perform search_observer__enqueue(new.forum_id,'UPDATE');

    return new;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION forums_forums_search__dtrg () RETURNS trigger AS $$
BEGIN
    perform search_observer__enqueue(old.forum_id,'DELETE');

    return old;
END;
$$ LANGUAGE plpgsql;



create trigger forums_forums_search__itrg after insert on forums_forums
for each row execute procedure forums_forums_search__itrg (); 

create trigger forums_forums_search__utrg after update on forums_forums
for each row execute procedure forums_forums_search__utrg (); 

create trigger forums_forums_search__dtrg after delete on forums_forums
for each row execute procedure forums_forums_search__dtrg (); 

