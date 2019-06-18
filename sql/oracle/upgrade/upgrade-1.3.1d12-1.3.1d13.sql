--
-- Add column 'attachments_allowed_p' to 'forums_forums', to be used to allow/disallow attachments on a per forum basis.
--

begin;

alter table forums_forums
    add attachments_allowed_p char(1)
    default 't'
    constraint forums_attachments_allowed_p_nn
    not null
    constraint forums_attachments_allowed_p_ck
    check (attachments_allowed_p in ('t','f'));

end;
