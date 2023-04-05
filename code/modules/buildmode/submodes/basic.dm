/datum/buildmode_mode/basic
	key = "basic"

/datum/buildmode_mode/basic/show_help(client/c)
	to_chat(c,
		"<span class='notice'>***********************************************************\n\
		Left Mouse Button        = Construct / Upgrade\n\
		Right Mouse Button       = Deconstruct / Delete / Downgrade\n\
		Left Mouse Button + ctrl = R-Window\n\
		Left Mouse Button + alt  = Airlock\n\
		\n\
		Use the button in the upper left corner to\n\
		change the direction of built objects.\n\
		***********************************************************</span>")

/datum/buildmode_mode/basic/handle_click(client/c, params, obj/object)
	var/list/modifiers = params2list(params)

	var/left_click = LAZYACCESS(modifiers, LEFT_CLICK)
	var/right_click = LAZYACCESS(modifiers, RIGHT_CLICK)
	var/alt_click = LAZYACCESS(modifiers, ALT_CLICK)
	var/ctrl_click = LAZYACCESS(modifiers, CTRL_CLICK)

	if(isturf(object) && left_click && !alt_click && !ctrl_click)
		var/turf/T = object
		if(isenvironmentturf(object))
			T.ChangeTurf(/turf/simulated/floor/plating)
		else if(isplatingturf(object))
			T.ChangeTurf(/turf/simulated/floor)
		else if(isfloorturf(object))
			T.ChangeTurf(/turf/simulated/wall)
		else if(iswallturf(object))
			T.ChangeTurf(/turf/simulated/wall/r_wall)
		log_admin("Build Mode: [key_name(c)] built [T] at [AREACOORD(T)]")
		return
	else if(right_click)
		log_admin("Build Mode: [key_name(c)] deleted [object] at [AREACOORD(object)]")
		if(isturf(object))
			var/turf/T = object
			if(T.density) // wall
				T.ChangeTurf(/turf/simulated/floor/plating)
			else
				T.ChangeTurf(/turf/environment)
		else if(isobj(object))
			qdel(object)
		return
	else if(isturf(object) && alt_click && left_click)
		log_admin("Build Mode: [key_name(c)] built an airlock at [AREACOORD(object)]")
		new/obj/machinery/door/airlock(get_turf(object))
	else if(isturf(object) && ctrl_click && left_click) // todo: buildmode fulltiles
		if(BM.build_dir in cornerdirs) // consistent with old behaviour
			new /obj/structure/window/fulltile/reinforced(get_turf(object), TRUE)
		else
			var/obj/structure/window/thin/window = new(get_turf(object))
			window.set_dir(BM.build_dir)
		log_admin("Build Mode: [key_name(c)] built a window at [AREACOORD(object)]")
