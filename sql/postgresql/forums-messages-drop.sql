
--
-- The Forums Package
--
-- @author gwong@orchardlabs.com,ben@openforce.biz
-- @creation-date 2002-05-16
--
-- This code is newly concocted by Ben, but with significant concepts and code
-- lifted from Gilbert. Thanks Orchard Labs!
--

-- privileges
-- NO PRIVILEGES FOR MESSAGES
-- we don't individually permission messages

--
-- The Data Model
--

drop table forums_messages;

--
-- Object Type
--

begin
        select acs_object_type__drop_type (
            'forums_message', 'f'
        );
end;
