<% 
foreach attachment $attachments {
   template::adp_puts "<td><a href=\"[lindex $attachment 2]\">$attachment_graphic</a></td>"
}
%>
