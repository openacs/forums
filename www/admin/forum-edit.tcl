ad_page_contract {
    
    Edit a Forum

    @author Ben Adida (ben@openforce)
    @creation-date 2002-05-25
    @version $Id$

} {
    forum_id:integer,notnull
}

form create forum

element create forum forum_id \
        -label "Forum ID" -datatype integer -widget hidden

element create forum name \
        -label "Name" -datatype text -widget text -html {size 60}

element create forum charter \
        -label "Charter" -datatype text -widget textarea -html {cols 60 rows 10 wrap soft}

element create forum presentation_type \
        -label "Presentation" -datatype text -widget select -options {{Flat flat} {Threaded threaded}}

element create forum posting_policy \
        -label "Posting Policy" -datatype text -widget select -options {{open open} {moderated moderated} {closed closed}}

element create forum new_threads_p \
        -label "Users Can Create New Threads" -datatype integer -widget radio -options {{yes 1} {no 0}}

if {[form is_valid forum]} {
    template::form get_values forum forum_id name charter presentation_type posting_policy new_threads_p

    forum::edit -forum_id $forum_id \
            -name $name \
            -charter $charter \
            -presentation_type $presentation_type \
            -posting_policy $posting_policy

    # Users can create new threads?
    if {$new_threads_p} {
        forum::new_questions_allow -forum_id $forum_id
    } else {
        forum::new_questions_deny -forum_id $forum_id
    }    

    ad_returnredirect "../forum-view?forum_id=$forum_id"
    ad_script_abort
}

# Select the info
set package_id [ad_conn package_id]
forum::get -forum_id $forum_id -array forum

# Proper scoping?
if {$package_id != $forum(package_id)} {
    ns_log Error "Forum Administration: Bad Scoping of Forum #$forum_id in Forum Editing"
    ad_returnredirect "./"
    ad_script_abort
}

element set_properties forum forum_id -value $forum_id
element set_properties forum name -value $forum(name)
element set_properties forum charter -value $forum(charter)
element set_properties forum presentation_type -value $forum(presentation_type)
element set_properties forum posting_policy -value $forum(posting_policy)
element set_properties forum new_threads_p -value [forum::new_questions_allowed_p -forum_id $forum_id]

ad_return_template
