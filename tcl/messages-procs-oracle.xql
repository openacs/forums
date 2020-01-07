<?xml version="1.0"?>

<queryset>
    <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

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
