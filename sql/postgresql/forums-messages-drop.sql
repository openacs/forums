--
-- The Forums Package
--
-- @author gwong@orchardlabs.com,ben@openforce.biz
-- @creation-date 2002-05-16
--
-- This code is newly concocted by Ben, but with significant concepts and code
-- lifted from Gilbert. Thanks Orchard Labs!
--

drop view forums_messages_pending;
drop view forums_messages_approved;
drop table forums_messages;

CREATE OR REPLACE FUNCTION inline_0 () RETURNS integer AS $$
BEGIN
    perform acs_object_type__drop_type (
        'forums_message', 'f'
    );

    return null;
END;
$$ LANGUAGE plpgsql;

select inline_0();
drop function inline_0 ();
