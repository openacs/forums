ad_library {
    Automated tests.

    @author Simon Carstensen
    @creation-date 15 November 2003
    @cvs-id $Id$
}

aa_register_case forum_new {
    Test the forum::new proc.
} {    

    aa_run_with_teardown \
        -rollback \
        -test_code {
            
            # Create forum
            set forum_id [forum::new \
                              -name "foo" \
                              -package_id [ad_conn package_id]]

            set success_p [db_string success_p {
                select 1 from forums_forums where forum_id = :forum_id
            } -default "0"]

            aa_equals "forum was created succesfully" $success_p 1
        }
}

aa_register_case forum_message_new {
    Test the forum::message::new proc.
} {    

    aa_run_with_teardown \
        -rollback \
        -test_code {
            
            # Create forum
            set forum_id [forum::new \
                              -name "foo" \
                              -package_id [ad_conn package_id]]
            
            # Create message
            set message_id [forum::message::new \
                                -forum_id $forum_id \
                                -subject "foo" \
                                -content "foo"]

            set success_p [db_string success_p {
                select 1 from forums_messages where message_id = :message_id
            } -default "0"]

            aa_equals "message was created succesfully" $success_p 1
        }
}
