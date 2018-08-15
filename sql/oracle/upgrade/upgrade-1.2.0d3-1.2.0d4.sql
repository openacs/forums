-- 
-- packages/forums/sql/oracle/upgrade/upgrade-1.2.0d3-1.2.0d4.sql
-- 
-- @author Deds Castillo (deds@i-manila.com.ph)
-- @creation-date 2006-05-10
-- @cvs-id $Id$
--

-- increase charter to 4000 chars

alter table forums_forums modify charter varchar(4000);
