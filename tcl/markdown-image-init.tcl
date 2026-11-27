ad_library {
    Clean up abandoned pasted forum images.
}

ad_schedule_proc -thread t 3600 ::forum::markdown_image::expire_drafts
