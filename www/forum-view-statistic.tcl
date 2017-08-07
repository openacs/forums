ad_page_contract {
    
    Forums History 

    @author Natalia Pérez (nperper@it.uc3m.es)
    @creation-date 2005-03-17    

} {
    forum_id:naturalnum,notnull    
}

# Get user information
db_1row get_forum_name "select name from forums_forums where forum_id= :forum_id"
set context [list [_ forums.Forums_History]]

ad_return_template

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
