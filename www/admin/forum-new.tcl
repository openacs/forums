ad_page_contract {
    
    Create a Forum

    @author Ben Adida (ben@openforce)
    @creation-date 2002-05-25
    @version $Id$

} -query {
    {name ""}
}

set package_id [ad_conn package_id]

form create forum

element create forum forum_id \
    -label "Forum ID" \
    -datatype integer \
    -widget hidden

element create forum name \
    -label Name \
    -datatype text \
    -widget text \
    -html {size 60}

element create forum charter \
    -label Charter \
    -datatype text \
    -widget textarea \
    -html {cols 60 rows 10 wrap soft} \
    -optional

element create forum presentation_type \
    -label Presentation \
    -datatype text \
    -widget select \
    -options {{Flat flat} {Threaded threaded}}

element create forum posting_policy \
    -label "Posting Policy" \
    -datatype text \
    -widget select \
    -options {{open open} {moderated moderated} {closed closed}}

element create forum new_threads_p \
    -label "Users Can Create New Threads" \
    -datatype integer \
    -widget radio \
    -options {{yes 1} {no 0}}

if {[form is_valid forum]} {
    template::form get_values forum \
        forum_id name charter presentation_type posting_policy new_threads_p

    set forum_id [forum::new -forum_id $forum_id \
        -name $name \
        -charter $charter \
        -presentation_type $presentation_type \
        -posting_policy $posting_policy \
        -package_id $package_id \
    ]

    # Users can create new threads?
    if {$new_threads_p} {
        forum::new_questions_allow -forum_id $forum_id
    } else {
        forum::new_questions_deny -forum_id $forum_id
    }

    ad_returnredirect "../"
    ad_script_abort
}

set context [list "Create New Forum"]

if { [form is_request forum] } {
    # Pre-fetch the forum_id
    set forum_id [db_nextval acs_object_id_seq]
    element set_properties forum forum_id -value $forum_id
    element set_properties forum name -value $name
    element set_properties forum presentation_type -value threaded
    element set_properties forum new_threads_p -value 1
}

ad_return_template
