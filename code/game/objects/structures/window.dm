/obj/structure/window
	name = "window"
	desc = "A window."
	icon = 'icons/obj/window.dmi'
	density = TRUE
	layer = 3.2//Just above doors
	anchored = TRUE
	flags = ON_BORDER
	can_be_unanchored = TRUE

	max_integrity = 14
	integrity_failure = 0.75
	resistance_flags = CAN_BE_HIT

	var/ini_dir = null
	var/state = 2
	var/reinf = 0
	var/basestate
	var/can_merge = 1	//Sometimes it's needed
	var/shardtype = /obj/item/weapon/shard
	var/image/crack_overlay
	var/damage_threshold = 5	//This will be deducted from any physical damage source.
//	var/silicate = 0 // number of units of silicate
//	var/icon/silicateIcon = null // the silicated icon

/obj/structure/window/play_attack_sound(damage_amount, damage_type, damage_flag)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(loc, 'sound/effects/Glasshit.ogg', VOL_EFFECTS_MASTER, 90)
			else
				playsound(loc, 'sound/weapons/tap.ogg', VOL_EFFECTS_MASTER, 50, TRUE)
		if(BURN)
			playsound(loc, 'sound/items/welder.ogg', VOL_EFFECTS_MASTER, 100, TRUE)

/obj/structure/window/run_atom_armor(damage_amount, damage_type, damage_flag, attack_dir)
	if(is_fulltile() && damage_threshold)
		switch(damage_type)
			if(BRUTE)
				return max(0, damage_amount - damage_threshold)
			if(BURN)
				return damage_amount * 0.3
	return ..()

/obj/structure/window/atom_break(damage_flag)
	. = ..()

	var/ratio = get_integrity() / max_integrity

	switch(ratio)
		if(0 to 0.25)
			if(!is_fulltile())
				visible_message("[src] looks like it's about to shatter!" )
			integrity_failure = 0
		if(0.25 to 0.5)
			if(!is_fulltile())
				visible_message("[src] looks seriously damaged!" )
			integrity_failure = 0.25
		if(0.5 to 0.75)
			if(!is_fulltile())
				visible_message("Cracks begin to appear in [src]!" )
			integrity_failure = 0.5
	update_icon()

/obj/structure/window/deconstruct()
	shatter()

/obj/structure/window/take_damage(damage_amount, damage_type = BRUTE, damage_flag = "", sound_effect = TRUE, attack_dir)
	. = ..()
	if(attack_dir && !reinf && . && get_integrity() < 7)
		if(anchored)
			anchored = FALSE
			update_nearby_icons()
			fastened_change()
		step(src, reverse_dir[attack_dir])

/obj/structure/window/proc/shatter()
	playsound(src, pick(SOUNDIN_SHATTER), VOL_EFFECTS_MASTER)
	visible_message("[src] shatters!")
	if(!(flags & NODECONSTRUCT))
		var/fulltile = is_fulltile()
		new shardtype(loc)
		if(fulltile)
			new shardtype
		if(reinf)
			new /obj/item/stack/rods(loc, fulltile ? 2 : 1)
	qdel(src)

/obj/structure/window/bullet_act(obj/item/projectile/Proj, def_zone)
	if(Proj.pass_flags & PASSGLASS)	//Lasers mostly use this flag.. Why should they able to focus damage with direct click...
		return PROJECTILE_FORCE_MISS

	return ..()

/obj/structure/window/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			qdel(src)
		if(EXPLODE_HEAVY)
			take_damage(rand(30, 50), BRUTE, BOMB)
		if(EXPLODE_LIGHT)
			take_damage(rand(5, 15), BRUTE, BOMB)

/obj/structure/window/airlock_crush_act()
	take_damage(DOOR_CRUSH_DAMAGE * 2, BRUTE, MELEE)
	..()

/obj/structure/window/blob_act()
	take_damage(rand(30, 50), BRUTE, MELEE)

/obj/structure/window/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return 1
	if(is_fulltile())
		return 0	//full tile window, you can't move into it!
	if(get_dir(loc, target) & dir)
		return !density
	else
		return 1

