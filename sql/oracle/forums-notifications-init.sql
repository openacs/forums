
--
-- The Forums Package
--
-- @author gwong@orchardlabs.com,ben@openforce.biz
-- @creation-date 2002-05-16
--
-- This code is newly concocted by Ben, but with significant concepts and code
-- lifted from Gilbert's UBB forums. Thanks Orchard Labs.
--

-- the integration with Notifications

declare
        v_foo   integer;
begin
        v_foo:= notification_type.new (
                short_name => 'forums_forum_notif',
                pretty_name => 'Forum Notification',
                description => 'Notifications for Entire Forums',
                creation_user => NULL,
                creation_ip => NULL
                );

        -- enable the various intervals and delivery methods
        insert into notification_types_intervals
        (type_id, interval_id)
        select v_foo, interval_id
        from notification_intervals where name in ('instant','hourly','daily');

        insert into notification_types_del_methods
        (type_id, delivery_method_id)
        select v_foo, delivery_method_id
        from notification_delivery_methods where short_name in ('email');

        v_foo:= notification_type.new (
                short_name => 'forums_message_notif',
                pretty_name => 'Message Notification',
                description => 'Notifications for Message Thread',
                creation_user => NULL,
                creation_ip => NULL
                );

        -- enable the various intervals and delivery methods
        insert into notification_types_intervals
        (type_id, interval_id)
        select v_foo, interval_id
        from notification_intervals where name in ('instant','hourly','daily');

        insert into notification_types_del_methods
        (type_id, delivery_method_id)
        select v_foo, delivery_method_id
        from notification_delivery_methods where short_name in ('email');

end;
/
show errors
