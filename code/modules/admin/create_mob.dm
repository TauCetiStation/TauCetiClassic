/datum/admins/proc/create_mob(mob/user)
	var/static/create_mob_html
	if (!create_mob_html)
		var/mobjs = jointext(typesof(/mob), ";")
		create_mob_html = file2text('html/create_object.html')
		create_mob_html = replacetext(create_mob_html, "null /* object types */", "\"[mobjs]\"")

	user << browse(replacetext(replacetext(create_mob_html, "/* custom style */", get_browse_zoom_style(user.client)), "/* ref src */", "\ref[src]"), "window=create_mob;[get_browse_size_parameter(user.client, 425, 475)]")
