<?xml version="1.0"?>
<queryset>

    <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

    <fullquery name="forums::move_thread::update_final_message">
        <querytext>
		  update forums_messages
		  set reply_count = reply_count + 1, approved_reply_count = approved_reply_count + 1, max_child_sortkey = tree.increment_key(max_child_sortkey) 
		  where message_id = :message_id
        </querytext>
    </fullquery>
    

    <fullquery name="forums::move_thread::get_all_child">
        <querytext>		  
		  select message_id as msge_id, substr(tree_sortkey, 13, length(tree_sortkey)) as child_tree_sortkey
		  from forums_messages 
                  where forum_id = :forum_id and tree_sortkey between tree.left('$message(tree_sortkey)') and tree.right('$message(tree_sortkey)') 
		  order by tree_sortkey desc
        </querytext>
    </fullquery>

    
    <fullquery name="forums::move_thread::get_final_tree_sortkey">
        <querytext>
		 select substr(tree_sortkey, 13, length(tree_sortkey)) as final_tree_sortkey, substr(tree_sortkey, 0, 6) as initial_tree_sortkey 
		 from forums_messages 
		 where message_id = $message(message_id) 
        </querytext>
    </fullquery>  
        
    <fullquery name="forums::move_thread::update_last_child_post_initial">
        <querytext>
	    update forums_messages
	    set last_child_post = (select max(last_child_post)
	    	  from forums_messages 
                  where forum_id = :forum_id and tree_sortkey between tree.left((select tree_sortkey from forums_messages where message_id = :father_message_id)) and tree.right((select tree_sortkey from forums_messages where message_id = :father_message_id)) 
	    ) 
	    where message_id = :father_message_id
        </querytext>
    </fullquery>
    
    <fullquery name="forums::move_thread::update_last_child_post_final">
        <querytext>
	    update forums_messages
	    set last_child_post = (select max(last_child_post)
	    	  from forums_messages 
                  where forum_id = :forum_id and tree_sortkey between tree.left((select tree_sortkey from forums_messages where message_id = :message_id)) and tree.right((select tree_sortkey from forums_messages where message_id = :message_id)) 
	    ) 
	    where message_id = :message_id
        </querytext>
    </fullquery>

    <fullquery name="forums::move_thread::update_reading_info">
      <querytext>
        begin;
        select forums_reading_info.move_thread_update($message(message_id), :selected_message);
        end;
      </querytext>
    </fullquery>

</queryset>
