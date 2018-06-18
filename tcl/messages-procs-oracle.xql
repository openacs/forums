<?xml version="1.0"?>

<queryset>
    <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

    <fullquery name="forum::message::get.select_message">
        <querytext>
            select m.*,
                   0 as n_attachments,
                   forums_message.root_message_id(m.message_id) as root_message_id,
                   (select subject from forums_messages
                    where message_id = forums_message.root_message_id(m.message_id)) as root_subject, 
                   to_char(m.posting_date, 'YYYY-MM-DD HH24:MI:SS') as posting_date_ansi
            from forums_messages m
            where m.message_id = :message_id
        </querytext>
    </fullquery>

    <fullquery name="forum::message::get.select_message_with_attachment">
        <querytext>
            select m.*,
                   (select count(*) from attachments where object_id = m.message_id) as n_attachments,
                   forums_message.root_message_id(m.message_id) as root_message_id,
                   (select subject from forums_messages
                    where message_id = forums_message.root_message_id(m.message_id)) as root_subject, 
                   to_char(m.posting_date, 'YYYY-MM-DD HH24:MI:SS') as posting_date_ansi
            from forums_messages m
            where m.message_id = :message_id
        </querytext>
    </fullquery>

    <fullquery name="forum::message::close.thread_close">
        <querytext>
            declare begin
                forums_message.thread_close(:message_id);
            end;
        </querytext>
    </fullquery>

    <fullquery name="forum::message::open.thread_open">
        <querytext>
            declare begin
                forums_message.thread_open(:message_id);
            end;
        </querytext>
    </fullquery>

</queryset>
