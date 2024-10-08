ad_library {
    Automated tests.

    @author Simon Carstensen
    @creation-date 15 November 2003
    @author Gerardo Morales
    @author Mounir Lallali
    @cvs-id $Id$
}

aa_register_case \
    -cats {api smoke} \
    -procs {
        forum::new
        callback::forum::forum_new::contract
        forum::flush_templating_cache
        forum::list_forums
        forum::valid_forum_id_p
    } \
    forum_new {
    Test the forum::new proc.
} {

    aa_run_with_teardown \
        -rollback \
        -test_code {

            set package_id [subsite::main_site_id]
            set no_package_id [db_string get_not_package_id {
                select min(package_id) - 1 from apm_packages
            }]

            # Create a couple of forums
            set forums [list]
            lappend forums \
                [list [forum::new \
                           -name "foo" \
                           -package_id $package_id] "foo"]
            lappend forums \
                [list [forum::new \
                           -name "bar" \
                           -package_id $package_id] "bar"]

            aa_equals "No forums retrieved for an invalid package" \
                [forum::list_forums -package_id $no_package_id] ""

            set api_forums [list]
            foreach s [forum::list_forums -package_id $package_id] {
                aa_equals "Set has the expected keys" \
                    [lsort [ns_set keys $s]] {forum_id name posting_policy presentation_type}

                set forum_id [ns_set get $s forum_id]
                lappend api_forums \
                    [list $forum_id [ns_set get $s name]]

                aa_true "Forum id '$forum_id' is valid (without package)" \
                    [forum::valid_forum_id_p \
                         -forum_id $forum_id]

                aa_true "Forum id '$forum_id' is valid (with package)" \
                    [forum::valid_forum_id_p \
                         -forum_id $forum_id \
                         -package_id $package_id]

                aa_false "Forum id '$forum_id' is not valid (wrong package)" \
                    [forum::valid_forum_id_p \
                         -forum_id $forum_id \
                         -package_id $no_package_id]
            }

            aa_equals "Api retrieves the expected forums" \
                [lsort -index 0 $forums] [lsort -index 0 $api_forums]

        }
}

