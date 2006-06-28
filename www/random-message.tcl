ad_page_contract {

    Create a specified  number of messages, with a random content
    @author Veronica De La Cruz (veronica@viaro.net)
    @creation-date 2006-03-15

} {

   rowcount:integer
   forum_id:integer
   message_id:integer
   
}



set return_url "[ad_conn package_url]message-view?message_id=$message_id"

#List of the ids of all the messages that are currently on the thread.
set message_list [db_list select_list "select fma.message_id \
        from   forums_messages_approved fma \
        where  fma.forum_id = $forum_id \
        and  fma.tree_sortkey between (select fm.tree_sortkey from forums_messages fm where fm.message_id = $message_id) \
        and  (select tree_right(fm.tree_sortkey) from forums_messages fm where fm.message_id = $message_id) \
        order by fma.message_id"]


ad_form  -name random_message -export {return_url message_id forum_id rowcount}  -form {

    {value:text {label "Number of messages to create:"}
	{html {size 3}}}
    

} -on_submit {       
   
    for {set i 0} {$i < $value} {incr i} {        

        set list_index [expr int([expr rand() * [llength $message_list]])]
        set content_length [expr int ([expr rand() * 50])]       
        set subject [ad_generate_random_string] 
        set content [ad_generate_random_string $content_length]       

        
        for {set j 0} {$j < $content_length} {incr j} {
            
            append content [ad_generate_random_string 5000]
            append content " "

        }
        
        # Choose randomly any message to be the parent_id
	set parent_id [lindex $message_list $list_index]
        
        # Create the message    
	set generated_message_id [forum::message::new \
				  -forum_id $forum_id \
				  -parent_id $parent_id \
				  -subject $subject \
				  -content $content]	
           	    
	# Include in the ids list the generated messages
         lappend message_list $generated_message_id   

    }
   
      
        
 } -after_submit {

     ad_returnredirect $return_url
     ad_script_abort

 } 


 
