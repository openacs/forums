
--
-- The Forums Package
--
-- @author gwong@orchardlabs.com,ben@openforce.biz
-- @creation-date 2002-05-16
--
-- This code is newly concocted by Ben, but with heavy concepts and heavy code
-- chunks lifted from Gilbert. Thanks Orchard Labs.
--

-- privileges
declare
begin
   -- moderate and post are new privileges
   -- the rest are obvious inheritance
   -- forum creation on a package allows a user to create forums
   -- forum creation on a forum allows a user to create new threads
   acs_privilege.create_privilege('forum_create',null,null);
   acs_privilege.create_privilege('forum_write',null,null);
   acs_privilege.create_privilege('forum_delete',null,null);
   acs_privilege.create_privilege('forum_read',null,null);
   acs_privilege.create_privilege('forum_post',null,null);
   acs_privilege.create_privilege('forum_moderate',null,null);

   -- add children
   acs_privilege.add_child('create','forum_create');
   acs_privilege.add_child('write','forum_write');
   acs_privilege.add_child('delete','forum_delete');
   acs_privilege.add_child('admin','forum_moderate');
   acs_privilege.add_child('forum_moderate','forum_read');
   acs_privilege.add_child('forum_moderate','forum_post');
   acs_privilege.add_child('forum_write','forum_read');
   acs_privilege.add_child('forum_write','forum_post');
   
   -- the last one that will cause all the updates
   acs_privilege.add_child('read','forum_read');
end;
/
show errors


--
-- The Data Model
--

create table forums_forums (
       forum_id                 integer not null
                                constraint forums_forum_id_fk
                                references acs_objects(object_id)
                                constraint forums_forum_id_pk
                                primary key,
       name                     varchar(200) constraint forum_name_nn not null,
       charter                  varchar(2000),
       presentation_type        varchar(100) 
                                constraint forum_type_nn not null
                                constraint forum_type_ch
                                check (presentation_type in ('flat','threaded')),
       posting_policy           varchar(100)
                                constraint forum_policy_nn not null
                                constraint forum_policy_ch
                                check (posting_policy in ('open','moderated','closed')),
       max_child_sortkey        raw(100),
       enabled_p                char(1) default 't' not null
                                constraint forum_enabled_p_ch check
                                (enabled_p in ('t','f')),
       package_id               integer constraint forum_package_id_nn not null
);

create view forums_forums_enabled
as select * from forums_forums where enabled_p='t';

--
-- Object Type
--

declare
begin
        acs_object_type.create_type (
            supertype => 'acs_object',
            object_type => 'forums_forum',
            pretty_name => 'Forums Forum',
            pretty_plural => 'Forums Forums',
            table_name => 'forums_forums',
            id_column => 'forum_id',
            package_name => 'forums_forum',
            name_method => 'forums_forum.name'
        );
end;
/
show errors
