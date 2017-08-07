ad_page_contract {
    <p>Include for displaying the latest threads/posts in a forums instance.
    Note this takes the following parameters - not declared with
    ad_page_contract because it's an include:

    <ul>
      <li>package_id - the ID of the forums instance to use
      <li>base_url - absolute URL of the forums instance
      <li>n - the maximum number of threads/posts to list (default 2)
      <li>class - CSS class to wrap the include in (optional)
      <li>id - CSS id to wrap the include in (optional)
      <li>cache - cache interval, seconds, 0 for no cache (default)
      <li>show_empty_p - if set, show even if there are no contents (default 1)
    </ul>
}

# validate args
if { (![info exists package_id] || $package_id eq "")
     && (![info exists base_url] || $base_url eq "") } {
    error "package_id and/or base_url must be given"
}
if { [info exists n] } {
    # need to do a type check, as this is interpolated into the PG query
    # (PG LIMIT clause doesn't accept bind vars)
    if { ![string is integer $n] || $n > 0 } {
        error "n must be an integer greater than 0"
    }
} else {
    set n 2
}
if {![info exists class]} {
    set class ""
}
if { ![info exists cache] || $cache < 0 } {
    set cache 0
}
if { ![info exists package_id] || $package_id eq "" } {
    set package_id [site_node::get_element \
                        -url $base_url -element object_id]
}
if { ![info exists base_url] || $base_url eq "" } {
    set base_url [lindex [site_node::get_url_from_object_id \
                              -object_id $package_id] 0]
}
if { ![info exists title] } {
    set title [apm_instance_name_from_id $package_id]
}
if { ![info exists show_empty_p] } {
    set show_empty_p 1
}


# obtain data (use list rather than multirow, as its easier to cache)
# identification problems (need package_id + n as part of key)
set new_topics_ds [db_list_of_lists -cache_key "new_topics_${n}_$package_id" \
		       new_topics {}]
set hot_topics_ds [db_list_of_lists -cache_key "hot_topics_${n}_$package_id" \
		       hot_topics {}]

multirow create new_topics name url
foreach row $new_topics_ds {
    set name [lindex $row 0]
    set thread_id [lindex $row 1]
    set url "${base_url}message-view?message_id=$thread_id"
    multirow append new_topics $name $url
}

multirow create hot_topics name url
foreach row $hot_topics_ds {
    set name [lindex $row 0]
    set thread_id [lindex $row 1]
    set message_id [lindex $row 2]
    set url "${base_url}message-view?message_id=${thread_id}&\#${message_id}"
    multirow append hot_topics $name $url
}

ad_return_template

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
