/*
CONTAINS:
RCD
*/
/obj/item/weapon/rcd
	name = "rapid-construction-device (RCD)"
	desc = "A device used to rapidly build walls/floor."
	icon = 'icons/obj/tools.dmi'
	icon_state = "rcd"
	opacity = 0
	density = FALSE
	anchored = FALSE
	flags = CONDUCT
	force = 10.0
	throwforce = 10.0
	throw_speed = 1
	throw_range = 5
	w_class = SIZE_SMALL
	m_amt = 50000
	origin_tech = "engineering=4;materials=2"
	usesound = 'sound/machines/click.ogg'

	var/datum/effect/effect/system/spark_spread/spark_system
	var/matter = 0
	var/max_matter = 30
	var/working = 0
	var/mode = RCD_MODE_FLOOR_WALLS
	var/list/available_modes = list(RCD_MODE_FLOOR_WALLS, RCD_MODE_AIRLOCK, RCD_MODE_DECONSTRUCT)
	var/canRwall = 0
	var/disabled = 0

	item_action_types = list(/datum/action/item_action/hands_free/switch_rcd)

/datum/action/item_action/hands_free/switch_rcd
	name = "Switch RCD"

/obj/item/weapon/rcd/atom_init()
	. = ..()
	rcd_list += src
	desc = "A RCD. It currently holds [matter]/[max_matter] matter-units."
	spark_system = new /datum/effect/effect/system/spark_spread
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

/obj/item/weapon/rcd/Destroy()
	rcd_list -= src
	qdel(spark_system)
	spark_system = null
	return ..()

/obj/item/weapon/rcd/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/rcd_ammo))
		var/obj/item/weapon/rcd_ammo/ammo = I
		if(matter >= max_matter)
			to_chat(user, "<span class='notice'>The RCD cant hold any more matter-units.</span>")
			return
		matter = min(matter+ammo.matter, max_matter)
		playsound(src, 'sound/machines/click.ogg', VOL_EFFECTS_MASTER)
		to_chat(user, "<span class='notice'>The RCD now holds [matter]/[max_matter] matter-units.</span>")
		desc = "A RCD. It currently holds [matter]/[max_matter] matter-units."
		qdel(ammo)

	else
		return ..()

/obj/item/weapon/rcd/attack_self(mob/user)
	//Change the mode

	if(available_modes.len <= 1)
		return

	playsound(src, 'sound/effects/pop.ogg', VOL_EFFECTS_MASTER, null, FALSE)
	if(!handle_fumbling(user, src, SKILL_TASK_EASY, list(/datum/skill/construction = SKILL_LEVEL_TRAINED)))
		return

	var/static/radial_floor_wall = image(icon = 'icons/turf/floors.dmi', icon_state = "plating")
	var/static/radial_airlock = image(icon = 'icons/obj/doors/airlocks/station/public.dmi', icon_state = "full")
	var/static/radial_pipe = image(icon = 'icons/obj/pipes/disposal.dmi', icon_state = "conpipe-s")
	var/static/radial_deconstruct = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_trash")

	var/list/options = list()

	if(RCD_MODE_FLOOR_WALLS in available_modes)
		options[RCD_MODE_FLOOR_WALLS] = radial_floor_wall
	if(RCD_MODE_AIRLOCK in available_modes)
		options[RCD_MODE_AIRLOCK] = radial_airlock
	if(RCD_MODE_DECONSTRUCT in available_modes)
		options[RCD_MODE_DECONSTRUCT] = radial_deconstruct
	if(RCD_MODE_PNEUMATIC in available_modes)
		options[RCD_MODE_PNEUMATIC] = radial_pipe

	var/choice = show_radial_menu(user, src, options, tooltips = TRUE)

	if(!choice) //closed radial menu
		return

	if(!user.Adjacent(src))
		return

	mode = choice

	to_chat(user, "<span class='notice'>Changed mode to '[mode]'</span>")
	if(prob(20))
		spark_system.start()

/obj/item/weapon/rcd/proc/activate()
	playsound(src, 'sound/items/Deconstruct.ogg', VOL_EFFECTS_MASTER)

