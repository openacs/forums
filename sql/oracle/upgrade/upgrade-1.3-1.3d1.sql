begin;

alter table forums_forums
      add column new_questions_allowed_p char(1)
                                    default 't'
                                    constraint forums_new_questions_allowed_p_nn
                                    not null
                                    constraint forums_new_questions_allowed_p_ck
                                    check (enabled_p in ('t','f'));

drop view forums_forums_enabled;
create view forums_forums_enabled
as
    select *
    from forums_forums
    where enabled_p = true;

end;
