ad_page_contract {
    
    Forums History 

    @author Natalia Pérez (nperper@it.uc3m.es)
    @creation-date 2005-03-17    

}

set package_id [ad_conn package_id]
set user_id [ad_conn user_id]

# get the colors from the params
set table_border_color [parameter::get -parameter table_border_color]
set table_bgcolor [parameter::get -parameter table_bgcolor]
set table_other_bgcolor [parameter::get -parameter table_other_bgcolor]

set visitor_name [_ acs-kernel.Unregistered_Visitor]
# provide screen_name functionality
set screen_name [expr {$user_id > 0 ?
                       [acs_user::get_element -user_id $user_id -element screen_name] :
                       $visitor_name}]
set useScreenNameP [parameter::get -parameter "UseScreenNameP" -default 0]

template::list::create \
    -html {width 50%} \
    -name persons \
    -multirow persons \
    -key message_id \
    -pass_properties {useScreenNameP screen_name} \
    -elements {
	name {
	    label "\#forums.User\#"
	    html {align left}
            display_template {
                <if @useScreenNameP;literal@ true>
                    @screen_name@
                </if>
                <else>
                <if @persons.user_id;literal@ ne 0><a href="@persons.user_url@"></if>
                @persons.user_name@
                <if @persons.user_id;literal@ ne 0></a></if>
                </else>
            }
	}
	num_msg {
	    label "\#forums.Number_of_Posts\#"
	    html {align left}
	}
	last_post {
	    label "\#forums.Posted\#"
	    html {align right}
	}
    }

db_multirow -extend {
    user_name
    user_url
} persons select_users_wrote_post {
    select user_id,
           count(*) as num_msg,
           to_char(max(last_child_post), 'YYYY-MM-DD HH24:MI:SS') as last_post
      from forums_messages
     where forum_id = :forum_id 
     group by user_id
} {
    if {$user_id > 0} {
        set user_name [person::name -person_id $user_id]
        set user_url user-history?user_id=$user_id
    } else {
        set user_name $visitor_name
        set user_url "#"
    }
}

if {[info exists alt_template] && $alt_template ne ""} {
  ad_return_template $alt_template
}

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
