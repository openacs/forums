<?xml version="1.0"?>

<queryset>
    <rdbms><type>postgresql</type><version>7.1</version></rdbms>

    <fullquery name="select_message_responses">
        <querytext>
            select message_id,
                   subject,
                   content,
                   person__name(user_id) as user_name,
                   to_char(posting_date, 'Mon DD YYYY HH24:MI:SS') as posting_date,
                   tree__tree_level(tree_sortkey) as tree_level,
                   state,
                   user_id
            from forums_messages_approved
            where forum_id = :forum_id
            and tree_sortkey between tree__left(:tree_sortkey) and tree__right(:tree_sortkey)
            order by tree_sortkey
        </querytext>
    </fullquery>

    <fullquery name="select_message_responses_flat">
        <querytext>
            select message_id,
                   subject,
                   content,
                   person__name(user_id) as user_name,
                   to_char(posting_date, 'Mon DD YYYY HH24:MI:SS') as posting_date,
                   tree__tree_level(tree_sortkey) as tree_level,
                   state,
                   user_id
            from forums_messages_approved
            where forum_id = :forum_id
            and tree_sortkey between tree__left(:tree_sortkey) and tree__right(:tree_sortkey)
            order by posting_date, tree_sortkey
        </querytext>
    </fullquery>

    <fullquery name="select_message_responses_moderator">
        <querytext>
            select message_id,
                   subject,
                   content,
                   person__name(user_id) as user_name,
                   to_char(posting_date, 'Mon DD YYYY HH24:MI:SS') as posting_date,
                   tree__tree_level(tree_sortkey) as tree_level,
                   state,
                   user_id
            from forums_messages
            where forum_id = :forum_id
            and tree_sortkey between tree__left(:tree_sortkey) and tree__right(:tree_sortkey)
            order by tree_sortkey
        </querytext>
    </fullquery>

    <fullquery name="select_message_responses_moderator_flat">
        <querytext>
            select message_id,
                   subject,
                   content,
                   person__name(user_id) as user_name,
                   to_char(posting_date, 'Mon DD YYYY HH24:MI:SS') as posting_date,
                   tree__tree_level(tree_sortkey) as tree_level,
                   state,
                   user_id
            from forums_messages
            where forum_id = :forum_id
            and tree_sortkey between tree__left(:tree_sortkey) and tree__right(:tree_sortkey)
            order by posting_date, tree_sortkey
        </querytext>
    </fullquery>

</queryset>
