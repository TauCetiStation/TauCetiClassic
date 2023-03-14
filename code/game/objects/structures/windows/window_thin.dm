/**
 * Base thin window
 */

/obj/structure/window/thin
	name = "thin window"
	desc = "A thin window."

	icon = 'icons/obj/window.dmi'
	icon_state = "window"

	flags = ON_BORDER

	var/ini_dir = null

/obj/structure/window/thin/atom_init()
	. = ..()

	ini_dir = dir
	color = color_windows()

	update_nearby_tiles(need_rebuild = 1)

	if(dir in cornerdirs)
		world.log << "WARNING: [x].[y].[z]: DIR [dir]"

/obj/structure/window/thin/take_damage(damage_amount, damage_type = BRUTE, damage_flag = "", sound_effect = TRUE, attack_dir)
	. = ..()
	if(attack_dir && . && get_integrity() < 7)
		anchored = FALSE
		step(src, reverse_dir[attack_dir])

/obj/structure/window/thin/deconstruct(disassembled)
	playsound(src, pick(SOUNDIN_SHATTER), VOL_EFFECTS_MASTER)
	visible_message("[src] shatters!")
	//if(!(flags & NODECONSTRUCT))
		//var/fulltile = is_fulltile()
		//new shardtype(loc)
		//if(fulltile)
		//	new shardtype
		//if(reinf) // todo: list/drop_contents = list(/rods/, /glass/ ...)
		//	new /obj/item/stack/rods(loc, fulltile ? 2 : 1)
	..()


	//if(!(flags & NODECONSTRUCT))
		//var/fulltile = is_fulltile()
		//new shardtype(loc)
		//if(fulltile)
		//	new shardtype
		//if(reinf) // todo: list/drop_contents = list(/rods/, /glass/ ...)
		//	new /obj/item/stack/rods(loc, fulltile ? 2 : 1)
	..()

/obj/structure/window/thin/CanPass(atom/movable/mover, turf/target, height=0)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return 1
	if(get_dir(loc, target) & dir)
		return !density
	else
		return 1

/obj/structure/window/thin/CanAStarPass(obj/item/weapon/card/id/ID, to_dir, caller)
	if(!density)
		return TRUE
	if((dir == SOUTHWEST) || (dir == to_dir))
		return FALSE

	return TRUE

/obj/structure/window/thin/CheckExit(atom/movable/O, target)
	if(istype(O) && O.checkpass(PASSGLASS))
		return 1
	if(get_dir(O.loc, target) == dir)
		return 0
	return 1

/obj/structure/window/thin/attackby(obj/item/W, mob/user)
/*	if(flags & NODECONSTRUCT)
		if(isscrewing(W) | isprying(W))
			return ..()

	user.SetNextMove(CLICK_CD_INTERACT)
	if(istype(W, /obj/item/weapon/airlock_painter))
		change_paintjob(W, user)

	else if(isscrewing(W))
		if(reinf && state >= 1)
			if(!handle_fumbling(user, src, SKILL_TASK_EASY, list(/datum/skill/construction = SKILL_LEVEL_TRAINED), message_self = "<span class='notice'>You fumble around, figuring out how to [state == 1 ? "fasten the window to the frame." : "unfasten the window from the frame."]</span>" ))
				return
			state = 3 - state
			playsound(src, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER)
			to_chat(user, (state == 1 ? "<span class='notice'>You have unfastened the window from the frame.</span>" : "<span class='notice'>You have fastened the window to the frame.</span>"))

		else if(reinf && state == 0)
			if(!handle_fumbling(user, src, SKILL_TASK_EASY, list(/datum/skill/construction = SKILL_LEVEL_TRAINED), message_self = "<span class='notice'>You fumble around, figuring out how to [anchored ? "unfasten the frame from the floor." : "fasten the frame to the floor."]</span>" ))
				return
			anchored = !anchored
			//update_nearby_icons()
			playsound(src, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER)
			to_chat(user, (anchored ? "<span class='notice'>You have fastened the frame to the floor.</span>" : "<span class='notice'>You have unfastened the frame from the floor.</span>"))
			fastened_change()

		else if(!reinf)
			if(!handle_fumbling(user, src, SKILL_TASK_EASY,list(/datum/skill/construction = SKILL_LEVEL_TRAINED), message_self = "<span class='notice'>You fumble around, figuring out how to [anchored ? "fasten the window to the floor." : "unfasten the window."]</span>" ))
				return
			anchored = !anchored
			//update_nearby_icons()
			playsound(src, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER)
			to_chat(user, (anchored ? "<span class='notice'>You have fastened the window to the floor.</span>" : "<span class='notice'>You have unfastened the window.</span>"))
			fastened_change()

	else if(isprying(W) && reinf && state <= 1)
		if(!handle_fumbling(user, src, SKILL_TASK_EASY, list(/datum/skill/construction = SKILL_LEVEL_TRAINED), message_self = "<span class='notice'>You fumble around, figuring out how to [state ? "pry the window out of the frame." : "pry the window into the frame."]</span>" ))
			return
		state = 1 - state
		playsound(src, 'sound/items/Crowbar.ogg', VOL_EFFECTS_MASTER)
		to_chat(user, (state ? "<span class='notice'>You have pried the window into the frame.</span>" : "<span class='notice'>You have pried the window out of the frame.</span>"))

	else if(istype(W, /obj/item/weapon/grab) && get_dist(src,user)<2)
		var/obj/item/weapon/grab/G = W
		if (isliving(G.affecting))
			user.SetNextMove(CLICK_CD_MELEE)
			var/mob/living/M = G.affecting
			var/mob/living/A = G.assailant
			var/state = G.state
			qdel(W)	//gotta delete it here because if window breaks, it won't get deleted
			switch (state)
				if(1)
					M.apply_damage(7)
					take_damage(7, BRUTE, MELEE)
					visible_message("<span class='danger'>[A] slams [M] against \the [src]!</span>")

					M.log_combat(user, "slammed against [name]")
				if(2)
					if (prob(50))
						M.Stun(1)
						M.Weaken(1)
					M.apply_damage(8)
					take_damage(9, BRUTE, MELEE)
					visible_message("<span class='danger'>[A] bashes [M] against \the [src]!</span>")
					M.log_combat(user, "bashed against [name]")
				if(3)
					M.Stun(5)
					M.Weaken(5)
					M.apply_damage(20)
					take_damage(12, BRUTE, MELEE)
					visible_message("<span class='danger'><big>[A] crushes [M] against \the [src]!</big></span>")
					M.log_combat(user, "crushed against [name]")
	else
		return ..()*/

