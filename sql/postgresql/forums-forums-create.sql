
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
    -- moderate and post are new privileges
    -- the rest are obvious inheritance
    -- forum creation on a package allows a user to create forums
    -- forum creation on a forum allows a user to create new threads
    perform acs_privilege__create_privilege(''forum_create'',null,null);
    perform acs_privilege__create_privilege(''forum_write'',null,null);
    perform acs_privilege__create_privilege(''forum_delete'',null,null);
    perform acs_privilege__create_privilege(''forum_read'',null,null);
    perform acs_privilege__create_privilege(''forum_post'',null,null);
    perform acs_privilege__create_privilege(''forum_moderate'',null,null);

    -- temporarily drop this trigger to avoid a data-change violation 
    -- on acs_privilege_hierarchy_index while updating the child privileges.

    drop trigger acs_priv_hier_ins_del_tr on acs_privilege_hierarchy;

    -- add children
    perform acs_privilege__add_child(''create'',''forum_create'');
    perform acs_privilege__add_child(''write'',''forum_write'');
    perform acs_privilege__add_child(''delete'',''forum_delete'');
    perform acs_privilege__add_child(''admin'',''forum_moderate'');
    perform acs_privilege__add_child(''forum_moderate'',''forum_read'');
    perform acs_privilege__add_child(''forum_moderate'',''forum_post'');
    perform acs_privilege__add_child(''forum_write'',''forum_read'');
    perform acs_privilege__add_child(''forum_write'',''forum_post'');
    
    -- re-enable the trigger before the last insert to force the 
    -- acs_privilege_hierarchy_index table to be updated.

    create trigger acs_priv_hier_ins_del_tr after insert or delete
    on acs_privilege_hierarchy for each row
    execute procedure acs_priv_hier_ins_del_tr ();

    -- the last one that will cause all the updates
    perform acs_privilege__add_child(''read'',''forum_read'');

    return null;
end;' language 'plpgsql';

select inline_0();
drop function inline_0 ();

create table forums_forums (
    forum_id                        integer
                                    constraint forums_forum_id_nn
                                    not null
                                    constraint forums_forum_id_fk
                                    references acs_objects (object_id)
                                    constraint forums_forum_id_pk
                                    primary key,
    name                            varchar(200)
                                    constraint forums_name_nn
                                    not null,
    charter                         varchar(2000),
    presentation_type               varchar(100) 
                                    constraint forums_presentation_type_nn
                                    not null
                                    constraint forums_presentation_type_ck
                                    check (presentation_type in ('flat','threaded')),
    posting_policy                  varchar(100)
                                    constraint forums_posting_policy_nn
                                    not null
                                    constraint forums_posting_policy_ck
                                    check (posting_policy in ('open','moderated','closed')),
    max_child_sortkey               varbit,
    enabled_p                       char(1)
                                    default 't'
                                    constraint forums_enabled_p_nn
                                    not null
                                    constraint forums_enabled_p_ck
                                    check (enabled_p in ('t','f')),
    package_id                      integer
                                    constraint forums_package_id_nn
                                    not null
);

create view forums_forums_enabled
as
    select *
    from forums_forums
    where enabled_p = 't';

create function inline_0 ()
returns integer as'
begin
    perform acs_object_type__create_type(
        ''forums_forum'',
        ''Forums Forum'',
        ''Forums Forums'',
        ''acs_object'',
        ''forums_forums'',
        ''forum_id'',
        ''forums_forum'',
        ''f'',
        null,
        ''forums_forum__name''
    );

    return null;
end;' language 'plpgsql';

select inline_0();
drop function inline_0();
