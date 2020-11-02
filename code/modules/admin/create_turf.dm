/var/create_turf_html = null
/datum/admins/proc/create_turf(mob/user)
	if (!create_turf_html)
		var/turfjs = null
		turfjs = jointext(typesof(/turf), ";")
		create_turf_html = file2text('html/create_object.html')
		create_turf_html = replacetext(create_turf_html, "null /* object types */", "\"[turfjs]\"")

	var/dat = replacetext(create_turf_html, "/* ref src */", "\ref[src]")

	var/datum/browser/popup = new(user, "create_turf", null, 425, 475)
	popup.set_content(dat)
	popup.open()
