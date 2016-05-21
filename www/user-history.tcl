ad_page_contract {
    
    Posting History for a User

    @author Ben Adida (ben@openforce.net)
    @creation-date 2002-05-29
    @cvs-id $Id$

} {
    user_id:naturalnum,notnull
    {view:word "date"}
    {groupby "forum_name"}
} -validate {
    valid_user -requires user_id {
        if {![person::person_p -party_id $user_id]} {
            ad_complain "Invalid user_id"
        }
    }
}

# Get user information
acs_user::get -user_id $user_id -array user

set context [list [_ forums.Posting_History]]

ad_return_template

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
