
--
-- The Forums Package
--
-- @author gwong@orchardlabs.com,ben@openforce.biz
-- @creation-date 2002-05-16
--
-- The Package for Messages
--
-- This code is newly concocted by Ben, but with heavy concepts and heavy code
-- chunks lifted from Gilbert. Thanks Orchard Labs!
--

create or replace package forums_message
as
        function new (
           message_id                   in forums_messages.message_id%TYPE default null,
           object_type                  in acs_objects.object_type%TYPE default 'forums_message',
           forum_id                     in forums_messages.forum_id%TYPE,
           subject                      in forums_messages.subject%TYPE,
           content                      in varchar,
           html_p                       in forums_messages.html_p%TYPE default 'f',
           user_id                      in forums_messages.user_id%TYPE,
           posting_date                 in forums_messages.posting_date%TYPE default sysdate,
           state                        in forums_messages.state%TYPE default null,
           parent_id                    in forums_messages.parent_id%TYPE default null,
           creation_date                in acs_objects.creation_date%TYPE default sysdate,
           creation_user                in acs_objects.creation_user%TYPE,
           creation_ip                  in acs_objects.creation_ip%TYPE,
           context_id                   in acs_objects.context_id%TYPE default null
        ) return forums_messages.message_id%TYPE;

        function root_message_id (
           message_id in forums_messages.message_id%TYPE
        ) return forums_messages.message_id%TYPE;

        procedure thread_open (
           message_id in forums_messages.message_id%TYPE
        );

        procedure thread_close (
           message_id in forums_messages.message_id%TYPE
        );
        
        procedure delete (
           message_id in forums_messages.message_id%TYPE
        );

        procedure delete_thread (
           message_id in forums_messages.message_id%TYPE
        );
end forums_message;
/
show errors



create or replace package body forums_message
as
        function new (
           message_id                   in forums_messages.message_id%TYPE default null,
           object_type                  in acs_objects.object_type%TYPE default 'forums_message',
           forum_id                     in forums_messages.forum_id%TYPE,
           subject                      in forums_messages.subject%TYPE,
           content                      in varchar,
           html_p                       in forums_messages.html_p%TYPE default 'f',
           user_id                      in forums_messages.user_id%TYPE,
           posting_date                 in forums_messages.posting_date%TYPE default sysdate,
           state                        in forums_messages.state%TYPE default null,
           parent_id                    in forums_messages.parent_id%TYPE default null,
           creation_date                in acs_objects.creation_date%TYPE default sysdate,
           creation_user                in acs_objects.creation_user%TYPE,
           creation_ip                  in acs_objects.creation_ip%TYPE,
           context_id                   in acs_objects.context_id%TYPE default null
        ) return forums_messages.message_id%TYPE
        is
           v_message_id                 acs_objects.object_id%TYPE;
           v_forum_policy               forums_forums.posting_policy%TYPE;
           v_state                      forums_messages.state%TYPE;
        begin
           v_message_id := acs_object.new (
                                 object_id => message_id,
                                 object_type => object_type,
                                 creation_date => creation_date,
                                 creation_user => creation_user,
                                 creation_ip => creation_ip,
                                 context_id => nvl(context_id,forum_id)
                           );
           
           IF state is NULL
           then
                select posting_policy into v_forum_policy from forums_forums
                where forum_id= new.forum_id;
                
                if v_forum_policy = 'moderated'
                then v_state := 'pending';
                else v_state := 'approved';
                end if;
           else
                v_state := state;
           end if;

           insert into forums_messages
           (message_id, forum_id, subject, content, html_p, user_id, posting_date, parent_id, state)
           values
           (v_message_id, forum_id, subject, content, html_p, user_id, posting_date, parent_id, v_state);

            acs_object.update_last_modified(forum_id);

           return v_message_id;
        end new;
        
        function root_message_id (
           message_id in forums_messages.message_id%TYPE
        ) return forums_messages.message_id%TYPE
        is 
           v_message_id forums_messages.message_id%TYPE;
           v_forum_id   forums_messages.forum_id%TYPE;
           v_sortkey    forums_messages.tree_sortkey%TYPE;
        begin
           select forum_id, tree_sortkey into v_forum_id, v_sortkey
           from forums_messages where message_id= root_message_id.message_id;

           select message_id into v_message_id from forums_messages where forum_id= v_forum_id
           and tree_sortkey= tree.ancestor_key(v_sortkey, 1);

           return v_message_id;
        end root_message_id;

        procedure thread_open (
           message_id in forums_messages.message_id%TYPE
        )
        is
           v_forum_id           forums_messages.forum_id%TYPE;
           v_sortkey            forums_messages.tree_sortkey%TYPE;
        begin
           select forum_id, tree_sortkey into v_forum_id, v_sortkey
           from forums_messages where message_id= thread_open.message_id;

           update forums_messages set open_p='t'
           where tree_sortkey between tree.left(v_sortkey) and tree.right(v_sortkey)
           and forum_id = v_forum_id;

           update forums_messages set open_p='t'
           where message_id= thread_open.message_id;
        end thread_open;

        procedure thread_close (
           message_id in forums_messages.message_id%TYPE
        )
        is
           v_forum_id           forums_messages.forum_id%TYPE;
           v_sortkey            forums_messages.tree_sortkey%TYPE;
        begin
           select forum_id, tree_sortkey into v_forum_id, v_sortkey
           from forums_messages where message_id= thread_close.message_id;

           update forums_messages set open_p='f'
           where tree_sortkey between tree.left(v_sortkey) and tree.right(v_sortkey)
           and forum_id = v_forum_id;

           update forums_messages set open_p='f'
           where message_id= thread_close.message_id;
        end thread_close;
        
        procedure delete (
           message_id in forums_messages.message_id%TYPE
        )
        is
        begin
           acs_object.delete(message_id);
        end delete;

        procedure delete_thread (
           message_id in forums_messages.message_id%TYPE
        )
        is
           v_forum_id           forums_messages.forum_id%TYPE;
           v_sortkey            forums_messages.tree_sortkey%TYPE;
           v_message            forums_messages%ROWTYPE;
        begin
           select forum_id, tree_sortkey into v_forum_id, v_sortkey
           from forums_messages where message_id= delete_thread.message_id;
           
           -- if it's already deleted
           if SQL%NOTFOUND
           then return;
           end if;

           -- delete all children
           -- order by tree_sortkey desc to guarantee
           -- that we never delete a parent before its child
           -- sortkeys are beautiful
           FOR v_message in
           (select * from forums_messages
           where forum_id = v_forum_id and 
           tree_sortkey between tree.left(v_sortkey) 
           and tree.right(v_sortkey) order by tree_sortkey desc)
           LOOP
                forums_message.delete(v_message.message_id);
           END LOOP;

           -- delete the message itself
           forums_message.delete(delete_thread.message_id);
        end delete_thread;

end forums_message;
/
show errors

