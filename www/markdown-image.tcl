ad_page_contract {
    Display a staged or attached inline forum image.
} {
    key:notnull
    {width ""}
}

# Only fixed variants are accepted, so arbitrary requests cannot grow the cache.
if {$width ne "" && $width ni [attachments::image::widths]} {
    ns_return 400 text/plain "Unsupported image width."
    ad_script_abort
}
ns_set put [ns_conn outputheaders] X-Content-Type-Options nosniff

lassign [forum::markdown_image::parts $key] forum_id message_id uuid
if {$uuid eq ""} {
    ns_returnnotfound
    ad_script_abort
}

# A draft is only visible to its uploader.
ns_set put [ns_conn outputheaders] Cache-Control "private, no-store"
if {[ad_conn user_id] != 0} {
    set file [forum::markdown_image::draft_path $key]
    set mime [forum::markdown_image::mime_type $file]
    if {$mime ne ""} {
        ns_returnfile 200 $mime [attachments::image::variant $file $width]
        ad_script_abort
    }
}

# Verify the relation and use the same visibility rules as the message page.
set revision_id [forum::markdown_image::attachment $message_id $uuid]
if {$revision_id eq ""} {
    ns_returnnotfound
    ad_script_abort
}
forum::message::get -message_id $message_id -array message
forum::get -forum_id $message(forum_id) -array forum
if {$message(forum_id) ne $forum_id
    || $forum(package_id) ne [ad_conn package_id]
    || !$forum(enabled_p)} {
    ns_returnnotfound
    ad_script_abort
}
forum::security::require_read_forum -forum_id $forum_id
if {$message(state) ne "approved"} {
    forum::security::require_moderate_forum -forum_id $forum_id
}
# Authorize above on every request, including cache hits. Browser caches must
# revalidate committed images when permissions or publication status change.
ns_set put [ns_conn outputheaders] Cache-Control "private, no-cache"
if {$width eq ""} {
    cr_write_content -revision_id $revision_id
} else {
    set file [content::revision::get_cr_file_path -revision_id $revision_id]
    set mime [ns_imgtype $file]
    ns_returnfile 200 image/$mime [attachments::image::variant $file $width revision-$revision_id]
}
ad_script_abort
