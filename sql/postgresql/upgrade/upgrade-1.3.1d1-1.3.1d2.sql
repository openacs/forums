begin;

alter table forums_forums
      add column anonymous_allowed_p boolean default false not null;

drop view forums_forums_enabled;
create view forums_forums_enabled
as
    select *
    from forums_forums
    where enabled_p = true;

end;
