--
--  Copyright (C) 2001, 2002 MIT
--
--  This file is part of dotLRN.
--
--  dotLRN is free software; you can redistribute it and/or modify it under the
--  terms of the GNU General Public License as published by the Free Software
--  Foundation; either version 2 of the License, or (at your option) any later
--  version.
--
--  dotLRN is distributed in the hope that it will be useful, but WITHOUT ANY
--  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
--  FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
--  details.
--

--
-- Support for searching of forum messages
--
-- @author <a href="mailto:yon@openforce.net">yon@openforce.net</a>
-- @creation-date 2002-07-01
-- @version $Id$
--

-- IMPORTANT:
-- replace all instances of the string "yon" below this line with your schema
-- user and schema password accordingly. also, replace the "connect
-- ctxsys/ctxsys" statement with the appropriate values for your system. need
-- to figure out how to do this in a better way.

-- as normal user

drop function im_convert;
drop procedure im_convert_length_check;

declare
begin
    for row in (select job
                from user_jobs
                where what like '%yon.forums_content_idx%')
    loop
        dbms_job.remove(job => row.job);
    end loop;
end;
/
show errors

drop index forums_content_idx;

execute ctx_ddl.unset_attribute('forums_user_datastore', 'procedure');
execute ctx_ddl.drop_preference('forums_user_datastore');

-- as ctxsys
connect ctxsys/ctxsys;

drop procedure s_index_message;

-- as normal user
connect yon/yon;

drop procedure index_message;
