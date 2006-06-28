ad_page_contract {

    View a random number of messages

} {
   rowcount:integer
   forum_id:integer
   message_id:integer
   
}

ns_log notice it's my page!
set mypage [ns_getform]
if {[string equal "" $mypage]} {
    ns_log notice no form was submitted on my page
} else {
    ns_log notice the following form was submitted on my page
    ns_set print $mypage
}



set return_url "[ad_conn package_url]message-view?message_id=$message_id"
set number_messages [expr $rowcount + 1]


ad_form  -name random_message -export {return_url message_id forum_id rowcount}  -form {

    {value:text {label "Number of messages to display"}
	{html {size 3}}}
    

} -on_submit {
    #ns_log notice "entro" 
    #form get_values random_message value return_url message_id forum_id
     
    set message_list [db_list select_list "select fma.message_id \
        from   forums_messages_approved fma \
        where  fma.forum_id = $forum_id \
        and  fma.tree_sortkey between (select fm.tree_sortkey from forums_messages fm where fm.message_id = $message_id) \
        and  (select tree_right(fm.tree_sortkey) from forums_messages fm where fm.message_id = $message_id) \
        order by fma.message_id"]

   for {set i 0} {$i < $value} {incr i} {
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
   
      
        
 } -after_submit {

     ad_returnredirect $return_url
     ad_script_abort

 } 


 