aa_register_case \
    -cats {api smoke} \
    -procs {
        forum::message::new
        forum::new
        forum::message::do_notifications
        forum::message::get
        forum::attachments_enabled_p
        forum::message::notify_users
        forum::message::notify_moderators
        forum::message::approve
        forum::message::reject
        forum::message::open
        forum::message::close
        forum::message::set_format
    } \
    forum_message_new {
    Test the forum::message::new proc.
} {

    aa_run_with_teardown \
        -rollback \
        -test_code {

            set main_site [site_node::get -url "/test"]
            set package_id [dict get $main_site object_id]

            aa_log "Require the attachments package"
            if {![site_node_apm_integration::child_package_exists_p \
                      -package_id $package_id \
                      -package_key attachments]} {
                site_node::instantiate_and_mount \
                    -package_key attachments \
                    -parent_node_id [dict get $main_site node_id]
            }

            # Create forum
            set forum_id [forum::new \
                              -name "foo" \
                              -posting_policy "moderated" \
                              -attachments_allowed_p false \
                              -package_id $package_id]

            aa_false "Attachments are disabled" \
                [forum::attachments_enabled_p -forum_id $forum_id]

            aa_log "Enable attachments on the forum"
            forum::edit -forum_id $forum_id -attachments_allowed_p true

            aa_true "Attachments are enabled" \
                [forum::attachments_enabled_p -forum_id $forum_id]

            # Create message
            set message_id [forum::message::new \
                                -forum_id $forum_id \
                                -subject "foo" \
                                -content "foo"]

            set child_message_id [forum::message::new \
                                      -forum_id $forum_id \
                                      -parent_id $message_id \
                                      -format text/plain \
                                      -subject "bar" \
                                      -content "bar"]

            aa_equals "There are no attachments on message '$message_id'" \
                [llength [attachments::get_attachments -object_id $message_id]] 0
            set attachments [db_list any_objects {
                select object_id from acs_objects
                where object_id not in (:message_id, :child_message_id, :forum_id, :package_id)
                order by object_id desc
                fetch first 3 rows only
            }]
            foreach attachment_id $attachments {
                attachments::attach \
                    -object_id $message_id \
                    -attachment_id $attachment_id \
                    -approved_p true
            }
            aa_equals "There are now 3 attachments on message '$message_id'" \
                [llength [attachments::get_attachments -object_id $message_id]] 3

            forum::message::get -message_id $message_id -array m
            aa_equals "Message '$message_id' is waiting for approval" \
                $m(state) "pending"

            forum::message::get -message_id $child_message_id -array cm
            aa_equals "Message '$child_message_id' is waiting for approval" \
                $cm(state) "pending"
            aa_equals "Message '$child_message_id' is child of '$message_id'" \
                $cm(parent_id) $message_id
            aa_equals "Message '$child_message_id' is in format 'text/plain'" \
                $cm(format) text/plain

            aa_log "Change the format of message '$child_message_id'"
            forum::message::set_format -message_id $child_message_id -format text/html
            forum::message::get -message_id $child_message_id -array cm
            aa_equals "Message '$child_message_id' is now in format 'text/html'" \
                $cm(format) text/html

            aa_log "Reject message '$message_id'"
            forum::message::reject -message_id $message_id
            forum::message::get -message_id $message_id -array m
            aa_equals "Message '$message_id' is rejected" \
                $m(state) "rejected"
            forum::message::get -message_id $child_message_id -array cm
            aa_equals "Message '$child_message_id' is still waiting for approval" \
                $cm(state) "pending"

            aa_log "Approve message '$message_id'"
            forum::message::approve -message_id $message_id
            forum::message::get -message_id $message_id -array m
            aa_equals "Message '$message_id' is approved" \
                $m(state) "approved"
            forum::message::get -message_id $child_message_id -array cm
            aa_equals "Message '$child_message_id' is still waiting for approval" \
                $cm(state) "pending"

            aa_log "Close message '$message_id' (meant as subthread)"
            forum::message::close -message_id $message_id
            forum::message::get -message_id $message_id -array m
            aa_false "Message '$message_id' is closed" $m(open_p)
            forum::message::get -message_id $child_message_id -array cm
            aa_false "Message '$child_message_id' is also closed" $cm(open_p)

            aa_log "Open message '$message_id' (meant as subthread)"
            forum::message::open -message_id $message_id
            forum::message::get -message_id $message_id -array m
            aa_true "Message '$message_id' is open" $m(open_p)
            forum::message::get -message_id $child_message_id -array cm
            aa_true "Message '$child_message_id' is also open" $cm(open_p)
        }
}

