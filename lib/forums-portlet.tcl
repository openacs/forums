ad_include_contract {
    Display the latest threads/posts in a forums instance.

    @param package_id        the ID of the forums instance to use
    @param base_url          absolute URL of the forums instance
    @param n                 the maximum number of threads/posts to list (default 2)
    @param class             CSS class to wrap the include in (default)
    @param id                CSS id to wrap the include in (default)
    @param cache             cache interval, seconds, 0 for no cache (default 0)
    @param show_empty_p      if set, show even if there are no contents (default 1)
} {
    {package_id:integer ""}
    {base_url:localurl ""}
    {n:naturalnum,notnull 2}
    {class:word ""}
    {id:word ""}
    {cache:naturalnum,notnull 0}
    {show_empty_p:boolean,notnull 1}
} -validate {
    package_id_or_base_url {
        if { $package_id eq "" && $base_url eq "" } {
            ad_complain
        }
    }
} -errors {
    package_id_or_base_url {package_id and/or base_url must be given}
}

if { $package_id eq "" } {
    set package_id [site_node::get_element \
                        -url $base_url -element object_id]
}
if { $base_url eq "" } {
    set base_url [lindex [site_node::get_url_from_object_id \
                              -object_id $package_id] 0]
}
if { ![info exists title] } {
    set title [apm_instance_name_from_id $package_id]
}

# obtain data (use list rather than multirow, as it's easier to cache)
# identification problems (need package_id + n as part of key)
set new_topics_ds [db_list_of_lists -cache_key "new_topics_${n}_$package_id" \
    new_topics {}]
set hot_topics_ds [db_list_of_lists -cache_key "hot_topics_${n}_$package_id" \
    hot_topics {}]

multirow create new_topics name url
foreach row $new_topics_ds {
    lassign $row name thread_id
    set url "${base_url}message-view?message_id=$thread_id"
    multirow append new_topics $name $url
}

multirow create hot_topics name url
foreach row $hot_topics_ds {
    lassign $row name thread_id message_id
    set url "${base_url}message-view?message_id=${thread_id}&\#${message_id}"
    multirow append hot_topics $name $url
}

ad_return_template

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
