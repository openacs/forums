<?xml version="1.0"?>

<queryset>
    <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

    <fullquery name="select_pending_threads">
        <querytext>
            select message_id,
                   subject,
                   user_id,
                   posting_date,
                   state,
                   tree.tree_level(tree_sortkey) as tree_level
            from forums_messages
            where message_id in (select message_id
                                 from forums_messages_pending
                                 where forum_id = :forum_id)
            or tree_sortkey in (select substr(tree_sortkey, 1, 6)
                                from forums_messages_pending
                                where forum_id = :forum_id)
            order by tree_sortkey
        </querytext>
    </fullquery>

</queryset>
