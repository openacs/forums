ad_page_contract {

    one forum view

    @author Andreas Benisch (andreas.benisch@wu-wien.ac.at)
    @creation-date 2004-09-06

} {
    forum_id:object_type(forums_forum),notnull
}

set user_id [ad_conn user_id]

db_dml forums_reading_info_user_add_forum {
    insert into forums_reading_info (
                                     root_message_id,
                                     user_id,
                                     forum_id
                                     )
    select message_id, :user_id, m.forum_id
    from forums_messages_approved m
    where m.forum_id = :forum_id
      and m.parent_id is null
      and not exists (select 1 from forums_reading_info
                       where user_id = :user_id
                         and root_message_id = m.message_id)
}


ad_returnredirect forum-view?forum_id=$forum_id
ad_script_abort

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
