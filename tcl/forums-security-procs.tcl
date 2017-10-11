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
        return [permission::permission_p -party_id $user_id -object_id $forum_id -privilege read]
    }

    ad_proc -public require_read_forum {
        {-user_id ""}
        {-forum_id:required}
    } {
        if {![can_read_forum_p -user_id $user_id -forum_id $forum_id]} {
            do_abort
        }
    }

    ad_proc -public can_post_forum_p {
        {-user_id ""}
        {-forum_id:required}
    } {
        if {[ad_conn user_id] == 0} {
            return false
        } elseif {[can_moderate_forum_p \
                       -forum_id $forum_id \
                       -user_id  $user_id]} {
            return true
        } else {
            forum::get -forum_id $forum_id -array forum
            return [expr {$forum(posting_policy) ne "closed"}]
        }
    }

    ad_proc -public require_post_forum {
        {-user_id ""}
        {-forum_id:required}
    } {
        if {![can_post_forum_p -user_id $user_id -forum_id $forum_id]} {
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

    ad_proc -public permissions {
        {-forum_id:required}
        {-user_id ""}
        array_name
    } {
        upvar $array_name array

        set array(admin_p)    [forum::security::can_moderate_forum_p -forum_id $forum_id]
        set array(moderate_p) $array(admin_p)
        set array(post_p)     [expr {$array(admin_p) || [forum::security::can_post_forum_p -forum_id $forum_id -user_id $user_id]}]
    }    

    ### Deprecated procs ###
    # 2017-09-26:    
    # we decided to simplify forums management and unwire dependency
    # with the registered_users group. This prevented forums package
    # to be ever used in a subsite aware context. Now posting policy
    # and new-threads-allowed won't be managed via setting
    # permsissions, but through plain table columns. Forum will also
    # decide for permissions on the messages.
    
    ad_proc -deprecated -public can_read_message_p {
        {-user_id ""}
        {-message_id:required}
    } {
        forum::message::get -message_id $message_id -array message
        return [can_read_forum_p -forum_id $message(forum_id) -user_id $user_id]
    }

    ad_proc -deprecated -public require_read_message {
        {-user_id ""}
        {-message_id:required}
    } {
        forum::message::get -message_id $message_id -array message
        return [require_read_forum -forum_id $message(forum_id) -user_id $user_id]
    }
    
    ad_proc -deprecated -public can_post_message_p {
        {-user_id ""}
        {-message_id:required}
    } {
        forum::message::get -message_id $message_id -array message
        return [can_post_forum_p -forum_id $message(forum_id) -user_id $user_id]
    }

    ad_proc -deprecated -public require_post_message {
        {-user_id ""}
        {-message_id:required}
    } {
        forum::message::get -message_id $message_id -array message
        return [require_post_forum -forum_id $message(forum_id) -user_id $user_id]
    }

    ad_proc -deprecated -public can_moderate_message_p {
        {-user_id ""}
        {-message_id:required}
    } {
        forum::message::get -message_id $message_id -array message
        return [can_moderate_forum_p -forum_id $message(forum_id) -user_id $user_id]
    }

    ad_proc -deprecated -public require_moderate_message {
        {-user_id ""}
        {-message_id:required}
    } {
        forum::message::get -message_id $message_id -array message        
        return [require_moderate_forum -forum_id $message(forum_id) -user_id $user_id]
    }

    # admin == moderate!
    ad_proc -deprecated -public can_admin_forum_p {
        {-user_id ""}
        {-forum_id:required}
    } {
        return [can_moderate_p -user_id $user_id -forum_id $forum_id]
    }

    ad_proc -deprecated -public require_admin_forum {
        {-user_id ""}
        {-forum_id:required}
    } {
        if {![can_moderate_forum_p -user_id $user_id -forum_id $forum_id]} {
            do_abort
        }
    }

    ###
}

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
