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
