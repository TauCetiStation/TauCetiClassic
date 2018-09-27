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
	var/created_window = /obj/structure/window/basic

/obj/item/stack/sheet/glass/cyborg
	name = "glass"
	desc = "HOLY SHEET! That is a lot of glass."
	singular_name = "glass sheet"
	icon_state = "sheet-glass"
	g_amt = 0
	created_window = /obj/structure/window/basic

/obj/item/stack/sheet/glass/attack_self(mob/user)
	construct_window(user)

/obj/item/stack/sheet/glass/attackby(obj/item/W, mob/user)
	..()
	if(istype(W,/obj/item/stack/cable_coil))

		var/list/resources_to_use = list()
		resources_to_use[W] = 5
		resources_to_use[src] = 1
		if(!use_multi(user, resources_to_use))
			return

		to_chat(user, "\blue You attach wire to the [name].")
		new /obj/item/stack/light_w(user.loc)
	else if(istype(W, /obj/item/stack/rods))

		var/list/resources_to_use = list()
		resources_to_use[W] = 1
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

/obj/item/stack/sheet/glass/proc/construct_window(mob/user)
	if(!user || !src)
		return 0
	if(!istype(user.loc,/turf))
		return 0
	if(!user.IsAdvancedToolUser())
		to_chat(user, "\red You don't have the dexterity to do this!")
		return 0
	var/title = "Sheet-Glass"
	title += " ([get_amount()] sheet\s left)"
	switch(input(title, "What would you like to make?", "One Direction") in list("One Direction", "Full Window", "Glass Table Parts", "Cancel"))
		if("One Direction")
			if(QDELETED(src))
				return 1
			if(src.loc != user)
				return 1

			var/list/directions = new/list(cardinal)
			var/i = 0
			for(var/obj/structure/window/win in user.loc)
				i++
				if(i >= 4)
					to_chat(user, "\red There are too many windows in this location.")
					return 1
				directions-=win.dir
				if(!(win.ini_dir in cardinal))
					to_chat(user, "\red Can't let you do that.")
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

			if(!src.use(1))
				to_chat(user, "\red You need more glass to do that.")
				return 1

			var/obj/structure/window/W
			W = new created_window(user.loc)
			W.dir = dir_to_set
			W.ini_dir = W.dir
			W.anchored = 0
		if("Full Window")
			if(QDELETED(src))
				return 1
			if(src.loc != user)
				return 1
			var/step = get_step(user, user.dir)
			var/turf/T = get_turf(step)
			if(T.density || (locate(/obj/structure/window) in step))
				to_chat(user, "\red There is something in the way.")
				return 1

			if(!src.use(2))
				to_chat(user, "\red You need more glass to do that.")
				return 1

			var/obj/structure/window/W
			W = new created_window(step)
			W.dir = SOUTHWEST
			W.ini_dir = SOUTHWEST
			W.anchored = 0
		if("Glass Table Parts")
			if(QDELETED(src))
				return 1
			if(src.loc != user)
				return 1

			if(!src.use(2))
				to_chat(user, "\red You need more glass to do that.")
				return 1

			new /obj/item/weapon/table_parts/glass(user.loc)
	return 0

/obj/item/stack/sheet/glass/after_throw(datum/callback/callback)
	..()
	playsound(src, "shatter", 70, 1)
	new /obj/item/weapon/shard(loc)
	set_amount(get_amount() - rand(5,35))

