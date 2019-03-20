/obj/structure/window
	name = "window"
	desc = "A window."
	icon = 'icons/obj/window.dmi'
	density = 1
	layer = 3.2//Just above doors
	anchored = 1.0
	flags = ON_BORDER
	var/maxhealth = 14.0
	var/health
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

/obj/structure/window/proc/take_damage(damage = 0, damage_type = BRUTE, sound_effect = 1)
	var/initialhealth = health
	var/message = 1
	var/fulltile = 0

	//if(silicate)
	//	damage = damage * (1 - silicate / 200)

	if(is_fulltile())
		message = 0
		fulltile = 1

	if(fulltile && damage_threshold)
		switch(damage_type)
			if(BRUTE)
				damage = max(0, damage - damage_threshold)
			if(BURN)
				damage *= 0.3
			if("generic")
				damage *= 0.5

	if(!damage)
		return

	health = max(0, health - damage)

	if(health <= 0)
		shatter()
	else
		if(sound_effect)
			playsound(loc, 'sound/effects/Glasshit.ogg', 100, 1)
		if(message)
			if(health < maxhealth / 4 && initialhealth >= maxhealth / 4)
				visible_message("[src] looks like it's about to shatter!" )
			else if(health < maxhealth / 2 && initialhealth >= maxhealth / 2)
				visible_message("[src] looks seriously damaged!" )
			else if(health < maxhealth * 3/4 && initialhealth >= maxhealth * 3/4)
				visible_message("Cracks begin to appear in [src]!" )
	update_icon()

/obj/structure/window/proc/shatter(display_message = 1)
	playsound(src, "shatter", 70, 1)
	if(display_message)
		visible_message("[src] shatters!")
	if(dir == SOUTHWEST)
		var/index = null
		index = 0
		while(index < 2)
			new shardtype(loc) //todo pooling?
			if(reinf)
				new /obj/item/stack/rods(loc)
			index++
	else
		new shardtype(loc) //todo pooling?
		if(reinf)
			new /obj/item/stack/rods(loc)
	qdel(src)
	return

/obj/structure/window/bullet_act(obj/item/projectile/Proj)
	if(Proj.pass_flags & PASSGLASS)	//Lasers mostly use this flag.. Why should they able to focus damage with direct click...
		return -1

	//Tasers and the like should not damage windows.
	if(!(Proj.damage_type == BRUTE || Proj.damage_type == BURN))
		return

	..()
	take_damage(Proj.damage, Proj.damage_type)
	return


/obj/structure/window/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			shatter(0)
			return
		if(3.0)
			if(prob(50))
				shatter(0)
				return


/obj/structure/window/blob_act()
	shatter()


/obj/structure/window/meteorhit()
	shatter()


/obj/structure/window/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return 1
	if(dir == SOUTHWEST || dir == SOUTHEAST || dir == NORTHWEST || dir == NORTHEAST)
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


/obj/structure/window/hitby(AM)
	..()
	visible_message("<span class='danger'>[src] was hit by [AM].</span>")
	var/tforce = 0
	if(ismob(AM))
		tforce = 40
	else if(isobj(AM))
		var/obj/item/I = AM
		tforce = I.throwforce
	if(reinf)
		tforce *= 0.25
	if(health - tforce <= 7 && !reinf)
		anchored = 0
		update_nearby_icons()
		step(src, get_dir(AM, src))
	take_damage(tforce)

/obj/structure/window/attack_tk(mob/user)
	user.visible_message("<span class='notice'>Something knocks on [src].</span>")
	playsound(loc, 'sound/effects/Glasshit.ogg', 50, 1)

/obj/structure/window/attack_hand(mob/user)	//specflags please!!
	user.SetNextMove(CLICK_CD_MELEE)
	if(HULK in user.mutations)
		user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!"))
		user.do_attack_animation(src)
		take_damage(rand(15,25), "generic")
	else if(user.dna && user.dna.mutantrace == "adamantine")
		user.do_attack_animation(src)
		take_damage(rand(15,25), "generic")
	else if (user.a_intent == "hurt")
		playsound(src.loc, 'sound/effects/glassknock.ogg', 80, 1)
		user.visible_message("<span class='danger'>[usr.name] bangs against the [src.name]!</span>", \
							"<span class='danger'>You bang against the [src.name]!</span>", \
							"You hear a banging sound.")
	else
		playsound(src.loc, 'sound/effects/glassknock.ogg', 80, 1)
		user.visible_message("[usr.name] knocks on the [src.name].", \
							"You knock on the [src.name].", \
							"You hear a knocking sound.")


