
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

select define_function_args('forums_forum__name','forum_id');

select define_function_args('forums_forum__delete','forum_id');


-- implementation

create function forums_forum__new (integer,varchar,varchar,varchar,varchar,varchar,integer,timestamp,integer,varchar,integer)
returns integer as '
DECLARE
	p_forum_id			alias for $1;
	p_object_type			alias for $2;
	p_name				alias for $3;
	p_charter			alias for $4;
	p_presentation_type		alias for $5;
	p_posting_policy		alias for $6;
	p_package_id			alias for $7;
	p_creation_date			alias for $8;
	p_creation_user			alias for $9;
	p_creation_ip			alias for $10;
	p_context_id			alias for $11;
	v_forum_id			integer;
BEGIN
	v_forum_id:= acs_object__new (
				     p_forum_id,
				     p_object_type,
				     p_creation_date,
				     p_creation_user,
				     p_creation_ip,
				     p_context_id);

        insert into forums_forums
        (forum_id, name, charter, presentation_type, posting_policy, package_id) values
        (v_forum_id, p_name, p_charter, p_presentation_type, p_posting_policy, p_package_id);

        select acs_object__update_last_modified(p_context_id);

	return v_forum_id;
END;
' language 'plpgsql';


create function forums_forum__name(integer)
returns varchar as '
DECLARE
	p_forum_id		alias for $1;
BEGIN
	return name from forums_forums where forum_id= p_forum_id;
END;
' language 'plpgsql';


create function forums_forum__delete(integer)
returns integer as '
DECLARE
	p_forum_id		alias for $1;
BEGIN
	perform acs_object__delete(p_forum_id);
	return 0;
END;
' language 'plpgsql';
