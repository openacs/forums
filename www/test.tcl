
db_transaction {
    # create the forum
    set forum_id [forum::new -name "test" -charter "test chrater" -presentation_type "flat" -posting_policy "open" -package_id [ad_conn package_id]]

    set msg_id [forum::message::new -forum_id $forum_id -subject "Test" -content "this is rocking content" -user_id [ad_conn user_id]]
}

doc_body_append $msg_id