/obj/structure/window/attack_paw(mob/user)
	return attack_hand(user)


/obj/structure/window/proc/attack_generic(mob/user, damage)
	if(!damage)
		return
	if(damage >= 10)
		visible_message("<span class='danger'>[user] smashes into [src]!</span>")
		take_damage(damage, "generic")
	else
		visible_message("<span class='notice'>\The [user] bonks \the [src] harmlessly.</span>")
	user.do_attack_animation(src)
	return 1


/obj/structure/window/attack_alien(mob/user)
	user.SetNextMove(CLICK_CD_MELEE)
	if(islarva(user) || isfacehugger(user))
		return
	attack_generic(user, 15)

/obj/structure/window/attack_animal(mob/user)
	if(!isanimal(user))
		return
	..()
	var/mob/living/simple_animal/M = user
	if(M.melee_damage_upper <= 0)
		return
	attack_generic(M, M.melee_damage_upper)


/obj/structure/window/attack_slime(mob/user)
	if(!isslimeadult(user))
		return
	user.SetNextMove(CLICK_CD_MELEE)
	user.do_attack_animation(src)
	attack_generic(user, rand(10, 15))


/obj/structure/window/attackby(obj/item/W, mob/user)
	if(!istype(W))
		return//I really wish I did not need this

	user.SetNextMove(CLICK_CD_INTERACT)
	if(istype(W, /obj/item/weapon/airlock_painter))
		change_paintjob(W, user)

	else if(isscrewdriver(W))
		if(reinf && state >= 1)
			state = 3 - state
			playsound(loc, 'sound/items/Screwdriver.ogg', 75, 1)
			to_chat(user, (state == 1 ? "<span class='notice'>You have unfastened the window from the frame.</span>" : "<span class='notice'>You have fastened the window to the frame.</span>"))

		else if(reinf && state == 0)
			anchored = !anchored
			update_nearby_icons()
			playsound(loc, 'sound/items/Screwdriver.ogg', 75, 1)
			to_chat(user, (anchored ? "<span class='notice'>You have fastened the frame to the floor.</span>" : "<span class='notice'>You have unfastened the frame from the floor.</span>"))

		else if(!reinf)
			anchored = !anchored
			update_nearby_icons()
			playsound(loc, 'sound/items/Screwdriver.ogg', 75, 1)
			to_chat(user, (anchored ? "<span class='notice'>You have fastened the window to the floor.</span>" : "<span class='notice'>You have unfastened the window.</span>"))

	else if(iscrowbar(W) && reinf && state <= 1)
		state = 1 - state
		playsound(loc, 'sound/items/Crowbar.ogg', 75, 1)
		to_chat(user, (state ? "<span class='notice'>You have pried the window into the frame.</span>" : "<span class='notice'>You have pried the window out of the frame.</span>"))

	else if(istype(W, /obj/item/weapon/grab) && get_dist(src,user)<2)
		var/obj/item/weapon/grab/G = W
		if (istype(G.affecting, /mob/living))
			user.SetNextMove(CLICK_CD_MELEE)
			var/mob/living/M = G.affecting
			var/mob/living/A = G.assailant
			var/state = G.state
			qdel(W)	//gotta delete it here because if window breaks, it won't get deleted
			switch (state)
				if(1)
					M.apply_damage(7)
					take_damage(7)
					visible_message("<span class='danger'>[user] slams [M] against \the [src]!</span>")
					M.attack_log += "\[[time_stamp()]\] <font color='orange'>Slammed by [A.name] against \the [src]([A.ckey])</font>"
					A.attack_log += "\[[time_stamp()]\] <font color='red'>Slams [M.name] against \the [src]([M.ckey])</font>"
					msg_admin_attack("[key_name(A)] slams [key_name(M)] into \the [src]")
				if(2)
					if (prob(50))
						M.Weaken(1)
					M.apply_damage(8)
					take_damage(9)
					visible_message("<span class='danger'>[user] bashes [M] against \the [src]!</span>")
					M.attack_log += "\[[time_stamp()]\] <font color='orange'>Bashed by [A.name] against \the [src]([A.ckey])</font>"
					A.attack_log += "\[[time_stamp()]\] <font color='red'>Bashes [M.name] against \the [src]([M.ckey])</font>"
					msg_admin_attack("[key_name(A)] bushes [key_name(M)] against \the [src]")
				if(3)
					M.Weaken(5)
					M.apply_damage(20)
					take_damage(12)
					visible_message("<span class='danger'><big>[user] crushes [M] against \the [src]!</big></span>")
					M.attack_log += "\[[time_stamp()]\] <font color='orange'>Crushed by [A.name] against \the [src]([A.ckey])</font>"
					A.attack_log += "\[[time_stamp()]\] <font color='red'>Crushes [M.name] against \the [src]([M.ckey])</font>"
					msg_admin_attack("[key_name(A)] crushes [key_name(M)] against \the [src]")

	else if(istype(W,/obj/item/weapon/changeling_hammer))
		var/obj/item/weapon/changeling_hammer/C = W
		user.SetNextMove(CLICK_CD_MELEE)
		if(C.use_charge(user))
			playsound(loc, pick('sound/effects/explosion1.ogg', 'sound/effects/explosion2.ogg'), 50, 1)
			shatter()

	else
		if(W.damtype == BRUTE || W.damtype == BURN)
			take_damage(W.force)
			if(health <= 7)
				anchored = 0
				update_nearby_icons()
				step(src, get_dir(user, src))
		else
			playsound(loc, 'sound/effects/Glasshit.ogg', 75, 1)
		..()

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

	if((!in_range(src, usr) && src.loc != usr) || !W.use(user, 1))
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
	dir = turn(dir, 90)
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
	dir = turn(dir, 270)
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

	health = maxhealth

	color = color_windows()

	update_nearby_tiles(need_rebuild = 1)
	update_nearby_icons()


