ad_page_contract {

    View a random number of messages

} {
   rowcount:integer
   forum_id:integer
   message_id:integer
   number:integer
   
}

#set generate_number 5
set return_url "[ad_conn package_url]message-view?message_id=$message_id"

set message_list [db_list select_list "select fma.message_id \
        from   forums_messages_approved fma \
        where  fma.forum_id = $forum_id \
        and    fma.tree_sortkey between (select fm.tree_sortkey from forums_messages fm where fm.message_id = $message_id) \
          and    (select tree_right(fm.tree_sortkey) from forums_messages fm where fm.message_id = $message_id) \
        order by fma.message_id"]


for {set i 0} {$i < $number} {incr i} {
	set reply [expr rand()]
        set list_index [expr int([expr rand() * [llength $message_list]])]
        set content_length [expr int ([expr rand() * 300])]
        ns_log notice "tamaño: $content_length"
        set subject [ad_generate_random_string] 
    set content [ad_generate_random_string $content_length]
        ns_log notice "l:$list_index"
        ns_log notice "s: $subject"
        ns_log notice "c: $content"
    set pato [llength $message_list]
        ns_log notice "$pato"

        if {$reply < 0.5} {
	    set reply 0
	} else {
	set reply 1
        }

        if {$reply == 1} {
	    set parent_id [lindex $message_list $list_index]
            
	    set generated_message_id [forum::message::new \
					  -forum_id $forum_id \
					  -parent_id $parent_id \
					  -subject $subject \
					  -content $content]	
           	    

        } else {
	    
	    set generated_message_id [forum::message::new \
					 -forum_id $forum_id \
                                         -parent_id $message_id \
					 -subject $subject \
				         -content $content]

        }

            lappend message_list $generated_message_id   

    }

 ad_returnredirect $return_url
 ad_script_abort
        