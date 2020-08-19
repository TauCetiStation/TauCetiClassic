/var/create_mob_html = null
/datum/admins/proc/create_mob(mob/user)
	if (!create_mob_html)
		var/mobjs = null
		mobjs = jointext(typesof(/mob), ";")
		create_mob_html = file2text('html/create_object.html')
		create_mob_html = replacetext(create_mob_html, "null /* object types */", "\"[mobjs]\"")

	var/dat = replacetext(create_mob_html, "/* ref src */", "\ref[src]")

	var/datum/browser/popup = new(user, "create_mob", null, 425, 475)
	popup.set_content(dat)
	popup.open()