/obj/structure/window/CanAStarPass(obj/item/weapon/card/id/ID, to_dir, caller)
	if(!density)
		return TRUE
	if((dir == SOUTHWEST) || (dir == to_dir))
		return FALSE

	return TRUE

/obj/structure/window/CheckExit(atom/movable/O, target)
	if(istype(O) && O.checkpass(PASSGLASS))
		return 1
	if(get_dir(O.loc, target) == dir)
		return 0
	return 1

/obj/structure/window/attack_hand(mob/user)	//specflags please!!
	user.SetNextMove(CLICK_CD_MELEE)
	if(HULK in user.mutations)
		user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!"))
		attack_generic(user, rand(15, 25), BRUTE, MELEE)
	else if(user.get_species() == GOLEM || user.get_species() == ABOMINATION)
		attack_generic(user, rand(15, 25), BRUTE, MELEE)
	else if (user.a_intent == INTENT_HARM)
		playsound(src, 'sound/effects/glassknock.ogg', VOL_EFFECTS_MASTER)
		user.visible_message("<span class='danger'>[usr.name] bangs against the [src.name]!</span>", \
							"<span class='danger'>You bang against the [src.name]!</span>", \
							"You hear a banging sound.")
	else
		playsound(src, 'sound/effects/glassknock.ogg', VOL_EFFECTS_MASTER)
		user.visible_message("[usr.name] knocks on the [src.name].", \
							"You knock on the [src.name].", \
							"You hear a knocking sound.")

/obj/structure/window/attack_tk(mob/user)
	user.visible_message("<span class='notice'>Something knocks on [src].</span>")
	playsound(src, 'sound/effects/Glasshit.ogg', VOL_EFFECTS_MASTER)
	return TRUE

/obj/structure/window/attack_paw(mob/user)
	return attack_hand(user)

/obj/structure/window/attack_generic(mob/user, damage_amount = 0, damage_type = BRUTE, damage_flag = 0, sound_effect = TRUE)
	if(!damage_amount)
		return
	if(damage_amount >= 10)
		visible_message("<span class='danger'>[user] smashes into [src]!</span>")
		return ..(user, damage_amount, damage_type, damage_flag, sound_effect)

	visible_message("<span class='notice'>\The [user] bonks \the [src] harmlessly.</span>")
	user.do_attack_animation(src)

/obj/structure/window/attack_slime(mob/user)
	if(!isslimeadult(user))
		return
	user.SetNextMove(CLICK_CD_MELEE)
	user.do_attack_animation(src)
	attack_generic(user, rand(10, 15))


/obj/structure/window/attackby(obj/item/W, mob/user)
	if(flags & NODECONSTRUCT)
		if(isscrewdriver(W) | iscrowbar(W))
			return ..()

	user.SetNextMove(CLICK_CD_INTERACT)
	if(istype(W, /obj/item/weapon/airlock_painter))
		change_paintjob(W, user)

	else if(isscrewdriver(W))
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
			update_nearby_icons()
			playsound(src, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER)
			to_chat(user, (anchored ? "<span class='notice'>You have fastened the frame to the floor.</span>" : "<span class='notice'>You have unfastened the frame from the floor.</span>"))
			fastened_change()

		else if(!reinf)
			if(!handle_fumbling(user, src, SKILL_TASK_EASY,list(/datum/skill/construction = SKILL_LEVEL_TRAINED), message_self = "<span class='notice'>You fumble around, figuring out how to [anchored ? "fasten the window to the floor." : "unfasten the window."]</span>" ))
				return
			anchored = !anchored
			update_nearby_icons()
			playsound(src, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER)
			to_chat(user, (anchored ? "<span class='notice'>You have fastened the window to the floor.</span>" : "<span class='notice'>You have unfastened the window.</span>"))
			fastened_change()

	else if(iscrowbar(W) && reinf && state <= 1)
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

	else if(istype(W,/obj/item/weapon/changeling_hammer))
		var/obj/item/weapon/changeling_hammer/C = W
		user.SetNextMove(CLICK_CD_MELEE)
		if(C.use_charge(user))
			playsound(src, pick('sound/effects/explosion1.ogg', 'sound/effects/explosion2.ogg'), VOL_EFFECTS_MASTER)
			shatter()
	else
		return ..()

