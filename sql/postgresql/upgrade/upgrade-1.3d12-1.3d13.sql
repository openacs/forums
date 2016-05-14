--
-- Alter caveman style booleans (type character(1)) to real SQL boolean types.
--

ALTER TABLE forums_forums
      DROP constraint forums_enabled_p_ck,
      ALTER COLUMN enabled_p DROP DEFAULT,
      ALTER COLUMN enabled_p TYPE boolean
      USING enabled_p::boolean,
      ALTER COLUMN enabled_p SET DEFAULT true;

ALTER TABLE forums_messages
      DROP constraint forum_mess_open_p_ck,
      ALTER COLUMN enabled_p DROP DEFAULT,
      ALTER COLUMN enabled_p TYPE boolean
      USING enabled_p::boolean,
      ALTER COLUMN enabled_p SET DEFAULT true;

