ad_page_contract {
    
    Disable a Forum

    @author Ben Adida (ben@openforce)
    @creation-date 2002-05-28
    @version $Id$

} {
    forum_id:integer,notnull
}

forum::enable -forum_id $forum_id

ad_returnredirect "./forum-edit?forum_id=$forum_id"
