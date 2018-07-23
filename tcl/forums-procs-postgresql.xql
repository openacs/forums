<?xml version="1.0"?>

<queryset>
    <rdbms><type>postgresql</type><version>9.1</version></rdbms>

    <fullquery name="forum::delete.forum_delete">
        <querytext>
            select forums_forum__delete(:forum_id);
        </querytext>
    </fullquery>
</queryset>
