ad_library {
    message formatting procs
}

namespace eval forum::format {

    ad_proc -public reply_subject { parent_subject } {

        Generates a subject string for a reply to an existing message.

        The prefix is always added using the system-wide locale to avoid
        the uncontrollable growth of the subject in a multi-language
        environment.

    } {

        set prefix [lang::message::lookup [lang::system::site_wide_locale] forums.Re]
        set prefix "[string trim $prefix] "

        # trim multiple leading prefixes:
        regsub "^($prefix)+" $parent_subject {} parent_subject

        set subject [concat $prefix $parent_subject]

        return $subject

    }

    ad_proc emoticons {
        {-content:required}
    } {
        Convert smileys (emoticons) in supplied content into emoji
        HTML entities.

        @see https://unicode.org/emoji/charts/full-emoji-list.html
    } {
        set emoticons_map [list]

        # if you change this list, consider changing
        # www/doc/emoticons.adp as well
        set emoticons_map {
            ":-)" "&#x1F60A;"
            ";-)" "&#x1F609;"
            ":-D" "&#x1F603;"
            "8-)" "&#x1F60E;"
            ":-(" "&#x1F61F;"
            ";-(" "&#x1F622;"
            ":-O" "&#x1F631;"
            ":-/" "&#x1F914;"
        }
        return [string map $emoticons_map $content]
    }

}

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
