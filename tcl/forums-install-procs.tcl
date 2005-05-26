ad_library {
    Forums install callbacks

    @creation-date 2004-04-01
    @author Jeff Davis davis@xarg.net
    @cvs-id $Id$
}

namespace eval forum::install {}

ad_proc -private forum::install::package_install {} { 
    package install callback
} {
    forum::sc::register_implementations
}

ad_proc -private forum::install::package_uninstall {} { 
    package uninstall callback
} {
    forum::sc::unregister_implementations
}

ad_proc -private forum::install::package_upgrade {
    {-from_version_name:required}
    {-to_version_name:required}
} {
    Package before-upgrade callback
} {
    apm_upgrade_logic \
        -from_version_name $from_version_name \
        -to_version_name $to_version_name \
        -spec {
            1.1d3 1.1d4 {
                # just need to install the forum_forum callback
                forum::sc::register_forum_fts_impl
            }
        }
}

ad_proc -private ::install::xml::action::forum-create { node } {
    Create a forum instance from an install.xml file
} {
    set url [apm_required_attribute_value $node url]
    set name [apm_required_attribute_value $node name]
    set presentation [apm_attribute_value -default "flat" $node presentation]
    set id [apm_attribute_value -default "" $node id]
    set posting_policy [apm_attribute_value -default "open" $node posting-policy]


    set charter_node [lindex [xml_node_get_children_by_name [lindex $node 0] charter] 0]
    set charter [xml_node_get_content $charter_node]

    set package_id [site_node::get_element -url $url -element package_id]

    set forum_id [forum::new \
                      -name $name \
                      -charter $charter \
                      -presentation_type $presentation \
                      -posting_policy $posting_policy \
                      -package_id $package_id]

    if {![string equal $id ""]} {
        set ::install::xml::ids($id) $forum_id
    }
}

ad_proc -public -callback forum::forum_new {
    {-package_id:required}
    {-forum_id:required}
} {
}

ad_proc -public -callback forum::forum_edit {
    {-package_id:required}
    {-forum_id:required}
} {
}

ad_proc -public -callback forum::forum_delete {
    {-package_id:required}
    {-forum_id:required}
} {
}

ad_proc -public -callback forum::message_new {
    {-package_id:required}
    {-message_id:required}
} {
}

ad_proc -public -callback forum::message_edit {
    {-package_id:required}
    {-message_id:required}
} {
}

ad_proc -public -callback forum::message_delete {
    {-package_id:required}
    {-message_id:required}
} {
}

ad_proc -public -callback pm::project_new -impl forums {
    {-package_id:required}
    {-project_id:required}
} {
    create a new forum for each new project
} {
    set pm_name [pm::project::name -project_item_id $project_id]

    foreach forum_package_id [application_link::get_linked -from_package_id $package_id -to_package_key "forums"] {
	set forum_id [forum::new \
			  -name $pm_name \
			  -package_id $forum_package_id \
			  -no_callback]

	application_data_link::new -this_object_id $project_id -target_object_id $forum_id
    }
}
