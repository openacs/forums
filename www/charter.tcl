# packages/forums/www/charter.tcl

ad_page_contract {
    
    Display the charter of a forum
    
    @author sussdorff aolserver (sussdorff@ipxserver.de)
    @creation-date 2005-09-29
    @arch-tag: b5184736-5c5c-4dc1-a054-7edb96957ac9
    @cvs-id $Id$
} {
    forum_id
} -properties {
} -validate {
} -errors {
}

# Get forum data
forum::get -forum_id $forum_id -array forum

