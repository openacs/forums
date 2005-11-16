ad_library {
    Automated tests for forum-callbacks.

    @author Luis de la Fuente (lfuente@it.uc3m.es)
    @creation-date 14 November 2005
}

aa_register_case forum_move {
    Test the cabability of moving forums.
} {    

    aa_run_with_teardown \
        -rollback \
        -test_code {
            #Create origin
            set origin_club_key [dotlrn_club::new -pretty_name [ad_generate_random_string]]

            #Create destiny
            set destiny_club_key [dotlrn_club::new -pretty_name [ad_generate_random_string]]

            set origin_forum_package [forum::get_forum_package -community_id $origin_club_key]
            set destiny_forum_package [forum::get_forum_package -community_id $destiny_club_key]

            # Create forum
            set forum_id [forum::new \
                              -name "foo" \
                              -package_id $origin_forum_package]

           # Move the forum
            callback -catch datamanager::move_forum -object_id $forum_id -selected_community $destiny_club_key

            #is the forum at the destiny?
            set dest_success_p [db_string dest_success_p {
                select 1 from forums_forums where forum_id = :forum_id and package_id = :destiny_forum_package
            } -default "0"]

            #is the forum at the origin?
            set orig_success_p [db_string orig_success_p {
                select 0 from forums_forums where forum_id = :forum_id and package_id = :origin_forum_package
            } -default "1"]

            if { $orig_success_p == 1 &&  $dest_success_p == 1 } { set success_p 1 } else { set success_p 0}
            aa_equals "forum was moved succesfully" $success_p 1
        }
}

aa_register_case forum_copy {
    Test the cabability of copying forums.
} {    
    aa_run_with_teardown \
        -rollback \
        -test_code {
            #Create origin
            set origin_club_key [dotlrn_club::new -pretty_name [ad_generate_random_string]]

            #Create destiny
            set destiny_club_key [dotlrn_club::new -pretty_name [ad_generate_random_string]]

            set origin_forum_package [forum::get_forum_package -community_id $origin_club_key]
            set destiny_forum_package [forum::get_forum_package -community_id $destiny_club_key]

            # Create forum
            set forum_id [forum::new \
                              -name "foo" \
                              -package_id $origin_forum_package]

           # Copy the forum
            set new_created_forum [callback -catch datamanager::copy_forum -object_id $forum_id -selected_community $destiny_club_key -mode "all"]

            #is the forum at the destiny?
            set dest_success_p [db_string dest_success_p {
                select 1 from forums_forums where forum_id = :new_created_forum and package_id = :destiny_forum_package
            } -default "0"]
ns_log Notice "nuevo foro: $new_created_forum, paquete: $destiny_forum_package"
            #is the forum at the origin?
            set orig_success_p [db_string orig_success_p {
                select 1 from forums_forums where forum_id = :forum_id and package_id = :origin_forum_package
            } -default "0"]

            aa_equals "forum was copied succesfully" $dest_success_p 1
            aa_equals "forum was correctly keeped at origin" $orig_success_p 1

        }
}
