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

create function inline_0 ()
returns integer as '
begin
    -- temporarily drop this trigger to avoid a data-change violation 
    -- on acs_privilege_hierarchy_index while updating the child privileges.
    drop trigger acs_priv_hier_ins_del_tr on acs_privilege_hierarchy;

    -- remove children
    perform acs_privilege__remove_child(''read'',''forum_read'');
    perform acs_privilege__remove_child(''create'',''forum_create'');
    perform acs_privilege__remove_child(''write'',''forum_write'');
    perform acs_privilege__remove_child(''delete'',''forum_delete'');
    perform acs_privilege__remove_child(''admin'',''forum_moderate'');
    perform acs_privilege__remove_child(''forum_moderate'',''forum_read'');
    perform acs_privilege__remove_child(''forum_moderate'',''forum_post'');
    perform acs_privilege__remove_child(''forum_write'',''forum_read'');

    -- reenable for trigger update
    create trigger acs_priv_hier_ins_del_tr after insert or delete
    on acs_privilege_hierarchy for each row
    execute procedure acs_priv_hier_ins_del_tr ();

    perform acs_privilege__remove_child(''forum_write'',''forum_post'');
    
    perform acs_privilege__drop_privilege(''forum_moderate'');
    perform acs_privilege__drop_privilege(''forum_post'');
    perform acs_privilege__drop_privilege(''forum_read'');
    perform acs_privilege__drop_privilege(''forum_create'');
    perform acs_privilege__drop_privilege(''forum_write'');
    perform acs_privilege__drop_privilege(''forum_delete'');

    return null;
end;' language 'plpgsql';

select inline_0();
drop function inline_0 ();

drop view forums_forums_enabled;
drop table forums_forums;

create function inline_0 ()
returns integer as '
begin
    perform acs_object_type__drop_type (
        ''forums_forum'', ''f''
    );

    return null;
end;' language 'plpgsql';

select inline_0();
drop function inline_0 ();
