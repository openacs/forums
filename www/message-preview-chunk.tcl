ad_page_contract {
    
    a message preview chunk to be included elsewhere

    @author yon (yon@openforce.net)
    @creation-date 2002-06-02
    @version $Id$

}

if {![array exists message]} {
    ad_return_complaint 1 "Need to provide a message to display."
}
if {![exists_and_not_null bgcolor]} { set bgcolor "#ffffff" }
