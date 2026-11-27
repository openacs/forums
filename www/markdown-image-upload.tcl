ad_page_contract {
    Stage a pasted bitmap for a specific Forums posting or editing form.
} {
    grant:notnull
}

if {[ns_conn method] ne "POST"} {
    ns_return 405 text/plain "Use POST to upload an image."
    ad_script_abort
}

auth::require_login
set token [security::csrf::new]
if {$token eq "" || [ns_queryget __csrf_token] ne $token
    || [catch {security::parameter::validated $grant} scope]} {
    ns_return 403 text/plain "Invalid upload token."
    ad_script_abort
}
lassign $scope purpose package_id user_id forum_id message_id mode
if {$purpose ne "forums-markdown-image" || $package_id ne [ad_conn package_id]
    || $user_id ne [ad_conn user_id] || $mode ni {post edit}} {
    ns_return 403 text/plain "Invalid upload scope."
    ad_script_abort
}

forum::get -forum_id $forum_id -array forum
if {$forum(package_id) ne $package_id || !$forum(enabled_p)
    || ![forum::image_paste_enabled_p -forum_id $forum_id]} {
    ns_return 403 text/plain "Image paste is unavailable for this forum."
    ad_script_abort
}
forum::security::require_read_forum -forum_id $forum_id
if {$mode eq "edit"} {
    forum::security::require_moderate_forum -forum_id $forum_id
    forum::message::get -message_id $message_id -array message
    if {$message(forum_id) ne $forum_id} {
        ns_return 403 text/plain "Invalid message."
        ad_script_abort
    }
} else {
    forum::security::require_post_forum -forum_id $forum_id
}

set files [ns_getformfile upload]
if {[llength $files] != 1 || ![security::safe_tmpfile_p -must_exist [lindex $files 0]]} {
    ns_return 400 text/plain "Upload one image."
    ad_script_abort
}
set file [lindex $files 0]
if {[forum::markdown_image::mime_type $file] eq ""} {
    ns_return 415 text/plain "Paste a PNG, JPEG, or GIF image."
    ad_script_abort
}

set key $forum_id.$message_id.[ns_uuid]
set directory [forum::markdown_image::directory]
file mkdir $directory
set channel [file tempfile temporary $directory/upload-]
close $channel
try {
    file copy -force -- $file $temporary
    file attributes $temporary -permissions 0600
    file rename -- $temporary [forum::markdown_image::draft_path $key]
} finally {
    file delete -- $temporary
}
# Dimensions are rendering hints only; delivery always inspects the actual file.
lassign [ns_imgsize $file] image_width image_height
ns_return 201 text/plain [export_vars -base [ad_conn package_url]markdown-image {key image_width image_height}]
ad_script_abort
