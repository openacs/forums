ad_library {

    Forums Security Library

    @creation-date 2002-05-25
    @author Ben Adida <ben@openforce.biz>
    @cvs-id $Id$

}

namespace eval forum::security {

    ad_proc -private do_abort {} {
        do an abort if security violation
    } {
        if { [ad_conn user_id] == 0 } { 
            ad_redirect_for_registration
        } else {
            ad_returnredirect "not-allowed"
        }
        ad_script_abort
    }    

    ad_proc -public can_read_forum_p {
        {-user_id ""}
        {-forum_id:required}
    } {
        return [permission::permission_p -party_id $user_id -object_id $forum_id -privilege forum_read]
    }

    ad_proc -public require_read_forum {
        {-user_id ""}
        {-forum_id:required}
    } {
        if {![can_read_forum_p -user_id $user_id -forum_id $forum_id]} {
            do_abort
        }
    }

    ad_proc -public can_read_message_p {
        {-user_id ""}
        {-message_id:required}
    } {
        return [permission::permission_p -party_id $user_id -object_id $message_id -privilege forum_read]
    }

    ad_proc -public require_read_message {
        {-user_id ""}
        {-message_id:required}
    } {
        if {![can_read_message_p -user_id $user_id -message_id $message_id]} {
            do_abort
        }
    }

    ad_proc -public can_post_forum_p {
        {-user_id ""}
        {-forum_id:required}
    } {
        return [permission::permission_p -party_id $user_id -object_id $forum_id -privilege forum_create]
    }

    ad_proc -public require_post_forum {
        {-user_id ""}
        {-forum_id:required}
    } {
        if {![can_post_forum_p -user_id $user_id -forum_id $forum_id]} {
            do_abort
        }
    }

    ad_proc -public can_post_message_p {
        {-user_id ""}
        {-message_id:required}
    } {
        return [permission::permission_p -party_id $user_id -object_id $message_id -privilege forum_write]
    }

    ad_proc -public require_post_message {
        {-user_id ""}
        {-message_id:required}
    } {
        if {![can_post_message_p -user_id $user_id -message_id $message_id]} {
            do_abort
        }
    }

    ad_proc -public can_moderate_forum_p {
        {-user_id ""}
        {-forum_id:required}
    } {
        return [permission::permission_p -party_id $user_id -object_id $forum_id -privilege forum_moderate]
    }

    ad_proc -public require_moderate_forum {
        {-user_id ""}
        {-forum_id:required}
    } {
        if {![can_moderate_forum_p -user_id $user_id -forum_id $forum_id]} {
            do_abort
        }
    }

    ad_proc -public can_moderate_message_p {
        {-user_id ""}
        {-message_id:required}
    } {
        return [permission::permission_p -party_id $user_id -object_id $message_id -privilege forum_moderate]
    }

    ad_proc -public require_moderate_message {
        {-user_id ""}
        {-message_id:required}
    } {
        if {![can_moderate_message_p -user_id $user_id -message_id $message_id]} {
            do_abort
        }
    }

    ad_proc -public can_admin_forum_p {
        {-user_id ""}
        {-forum_id:required}
    } {
        return [permission::permission_p -party_id $user_id -object_id $forum_id -privilege forum_moderate]
    }

    ad_proc -public require_admin_forum {
        {-user_id ""}
        {-forum_id:required}
    } {
        if {![can_admin_forum_p -user_id $user_id -forum_id $forum_id]} {
            do_abort
        }
    }

}



