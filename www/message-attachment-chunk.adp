<% 
foreach attachment $attachments {
   template::adp_puts "<a href=\"[lindex $attachment 2]\">$attachment_graphic</a> &nbsp;"
}
%>

