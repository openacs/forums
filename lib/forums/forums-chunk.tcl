ad_page_contract {

    top level list of forums

    @author Ben Adida (ben@openforce.net)
    @creation-date 2002-05-24
    @cvs-id $Id$

}

set package_id [ad_conn package_id]
set user_id [ad_verify_and_get_user_id]

set admin_p [permission::permission_p -object_id $package_id -privilege admin]

# get the colors from the params
set table_border_color [parameter::get -parameter table_border_color]
set table_bgcolor [parameter::get -parameter table_bgcolor]
set table_other_bgcolor [parameter::get -parameter table_other_bgcolor]

set actions [list]
if { $admin_p } {
    lappend actions [_ forums.New_Forum] "admin/forum-new" {}
    lappend actions [_ forums.Administration] "admin/" {}
}

template::list::create \
    -name forums \
    -actions $actions \
    -no_data [_ forums.No_Forums] \
    -elements {
        name {
            label {\#forums.Forum_Name\#}
            link_url_col forum_view_url
            display_template {
                <if @forums.new_p@ and @forums.n_threads@ gt 0>
                  <strong>
                </if>
                @forums.name@
                <if @forums.new_p@ and @forums.n_threads@ gt 0>
                  </strong>
                </if>
            }
        }
        n_threads {
            label {\#forums.Threads\#}
            display_col n_threads_pretty
            html { align right }
        }
        last_post {
            label {\#forums.Last_Post\#}
            display_col last_modified_pretty
        }
    }

db_multirow -extend { forum_view_url last_modified_pretty n_threads_pretty } forums select_forums {} {
    set last_modified_pretty [lc_time_fmt $last_post_ansi "%x %X"]
    set forum_view_url [export_vars -base forum-view { forum_id }]
    set n_threads_pretty [lc_numeric $n_threads]
}

if {[exists_and_not_null alt_template]} {
  ad_return_template $alt_template
}
