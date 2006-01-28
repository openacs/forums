--
-- The Forums Package
--
-- @author gwong@orchardlabs.com,ben@openforce.biz
-- @creation-date 2002-05-16
--
-- This code is newly concocted by Ben, but with significant concepts and code
-- lifted from Gilbert's UBB forums. Thanks Orchard Labs.
--

create function inline_0 ()
returns integer as '
declare
    row                             record;
begin
    for row in select nt.type_id
               from notification_types nt
               where nt.short_name in (''forums_forum_notif'', ''forums_message_notif'')
    loop
        perform notification_type__delete(row.type_id);
    end loop;

    return null;
end;' language 'plpgsql';

select inline_0();
drop function inline_0 ();
