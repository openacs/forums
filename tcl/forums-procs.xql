<?xml version="1.0"?>
<queryset>

<fullquery name="forum::edit.update_forum">
<querytext>
update forums_forums set
name= :name,
charter= :charter,
presentation_type= :presentation_type,
posting_policy= :posting_policy
where 
forum_id= :forum_id
</querytext>
</fullquery>

<fullquery name="forum::get.select_forum">      
      <querytext>
      
        select * from forums_forums where forum_id = :forum_id
    
      </querytext>
</fullquery>

<fullquery name="forum::enable.update_forum_enabled_p">
<querytext>
update forums_forums set enabled_p='t'
where forum_id= :forum_id
</querytext>
</fullquery> 

<fullquery name="forum::disable.update_forum_disabled_p">
<querytext>
update forums_forums set enabled_p='f'
where forum_id= :forum_id
</querytext>
</fullquery>
 
</queryset>
