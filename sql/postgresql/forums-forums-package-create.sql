
--
-- The Forums Package
--
-- @author gwong@orchardlabs.com,ben@openforce.biz
-- @creation-date 2002-05-16
--
-- The Package
--
-- This code is newly concocted by Ben, but with heavy concepts and heavy code
-- chunks lifted from Gilbert. Thanks Orchard Labs!
--

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

select define_function_args('forums_forum__name','forum_id');



--
-- procedure forums_forum__name/1
--
CREATE OR REPLACE FUNCTION forums_forum__name(
   p_forum_id integer
) RETURNS varchar AS $$
DECLARE
BEGIN
    return name from forums_forums where forum_id = p_forum_id;
END;

$$ LANGUAGE plpgsql;

select define_function_args('forums_forum__delete','forum_id');



--
-- procedure forums_forum__delete/1
--
CREATE OR REPLACE FUNCTION forums_forum__delete(
   p_forum_id integer
) RETURNS integer AS $$
DECLARE
BEGIN
    perform acs_object__delete(p_forum_id);
    return 0;
END;

$$ LANGUAGE plpgsql;
