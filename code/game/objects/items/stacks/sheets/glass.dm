/* Glass stack types
 * Contains:
 *		Glass sheets
 *		Reinforced glass sheets
 *		Phoron Glass Sheets
 *		Reinforced Phoron Glass Sheets (AKA Holy fuck strong windows)
 *		Glass shards - TODO: Move this into code/game/object/item/weapons
 */

/*
 * Glass sheets
 */
/obj/item/stack/sheet/glass
	name = "glass"
	desc = "HOLY SHEET! That is a lot of glass."
	singular_name = "glass sheet"
	icon_state = "sheet-glass"
	g_amt = 3750
	origin_tech = "materials=1"
	var/created_window = /obj/structure/window/thin
	required_skills = list(/datum/skill/construction = SKILL_LEVEL_NOVICE)

/obj/item/stack/sheet/glass/cyborg
	name = "glass"
	desc = "HOLY SHEET! That is a lot of glass."
	singular_name = "glass sheet"
	icon_state = "sheet-glass"
	g_amt = 0
	created_window = /obj/structure/window/thin

/obj/item/stack/sheet/glass/attack_self(mob/user)
	construct_window(user)

/obj/item/stack/sheet/glass/attackby(obj/item/I, mob/user, params)
	if(iscoil(I))
		var/list/resources_to_use = list()
		resources_to_use[I] = 5
		resources_to_use[src] = 1
		if(!use_multi(user, resources_to_use))
			return

		to_chat(user, "<span class='notice'>You attach wire to the [name].</span>")
		new /obj/item/stack/light_w(user.loc)

	else if(istype(I, /obj/item/stack/rods))
		var/list/resources_to_use = list()
		resources_to_use[I] = 1
		resources_to_use[src] = 1
		if(!use_multi(user, resources_to_use))
			return

		var/obj/item/stack/sheet/rglass/RG = new (user.loc)
		RG.add_fingerprint(user)
		for(var/obj/item/stack/sheet/rglass/G in user.loc)
			if(G==RG)
				continue
			if(G.get_amount() >= G.max_amount)
				continue
			G.attackby(RG, user)
			to_chat(usr, "You add the reinforced glass to the stack. It now contains [RG.get_amount()] sheets.")

	else
		return ..()

/obj/item/stack/sheet/glass/phoronglass/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stack/rods))
		var/list/resources_to_use = list()
		resources_to_use[I] = 1
		resources_to_use[src] = 1
		if(!use_multi(user, resources_to_use))
			return

		var/obj/item/stack/sheet/glass/phoronrglass/FG = new (user.loc)
		FG.add_fingerprint(user)
		for(var/obj/item/stack/sheet/glass/phoronrglass/G in user.loc)
			if(G == FG)
				continue
			if(G.get_amount() >= G.max_amount)
				continue
			G.attackby(FG, user)

	else
		return ..()

/obj/item/stack/sheet/glass/proc/construct_window(mob/user)
	if(!user || !src)
		return 0
	if(!istype(user.loc,/turf))
		return 0
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return 0
	var/title = "Sheet-Glass"
	if(!handle_fumbling(user, user, SKILL_TASK_AVERAGE, required_skills, "<span class='notice'>You fumble around figuring out how to use glass to make window.</span>"))
		return
	title += " ([get_amount()] sheet\s left)"
	switch(input(title, "What would you like to make?", "Thin Windows") in list("Thin Windows", "Glass Table Parts", "Cancel"))
		if("Thin Windows")
			if(QDELETED(src))
				return 1
			if(src.loc != user)
				return 1

			var/list/directions = global.cardinal.Copy()
			var/i = 0
			for(var/obj/structure/window/thin/win in user.loc)
				i++
				if(i >= 4)
					to_chat(user, "<span class='warning'>There are too many windows in this location.</span>")
					return 1
				directions-=win.dir
				if(!(win.ini_dir in cardinal))
					to_chat(user, "<span class='warning'>Can't let you do that.</span>")
					return 1

			//Determine the direction. It will first check in the direction the person making the window is facing, if it finds an already made window it will try looking at the next cardinal direction, etc.
			var/dir_to_set = 2
			for(var/direction in list(user.dir, turn(user.dir,90), turn(user.dir,180), turn(user.dir,270)))
				var/found = 0
				for(var/obj/structure/window/WT in user.loc)
					if(WT.dir == direction)
						found = 1
				if(!found)
					dir_to_set = direction
					break

			if(!use(1))
				to_chat(user, "<span class='warning'>You need more glass to do that.</span>")
				return 1

			var/obj/structure/window/thin/W
			W = new created_window(user.loc)
			W.set_dir(dir_to_set)
			W.ini_dir = W.dir
			W.anchored = FALSE

		if("Glass Table Parts")
			if(QDELETED(src))
				return 1
			if(src.loc != user)
				return 1

			if(!use(2))
				to_chat(user, "<span class='warning'>You need more glass to do that.</span>")
				return 1

			new /obj/item/weapon/table_parts/glass(user.loc)
	return 0

/obj/item/stack/sheet/glass/after_throw(datum/callback/callback)
	..()
	playsound(src, pick(SOUNDIN_SHATTER), VOL_EFFECTS_MASTER)
	new /obj/item/weapon/shard(loc) // todo: phoron shard types
	set_amount(get_amount() - rand(5,35))

