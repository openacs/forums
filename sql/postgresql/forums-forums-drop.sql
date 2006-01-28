
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
   -- temporarily drop this trigger to avoid a data-change violation 
   -- on acs_privilege_hierarchy_index while updating the child privileges.

   drop trigger acs_priv_hier_ins_del_tr on acs_privilege_hierarchy;

   -- remove children
   select acs_privilege__remove_child('read','forum_read');
   select acs_privilege__remove_child('create','forum_create');
   select acs_privilege__remove_child('write','forum_write');
   select acs_privilege__remove_child('delete','forum_delete');
   select acs_privilege__remove_child('admin','forum_moderate');
   select acs_privilege__remove_child('forum_moderate','forum_read');
   select acs_privilege__remove_child('forum_moderate','forum_post');
   select acs_privilege__remove_child('forum_write','forum_read');

   -- reenable for trigger update
   create trigger acs_priv_hier_ins_del_tr after insert or delete
   on acs_privilege_hierarchy for each row
   execute procedure acs_priv_hier_ins_del_tr ();

   select acs_privilege__remove_child('forum_write','forum_post');
   
   select acs_privilege__drop_privilege('forum_moderate');
   select acs_privilege__drop_privilege('forum_post');
   select acs_privilege__drop_privilege('forum_read');
   select acs_privilege__drop_privilege('forum_create');
   select acs_privilege__drop_privilege('forum_write');
   select acs_privilege__drop_privilege('forum_delete');
end;


--
-- The Data Model
--

drop table forums_forums;

--
-- Object Type
--

begin
        select acs_object_type__drop_type (
            'forums_forum', 'f'
        );
end;
