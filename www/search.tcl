ad_page_contract {

    @author <a href="mailto:yon@openforce.net">yon@openforce.net</a>
    @creation-date 2002-07-01
    @version $Id$

} -query {
    {forum_id ""}
}

set package_id [ad_conn package_id]

form create search

element create search search_text \
    -label Search \
    -datatype text \
    -widget text \
    -html {size 60}

element create search forum_id \
    -label ForumID \
    -datatype text \
    -widget hidden \
    -value $forum_id \
    -optional

if {[form is_valid search]} {
    form get_values search search_text forum_id

    # remove any special characters from the search text so we
    # don't crash interMedia
    regsub -all {[^[:alnum:]_[:blank:]]} $search_text {} search_text

    ns_log notice "YON: search_text is $search_text"

    set query search_all_forums
    if {![empty_string_p $forum_id]} {
        set query search_one_forum
    }

    db_multirow messages $query {}

} else {
    set messages:rowcount 0
}

set context_bar {Search}

ad_return_template
