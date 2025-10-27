/datum/admins/proc/create_turf(mob/user)
	var/static/create_turf_html = null
	if (!create_turf_html)
		var/turfjs = jointext(typesof(/turf), ";")
		create_turf_html = file2text('html/create_object.html')
		create_turf_html = replacetext(create_turf_html, "null /* object types */", "\"[turfjs]\"")

	user << browse(replacetext(replacetext(create_turf_html, "/* custom style */", get_browse_zoom_style(user.client)), "/* ref src */", "\ref[src]"), "window=create_turf;size=425x475")
