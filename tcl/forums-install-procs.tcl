ad_library {
    Forums install callbacks

    @creation-date 2004-04-01
    @author Jeff Davis davis@xarg.net
    @cvs-id $Id$
}

namespace eval forum::install {}

ad_proc -private forum::install::package_install {} { 
    package install callback
} {
    # Since before 5.5, search is implemented using callbacks. New
    # installations will not register search service contract
    # implementations. See forums-callback-procs.
    # forum::sc::register_implementations

    # Create notification types
    forum::install::create_notification_types
}

ad_proc -private forum::install::package_uninstall {} { 
    package uninstall callback
} {
    # Since before 5.5, search is implemented using callbacks. New
    # installations will not register search service contract
    # implementations. See forums-callback-procs.
    # forum::sc::unregister_implementations

    # Delete notification types
    forum::install::delete_notification_types
}

ad_proc -private forum::install::package_upgrade {
    {-from_version_name:required}
    {-to_version_name:required}
} {
    Package before-upgrade callback
} {
    apm_upgrade_logic \
        -from_version_name $from_version_name \
        -to_version_name $to_version_name \
        -spec {
            1.1d3 1.1d4 {
                # just need to install the forum_forum callback
                # This proc is deprecated, so we just skip it
                # See acs-api-browser.graph__bad_calls automated test
                # forum::sc::register_forum_fts_impl
            }
            1.3.1d17 1.3.1d18 {
                # Unregister search service contract implementation
                # and rely on callbacks from now on.
                forum::sc::unregister_implementations
            }
            1.3.1d18 1.4.0d1 {
                ## Forum moderator notifications
                forum::install::create_moderator_notification_types
            }
        }
}

ad_proc -private forum::install::create_notification_types {} {
    Create the Forum Notification types used to notify users of forum
    changes.
} {
    ## Forum user notifications
    forum::install::create_user_notification_types

    ## Forum moderator notifications
    forum::install::create_moderator_notification_types
}

ad_proc -private forum::install::create_user_notification_types {} {
    Create the Forum Notification types used to notify users of forum
    changes.
} {
    # Entire forum
    set spec {
        contract_name "NotificationType"
        owner "forums"
        name "forums_forum_notif_type"
        pretty_name "forums_forum_notif_type"
        aliases {
            GetURL       forum::notification::get_url
            ProcessReply forum::notification::process_reply
        }
    }
    set sc_impl_id [acs_sc::impl::new_from_spec -spec $spec]

    set type_id [notification::type::new \
                     -sc_impl_id $sc_impl_id \
                     -short_name "forums_forum_notif" \
                     -pretty_name "Forum Notification" \
                     -description "Notifications for Entire Forums"]

    # Enable the various intervals and delivery methods
    db_dml insert_intervals {
        insert into notification_types_intervals
        (type_id, interval_id)
        select :type_id, interval_id
        from notification_intervals where name in ('instant','hourly','daily')
    }
    db_dml insert_del_method {
        insert into notification_types_del_methods
        (type_id, delivery_method_id)
        select :type_id, delivery_method_id
        from notification_delivery_methods where short_name in ('email')
    }

    # Message
    set spec {
        contract_name "NotificationType"
        owner "forums"
        name "forums_message_notif_type"
        pretty_name "forums_message_notif_type"
        aliases {
            GetURL       forum::notification::get_url
            ProcessReply forum::notification::process_reply
        }
    }
    set sc_impl_id [acs_sc::impl::new_from_spec -spec $spec]

    set type_id [notification::type::new \
                     -sc_impl_id $sc_impl_id \
                     -short_name "forums_message_notif" \
                     -pretty_name "Message Notification" \
                     -description "Notifications for Message Thread"]

    # Enable the various intervals and delivery methods
    db_dml insert_intervals {
        insert into notification_types_intervals
        (type_id, interval_id)
        select :type_id, interval_id
        from notification_intervals where name in ('instant','hourly','daily')
    }
    db_dml insert_del_method {
        insert into notification_types_del_methods
        (type_id, delivery_method_id)
        select :type_id, delivery_method_id
        from notification_delivery_methods where short_name in ('email')
    }
}

