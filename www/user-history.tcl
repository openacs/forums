ad_page_contract {
    
    Posting History for a User

    @author Ben Adida (ben@openforce.net)
    @creation-date 2002-05-29
    @cvs-id $Id$

} {
    user_id:object_type(user),notnull
    {view:word "date"}
    {groupby "forum_name"}
}

# Get username
set user_name [person::name -person_id $user_id]

set context [list [_ forums.Posting_History]]

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
