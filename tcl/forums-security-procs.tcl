ad_library {

    Forums Security Library

    @creation-date 2002-05-25
    @author Ben Adida <ben@openforce.biz>
    @cvs-id $Id$

}

namespace eval forum::security {

    ad_proc -public can_read_forum_p {
        {-user_id ""}
        {-forum_id:required}
    } {
        # hack
        return 1
    }

    ad_proc -public require_read_forum {
        {-user_id ""}
        {-forum_id:required}
    } {

    }

    ad_proc -public can_read_message_p {
        {-user_id ""}
        {-message_id:required}
    } {
        # hack
        return 1
    }

    ad_proc -public require_read_message {
        {-user_id ""}
        {-message_id:required}
    } {

    }

    ad_proc -public can_post_forum_p {
        {-user_id ""}
        {-forum_id:required}
    } {
        return [permission::permission_p -object_id $forum_id \
                -party_id $user_id \
                -privilege forum_create]
    }

    ad_proc -public require_post_forum {
        {-user_id ""}
        {-forum_id:required}
    } {

    }

    ad_proc -public can_post_message_p {
        {-user_id ""}
        {-message_id:required}
    } {
        # hack
        return 1
    }

    ad_proc -public require_post_message {
        {-user_id ""}
        {-message_id:required}
    } {

    }

    ad_proc -public can_moderate_forum_p {
        {-user_id ""}
        {-forum_id:required}
    } {
        # hack
        return 1
    }

    ad_proc -public require_moderate_forum {
        {-user_id ""}
        {-forum_id:required}
    } {

    }

    ad_proc -public can_moderate_message_p {
        {-user_id ""}
        {-message_id:required}
    } {
        # hack
        return 1
    }

    ad_proc -public require_moderate_message {
        {-user_id ""}
        {-message_id:required}
    } {

    }

    ad_proc -public can_admin_forum_p {
        {-user_id ""}
        {-forum_id:required}
    } {
        # hack
        return 1
    }

    ad_proc -public require_admin_forum {
        {-user_id ""}
        {-forum_id:required}
    } {

    }
}
