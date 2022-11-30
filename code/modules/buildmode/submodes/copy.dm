/datum/buildmode_mode/copy
	key = "copy"
	var/atom/movable/stored = null

/datum/buildmode_mode/copy/Destroy()
	stored = null
	return ..()

/datum/buildmode_mode/copy/show_help(client/c)
	to_chat(c,
		"<span class='notice'>***********************************************************\n\
		Left Mouse Button on obj/turf/mob   = Spawn a Copy of selected target\n\
		Right Mouse Button on obj/mob = Select target to copy\n\
		***********************************************************</span>")

/datum/buildmode_mode/copy/handle_click(client/c, params, obj/object)
	var/list/modifiers = params2list(params)

	if(LAZYACCESS(modifiers, LEFT_CLICK))
		var/turf/T = get_turf(object)
		if(!stored)
			to_chat(c, "<span class='warning'>Select target first.</span>")
			return
		DuplicateObject(stored, perfectcopy=TRUE, sameloc=FALSE, newloc=T)
		log_admin("Build Mode: [key_name(c)] copied [stored] to [AREACOORD(object)]")
	else if(LAZYACCESS(modifiers, RIGHT_CLICK))
		if(ismovable(object)) // No copying turfs for now.
			to_chat(c, "<span class='notice'>[object] set as template.</span>")
			stored = object