ad_proc -private forum::install::create_moderator_notification_types {} {
    Create the Forum Notification types used to notify usersmoderators
    of forum changes.
} {
    # Entire forum
    set spec {
        contract_name "NotificationType"
        owner "forums"
        name "forums_forum_moderator_notif_type"
        pretty_name "forums_forum_moderator_notif_type"
        aliases {
            GetURL       forum::notification::get_url
            ProcessReply forum::notification::process_reply
        }
    }
    set sc_impl_id [acs_sc::impl::new_from_spec -spec $spec]

    set type_id [notification::type::new \
                     -sc_impl_id $sc_impl_id \
                     -short_name "forums_forum_moderator_notif" \
                     -pretty_name "Forum Moderator Notification" \
                     -description "Moderator notifications for Entire Forums"]

    # Enable the various intervals and delivery methods
    db_dml insert_intervals {
        insert into notification_types_intervals
        (type_id, interval_id)
        select :type_id, interval_id
        from notification_intervals where name in ('instant','hourly','daily')
    }
    db_dml insert_del_method {
        insert into notification_types_del_methods
        (type_id, delivery_method_id)
        select :type_id, delivery_method_id
        from notification_delivery_methods where short_name in ('email')
    }

    # Message
    set spec {
        contract_name "NotificationType"
        owner "forums"
        name "forums_message_moderator_notif_type"
        pretty_name "forums_message_moderator_notif_type"
        aliases {
            GetURL       forum::notification::get_url
            ProcessReply forum::notification::process_reply
        }
    }
    set sc_impl_id [acs_sc::impl::new_from_spec -spec $spec]

    set type_id [notification::type::new \
                     -sc_impl_id $sc_impl_id \
                     -short_name "forums_message_moderator_notif" \
                     -pretty_name "Message Moderator Notification" \
                     -description "Moderator notifications for Message Thread"]

    # Enable the various intervals and delivery methods
    db_dml insert_intervals {
        insert into notification_types_intervals
        (type_id, interval_id)
        select :type_id, interval_id
        from notification_intervals where name in ('instant','hourly','daily')
    }
    db_dml insert_del_method {
        insert into notification_types_del_methods
        (type_id, delivery_method_id)
        select :type_id, delivery_method_id
        from notification_delivery_methods where short_name in ('email')
    }
}

ad_proc -private forum::install::delete_notification_types {} {
    Delete notification types on uninstall
} {
    foreach {short_name impl_name} {
        "forums_forum_notif"   "forums_forum_notif_type"
        "forums_message_notif" "forums_message_notif_type"
        "forums_forum_moderator_notif" "forums_forum_moderator_notif_type"
        "forums_message_moderator_notif" "forums_message_moderator_notif_type"
    } {
        notification::type::delete -short_name $short_name

        acs_sc::impl::delete \
            -contract_name "NotificationType" \
            -impl_name $impl_name
    }
}

ad_proc -private ::install::xml::action::forum-create { node } {
    Create a forum instance from an install.xml file
} {
    set url [apm_required_attribute_value $node url]
    set name [apm_required_attribute_value $node name]
    set presentation [apm_attribute_value -default "flat" $node presentation]
    set id [apm_attribute_value -default "" $node id]
    set posting_policy [apm_attribute_value -default "open" $node posting-policy]


    set charter_node [lindex [xml_node_get_children_by_name [lindex $node 0] charter] 0]
    set charter [xml_node_get_content $charter_node]

    set package_id [site_node::get_element -url $url -element package_id]

    set forum_id [forum::new \
                      -name $name \
                      -charter $charter \
                      -presentation_type $presentation \
                      -posting_policy $posting_policy \
                      -package_id $package_id]

    if {$id ne "" } {
        set ::install::xml::ids($id) $forum_id
    }
}



ad_proc -private forum::install::before-uninstantiate {
  -package_id
} {
   Make sure all threads are deleted before the forum is uninstantiated.
   @author realfsen@km.co.at
   @creation-date 2009.03.24
} {
  # Delete each message in the each forum
  foreach set_id [forum::list_forums -package_id $package_id] {
    ad_ns_set_to_tcl_vars $set_id ;# get the forum_id
    foreach message_id [db_list _ "select message_id from forums_messages where forum_id = :forum_id"] {
      forum::message::delete -message_id $message_id
    }
    db_exec_plsql _ "select forums_forum__delete(:forum_id)"
    # ÃR: is this really necessary  ??
    callback::forum::forum_delete::contract -package_id $package_id -forum_id $forum_id
  }
}

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
