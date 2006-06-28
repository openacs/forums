update acs_permissions
 set privilege = 'read'
 where privilege = 'forum_read';

update acs_permissions
 set privilege = 'write'
 where privilege = 'forum_write';

update acs_permissions
 set privilege = 'create'
 where privilege = 'forum_create';