/obj/structure/window/thin/verb/rotate()
	set name = "Rotate Window Counter-Clockwise"
	set category = "Object"
	set src in oview(1)

	if(isobserver(usr)) //to stop ghosts from rotating
		return

	if(anchored)
		to_chat(usr, "It is fastened to the floor therefore you can't rotate it!")
		return 0

	update_nearby_tiles(need_rebuild=1) //Compel updates before
	set_dir(turn(dir, 90))
//	updateSilicate()
	update_nearby_tiles(need_rebuild=1)
	ini_dir = dir
	return

/obj/structure/window/thin/verb/revrotate()
	set name = "Rotate Window Clockwise"
	set category = "Object"
	set src in oview(1)

	if(isobserver(usr)) //to stop ghosts from rotating
		return

	if(anchored)
		to_chat(usr, "It is fastened to the floor therefore you can't rotate it!")
		return 0

	update_nearby_tiles(need_rebuild=1) //Compel updates before
	set_dir(turn(dir, 270))
//	updateSilicate()
	update_nearby_tiles(need_rebuild=1)
	ini_dir = dir
	return

/obj/structure/window/thin/Destroy()
	density = FALSE
	playsound(src, pick(SOUNDIN_SHATTER), VOL_EFFECTS_MASTER)
	update_nearby_tiles()
	//update_nearby_icons()
	return ..()

/obj/structure/window/thin/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0)
	update_nearby_tiles(need_rebuild=1)
	. = ..()

	if(moving_diagonally)
		return .

	set_dir(ini_dir)
	update_nearby_tiles(need_rebuild=1)


/**
 * Thin phoron
 */

/obj/structure/window/thin/phoron
	name = "phoron thin window"
	desc = "A phoron-glass alloy window. It looks insanely tough to break. It appears it's also insanely tough to burn through."

	icon_state = "phoronwindow"

	max_integrity = 120

/obj/structure/window/thin/phoron/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > T0C + 32000)
		take_damage(round(exposed_volume / 1000), BURN, FIRE, FALSE)

/**
 * Thin reinforced
 */

/obj/structure/window/thin/reinforced
	name = "reinforced thin window"
	desc = "It looks rather strong. Might take a few good hits to shatter it."

	icon_state = "rwindow"

	max_integrity = 100

/**
 * Fulltile reinforced phoron
 */

/obj/structure/window/thin/reinforced/phoron
	name = "reinforced thin phoron window"
	desc = "A phoron-glass alloy window, with rods supporting it. It looks hopelessly tough to break. It also looks completely fireproof, considering how basic phoron windows are insanely fireproof."

	icon_state = "phoronrwindow"

	max_integrity = 160

/obj/structure/window/fulltile/reinforced/phoron/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	return

/**
 * Thin reinforced tinted
 */

/obj/structure/window/thin/reinforced/tinted
	name = "reinforced thin tinted window"
	desc = "It looks rather strong and opaque. Might take a few good hits to shatter it."
	opacity = 1

	icon_state = "twindow"

 /**
 * Thin reinforced holo
 */

/obj/structure/window/thin/reinforced/holowindow // should be moved from subtypes to flags
	flags = NODECONSTRUCT | ON_BORDER

/obj/structure/window/thin/reinforced/holowindow/attackby(obj/item/W, mob/user)
	if(isscrewing(W))
		to_chat(user, ("<span class='notice'>It's a holowindow, you can't unfasten it!</span>"))
	else if(isprying(W))
		to_chat(user, ("<span class='notice'>It's a holowindow, you can't pry it!</span>"))
	else
		return ..()

/obj/structure/window/thin/reinforced/holowindow/disappearing // wtf
