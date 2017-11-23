<?xml version="1.0"?>
<queryset>

    <partialquery name="unread_or_new_query">
        <querytext>
	  approved_thread_count - coalesce(
            (SELECT forums_reading_info_user.threads_read
	       FROM forums_reading_info_user
	      WHERE forums_reading_info_user.forum_id=forums_forums_enabled.forum_id
                AND forums_reading_info_user.user_id=:user_id),
           0) as count_unread
        </querytext>
    </partialquery>

</queryset>
