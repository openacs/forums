--
-- The Forums Package
--
-- @author David Arroyo darroyo@innova.uned.es
-- @creation-date 01-06-2007
-- @version $Id$
--
-- This is free software distributed under the terms of the GNU Public
-- License version 2 or later.  Full text of the license is available from the GNU Project:
-- http://www.fsf.org/copyleft/gpl.html

drop function forums_reading_info__move_thread_update (integer,integer);
drop function forums_reading_info__user_add_msg (integer,integer);
drop function forums_reading_info__user_add_forum (integer,integer);
drop function forums_reading_info__remove_msg (integer);
drop view forums_reading_info_user;
drop table forums_reading_info;
