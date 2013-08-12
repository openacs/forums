-- Update the package ids for projects


--
-- procedure inline_0/0
--
CREATE OR REPLACE FUNCTION inline_0(

) RETURNS integer AS $$
DECLARE
    ct RECORD;
BEGIN
  for ct in select package_id, forum_id from forums_forums
  loop
	update acs_objects set package_id = ct.package_id where object_id = ct.forum_id;
  end loop;

  return null;
END;
$$ LANGUAGE plpgsql;

select inline_0();
drop function inline_0();