/obj/item/stack/sheet/rglass/after_throw(datum/callback/callback)
	..()
	playsound(src, pick(SOUNDIN_SHATTER), VOL_EFFECTS_MASTER)
	new /obj/item/weapon/shard(loc)
	set_amount(get_amount() - rand(1,15))

/*
 * Reinforced glass sheets
 */
/obj/item/stack/sheet/rglass
	name = "reinforced glass"
	desc = "Glass which seems to have rods or something stuck in them."
	singular_name = "reinforced glass sheet"
	icon_state = "sheet-rglass"
	g_amt = 3750
	m_amt = 1875
	origin_tech = "materials=2"
	required_skills = list(/datum/skill/construction = SKILL_LEVEL_TRAINED)

/obj/item/stack/sheet/rglass/cyborg
	name = "reinforced glass"
	desc = "Glass which seems to have rods or something stuck in them."
	singular_name = "reinforced glass sheet"
	icon_state = "sheet-rglass"
	g_amt = 0
	m_amt = 0

/obj/item/stack/sheet/rglass/attack_self(mob/user)
	construct_window(user)

/obj/item/stack/sheet/rglass/proc/construct_window(mob/user)
	if(!user || QDELETED(src))
		return 0
	if(!isturf(user.loc))
		return 0
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return 0
	var/title = "Sheet Reinf. Glass"
	title += " ([get_amount()] sheet\s left)"
	if(!handle_fumbling(user, user, SKILL_TASK_AVERAGE, required_skills, "<span class='notice'>You fumble around figuring out how to use reinforced glass to make window.</span>"))
		return
	switch(input(title, "Would you like thin windows glass pane or a windoor?") in list("Thin Windows", "Windoor", "Cancel"))
		if("Thin Windows")
			if(QDELETED(src))
				return 1
			if(src.loc != user)
				return 1
			var/list/directions = global.cardinal.Copy()
			var/i = 0
			for (var/obj/structure/window/thin/win in user.loc)
				i++
				if(i >= 4)
					to_chat(user, "<span class='warning'>There are too many windows in this location.</span>")
					return 1
				directions-=win.dir
				if(!(win.ini_dir in cardinal))
					to_chat(user, "<span class='warning'>Can't let you do that.</span>")
					return 1

			//Determine the direction. It will first check in the direction the person making the window is facing, if it finds an already made window it will try looking at the next cardinal direction, etc.
			var/dir_to_set = 2
			for(var/direction in list( user.dir, turn(user.dir,90), turn(user.dir,180), turn(user.dir,270) ))
				var/found = 0
				for(var/obj/structure/window/WT in user.loc)
					if(WT.dir == direction)
						found = 1
				if(!found)
					dir_to_set = direction
					break

			if(!use(1))
				to_chat(user, "<span class='warning'>You need more glass to do that.</span>")
				return 1

			var/obj/structure/window/thin/W
			W = new /obj/structure/window/thin/reinforced(user.loc)
			W.set_dir(dir_to_set)
			W.ini_dir = W.dir
			W.anchored = FALSE

		if("Windoor")
			if(QDELETED(src) || src.loc != user)
				return 1

			if(isturf(user.loc) && locate(/obj/structure/windoor_assembly, user.loc))
				to_chat(user, "<span class='warning'>There is already a windoor assembly in that location.</span>")
				return 1

			if(isturf(user.loc) && locate(/obj/machinery/door/window, user.loc))
				to_chat(user, "<span class='warning'>There is already a windoor in that location.</span>")
				return 1

			if(!use(5))
				to_chat(user, "<span class='warning'>You need more glass to do that.</span>")
				return 1

			var/obj/structure/windoor_assembly/WD
			WD = new /obj/structure/windoor_assembly(user.loc)
			WD.state = "01"
			WD.anchored = FALSE
			switch(user.dir)
				if(SOUTH)
					WD.set_dir(SOUTH)
					WD.ini_dir = SOUTH
				if(EAST)
					WD.set_dir(EAST)
					WD.ini_dir = EAST
				if(WEST)
					WD.set_dir(WEST)
					WD.ini_dir = WEST
				else//If the user is facing northeast. northwest, southeast, southwest or north, default to north
					WD.set_dir(NORTH)
					WD.ini_dir = NORTH
		else
			return 1


	return 0

/*
 * Phoron Glass sheets
 */
/obj/item/stack/sheet/glass/phoronglass
	name = "phoron glass"
	desc = "A very strong and very resistant sheet of a phoron-glass alloy."
	singular_name = "phoron glass sheet"
	icon_state = "sheet-phoronglass"
	g_amt = 7500
	origin_tech = "materials=3;phorontech=2"
	created_window = /obj/structure/window/thin/phoron
	required_skills = list(/datum/skill/construction = SKILL_LEVEL_PRO)

/obj/item/stack/sheet/glass/phoronglass/attack_self(mob/user)
	construct_window(user)

/*
 * Reinforced phoron glass sheets
 */
/obj/item/stack/sheet/glass/phoronrglass
	name = "reinforced phoron glass"
	desc = "Phoron glass which seems to have rods or something stuck in them."
	singular_name = "reinforced phoron glass sheet"
	icon_state = "sheet-phoronrglass"
	g_amt = 7500
	m_amt = 1875
	origin_tech = "materials=4;phorontech=2"
	created_window = /obj/structure/window/thin/reinforced/phoron
	required_skills = list(/datum/skill/construction = SKILL_LEVEL_MASTER)

/obj/item/stack/sheet/glass/phoronrglass/attack_self(mob/user)
	construct_window(user)
