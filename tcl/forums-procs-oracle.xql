<?xml version="1.0"?>

<queryset>
    <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

    <fullquery name="forum::delete.forum_delete">
        <querytext>
            select forums_forum.del(:forum_id);
        </querytext>
    </fullquery>
</queryset>
