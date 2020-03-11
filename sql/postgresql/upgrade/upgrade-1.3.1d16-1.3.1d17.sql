begin;

drop view forums_forums_enabled;

ALTER TABLE forums_forums ALTER column charter TYPE text;

create view forums_forums_enabled
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
           last_post
 from forums_forums
    where enabled_p = true;

end;
