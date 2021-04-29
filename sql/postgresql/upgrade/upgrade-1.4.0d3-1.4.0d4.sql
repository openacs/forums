begin;

-- Account for moderation in the search package triggers: make sure we
-- do not index unapproved threads and messages.

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

-- Schedule unindexing of all unapproved threads
select search_observer__enqueue(message_id,'DELETE')
from forums_messages
where parent_id is null
  and state <> 'approved';

-- Schedule the reindexing of all threads that are themselves
-- approved, but contain unapproved messages. The datasource callback
-- will take care of not rendering the unapproved messages.
select search_observer__enqueue(message_id,'UPDATE')
from (
select distinct thread.message_id
    from forums_messages thread,
         forums_messages messages
    where thread.forum_id = messages.forum_id
      and thread.parent_id is null
      and thread.state = 'approved'
      and thread.tree_sortkey = tree_ancestor_key(messages.tree_sortkey, 1)
      and messages.parent_id is not null
      and messages.state <> 'approved') as threads_with_unapproved_messages;

end;
