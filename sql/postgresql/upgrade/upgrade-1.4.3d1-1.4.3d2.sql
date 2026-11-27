-- Separate image paste from general file attachments. Existing forums opt in.
alter table forums_forums alter column attachments_allowed_p set default false;

alter table forums_forums add column image_paste_allowed_p boolean default false not null;

create or replace view forums_forums_enabled
as
    select forum_id,
           name,
           charter,
           presentation_type,
           posting_policy,
           max_child_sortkey,
           enabled_p,
           new_questions_allowed_p,
           anonymous_allowed_p,
           attachments_allowed_p,
           package_id,
           thread_count,
           approved_thread_count,
           forums_forums,
           last_post,
           image_paste_allowed_p
 from forums_forums
    where enabled_p = true;
