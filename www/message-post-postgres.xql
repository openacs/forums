<?xml version="1.0"?>
<queryset>

    <fullquery name="select_name">
        <querytext>
          select first_names || ' ' || last_name
          from persons
          where person_id = :user_id
        </querytext>
    </fullquery>

    <fullquery name="messages_select">
        <querytext>
          select to_char(current_timestamp, 'Mon DD YYYY HH24:MI:SS') 
        </querytext>
    </fullquery>

</queryset>
