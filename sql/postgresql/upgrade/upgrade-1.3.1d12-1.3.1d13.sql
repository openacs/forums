--
-- Add column 'attachments_allowed_p' to 'forums_forums', to be used to allow/disallow attachments on a per forum basis.
--

begin;

alter table forums_forums
      add column attachments_allowed_p boolean default true not null;

end;
