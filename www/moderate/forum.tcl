ad_page_contract {

    Moderate a Forum

    @author Ben Adida (ben@openforce.net)
    @creation-date 2002-05-24
    @cvs-id $Id$

} {
    forum_id:object_type(forums_forum),notnull
}

# Check that the user can moderate the forum
forum::security::require_moderate_forum -forum_id $forum_id

# Get forum data
forum::get -forum_id $forum_id -array forum

ad_return_template

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
