ad_page_contract {
    Permissions for the subsite itself.
    
    @author Lars Pind (lars@collaboraid.biz)
    @creation-date 2003-06-13
    @cvs-id $Id$
} {
    object_id:integer
}

forum::get -forum_id $object_id -array forum

set page_title "$forum(name) Permissions"

set context [list $page_title]

