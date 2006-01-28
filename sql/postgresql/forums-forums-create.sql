
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
begin
   -- moderate and post are new privileges
   -- the rest are obvious inheritance
   -- forum creation on a package allows a user to create forums
   -- forum creation on a forum allows a user to create new threads
   select acs_privilege__create_privilege('forum_create',null,null);
   select acs_privilege__create_privilege('forum_write',null,null);
   select acs_privilege__create_privilege('forum_delete',null,null);
   select acs_privilege__create_privilege('forum_read',null,null);
   select acs_privilege__create_privilege('forum_post',null,null);
   select acs_privilege__create_privilege('forum_moderate',null,null);

   -- temporarily drop this trigger to avoid a data-change violation 
   -- on acs_privilege_hierarchy_index while updating the child privileges.

   drop trigger acs_priv_hier_ins_del_tr on acs_privilege_hierarchy;

   -- add children
   select acs_privilege__add_child('create','forum_create');
   select acs_privilege__add_child('write','forum_write');
   select acs_privilege__add_child('delete','forum_delete');
   select acs_privilege__add_child('admin','forum_moderate');
   select acs_privilege__add_child('forum_moderate','forum_read');
   select acs_privilege__add_child('forum_moderate','forum_post');
   select acs_privilege__add_child('forum_write','forum_read');
   select acs_privilege__add_child('forum_write','forum_post');
   
   -- re-enable the trigger before the last insert to force the 
   -- acs_privilege_hierarchy_index table to be updated.

   create trigger acs_priv_hier_ins_del_tr after insert or delete
   on acs_privilege_hierarchy for each row
   execute procedure acs_priv_hier_ins_del_tr ();

   -- the last one that will cause all the updates
   select acs_privilege__add_child('read','forum_read');
end;


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
       max_child_sortkey        varbit,
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

begin
        select acs_object_type__create_type (
            'forums_forum',
            'Forums Forum',
            'Forums Forums',
            'acs_object',
            'forums_forums',
            'forum_id',
            'forums_forum',
	    'f',
	    NULL,
	    'forums_forum__name'
        );
end;
