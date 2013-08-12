
--
-- The Forums Package
--
-- @author gwong@orchardlabs.com,ben@openforce.biz
-- @creation-date 2002-05-16
--
-- This code is newly concocted by Ben, but with significant concepts and code
-- lifted from Gilbert. Thanks Orchard Labs!
--

--
-- This is the sortkey code
--



--
-- procedure forums_mess_insert_tr/0
--
CREATE OR REPLACE FUNCTION forums_mess_insert_tr(

) RETURNS trigger AS $$
DECLARE
    v_max_child_sortkey             forums_forums.max_child_sortkey%TYPE;
    v_parent_sortkey                forums_messages.tree_sortkey%TYPE;
BEGIN

    if new.parent_id is null
    then

        select '', max_child_sortkey
        into v_parent_sortkey, v_max_child_sortkey
        from forums_forums
        where forum_id = new.forum_id
        for update;

        v_max_child_sortkey := tree_increment_key(v_max_child_sortkey);

        update forums_forums
        set max_child_sortkey = v_max_child_sortkey
        where forum_id = new.forum_id;

    else

        select coalesce(tree_sortkey, ''), max_child_sortkey
        into v_parent_sortkey, v_max_child_sortkey
        from forums_messages
        where message_id = new.parent_id
        for update;

        v_max_child_sortkey := tree_increment_key(v_max_child_sortkey);

        update forums_messages
        set max_child_sortkey = v_max_child_sortkey
        where message_id = new.parent_id;

    end if;

    new.tree_sortkey := v_parent_sortkey || v_max_child_sortkey;

    return new;
END;
$$ LANGUAGE plpgsql;

create trigger forums_mess_insert_tr
before insert on forums_messages
for each row
execute procedure forums_mess_insert_tr();
