-- forums service contracts for Search package
-- dave bauer <dave@thedesignexperience.org>
-- August 7, 2002

select acs_sc_impl__new(
	'FtsContentProvider',		-- impl_contract_name
	'forums_message',			-- impl_name
	'forums'			-- impl_owner.name
);

select acs_sc_impl_alias__new(
	'FtsContentProvider',		-- impl_contract_name
	'forums_message',			-- impl_name
	'datasource',			-- impl_operation_name
	'forum::message::datasource',	-- impl_alias
	'TCL'				-- impl_pl
);

select acs_sc_impl_alias__new(
	'FtsContentProvider',		-- impl_contract_name
	'forums_message',			-- impl_name
	'url',				-- impl_operation_name
	'forum::message::url',		-- impl_alias
	'TCL'				-- impl_pl
);

-- til: only indexing full threads. changes to child messages will be treated as 
-- change to the thread.

create or replace function forums_message_search__itrg ()
returns opaque as '
begin
    if new.parent_id is null then
        perform search_observer__enqueue(new.message_id,''INSERT'');
    else
        perform search_observer__enqueue(forums_message__root_message_id(new.parent_id),''UPDATE'');
    end if;
    return new;
end;' language 'plpgsql';

create or replace function forums_message_search__dtrg ()
returns opaque as '
declare
     v_root_message_id          forums_messages.message_id%TYPE;
begin
    -- if the deleted msg has a parent then its an UPDATE to a thread, otherwise a DELETE.

    if old.parent_id is null then
        perform search_observer__enqueue(old.message_id,''DELETE'');
    else
        v_root_message_id := forums_message__root_message_id(old.parent_id);
        if not v_root_message_id is null then
            perform search_observer__enqueue(v_root_message_id,''UPDATE'');
        end if;
    end if;

    return old;
end;' language 'plpgsql';

create or replace function forums_message_search__utrg ()
returns opaque as '
begin
    perform search_observer__enqueue(forums_message__root_message_id (old.message_id),''UPDATE'');
    return old;
end;' language 'plpgsql';


create trigger forums_message_search__itrg after insert on forums_messages
for each row execute procedure forums_message_search__itrg (); 

create trigger forums_message_search__dtrg after delete on forums_messages
for each row execute procedure forums_message_search__dtrg (); 

create trigger forums_message_search__utrg after update on forums_messages
for each row execute procedure forums_message_search__utrg (); 

