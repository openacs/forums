
if {[info exists context_bar]} {
    set context_bar [eval ad_context_bar $context_bar]
} else {
    set context_bar ""
}
