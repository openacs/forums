<?xml version="1.0"?>

<queryset>
    <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

    <fullquery name="select_forums">
        <querytext>
            select forums_forums_enabled.*,
                   approved_thread_count as n_threads,
                   to_char(last_post, 'YYYY-MM-DD HH24:MI:SS') as last_post_ansi,
		   $unread_or_new_query_clause
            from forums_forums_enabled
            where forums_forums_enabled.package_id = :package_id
            and acs_permission.permission_p(forums_forums_enabled.forum_id, :user_id, 'read') = 't'
            order by forums_forums_enabled.name
        </querytext>
    </fullquery>

    <partialquery name="unread_or_new_query">
        <querytext>
	approved_thread_count-nvl((SELECT forums_reading_info_user.threads_read
					FROM forums_reading_info_user
					WHERE forums_reading_info_user.forum_id=forums_forums_enabled.forum_id 
					AND forums_reading_info_user.user_id=:user_id), 0)
	as count_unread
        </querytext>
    </partialquery>

</queryset>
