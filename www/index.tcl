
ad_page_contract {

    List of Forums

    @author Ben Adida (ben@openforce)
    @creation-date 2002-05-24
    @cvs-id $Id$
} {
}

set package_id [ad_conn package_id]

set user_id [ad_verify_and_get_user_id]
set admin_p [ad_permission_p $package_id admin]

db_multirow forums forums_select {
    select forum_id, name, posting_policy
      from forums_forums_enabled
      where package_id = :package_id
      and 
      (posting_policy= 'open' or posting_policy= 'moderated' or
      acs_permission.permission_p(:user_id, forum_id, 'forum_read') ='t')
    order by name
}

set context_bar ""

ad_return_template
