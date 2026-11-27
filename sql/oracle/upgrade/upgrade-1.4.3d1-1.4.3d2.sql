-- Separate image paste from general file attachments. Existing forums opt in.
alter table forums_forums modify attachments_allowed_p default 'f';

alter table forums_forums add image_paste_allowed_p char(1) default 'f' not null
    constraint forums_image_paste_allowed_ck check (image_paste_allowed_p in ('t','f'));

create or replace view forums_forums_enabled as
    select * from forums_forums where enabled_p = 't';
