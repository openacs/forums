ad_page_contract {
    Permissions for the subsite itself.
    
    @author Lars Pind (lars@collaboraid.biz)
    @creation-date 2003-06-13
    @cvs-id $Id$
} {
    object_id:object_type(apm_package|forums_forum)
}

if { $object_id == [ad_conn package_id] } {
    set page_title "Permissions"
} else {
    forum::get -forum_id $object_id -array forum
    set page_title "$forum(name) Permissions"
}

set context [list $page_title]


# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
