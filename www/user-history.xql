<?xml version="1.0"?>

<queryset>

    <fullquery name="select_messages">
        <querytext>
            select forums_messages.message_id,
                   forums_messages.subject,
                   to_char(forums_messages.posting_date, 'Mon DD YYYY HH24:MI:SS') as posting_date,
                   forums_forums.forum_id,
                   forums_forums.name as forum_name
            from forums_messages,
                 forums_forums
            where forums_messages.user_id = :user_id
            and forums_messages.forum_id = forums_forums.forum_id
            and forums_forums.package_id = :package_id
            $sql_order_by
        </querytext>
    </fullquery>

</queryset>
