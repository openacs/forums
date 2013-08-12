-- Make sure that forums actually have the package_id set.
update acs_objects set package_id = context_id where object_type = 'forums_forum';

-- And now rewrite the new function as old installations will not have this updated version that stores the package_id
select define_function_args('forums_forum__new','forum_id,object_type;forums_forum,name,charter,presentation_type,posting_policy,package_id,creation_date,creation_user,creation_ip,context_id');



--
-- procedure forums_forum__new/11
--
CREATE OR REPLACE FUNCTION forums_forum__new(
   p_forum_id integer,
   p_object_type varchar, -- default 'forums_forum'
   p_name varchar,
   p_charter varchar,
   p_presentation_type varchar,
   p_posting_policy varchar,
   p_package_id integer,
   p_creation_date timestamptz,
   p_creation_user integer,
   p_creation_ip varchar,
   p_context_id integer

) RETURNS integer AS $$
DECLARE
    v_forum_id                      integer;
BEGIN
    v_forum_id:= acs_object__new(
        p_forum_id,
        p_object_type,
        p_creation_date,
        p_creation_user,
        p_creation_ip,
        coalesce(p_context_id, p_package_id),
        't',
        p_name,
        p_package_id
    );

    insert into forums_forums
    (forum_id, name, charter, presentation_type, posting_policy, package_id)
    values
    (v_forum_id, p_name, p_charter, p_presentation_type, p_posting_policy, p_package_id);

    return v_forum_id;
END;

$$ LANGUAGE plpgsql;
