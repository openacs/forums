<?xml version="1.0"?>

<queryset>
    <rdbms><type>postgresql</type><version>7.1</version></rdbms>

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
