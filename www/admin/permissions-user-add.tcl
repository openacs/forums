ad_page_contract {
    Redirect page for adding users to the permissions list.
    
    @author Lars Pind (lars@collaboraid.biz)
    @creation-date 2003-06-13
    @cvs-id $Id$
} {
    object_id:object_type(apm_package|forums_forum)
}

if { $object_id == [ad_conn package_id] } {
    set what "Package"
} else {
    forum::get -forum_id $object_id -array forum
    set what "$forum(name)"
}

set page_title "Add User on $what"

set context [list [list [export_vars -base permissions { object_id }] "$what Permissions"] $page_title]

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
