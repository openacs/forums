ad_page_contract {

    one forum view

    @author Andreas Benisch (andreas.benisch@wu-wien.ac.at)
    @creation-date 2004-09-06

} {
    forum_id:naturalnum,notnull
}

    set user_id [ad_conn user_id]
    set db_antwort [db_exec_plsql forums_reading_info__user_add_forum {}]


ad_returnredirect forum-view?forum_id=$forum_id

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
