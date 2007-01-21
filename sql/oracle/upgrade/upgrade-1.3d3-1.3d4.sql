-- Make sure that forums actually have the package_id set.
update acs_objects set package_id = context_id where object_type = 'forums_forum';