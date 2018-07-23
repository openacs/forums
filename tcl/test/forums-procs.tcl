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
    -procs {forum::delete} \
    web_forum_new {
       Testing the creation of a forum via web
} {

    aa_run_with_teardown -test_code {

        #tclwebtest::cookies clear

        #
        # Create a new admin user
        #
        set user_info [acs::test::user::create -admin]
        set user_id [dict get $user_info user_id]

        #
	# Get the forums admin page url
        #
	set forums_page [aa_get_first_url -package_key forums]
        set d [acs::test::http \
                   -user_id $user_id \
                   $forums_page/admin/forum-new]
        aa_equals "Status code valid" [dict get $d status] 200

        #
        # Get the form specific data (action, method and provided form-fields)
        #
        acs::test::dom_html root [dict get $d body] {
            set n_form   [$root selectNodes {//form[@id="forum"]}]
            set f_action [lindex [$root selectNodes {//form[@id='forum']/@action}] 0 1]
            set f_method [lindex [$root selectNodes {//form[@id='forum']/@method}] 0 1]
            set f_fields [::acs::test::xpath::get_form_values $root {//form[@id='forum']}]
        }

        #
        # Fill in a few values into the form
        #
        set d [::acs::test::form_reply \
                   -user_id $user_id \
                   -url $f_action \
                   -update [subst {
                       name             "[ad_generate_random_string]"
                       charter          "[ad_generate_random_string] [ad_generate_random_string]"
                       charter.format    text/plain
                       presentation_type flat
                       posting_policy    open
                   }] \
                    $f_fields ]
        set reply [dict get $d body]
        #set F [open /tmp/REPLY.html w]; puts $F $reply; close $F

        #
        # Check, if the form was correctly validated
        #
        aa_false  "Reply contains form-error" [string match *form-error* $reply]
        aa_equals "Status code valid" [dict get $d status] 302

        #
        # in order to be able to delete the user, we have first to
        # delete the fresh forum (via API)
        #
        forum::delete -forum_id [dict get $f_fields forum_id]
        
    } -teardown_code {
        acs::test::user::delete -user_id [dict get $user_info user_id]
    }

}

aa_register_case \
    -cats {web smoke} \
    -libraries tclwebtest \
    -procs {forums::twt::edit forums::twt::new} \
    web_forum_edit {
        Testing the edition of an existing forum
} {

    aa_run_with_teardown -test_code {

        tclwebtest::cookies clear

        # Login user
        array set user_info [twt::user::create -admin]
        twt::user::login $user_info(email) $user_info(password)

        # Create a forum
        set name [ad_generate_random_string]
        forums::twt::new $name

        # Edit the created forum
        set response [forums::twt::edit $name]
        aa_display_result -response $response -explanation {Webtest for the edition of a forum}

        twt::user::logout
    }
}

aa_register_case \
    -cats {web smoke} \
    -libraries tclwebtest \
    -procs {forums::twt::new forums::twt::new_post} \
    web_message_new {
       Posting a new message to an existing forum
} {


    aa_run_with_teardown -test_code {

        tclwebtest::cookies clear

        # Login user
        array set user_info [twt::user::create -admin]
        twt::user::login $user_info(email) $user_info(password)

        # Create a forum
        set name [ad_generate_random_string]
        forums::twt::new "$name"

        # Post a message in the created forum
        set subject [ad_generate_random_string]
        set response [forums::twt::new_post "$name" "$subject"]
        aa_display_result -response $response -explanation {Webtest for posting a message in a forum}

        twt::user::logout
    }
}

aa_register_case \
    -cats {web smoke} \
    -libraries tclwebtest \
    -procs {forums::twt::new_post forums::twt::new_post forums::twt::edit_post} \
    web_message_edit {
 Editing a message of a forum
} {

    aa_run_with_teardown -test_code {

        tclwebtest::cookies clear

        # Login user
        array set user_info [twt::user::create -admin]
        twt::user::login $user_info(email) $user_info(password)

        # Create a forum
        set name [ad_generate_random_string]
        forums::twt::new "$name"

        # Post a message in the created forum
        set subject [ad_generate_random_string]
        forums::twt::new_post "$name" "$subject"

        # Edit the posted message
        set response [forums::twt::edit_post "$name" "$subject"]
        aa_display_result -response $response -explanation {Webtest for editing the message of a forum}

        twt::user::logout
    }
}

aa_register_case \
    -cats {web smoke} \
    -libraries tclwebtest \
    -procs {forums::twt::new forums::twt::new_post forums::twt::reply_msg} \
    web_message_reply {
    Post a reply a message in the forum
} {
    aa_run_with_teardown -test_code {

        tclwebtest::cookies clear

        # Login user
        array set user_info [twt::user::create -admin]
        twt::user::login $user_info(email) $user_info(password)

        # Create a forum
        set name [ad_generate_random_string]
        forums::twt::new "$name"

        # Post a message in the created forum
        set subject [ad_generate_random_string]
        forums::twt::new_post "$name" "$subject"

        # Edit the posted message
        set response [forums::twt::reply_msg "$name" "$subject"]
        aa_display_result -response $response -explanation {Webtest for posting a reply to a msg in the forum}

        twt::user::logout
    }
}

aa_register_case \
    -cats {web smoke} \
    -libraries tclwebtest \
    -procs {forums::twt::new forums::twt::new_post forums::twt::delete_post} \
    web_message_delete {
    Delete a message in the forum
} {
    aa_run_with_teardown -test_code {

        tclwebtest::cookies clear

        # Login user
        array set user_info [twt::user::create -admin]
        twt::user::login $user_info(email) $user_info(password)

        # Create a forum
        set name [ad_generate_random_string]
        forums::twt::new "$name"

        # Post a message in the created forum
        set subject [ad_generate_random_string]
        forums::twt::new_post "$name" "$subject"

        # Edit the posted message
        set response [forums::twt::delete_post "$name" "$subject"]
        aa_display_result -response $response -explanation {Webtest for deleting a message posted in the forum}

        twt::user::logout
    }
}
# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
