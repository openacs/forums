
ad_page_contract {
    
    Disable a Forum

    @author Ben Adida (ben@openforce)
    @creation-date 2002-05-28
    @cvs-id $id: Exp $
} {
    forum_id:integer,notnull
}

forum::enable -forum_id $forum_id

ad_returnredirect "./"