/obj/item/stack/sheet/rglass/after_throw(datum/callback/callback)
	..()
	playsound(src, "shatter", 70, 1)
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
		to_chat(user, "\red You don't have the dexterity to do this!")
		return 0
	var/title = "Sheet Reinf. Glass"
	title += " ([get_amount()] sheet\s left)"
	switch(input(title, "Would you like full tile glass a one direction glass pane or a windoor?") in list("One Direction", "Full Window", "Windoor", "Cancel"))
		if("One Direction")
			if(QDELETED(src))
				return 1
			if(src.loc != user)
				return 1
			var/list/directions = new/list(cardinal)
			var/i = 0
			for (var/obj/structure/window/win in user.loc)
				i++
				if(i >= 4)
					to_chat(user, "\red There are too many windows in this location.")
					return 1
				directions-=win.dir
				if(!(win.ini_dir in cardinal))
					to_chat(user, "\red Can't let you do that.")
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

			if(!src.use(1))
				to_chat(user, "\red You need more glass to do that.")
				return 1

			var/obj/structure/window/W
			W = new /obj/structure/window/reinforced(user.loc)
			W.state = 0
			W.dir = dir_to_set
			W.ini_dir = W.dir
			W.anchored = 0

		if("Full Window")
			if(QDELETED(src))
				return 1
			if(src.loc != user)
				return 1
			var/step = get_step(user, user.dir)
			var/turf/T = get_turf(step)
			if(T.density || (locate(/obj/structure/window) in step))
				to_chat(user, "\red There is something in the way.")
				return 1
			if(!src.use(2))
				to_chat(user, "\red You need more glass to do that.")
				return 1
			var/obj/structure/window/W
			W = new /obj/structure/window/reinforced(step)
			W.state = 0
			W.dir = SOUTHWEST
			W.ini_dir = SOUTHWEST
			W.state = 0
			W.anchored = 0

		if("Windoor")
			if(QDELETED(src) || src.loc != user)
				return 1

			if(isturf(user.loc) && locate(/obj/structure/windoor_assembly/, user.loc))
				to_chat(user, "\red There is already a windoor assembly in that location.")
				return 1

			if(isturf(user.loc) && locate(/obj/machinery/door/window/, user.loc))
				to_chat(user, "\red There is already a windoor in that location.")
				return 1

			if(!src.use(5))
				to_chat(user, "\red You need more glass to do that.")
				return 1

			var/obj/structure/windoor_assembly/WD
			WD = new /obj/structure/windoor_assembly(user.loc)
			WD.state = "01"
			WD.anchored = 0
			switch(user.dir)
				if(SOUTH)
					WD.dir = SOUTH
					WD.ini_dir = SOUTH
				if(EAST)
					WD.dir = EAST
					WD.ini_dir = EAST
				if(WEST)
					WD.dir = WEST
					WD.ini_dir = WEST
				else//If the user is facing northeast. northwest, southeast, southwest or north, default to north
					WD.dir = NORTH
					WD.ini_dir = NORTH
		else
			return 1


	return 0

/*
 * Glass shards - TODO: Move this into code/game/object/item/weapons
 */
/obj/item/weapon/shard/Bump()
	if(prob(20))
		force = 15
	else
		force = 4
	..()

/obj/item/weapon/shard/atom_init()
	. = ..()

	icon_state = pick("large", "medium", "small")
	switch(icon_state)
		if("small")
			pixel_x = rand(-12, 12)
			pixel_y = rand(-12, 12)
		if("medium")
			pixel_x = rand(-8, 8)
			pixel_y = rand(-8, 8)
		if("large")
			pixel_x = rand(-5, 5)
			pixel_y = rand(-5, 5)

/obj/item/weapon/shard/attackby(obj/item/weapon/W, mob/user)
	..()
	if(istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W
		if(WT.remove_fuel(0, user))
			var/obj/item/stack/sheet/glass/NG = new (user.loc)
			for(var/obj/item/stack/sheet/glass/G in user.loc)
				if(G==NG)
					continue
				if(G.get_amount() >= G.max_amount)
					continue
				G.attackby(NG, user)
				to_chat(usr, "You add the newly-formed glass to the stack. It now contains [NG.get_amount()] sheets.")
			//SN src = null
			qdel(src)
			return
	return ..()

/obj/item/weapon/shard/Crossed(AM as mob|obj)
	if(ismob(AM))
		var/mob/M = AM
		to_chat(M, "\red <B>You step in the broken glass!</B>")
		playsound(src.loc, 'sound/effects/glass_step.ogg', 50, 1)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M

			if(H.species.flags[IS_SYNTHETIC])
				return

			if(H.wear_suit && (H.wear_suit.body_parts_covered & LEGS) && H.wear_suit.flags & THICKMATERIAL)
				return

			if(!H.shoes)
				var/obj/item/organ/external/BP = H.bodyparts_by_name[pick(BP_L_LEG , BP_R_LEG)]
				if(BP.status & ORGAN_ROBOT)
					return
				H.Weaken(3)
				BP.take_damage(5, 0)
				H.updatehealth()
	..()




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
	created_window = /obj/structure/window/phoronbasic

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
	created_window = /obj/structure/window/phoronreinforced

/obj/item/stack/sheet/glass/phoronrglass/attack_self(mob/user)
	construct_window(user)
