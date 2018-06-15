<?xml version="1.0"?>

<queryset>
    <rdbms><type>postgresql</type><version>7.1</version></rdbms>

    <fullquery name="forum::message::get.select_message">
        <querytext>
            select forums_messages.*,
                   tree_level(forums_messages.tree_sortkey) as tree_level,
                   forums_message__root_message_id(forums_messages.message_id) as root_message_id,
                   (select subject from forums_messages
                     where message_id = forums_message__root_message_id(forums_messages.message_id)) as root_subject,
                   to_char(forums_messages.posting_date, 'YYYY-MM-DD HH24:MI:SS') as posting_date_ansi
            from forums_messages
            where forums_messages.message_id= :message_id
        </querytext>
    </fullquery>

    <fullquery name="forum::message::get.select_message_with_attachment">
        <querytext>
            select forums_messages.*,
                   (select count(*) from attachments where object_id= message_id) as n_attachments,
                   forums_message__root_message_id(forums_messages.message_id) as root_message_id,
                   (select subject from forums_messages
                    where message_id = forums_message__root_message_id(forums_messages.message_id)) as root_subject, 
                   to_char(forums_messages.posting_date, 'YYYY-MM-DD HH24:MI:SS') as posting_date_ansi
            from forums_messages
            where forums_messages.message_id= :message_id
        </querytext>
    </fullquery>

    <fullquery name="forum::message::close.thread_close">
        <querytext>
            select forums_message__thread_close(:message_id);
        </querytext>
    </fullquery>

    <fullquery name="forum::message::open.thread_open">
        <querytext>
            select forums_message__thread_open(:message_id);
        </querytext>
    </fullquery>

</queryset>
