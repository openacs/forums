<?xml version="1.0"?>
<queryset>

    <fullquery name="messages_select_paginate">
        <querytext>
            select message_id, subject
            from forums_messages_approved 
            where forum_id = :forum_id
            and parent_id is null
            [template::list::orderby_clause -orderby -name messages]
        </querytext>
    </fullquery>

    <partialquery name="orderby_user_name_desc">
        <querytext>
      user_name desc
        </querytext>
    </partialquery>
    <partialquery name="orderby_user_name_asc">
        <querytext>
      user_name asc
        </querytext>
    </partialquery>

</queryset>