/obj/structure/window/proc/fastened_change()
	return

//painter
/obj/structure/window/proc/change_paintjob(obj/item/C, mob/user)
	var/obj/item/weapon/airlock_painter/W
	if(istype(C, /obj/item/weapon/airlock_painter))
		W = C
	else
		return

	if(!W.can_use(user, 1))
		return

	var/new_color = input(user, "Choose color!") as color|null
	if(!new_color) return

	if(!Adjacent(usr) || !W.use(1))
		return
	else
		color = new_color

/obj/structure/window/verb/rotate()
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


/obj/structure/window/verb/revrotate()
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


/*
/obj/structure/window/proc/updateSilicate()
	if(silicateIcon && silicate)
		icon = initial(icon)

		var/icon/I = icon(icon,icon_state,dir)

		var/r = (silicate / 100) + 1
		var/g = (silicate / 70) + 1
		var/b = (silicate / 50) + 1
		I.SetIntensity(r,g,b)
		icon = I
		silicateIcon = I
*/


/obj/structure/window/atom_init()
	. = ..()

	ini_dir = dir
	color = color_windows()

	update_nearby_tiles(need_rebuild = 1)
	update_nearby_icons()


/obj/structure/window/Destroy()
	density = FALSE
	playsound(src, pick(SOUNDIN_SHATTER), VOL_EFFECTS_MASTER)
	update_nearby_tiles()
	update_nearby_icons()
	return ..()


/obj/structure/window/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0)
	update_nearby_tiles(need_rebuild=1)
	. = ..()

	if(moving_diagonally)
		return .

	set_dir(ini_dir)
	update_nearby_tiles(need_rebuild=1)

//checks if this window is full-tile one
/obj/structure/window/proc/is_fulltile()
	return ISDIAGONALDIR(dir)

//This proc is used to update the icons of nearby windows. It should not be confused with update_nearby_tiles(), which is an atmos proc!
/obj/structure/window/proc/update_nearby_icons()
	update_icon()
	for(var/direction in cardinal)
		for(var/obj/structure/window/W in get_step(src,direction) )
			W.update_icon()

//merges adjacent full-tile windows into one (blatant ripoff from game/smoothwall.dm)
/obj/structure/window/update_icon()
	//A little cludge here, since I don't know how it will work with slim windows. Most likely VERY wrong.
	//this way it will only update full-tile ones
	//This spawn is here so windows get properly updated when one gets deleted.
	spawn(2)
		if(!src)
			return
		if(!is_fulltile())
			icon_state = "[basestate]"
			return

		var/junction = 0 //will be used to determine from which side the window is connected to other windows
		if(anchored)
			for(var/obj/structure/window/W in orange(src,1))
				if(W.anchored && W.density && W.is_fulltile() && W.can_merge) //Only counts anchored, not-destroyed fill-tile windows.
					if(abs(x-W.x)-abs(y-W.y) ) 		//doesn't count windows, placed diagonally to src
						junction |= get_dir(src,W)
		icon_state = "[basestate][junction]"

		var/ratio = get_integrity() / max_integrity
		ratio = CEIL(ratio * 4) * 25

		cut_overlay(crack_overlay)
		if(ratio > 75)
			return
		crack_overlay = image('icons/obj/window.dmi',"damage[ratio]",-(layer+0.1))
		add_overlay(crack_overlay)

/obj/structure/window/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > T0C + 800)
		take_damage(round(exposed_volume / 100), BURN, FIRE, FALSE)


/obj/structure/window/basic
	desc = "It looks thin and flimsy. A few knocks with... anything, really should shatter it."
	icon_state = "window"
	basestate = "window"

/obj/structure/window/phoronbasic
	name = "phoron window"
	desc = "A phoron-glass alloy window. It looks insanely tough to break. It appears it's also insanely tough to burn through."
	basestate = "phoronwindow"
	icon_state = "phoronwindow"
	shardtype = /obj/item/weapon/shard/phoron
	max_integrity = 120