aa_register_case \
    -cats {db smoke} \
    -procs {
        forum::get
        forum::message::delete
        forum::message::get
        forum::flush_cache
        forum::flush_namespaced_cache
        forum::message::new
        forum::message::do_notifications
        forum::message::notify_moderators
        forum::message::notify_users
        forum::message::set_state
        forum::new
    } \
    forum_count_test {
    Test the thread count and reply count tracking code.
} {

    aa_run_with_teardown \
        -rollback \
        -test_code {

            set package_id [subsite::main_site_id]

            # Create open forum
            set forum_id [forum::new \
                              -name foo \
                              -package_id $package_id]

            forum::get -forum_id $forum_id -array forum
            aa_equals "New forum has zero approved threads" $forum(approved_thread_count) 0
            aa_equals "New forum has zero threads" $forum(thread_count) 0

            # Create message
            set message_id [forum::message::new \
                                -forum_id $forum_id \
                                -subject foo \
                                -content foo]

            forum::get -forum_id $forum_id -array forum
            aa_equals "After post forum has one approved thread" $forum(approved_thread_count) 1
            aa_equals "After post forum has one threads" $forum(thread_count) 1

            forum::message::get -message_id $message_id -array message
            aa_equals "New post has zero approved replies" $message(approved_reply_count) 0
            aa_equals "New post has zero threads" $message(reply_count) 0

            set reply_id [forum::message::new \
                             -forum_id $forum_id \
                             -parent_id $message_id \
                             -subject foo \
                             -content foo]

            forum::get -forum_id $forum_id -array forum
            aa_equals "After reply forum has one approved thread" $forum(approved_thread_count) 1
            aa_equals "After reply forum has one thread" $forum(thread_count) 1

            forum::message::get -message_id $message_id -array message
            aa_equals "After reply post has one approved replies" $message(approved_reply_count) 1
            aa_equals "After reply post has one reply" $message(reply_count) 1

            # Create moderated forum
            set forum_id [forum::new \
                              -name bar \
                              -posting_policy moderated \
                              -package_id $package_id]

            # Create message
            set message_id [forum::message::new \
                                -forum_id $forum_id \
                                -subject "foo" \
                                -content "foo"]

            forum::get -forum_id $forum_id -array forum
            aa_equals "After post moderated forum has zero approved threads" $forum(approved_thread_count) 0
            aa_equals "After post moderated forum has one thread" $forum(thread_count) 1

            set reply_id [forum::message::new \
                             -forum_id $forum_id \
                             -parent_id $message_id \
                             -subject "foo" \
                             -content "foo"]

            forum::message::get -message_id $message_id -array message
            aa_equals "After reply moderated post has zero approved replies" $message(approved_reply_count) 0
            aa_equals "After reply moderated post has one reply" $message(reply_count) 1

            forum::message::set_state -message_id $message_id -state approved

            forum::get -forum_id $forum_id -array forum
            aa_equals "After approval moderated forum has one approved thread" $forum(approved_thread_count) 1
            aa_equals "After approval moderated forum has one thread" $forum(thread_count) 1

            forum::message::set_state -message_id $reply_id -state approved

            forum::message::get -message_id $message_id -array message
            aa_equals "After reply approval post has one approved reply" $message(approved_reply_count) 1
            aa_equals "After reply approval post has one reply" $message(reply_count) 1

            forum::message::delete -message_id $message_id

            forum::get -forum_id $forum_id -array forum
            aa_equals "After deletion moderated forum has zero approved threads" $forum(approved_thread_count) 0
            aa_equals "After deletion moderated forum has zero threads" $forum(thread_count) 0
        }
}


aa_register_case \
    -cats {api web smoke} \
    -procs {
        forum::new
        forum::delete

        aa_get_first_url
        acs_community_member_admin_url
        ds_adp_start_box
        ds_adp_end_box
        forums::form::forum
    } \
    -urls {
        /admin/forum-new
    } web_forum_new {
       Testing the creation of a forum via web
} {

    set forum_id 0
    aa_run_with_teardown -test_code {

        #
        # Create a new admin user
        #
        set user_info [acs::test::user::create -admin]
        set user_id [dict get $user_info user_id]

        #
        # Create a new forum
        #
        set name [ad_generate_random_string]
        set d [forums::test::new -user_info $user_info $name]
        set forum_id [dict get $d payload forum_id]


    } -teardown_code {
        #
        # In order to be able to delete the user, we have first to
        # delete the fresh forum (via API).
        #
        if {$forum_id != 0} {
            forum::delete -forum_id $forum_id
        }
        acs::test::user::delete -user_id [dict get $user_info user_id]
    }

}

aa_register_case \
    -cats {web smoke} \
    -procs {
        aa_get_first_url
        acs_community_member_admin_url
        ad_context_node_list
        forum::delete
        forum::get
        forum::new
        forums::form::forum
        forums::form::search
    } \
    -urls {
        /admin/forum-new
        /forum-view
    } web_forum_view {
       Testing the creation of a forum via web
} {
    set forum_id 0
    aa_run_with_teardown -test_code {

        #
        # Create a new admin user
        #
        set user_info [acs::test::user::create -admin]
        set user_id [dict get $user_info user_id]

        #
        # Create a new forum
        #
        set name [ad_generate_random_string]
        set d [forums::test::new -user_info $user_info $name]
        set forum_id [dict get $d payload forum_id]
        aa_log "Created forum with id $forum_id"

        #
        # View a forum via name.
        #
        set response [forums::test::view \
                          -last_request $d \
                          -name $name ]
        #
        # View a forum via forum_id.
        #
        set response [forums::test::view \
                          -last_request $d \
                          -forum_id $forum_id ]

    } -teardown_code {
        #
        # Delete the forum.
        #
        if {$forum_id != 0} {
            forum::delete -forum_id $forum_id
        }
        acs::test::user::delete -user_id [dict get $user_info user_id]
    }
}


