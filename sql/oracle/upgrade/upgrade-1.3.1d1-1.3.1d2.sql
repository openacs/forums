begin;

alter table forums_forums
      add anonymous_allowed_p char(1)
                                    default 'f'
                                    constraint forums_anonymous_allowed_p_nn
                                    not null
                                    constraint forums_anonymous_allowed_p_ck
                                    check (anonymous_allowed_p in ('t','f'));

alter table forums_forums
      column new_questions_allowed_p char(1)
                                    default 't'
                                    constraint forums_new_questions_allowed_p_nn
                                    not null
                                    constraint forums_new_questions_allowed_p_ck
                                    check (new_questions_allowed_p in ('t','f'));

drop view forums_forums_enabled;

create view forums_forums_enabled
as
    select *
    from forums_forums
    where enabled_p = 't';

end;