/obj/structure/window/Destroy()
	density = 0
	playsound(src, "shatter", 70, 1)
	update_nearby_tiles()
	update_nearby_icons()
	return ..()


/obj/structure/window/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0)
	update_nearby_tiles(need_rebuild=1)
	. = ..()
	dir = ini_dir
	update_nearby_tiles(need_rebuild=1)

//checks if this window is full-tile one
/obj/structure/window/proc/is_fulltile()
	if(dir & (dir - 1))
		return 1
	return 0

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

		var/ratio = health / maxhealth
		ratio = ceil(ratio * 4) * 25

		overlays -= crack_overlay
		if(ratio > 75)
			return
		crack_overlay = image('icons/obj/window.dmi',"damage[ratio]",-(layer+0.1))
		overlays += crack_overlay

/obj/structure/window/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > T0C + 800)
		take_damage(round(exposed_volume / 100), BURN, 0)
	..()



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
	maxhealth = 120.0

/obj/structure/window/phoronbasic/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > T0C + 32000)
		take_damage(round(exposed_volume / 1000), BURN, 0)
	..()

/obj/structure/window/phoronreinforced
	name = "reinforced phoron window"
	desc = "A phoron-glass alloy window, with rods supporting it. It looks hopelessly tough to break. It also looks completely fireproof, considering how basic phoron windows are insanely fireproof."
	basestate = "phoronrwindow"
	icon_state = "phoronrwindow"
	shardtype = /obj/item/weapon/shard/phoron
	reinf = 1
	maxhealth = 160.0

/obj/structure/window/phoronreinforced/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	return

/obj/structure/window/reinforced
	name = "reinforced window"
	desc = "It looks rather strong. Might take a few good hits to shatter it."
	icon_state = "rwindow"
	basestate = "rwindow"
	maxhealth = 100.0
	reinf = 1
	damage_threshold = 15

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
	maxhealth = 30.0
	damage_threshold = 0

/obj/structure/window/shuttle
	name = "shuttle window"
	desc = "It looks rather strong. Might take a few good hits to shatter it."
	icon = 'icons/obj/podwindows.dmi'
	icon_state = "window"
	basestate = "window"
	maxhealth = 150.0
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
		set_opacity(0)
	else
		icon_state = "twindowold"
		set_opacity(1)

/obj/machinery/windowtint/attack_hand(mob/user as mob)
	if(..())
		return 1

	toggle_tint()

/obj/machinery/windowtint/proc/toggle_tint()
	use_power(5)

	active = !active
	update_icon()

	for(var/obj/structure/window/reinforced/polarized/W in range(src,range))
		if (W.id == src.id || !W.id)
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
	. = ..()
