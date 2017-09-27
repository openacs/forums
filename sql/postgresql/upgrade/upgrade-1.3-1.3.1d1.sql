begin;

alter table forums_forums
      add column new_questions_allowed_p boolean default true not null;

drop view forums_forums_enabled;
create view forums_forums_enabled
as
    select *
    from forums_forums
    where enabled_p = true;

end;
