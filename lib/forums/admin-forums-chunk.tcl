ad_page_contract {

    Forums Administration

    @author Ben Adida (ben@openforce.net)
    @creation-date 2002-05-24
    @cvs-id $Id$

}
set subsite_url [subsite::get_element -element url -notrailing]

template::list::create \
    -name forums \
    -multirow forums \
    -actions [list \
                  [_ forums.Create_a_New_Forum] forum-new {} \
                  [_ forums.Parameters] [export_vars -base "$subsite_url/shared/parameters" { { return_url [ad_return_url] } { package_id {[ad_conn package_id]} } }] {} \
                  [_ acs-subsite.Permissions] [export_vars -base "permissions" { { object_id {[ad_conn package_id]} } }] {}
              ]\
    -elements {
        edit {
            label {}
            sub_class narrow
            display_template {
                <a href="@forums.edit_url@" title="#forums.Edit_forum# @forums.name@"><img src="/shared/images/Edit16.gif" height="16" width="16" alt="edit"></a>
            }
        }
        name {
            label "#forums.Forum_Name#"
            link_url_col view_url
        }
        enabled {
            label "Enabled"
            html { align center }
            display_template {
                <if @forums.enabled_p;literal@ true>
                  <a href="@forums.disable_url@" title="Disable forum @forums.name@"><img src="/resources/acs-subsite/checkboxchecked.gif" height="13" width="13" style="background-color: white;" alt="\#forums.disable\#"></a>
                </if>
                <else>
                  <a href="@forums.enable_url@" title="Enable forum @forums.name@"><img src="/resources/acs-subsite/checkbox.gif" height="13" width="13" style="background-color: white;" alt="\#forums.enable\#"></a>
                </else>
            }
        }
        permissions {
            label "#acs-subsite.Permissions#"
            display_template {<a href="@forums.permissions_url@" title="@forums.name@ #acs-subsite.Permissions#">#acs-subsite.Permissions#</a>}
        }
    }


# List of forums
set package_id [ad_conn package_id]
db_multirow -extend {
    view_url
    edit_url
    permissions_url
    enable_url
    disable_url
}  forums select_forums {} {
    if { [template::util::is_true $enabled_p] } {
        set view_url [export_vars -base "[ad_conn package_url]forum-view" { forum_id }]
    } else {
        set view_url {}
    }
    set edit_url [export_vars -base "forum-edit" { forum_id }]
    set permissions_url [export_vars -base permissions { { object_id $forum_id } }]
    set enable_url [export_vars -base "forum-enable" { forum_id }]
    set disable_url [export_vars -base "forum-disable" { forum_id }]
}

if {[info exists alt_template] && $alt_template ne ""} {
  ad_return_template $alt_template
}

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
