ad_library {
    Stage pasted forum images and save them as message attachments.
}

namespace eval ::forum::markdown_image {}

ad_proc -private ::forum::markdown_image::directory {} {
    Return the staging directory for forum images.
} {
    return [file join [ns_config ns/parameters tmpdir] forums-markdown-images]
}

ad_proc -private ::forum::markdown_image::draft_path {key} {
    Find a staged image belonging to the current user and package.
} {
    return [file join [directory] "[ad_conn package_id].[ad_conn user_id].$key"]
}

ad_proc -private ::forum::markdown_image::parts {key} {
    Decode a local image key.
} {
    if {![regexp {^([1-9][0-9]*)[.]([1-9][0-9]*)[.]([a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12})$} $key _ forum_id message_id uuid]} {
        return {}
    }
    return [list $forum_id $message_id $uuid]
}

ad_proc -private ::forum::markdown_image::mime_type {path} {
    Recognize supported bitmap images from the uploaded bytes.
} {
    if {![file isfile $path] || [catch {ns_imgtype $path} type] || $type ni {png jpeg gif}
        || [catch {ns_imgsize $path} size] || [llength $size] != 2
        || [lindex $size 0] <= 0 || [lindex $size 1] <= 0} {
        return ""
    }
    return image/$type
}

ad_proc -private ::forum::markdown_image::upload_url {forum_id message_id mode} {
    Authorize clipboard uploads for an already validated posting or editing form.
} {
    if {![string is integer -strict $message_id] || $message_id <= 0 || [ad_conn user_id] == 0
        || ![forum::image_paste_enabled_p -forum_id $forum_id]} {
        return ""
    }
    set grant [security::parameter::signed -max_age 86400 \
                   [list forums-markdown-image [ad_conn package_id] [ad_conn user_id] $forum_id $message_id $mode]]
    return [export_vars -base [ad_conn package_url]markdown-image-upload {grant}]
}

ad_proc -private ::forum::markdown_image::attachment {message_id uuid} {
    Look up a previously committed inline image on its specific message.
} {
    set name markdown-$message_id-$uuid
    return [db_string forum_markdown_image_attachment {
        select r.revision_id
        from attachments a
        join cr_items i on i.item_id = a.item_id
        join cr_revisions r on r.revision_id = i.live_revision
        where a.object_id = :message_id and i.name = :name
          and r.mime_type in ('image/png', 'image/jpeg', 'image/gif')
    } -default ""]
}

ad_proc -private ::forum::markdown_image::drafts {forum_id message_id content format} {
    Find this message's pasted images that still need to be attached.
} {
    if {$format ne "text/html" || [string first markdown-image?key= $content] == -1} {
        return {}
    }
    set prefix [ad_conn package_url]markdown-image?key=
    set drafts {}
    foreach tag [ns_parsehtml -onlytags -- $content] {
        lassign $tag element attributes
        if {![string equal -nocase $element img] || ![dict exists $attributes src]} {
            continue
        }
        set src [dict get $attributes src]
        if {[string first $prefix $src] != 0} {
            continue
        }
        # Responsive delivery adds query parameters after the stable image identity.
        set key [lindex [split [string range $src [string length $prefix] end] &] 0]
        lassign [parts $key] image_forum image_message uuid
        if {$forum_id ne $image_forum || $message_id ne $image_message || [dict exists $drafts $uuid]
            || [attachment $message_id $uuid] ne ""} {
            continue
        }
        set path [draft_path $key]
        set mime [mime_type $path]
        if {$mime eq "" || ![forum::image_paste_enabled_p -forum_id $forum_id]} {
            return -code error -errorcode {FORUM IMAGE UNAVAILABLE} "A pasted image is unavailable. Remove it or paste it again."
        }
        dict set drafts $uuid [list $path $mime]
    }
    return $drafts
}

ad_proc -private ::forum::markdown_image::attach {forum_id message_id drafts} {
    Import staged images through the Forums content repository attachment workflow.
} {
    if {[dict size $drafts] == 0} {
        return
    }
    set folder_id [content::item::get_id -root_folder_id $forum_id -item_path attachments]
    if {$folder_id eq ""} {
        set folder_id [content::item::new -parent_id $forum_id -name attachments]
    }
    dict for {uuid image} $drafts {
        if {[attachment $message_id $uuid] ne ""} {
            continue
        }
        lassign $image path mime
        set item_id [content::item::new \
                         -name markdown-$message_id-$uuid \
                         -title "Pasted image.[lindex [split $mime /] 1]" \
                         -parent_id $folder_id -context_id $message_id \
                         -creation_user [ad_conn user_id] -creation_ip [ad_conn peeraddr] \
                         -package_id [ad_conn package_id] -storage_type file \
                         -tmp_filename $path -mime_type $mime -is_live t]
        attachments::attach -object_id $message_id -attachment_id $item_id
        # The posting form can be inside another transaction. Keep the draft
        # on rollback, and discard it only after the attachment is committed.
        ns_atclose [list ::forum::markdown_image::discard_attached_draft $message_id $uuid $path]
    }
}

ad_proc -private ::forum::markdown_image::discard_attached_draft {message_id uuid path} {
    Remove a staged image only when its message attachment has committed.
} {
    if {[attachment $message_id $uuid] ne ""} {
        file delete -- $path
    }
}

ad_proc -private ::forum::markdown_image::expire_drafts {} {
    Remove abandoned draft images after one day.
} {
    set cutoff [expr {[clock seconds] - 86400}]
    foreach path [glob -nocomplain -directory [directory] -types f *] {
        catch {
            if {[file mtime $path] < $cutoff} {
                file delete -- $path
            }
        }
    }
}
