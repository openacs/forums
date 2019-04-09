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
    -procs {forum::new} \
    forum_new {
    Test the forum::new proc.
} {

    aa_run_with_teardown \
        -rollback \
        -test_code {

            set package_id [subsite::main_site_id]

            # Create forum
            set forum_id [forum::new \
                              -name "foo" \
                              -package_id $package_id]

            set success_p [db_string success_p {
                select 1 from forums_forums where forum_id = :forum_id
            } -default "0"]

            aa_equals "forum was created successfully" $success_p 1
        }
}

aa_register_case \
    -cats {api smoke} \
    -procs {
        forum::message::new
        forum::new
    } \
    forum_message_new {
    Test the forum::message::new proc.
} {

    aa_run_with_teardown \
        -rollback \
        -test_code {

            set package_id [subsite::main_site_id]

            # Create forum
            set forum_id [forum::new \
                              -name "foo" \
                              -package_id $package_id]

            # Create message
            set message_id [forum::message::new \
                                -forum_id $forum_id \
                                -subject "foo" \
                                -content "foo"]

            set success_p [db_string success_p {
                select 1 from forums_messages where message_id = :message_id
            } -default "0"]

            aa_equals "message was created successfully" $success_p 1
        }
}

aa_register_case \
    -cats {db smoke} \
    -procs {
        forum::get
        forum::message::delete
        forum::message::get
        forum::message::new
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
    -procs {forum::new forum::delete} \
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
        set d [forums::test::new -user_id $user_id $name]
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
    -cats {api web smoke} \
    -procs {forum::new forum::get forum::delete} \
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
        set d [forums::test::new -user_id $user_id $name]
        set forum_id [dict get $d payload forum_id]
        aa_log "Created forum with id $forum_id"

        #
        # View a forum via name.
        #
        set response [forums::test::view \
                          -last_request $d \
                          -user_id $user_id \
                          -name $name ]
        #
        # View a forum via forum_id.
        #
        set response [forums::test::view \
                          -last_request $d \
                          -user_id $user_id \
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
    -procs {forum::new forum::get forum::edit forum::delete} \
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
        set d [forums::test::new -user_id $user_id $name]
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
        set d [forums::test::new -user_id $user_id $name]
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


# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
