
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
create function inline_0 ()
returns integer as '
declare
    v_foo                           integer;
begin

    v_foo := notification_type__new(
        null,
        ''forums_forum_notif'',
        ''Forum Notification'',
        ''Notifications for Entire Forums'',
        null,
        null,
        null,
        null
    );

    -- enable the various intervals and delivery methods
    insert into notification_types_intervals
    (type_id, interval_id)
    select v_foo, interval_id
    from notification_intervals
    where name in (''instant'',''hourly'',''daily'');

    insert into notification_types_del_methods
    (type_id, delivery_method_id)
    select v_foo, delivery_method_id
    from notification_delivery_methods
    where short_name in (''email'');

    v_foo := notification_type__new(
        null,
        ''forums_message_notif'',
        ''Message Notification'',
        ''Notifications for Message Thread'',
        null,
        null,
        null,
        null
    );

    -- enable the various intervals and delivery methods
    insert into notification_types_intervals
    (type_id, interval_id)
    select v_foo, interval_id
    from notification_intervals
    where name in (''instant'',''hourly'',''daily'');

    insert into notification_types_del_methods
    (type_id, delivery_method_id)
    select v_foo, delivery_method_id
    from notification_delivery_methods
    where short_name in (''email'');

    return null;

end;' language 'plpgsql';

select inline_0();
drop function inline_0 ();
