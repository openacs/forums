<?xml version="1.0"?>

<queryset>
    <rdbms><type>postgresql</type><version>7.1</version></rdbms>

    <fullquery name="forum::message::get.select_message">
        <querytext>
            select message_id,
                   forum_id,
                   subject,
                   content,
                   person__name(user_id) as user_name, 
                   party__email(user_id) as user_email,
                   user_id,
                   forums_forum__name(forum_id) as forum_name, 
                   forums_message__root_message_id(forums_messages.message_id) as root_message_id,
                   (select subject
                    from forums_messages fm2 
                    where message_id = forums_message__root_message_id(forums_messages.message_id)) as root_subject, 
                   to_char(posting_date, 'Mon DD YYYY HH24:MI:SS') as posting_date,
                   tree_sortkey,
                   parent_id,
                   state,
                   html_p
            from forums_messages
            where message_id= :message_id
        </querytext>
    </fullquery>

    <fullquery name="forum::message::do_notifications.select_forums_package_url">
        <querytext>
            select site_node__url(node_id)
            from site_nodes
            where object_id = (select package_id
                               from forums_forums
                               where forums_forums.forum_id = :forum_id)
        </querytext>
    </fullquery>

    <fullquery name="forum::message::delete.delete_message">
        <querytext>
            declare begin
                forums_message__delete_thread(:message_id);
            end;
        </querytext>
    </fullquery>

    <fullquery name="forum::message::close.thread_close">
        <querytext>
            declare begin
                forums_message__thread_close(:message_id);
            end;
        </querytext>
    </fullquery>

    <fullquery name="forum::message::open.thread_open">
        <querytext>
            declare begin
                forums_message__thread_open(:message_id);
            end;
        </querytext>
    </fullquery>

</queryset>
