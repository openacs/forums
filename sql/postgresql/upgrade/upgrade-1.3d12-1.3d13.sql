--
-- Alter caveman style booleans (type character(1)) to real SQL boolean types.
--

drop view if exists forums_forums_enabled;
drop view if exists forums_messages_pending;
drop view if exists forums_messages_approved;

ALTER TABLE forums_forums
      DROP constraint IF EXISTS forums_enabled_p_ck,
      ALTER COLUMN enabled_p DROP DEFAULT,
      ALTER COLUMN enabled_p TYPE boolean
      USING enabled_p::boolean,
      ALTER COLUMN enabled_p SET DEFAULT true;

ALTER TABLE forums_messages
      DROP constraint IF EXISTS forum_mess_open_p_ck,
      ALTER COLUMN open_p DROP DEFAULT,
      ALTER COLUMN open_p TYPE boolean
      USING open_p::boolean,
      ALTER COLUMN open_p SET DEFAULT true;

create view forums_forums_enabled
as
    select *
    from forums_forums
    where enabled_p = true;

create or replace view forums_messages_pending
as
    select *
    from forums_messages
    where state= 'pending';
    
create or replace view forums_messages_approved
as
    select *
    from forums_messages
    where state = 'approved';
