ad_page_contract {

    Create a random number of messages

} {

   rowcount:integer
   forum_id:integer
   message_id:integer
   
}


set number_of_messages $rowcount
set return_url "[ad_conn package_url]/message-view?message_id=$message_id"

set message_list [db_list select_list "select fma.message_id \
        from   forums_messages_approved fma \
        where  fma.forum_id = $forum_id \
        and  fma.tree_sortkey between (select fm.tree_sortkey from forums_messages fm where fm.message_id = $message_id) \
        and  (select tree_right(fm.tree_sortkey) from forums_messages fm where fm.message_id = $message_id) \
        order by fma.message_id"]

form create random_message 

element create random_message generate_number  -datatype integer \
                                               -label "Number of messages to display" \
                                               -widget text \
                                               -html {size 5}


 template::form::get_values random_message 
     ns_log notice "ffd: $generate_number"





if {[template::form::is_valid random_message]} {
  ns_log notice ""

   form get_values random_message 
     ns_log notice "ffd: $generate_number"

    ad_returnredirect "[ad_conn package_url]/crear-men?rowcount=$rowcount&forum_id=$forum_id&message_id=$message_id&number=$generate_number"

    ad_script_abort

}

#set f [ template::element::get_value random_message generate_number]

 #ns_log notice "dslk:generate_number"
