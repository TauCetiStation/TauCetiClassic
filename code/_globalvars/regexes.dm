//These are a bunch of regex datums for use

var/global/regex/is_http_protocol = regex("^https?://")

var/global/regex/html_tags = regex(@"<.*?>", "g")