/obj/item/weapon/rcd/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity)
		return FALSE
	if(disabled && !isrobot(user))
		return FALSE
	if(istype(target, /area/shuttle))
		return FALSE
	if(!(mode in available_modes))
		to_chat(user, "<span class='warning'>Somehow you broke it. Please contact developers.</span>")
		return

	switch(mode)
		if(RCD_MODE_FLOOR_WALLS)
			if(isenvironmentturf(target) || istype(target, /obj/structure/lattice))
				var/turf/T = get_turf(target)
				if(!canBuildOnTurf(T))
					to_chat(user, "<span class='warning'>You can't build floor here.</span>")
					return FALSE
				to_chat(user, "<span class='notice'>Building Floor...</span>")
				if(!use_tool(target, user, 0, amount = 1, volume = 0))
					return FALSE
				activate()
				T.ChangeTurf(/turf/simulated/floor/plating/airless)
				return TRUE

			if(isfloorturf(target) && !user.is_busy())
				var/turf/simulated/floor/F = target
				if(!canBuildOnTurf(F))
					to_chat(user, "<span class='warning'>You can't build wall here.</span>")
					return FALSE
				to_chat(user, "<span class='notice'>Building Wall ...</span>")
				if(!use_tool(target, user, 20, amount = 3))
					return FALSE
				activate()
				F.ChangeTurf(/turf/simulated/wall)
				return TRUE

		if(RCD_MODE_AIRLOCK)
			if(isfloorturf(target))
				if(!canBuildOnTurf(target))
					to_chat(user, "<span class='warning'>You can't build airlock here.</span>")
					return FALSE

				to_chat(user, "<span class='notice'>Building Airlock...</span>")
				if(!use_tool(target, user, 50, amount = 10))
					return
				activate()
				new /obj/machinery/door/airlock(target)
				return TRUE

		if(RCD_MODE_DECONSTRUCT)
			if(iswallturf(target))
				var/turf/simulated/wall/W = target
				if(istype(W, /turf/simulated/wall/r_wall) && !canRwall)
					return FALSE
				to_chat(user, "<span class='danger'>Deconstructing Wall...</span>")
				if(!use_tool(target, user, 40, amount = 5))
					return FALSE
				activate()
				W.ChangeTurf(/turf/simulated/floor/plating/airless)
				return TRUE

			if(isfloorturf(target))
				var/turf/simulated/floor/F = target
				to_chat(user, "<span class='danger'>Deconstructing Floor...</span>")
				if(!use_tool(target, user, 50, amount = 5))
					return FALSE
				activate()
				F.BreakToBase()
				return TRUE

			if(istype(target, /obj/machinery/door/airlock) && !user.is_busy())
				to_chat(user, "<span class='danger'>Deconstructing Airlock...</span>")
				if(!use_tool(target, user, 50, amount = 10))
					return FALSE

				activate()
				qdel(target)
				return TRUE

			return FALSE

		if(RCD_MODE_PNEUMATIC)
			if(istype(target, /obj/structure/disposalconstruct))
				var/obj/structure/disposalconstruct/D = target
				to_chat(user, "<span class='notice'>Changing shape of the pipe...</span>")
				if(!use_tool(target, user, 0, amount = 0, volume = 20))
					return FALSE
				// some shitty disposals code here
				// look for /obj/machinery/pipedispenser/disposal/Topic
				D.ptype += 1
				if(D.ptype > 9)
					D.ptype = 0

				if(D.ptype in list(6, 7, 8))
					D.density = TRUE
				else
					D.density = FALSE

				D.update()
				activate()
				return TRUE

			else if(isfloorturf(target))
				if(!canBuildOnTurf(target))
					to_chat(user, "<span class='warning'>You can't build pipe here.</span>")
					return FALSE

				to_chat(user, "<span class='notice'>Building Pipe...</span>")
				if(!use_tool(target, user, 10, amount = 2, volume = 0))
					return FALSE

				activate()
				new /obj/structure/disposalconstruct(target)

				return TRUE

	return FALSE

/obj/item/weapon/rcd/proc/canBuildOnTurf(turf/target)
	for(var/atom/AT in target)
		if(AT.density || istype(AT, /obj/machinery/door) || istype(AT, /obj/structure/mineral_door))
			return FALSE
	return TRUE

/obj/item/weapon/rcd/use(amount, mob/user)
	if(matter < amount)
		return FALSE
	matter -= amount
	desc = "A RCD. It currently holds [matter]/[max_matter] matter-units."
	return TRUE

/obj/item/weapon/rcd/tool_start_check(mob/user, amount)
	return matter >= amount

/obj/item/weapon/rcd/borg/use(amount, mob/user)
	if(!isrobot(user))
		return FALSE
	return user:cell:use(amount * 30)

/obj/item/weapon/rcd/borg/tool_start_check(mob/user, amount)
	if(!isrobot(user))
		return FALSE
	return user:cell:charge >= (amount * 30)

/obj/item/weapon/rcd/borg/atom_init()
	. = ..()
	desc = "A device used to rapidly build walls/floor."
	canRwall = 1

/obj/item/weapon/rcd_ammo
	name = "compressed matter cartridge"
	desc = "Highly compressed matter for the RCD."
	icon = 'icons/obj/tools.dmi'
	icon_state = "rcd_ammo"
	item_state = "rcdammo"
	opacity = 0
	density = FALSE
	anchored = FALSE
	origin_tech = "materials=2"
	m_amt = 30000
	g_amt = 15000
	w_class = SIZE_TINY

	var/matter = 30

/obj/item/weapon/rcd/pp
	name = "Pneumatic-pipenet-rapid-construction-device (PP-RCD)"
	desc = "A device used to rapidly build pneumatic pipenet. But, you still need to secure pipes manyally."
	mode = RCD_MODE_PNEUMATIC
	available_modes = list(RCD_MODE_PNEUMATIC)

// shitspawn types, pls fix m_amt/g_amt if you want to use it somewhere
/obj/item/weapon/rcd_ammo/bluespace
	name = "highly compressed matter cartridge"
	matter = 30

/obj/item/weapon/rcd/bluespace
	max_matter = 100
	matter = 100
	w_class = SIZE_TINY

/obj/item/weapon/rcd/pp/bluespace
	max_matter = 100
	matter = 100
	w_class = SIZE_TINY
