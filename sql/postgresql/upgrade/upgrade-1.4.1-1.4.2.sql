-- Add names only to signatures verified against the current install SQL.
-- Prefix names to avoid collisions with the aliases in legacy bodies.
do $$
declare
    target record;
    definition text;
begin
    for target in
        with expected(function_name, input_types, input_names) as (
            values
            ('forums_forum__delete', 'integer', 'forum_id'),
            ('forums_forum__name', 'integer', 'forum_id'),
            ('forums_message__delete', 'integer', 'message_id'),
            ('forums_message__delete_thread', 'integer', 'message_id'),
            ('forums_message__name', 'integer', 'message_id'),
            ('forums_message__new', 'integer,varchar,integer,varchar,text,character,integer,varchar,integer,timestamptz,integer,varchar,integer', 'message_id,object_type,forum_id,subject,content,format,user_id,state,parent_id,creation_date,creation_user,creation_ip,context_id'),
            ('forums_message__root_message_id', 'integer', 'message_id'),
            ('forums_message__set_state', 'integer,varchar', 'message_id,state'),
            ('forums_message__thread_close', 'integer', 'message_id'),
            ('forums_message__thread_open', 'integer', 'message_id')
        )
        select p.oid, n.nspname, p.proname, arguments.signature
          from expected e
          join pg_proc p on p.oid = to_regprocedure(
              format('%I.%I(%s)', current_schema(), e.function_name, e.input_types))
          join pg_namespace n on n.oid = p.pronamespace
          cross join lateral (
              select string_agg(
                         format('%I %s', 'arg_' || a.arg_name, format_type(a.type_oid, null)),
                         ', ' order by a.position) as signature
                from unnest(p.proargtypes::oid[], string_to_array(e.input_names, ','))
                     with ordinality as a(type_oid, arg_name, position)
          ) arguments
         where p.prokind = 'f'
           and p.proargnames is null
           and p.proargmodes is null
           and p.pronargdefaults = 0
           and p.pronargs = cardinality(string_to_array(e.input_names, ','))
           and p.pronargs = (
               select count(*) from acs_function_args a
                where a.function = upper(e.function_name)
           )
           and not exists (
               select 1 from acs_function_args a
                where a.function = upper(e.function_name)
                  and (a.arg_seq < 1 or a.arg_seq > p.pronargs)
           )
           and e.input_names = (
               select string_agg(lower(a.arg_name), ',' order by a.arg_seq)
                 from acs_function_args a
                where a.function = upper(e.function_name)
           )
           and not exists (
               select 1 from pg_proc other
                where other.proname = p.proname
                  and other.pronargs = p.pronargs
                  and other.oid <> p.oid
           )
    loop
        definition := pg_get_functiondef(target.oid);
        execute format('CREATE OR REPLACE FUNCTION %I.%I(%s)',
                       target.nspname, target.proname, target.signature)
                || substr(definition, strpos(definition, chr(10)));
    end loop;
end;
$$;
