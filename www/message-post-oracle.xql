<?xml version="1.0"?>
<queryset>
    <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

    <fullquery name="select_date">
        <querytext>
          select to_char(sysdate, 'Mon DD YYYY HH24:MI:SS') 
          from dual
        </querytext>
    </fullquery>

</queryset>