aa_register_case \
    -cats {web smoke} \
    -procs {
        aa_get_first_url
        acs_community_member_admin_url
        ad_context_node_list
        ds_adp_end_box
        ds_adp_start_box
        forum::delete
        forum::edit
        forum::get
        forum::new
        forums::form::forum
        forums::form::search
    } \
    -urls {
        /admin/forum-new
        /admin/forum-edit
    } \
    web_forum_edit {
        Testing the editing of an existing forum.
} {
    set forum_id 0
    aa_run_with_teardown -test_code {
        #
        # Create a new admin user
        #
        set user_info [acs::test::user::create -admin]
        set user_id [dict get $user_info user_id]

        #
        # Create a new forum
        #
        set name [ad_generate_random_string]
        set d [forums::test::new -user_info $user_info $name]
        set forum_id [dict get $d payload forum_id]

        #
        # Edit the meta info of the created forum
        #
        set response [forums::test::edit \
                          -last_request $d \
                          -forum_id $forum_id ]

    } -teardown_code {
        if {$forum_id != 0} {
            forum::delete -forum_id $forum_id
        }
        acs::test::user::delete -user_id [dict get $user_info user_id]
    }
}

aa_register_case \
    -cats {web smoke} \
    -procs {
        forum::delete
        forum::edit
        forum::get
        forum::message::delete
        forum::message::delete
        forum::message::edit
        forum::message::get
        forum::message::new
        forum::message::set_state
        forum::new
        forum::security::require_post_forum

        aa_get_first_url
        acs_community_member_admin_url
        ad_context_node_list
        ds_adp_start_box
        ds_adp_end_box
        ad_form
        forum::format::emoticons
        forum::security::can_post_forum_p
        forum::security::permissions
        forum::security::require_moderate_forum
        forum::security::require_read_forum
        forum::security::require_post_forum
        forum::use_ReadingInfo_p
        forum::valid_forum_id_p
        forums::form::forum
        forums::form::message
        forums::form::search
    } \
    -urls {
        /message-post
        /forum-view
        /message-view
        /message-post
        /moderate/message-edit
        /moderate/message-delete
    } \
    web_forums_message_and_reply {
        Do various operations in a longer test:
        - create a forum
        - add a forums entry
        - reply to the forum
        - edit the forums entry
        - delete the forums entry
} {

    set forum_id 0
    set message_id 0
    aa_run_with_teardown -test_code {
        #
        # Create a new admin user
        #
        set user_info [acs::test::user::create -admin]
        set user_id [dict get $user_info user_id]

        #
        # Create a new forum
        #
        set name [ad_generate_random_string]
        set d [forums::test::new -user_info $user_info $name]
        set forum_id [dict get $d payload forum_id]

        # Post a message in the created forum
        set message_id [forums::test::new_postings \
                            -last_request $d \
                            -forum_id $forum_id ]


    } -teardown_code {
        if {$message_id != 0} {
            forum::message::delete -message_id $message_id
        }
        if {$forum_id != 0} {
            forum::delete -forum_id $forum_id
        }
        acs::test::user::delete -user_id [dict get $user_info user_id]
    }
}

aa_register_case -cats {
    api
} -procs {
    forum::new
    forum::enable
    forum::disable
} forum_enable_disable {
    Test forum enabling and disabling.
} {
    #
    # Helper proc to check if the forum is enabled
    #
    proc forum_enabled_p {forum_id} {
        return [db_string enabled_p {
            select enabled_p
              from forums_forums
             where forum_id = :forum_id
        } -default "0"]
    }
    #
    # Start the tests
    #
    aa_run_with_teardown -rollback -test_code {
        #
        # Create forum
        #
        set package_id [subsite::main_site_id]
        set forum_id [forum::new \
                          -name "foo" \
                          -package_id $package_id]
        #
        # Enable forum if it is disabled
        #
        if {![forum_enabled_p $forum_id]} {
            forum::enable -forum_id $forum_id
        }
        aa_true "Forum $forum_id is enabled" [forum_enabled_p $forum_id]
        #
        # Disable
        #
        forum::disable -forum_id $forum_id
        aa_false "Forum $forum_id is enabled" [forum_enabled_p $forum_id]
        #
        # Enable again
        #
        forum::enable -forum_id $forum_id
        aa_true "Forum $forum_id is enabled" [forum_enabled_p $forum_id]
    }
}

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