/obj/structure/window/phoronbasic/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > T0C + 32000)
		take_damage(round(exposed_volume / 1000), BURN, FIRE, FALSE)

/obj/structure/window/phoronreinforced
	name = "reinforced phoron window"
	desc = "A phoron-glass alloy window, with rods supporting it. It looks hopelessly tough to break. It also looks completely fireproof, considering how basic phoron windows are insanely fireproof."
	basestate = "phoronrwindow"
	icon_state = "phoronrwindow"
	shardtype = /obj/item/weapon/shard/phoron
	reinf = 1
	max_integrity = 160

/obj/structure/window/phoronreinforced/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	return

/obj/structure/window/reinforced
	name = "reinforced window"
	desc = "It looks rather strong. Might take a few good hits to shatter it."
	icon_state = "rwindow"
	basestate = "rwindow"
	max_integrity = 100
	reinf = 1
	damage_threshold = 15

/obj/structure/window/reinforced/indestructible
	flags = NODECONSTRUCT | ON_BORDER
	resistance_flags = FULL_INDESTRUCTIBLE

/obj/structure/window/reinforced/tinted
	name = "tinted window"
	desc = "It looks rather strong and opaque. Might take a few good hits to shatter it."
	icon_state = "twindow"
	basestate = "twindow"
	opacity = 1

/obj/structure/window/reinforced/tinted/frosted //Actually, there is no icon for this!!
	name = "frosted window"
	desc = "It looks rather strong and frosted over. Looks like it might take a few less hits then a normal reinforced window."
	icon_state = "fwindow"
	basestate = "fwindow"
	max_integrity = 30
	damage_threshold = 0

/obj/structure/window/shuttle
	name = "shuttle window"
	desc = "It looks rather strong. Might take a few good hits to shatter it."
	icon = 'icons/obj/podwindows.dmi'
	icon_state = "window"
	basestate = "window"
	max_integrity = 150
	reinf = 1
	dir = 5
	damage_threshold = 30

/obj/structure/window/shuttle/update_icon() //icon_state has to be set manually
	return

/obj/structure/window/reinforced/polarized
	name = "electrochromic window"
	desc = "Adjusts its tint with voltage. Might take a few good hits to shatter it."
	icon_state = "fwindow"
	basestate = "fwindow"
	var/id

/obj/structure/window/reinforced/polarized/proc/toggle()
	if(opacity)
		icon_state = "fwindow"
		basestate = "fwindow"
		set_opacity(0)
	else
		icon_state = "twindowold"
		basestate = "twindowold"
		set_opacity(1)

/obj/structure/window/reinforced/polarized/fastened_change()
	if(opacity && !anchored)
		toggle()

/obj/machinery/windowtint/attack_hand(mob/user as mob)
	if(..())
		return 1

	toggle_tint()

/obj/machinery/windowtint/proc/toggle_tint()
	use_power(5)

	active = !active
	update_icon()

	for(var/obj/structure/window/reinforced/polarized/W in range(src,range))
		if ((W.id == src.id || !W.id) && W.anchored)
			W.toggle()

/obj/machinery/windowtint/power_change()
	..()
	if(active && !powered(power_channel))
		toggle_tint()

/obj/machinery/windowtint/update_icon()
	icon_state = "light[active]"

/obj/machinery/windowtint/attackby(obj/item/W as obj, mob/user as mob)
	if(ismultitool(W))
		var/t = sanitize(input(user, "Enter an ID for \the [src].", src.name, null), MAX_NAME_LEN)
		src.id = t
		to_chat(user, "<span class='notice'>The new ID of \the [src] is [id]</span>")
		return
	. = ..()

/obj/structure/window/reinforced/polarized/attackby(obj/item/W as obj, mob/user as mob)
	if(ismultitool(W) && !anchored) // Only allow programming if unanchored!
		var/t = sanitize(input(user, "Enter the ID for the window.", src.name, null), MAX_NAME_LEN)
		src.id = t
		to_chat(user, "<span class='notice'>The new ID of \the [src] is [id]</span>")
		return TRUE
	return ..()
