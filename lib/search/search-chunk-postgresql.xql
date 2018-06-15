<?xml version="1.0"?>

<queryset>
    <rdbms><type>postgresql</type><version>7.1</version></rdbms>

    <fullquery name="search_all_forums">
        <querytext>
            select forums_messages.*,
                   to_char(forums_messages.posting_date, 'YYYY-MM-DD HH24:MI:SS') as posting_date_ansi,
                   100 as the_score
            from   forums_messages,
                   forums_forums
            where  forums_messages.forum_id = forums_forums.forum_id
            and    (:forum_id is null or forums_forums.forum_id = :forum_id)
	    and    forums_forums.package_id = :package_id
            and    forums_messages.state = 'approved'
            and    forums_messages.subject || ' ' || forums_messages.content || ' ' || person__name(forums_messages.user_id)
                       ilike :search_pattern
            order  by forums_messages.posting_date desc
        </querytext>
    </fullquery>

</queryset>
