---
--- add markdown to list of constraints (which is currently just
--- relevant for upgrades, since new installations did not have this
--- constraint.
--- 
ALTER TABLE forums_messages
      DROP constraint IF EXISTS forums_mess_format_ck;

ALTER TABLE forums_messages
      ADD constraint forums_mess_format_ck check (format in ('text/enhanced', 'text/markdown', 'text/plain', 'text/fixed-width', 'text/html'));

