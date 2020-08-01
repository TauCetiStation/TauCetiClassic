/obj/machinery/bot/secbot/ed209
	name = "ED-209 Security Robot"
	desc = "A security robot.  He looks less than thrilled."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "ed2090"
	icon_state_arrest = "ed209-c"
	health = 100
	maxhealth = 100

	var/lastfired = 0
	var/shot_delay = 3 //.3 seconds between shots

	var/disabled = 0//A holder for if it needs to be disabled, if true it will not seach for targets, shoot at targets, or move, currently only used for lasertag
	idcheck = 1 //If false, all station IDs are authorized for weapons.
	check_records = 1 //Does it check security records? Checks arrest status and existence of record
	var/projectile = null//Holder for projectile type, to avoid so many else if chains

	var/lasertag_color = ""

/obj/item/weapon/ed209_assembly
	name = "ED-209 assembly"
	desc = "Some sort of bizarre assembly."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "ed209_frame"
	item_state = "ed209_frame"
	var/build_step = 0
	var/created_name = "ED-209 Security Robot" //To preserve the name if it's a unique securitron I guess
	var/lasertag_color = ""


/obj/machinery/bot/secbot/ed209/atom_init(mapload, created_name, created_lasercolor)
	. = ..()
	if(created_name)
		name = created_name
	if(created_lasercolor)
		lasertag_color = created_lasercolor
		update_icon()

	if(lasertag_color)
		shot_delay = 6		//Longer shot delay because JESUS CHRIST
		check_records = 0	//Don't actively target people set to arrest
		arrest_type = 1		//Don't even try to cuff
		req_one_access.Cut()
		req_access = list(access_maint_tunnels)
		arrest_type = 1
		if((lasertag_color == "blue") && (name == "ED-209 Security Robot"))//Picks a name if there isn't already a custome one
			name = pick("BLUE BALLER","SANIC","BLUE KILLDEATH MURDERBOT")
		if((lasertag_color == "red") && (name == "ED-209 Security Robot"))
			name = pick("RED RAMPAGE","RED ROVER","RED KILLDEATH MURDERBOT")


/obj/machinery/bot/secbot/ed209/update_icon()
	icon_state = "[lasertag_color]ed209[on]"

/obj/machinery/bot/secbot/ed209/is_operational_topic()
	if(lasertag_color && ishuman(usr))
		var/mob/living/carbon/human/H = usr
		var/obj/item/clothing/suit/lasertag/L = H.wear_suit
		if(istype(L) && L.lasertag_color != lasertag_color)
			return FALSE
	return TRUE

/obj/machinery/bot/secbot/ed209/ui_interact(mob/user)
	var/dat

	dat += text({"
		<TT><B>Automatic Security Unit v2.5</B></TT><BR><BR>
		Status: []<BR>
		Behaviour controls are [locked ? "locked" : "unlocked"]<BR>
		Maintenance panel panel is [open ? "opened" : "closed"]"},

		"<A href='?src=\ref[src];power=1'>[on ? "On" : "Off"]</A>" )

	if(!locked || issilicon(user) || isobserver(user))
		if(!lasercolor)
			dat += text({"<BR>
				Check for Weapon Authorization: []<BR>
				Check Security Records: []<BR>
				Operating Mode: []<BR>
				Report Arrests: []"},

				"<A href='?src=\ref[src];operation=idcheck'>[idcheck ? "Yes" : "No"]</A>",
				"<A href='?src=\ref[src];operation=ignorerec'>[check_records ? "Yes" : "No"]</A>",
				"<A href='?src=\ref[src];operation=switchmode'>[arrest_type ? "Detain" : "Arrest"]</A>",
				"<A href='?src=\ref[src];operation=declarearrests'>[declare_arrests ? "Yes" : "No"]</A>" )

		dat += text({"<BR>
			Auto Patrol: []"},

			"<A href='?src=\ref[src];operation=patrol'>[auto_patrol ? "On" : "Off"]</A>" )

	var/datum/browser/popup = new(user, "window=autosec", src.name)
	popup.set_content(dat)
	popup.open()


/obj/machinery/bot/secbot/ed209/beingAttacked(obj/item/weapon/W, mob/user)
	if(!isscrewdriver(W) && W.force && !target)
		target = user
		mode = SECBOT_HUNT
		if(lasertag_color)//To make up for the fact that lasertag bots don't hunt
			shootAt(user)


/obj/machinery/bot/secbot/ed209/emag_act(mob/user)
	..()
	if(open && !locked)
		projectile = null

/obj/machinery/bot/secbot/ed209/process()
	if(!on)
		return

	var/list/mob/living/targets = list()
	for(var/mob/living/L in view(12, src)) //Let's find us a target
		var/threatlevel = 0
		if(L.stat || L.lying && !L.crawling)
			continue
		threatlevel = assess_perp(L)
		//speak(C.real_name + text(": threat: []", threatlevel))
		if(threatlevel < 4)
			continue

		var/dst = get_dist(src, L)
		if(dst <= 1)
			continue
		targets += L

	if(targets.len)
		shootAt(pick(targets))

	if((mode == SECBOT_HUNT || mode == SECBOT_PREP_ARREST) && lasercolor) //Lasertag bots do not tase or arrest anyone, just patrol and shoot and whatnot
		mode = SECBOT_IDLE
		return

	..()

// perform a single patrol step

/obj/machinery/bot/secbot/ed209/patrol_step()
	if(loc == patrol_target)		// reached target
		at_patrol_target()
		return

	else if(path.len > 0 && patrol_target)		// valid path
		var/turf/next = path[1]
		if(next == loc)
			path -= next
			return

		if(istype(next, /turf/simulated))
			var/moved = step_towards(src, next)	// attempt to move
			if(moved)	// successful move
				blockcount = 0
				path -= loc

				look_for_perp()
				if(lasertag_color)
					sleep(20)
			else		// failed to move
				blockcount++
				if(blockcount > 5)	// attempt 5 times before recomputing
					// find new path excluding blocked turf
					addtimer(CALLBACK(src, .proc/patrol_substep, next), 2)

		else	// not a valid turf
			mode = SECBOT_IDLE

	else	// no path, so calculate new one
		mode = SECBOT_START_PATROL



// look for a criminal in view of the bot

/obj/machinery/bot/secbot/ed209/look_for_perp()
	if(disabled)
		return

	anchored = 0
	threatlevel = 0
	for(var/mob/living/L in view(12, src)) //Let's find us a criminal
		if(L.stat || (lasercolor && L.lying && !L.crawling))
			continue //Does not shoot at people lyind down when in lasertag mode, because it's just annoying, and they can fire once they get up.

		if(iscarbon(L))
			var/mob/living/carbon/C = L
			if(C.handcuffed)
				continue

		if((L.name == oldtarget_name) && (world.time < last_found + 100))
			continue

		threatlevel = assess_perp(L)

		if(threatlevel >= 4)
			target = L
			oldtarget_name = L.name
			speak("Level [threatlevel] infraction alert!")
			if(!lasercolor)
				playsound(src, pick('sound/voice/ed209_20sec.ogg', 'sound/voice/EDPlaceholder.ogg'), VOL_EFFECTS_MASTER, null, FALSE)
			visible_message("<b>[src]</b> points at [L.name]!")
			mode = SECBOT_HUNT
			process() // ensure bot quickly responds to a perp
			break
		else
			continue


//If the security records say to arrest them, arrest them
//Or if they have weapons and aren't security, arrest them.
/obj/machinery/bot/secbot/ed209/assess_perp(mob/living/perp)
	var/threatcount = ..()

	if(lasertag_color && ishuman(perp))
		var/mob/living/carbon/human/hperp = perp
		var/obj/item/active = hperp.get_active_hand()
		var/obj/item/inactive = hperp.get_inactive_hand()
		var/list/to_check = list(active, inactive, hperp.belt, hperp.wear_suit)

		for(var/obj/item/I in to_check)
			if(istype(I, /obj/item/clothing/suit/lasertag))
				var/obj/item/clothing/suit/lasertag/L = I
				if(L.lasertag_color != lasertag_color)
					threatcount += 4
			else if(istype(I, /obj/item/weapon/gun/energy/laser/lasertag))
				var/obj/item/weapon/gun/energy/laser/lasertag/L = I
				if(L.lasertag_color != lasertag_color)
					threatcount += 4

	if(idcheck && allowed(perp) && !lasertag_color)
		threatcount = 0//Corrupt cops cannot exist beep boop

	return threatcount

/obj/machinery/bot/secbot/ed209/explode()
	walk_to(src, 0)
	visible_message("<span class='warning'><B>[src] blows apart!</B></span>")
	var/turf/Tsec = get_turf(src)

	var/obj/item/weapon/ed209_assembly/Sa = new /obj/item/weapon/ed209_assembly(Tsec)
	Sa.build_step = 1
	Sa.add_overlay(image('icons/obj/aibots.dmi', "hs_hole"))
	Sa.created_name = name
	new /obj/item/device/assembly/prox_sensor(Tsec)

	if(!lasercolor)
		var/obj/item/weapon/gun/energy/taser/G = new /obj/item/weapon/gun/energy/taser(Tsec)
		G.power_supply.charge = 0
	else if(lasertag_color == "blue")
		var/obj/item/weapon/gun/energy/laser/lasertag/bluetag/G = new /obj/item/weapon/gun/energy/laser/lasertag/bluetag(Tsec)
		G.power_supply.charge = 0
	else if(lasertag_color == "red")
		var/obj/item/weapon/gun/energy/laser/lasertag/redtag/G = new /obj/item/weapon/gun/energy/laser/lasertag/redtag(Tsec)
		G.power_supply.charge = 0

	if(prob(50))
		new /obj/item/robot_parts/l_leg(Tsec)
		if(prob(25))
			new /obj/item/robot_parts/r_leg(Tsec)
	if(prob(25))//50% chance for a helmet OR vest
		if(prob(50))
			new /obj/item/clothing/head/helmet(Tsec)
		else
			if(!lasercolor)
				new /obj/item/clothing/suit/storage/flak(Tsec)
			if(lasertag_color == "blue")
				new /obj/item/clothing/suit/lasertag/bluetag(Tsec)
			if(lasertag_color == "red")
				new /obj/item/clothing/suit/lasertag/redtag(Tsec)

	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(3, 1, src)
	s.start()

	new /obj/effect/decal/cleanable/blood/oil(loc)
	qdel(src)


/obj/machinery/bot/secbot/ed209/proc/shootAt(mob/target)
	if(lastfired && world.time - lastfired < shot_delay)
		return
	lastfired = world.time
	var/turf/T = get_turf(src)
	var/atom/U = get_turf(target)
	if(!istype(T) || !istype(U))
		return

	//if(lastfired && world.time - lastfired < 100)
	//	playsound(src, 'ed209_shoot.ogg', VOL_EFFECTS_MASTER, null, FALSE)

	if(!projectile)
		if(!lasercolor)
			if(emagged == 2)
				projectile = /obj/item/projectile/beam
			else
				projectile = /obj/item/projectile/energy/electrode
		else if(lasercolor == "b")
			if(emagged == 2)
				projectile = /obj/item/projectile/beam/lasertag/omni
			else
				projectile = /obj/item/projectile/beam/lasertag/blue
		else if(lasercolor == "r")
			if(emagged == 2)
				projectile = /obj/item/projectile/beam/lasertag/omni
			else
				projectile = /obj/item/projectile/beam/lasertag/red

	var/obj/item/projectile/A = new projectile(loc)
	A.original = target
	A.current = T
	A.starting = T
	A.fake = TRUE
	A.yo = U.y - T.y
	A.xo = U.x - T.x
	A.process()

/obj/machinery/bot/secbot/ed209/attack_alien(mob/living/carbon/xenomorph/user)
	..()
	if(!isxeno(target))
		target = user
		mode = SECBOT_HUNT


/obj/machinery/bot/secbot/ed209/emp_act(severity)
	if(severity == 2 && prob(70))
		..(severity - 1)
	else
		var/obj/effect/overlay/pulse2 = new/obj/effect/overlay(loc)
		pulse2.icon = 'icons/effects/effects.dmi'
		pulse2.icon_state = "empdisable"
		pulse2.name = "emp sparks"
		pulse2.anchored = 1
		pulse2.dir = pick(cardinal)
		QDEL_IN(pulse2, 10)
		var/list/mob/living/carbon/targets = new
		for(var/mob/living/carbon/C in view(12, src))
			if(C.stat == DEAD)
				continue
			targets += C
		if(targets.len)
			if(prob(50))
				var/mob/toshoot = pick(targets)
				if(toshoot)
					targets -= toshoot
					if(prob(50) && emagged < 2)
						emagged = 2
						shootAt(toshoot)
						emagged = 0
					else
						shootAt(toshoot)
			else if(prob(50))
				if(targets.len)
					var/mob/toarrest = pick(targets)
					if(toarrest)
						target = toarrest
						mode = SECBOT_HUNT



/obj/item/weapon/ed209_assembly/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/pen))
		var/t = sanitize_safe(input(user, "Enter new robot name", name, input_default(created_name)), MAX_NAME_LEN)
		if(!t)
			return
		if(!in_range(src, usr) && loc != usr)
			return
		created_name = t
		return

	var/did_something = FALSE

	switch(build_step)
		if(0, 1)
			if(istype(I, /obj/item/robot_parts/l_leg) || istype(I, /obj/item/robot_parts/r_leg))
				qdel(I)
				build_step++
				to_chat(user, "<span class='notice'>You add the robot leg to [src].</span>")
				name = "legs/frame assembly"
				if(build_step == 1)
					item_state = "ed209_leg"
					icon_state = "ed209_leg"
				else
					item_state = "ed209_legs"
					icon_state = "ed209_legs"
				did_something = TRUE

		if(2)
			if(istype(I, /obj/item/clothing/suit/lasertag/redtag))
				lasertag_color = "red"
			else if(istype(I, /obj/item/clothing/suit/lasertag/bluetag))
				lasertag_color = "blue"
			if(lasertag_color || istype(I, /obj/item/clothing/suit/storage/flak))
				qdel(I)
				build_step++
				to_chat(user, "<span class='notice'>You add the armor to [src].</span>")
				name = "vest/legs/frame assembly"
				item_state = "[lasertag_color]ed209_shell"
				icon_state = "[lasertag_color]ed209_shell"
				did_something = TRUE

		if(3)
			if(iswelder(I))
				var/obj/item/weapon/weldingtool/WT = I
				if(WT.use(0,user))
					build_step++
					name = "shielded frame assembly"
					to_chat(user, "<span class='notice'>You welded the vest to [src].</span>")
				did_something = TRUE
		if(4)
			if(istype(I, /obj/item/clothing/head/helmet))
				qdel(I)
				build_step++
				to_chat(user, "<span class='notice'>You add the helmet to [src].</span>")
				name = "covered and shielded frame assembly"
				item_state = "[lasertag_color]ed209_hat"
				icon_state = "[lasertag_color]ed209_hat"
				did_something = TRUE

		if(5)
			if(isprox(I))
				qdel(I)
				build_step++
				to_chat(user, "<span class='notice'>You add the prox sensor to [src].</span>")
				name = "covered, shielded and sensored frame assembly"
				item_state = "[lasertag_color]ed209_prox"
				icon_state = "[lasertag_color]ed209_prox"
				did_something = TRUE

		if(6)
			if(iscoil(I))
				if(user.is_busy(src))
					return
				to_chat(user, "<span class='notice'>You start to wire [src]...</span>")
				if(I.use_tool(src, user, 40, amount = 1, volume = 50))
					if(build_step == 6)
						build_step++
						to_chat(user, "<span class='notice'>You wire the ED-209 assembly.</span>")
						name = "wired ED-209 assembly"
				did_something = TRUE

		if(7)
			switch(lasertag_color)
				if("blue")
					if(!istype(I, /obj/item/weapon/gun/energy/laser/lasertag/bluetag))
						return
					name = "bluetag ED-209 assembly"
				if("red")
					if(!istype(I, /obj/item/weapon/gun/energy/laser/lasertag/redtag))
						return
					name = "redtag ED-209 assembly"
				if("")
					if(!istype(I, /obj/item/weapon/gun/energy/taser/stunrevolver))
						return
					name = "taser ED-209 assembly"
				else
					return
			build_step++
			to_chat(user, "<span class='notice'>You add [I] to [src].</span>")
			item_state = "[lasertag_color]ed209_taser"
			icon_state = "[lasertag_color]ed209_taser"
			qdel(I)
			did_something = TRUE

		if(8)
			if(isscrewdriver(I))
				if(user.is_busy(src))
					return
				to_chat(user, "<span class='notice'>Now attaching the gun to the frame...</span>")
				if(I.use_tool(src, user, 40, volume = 100))
					if(build_step == 8)
						build_step++
						name = "armed [name]"
						to_chat(user, "<span class='notice'>Taser gun attached.</span>")
				did_something = TRUE

		if(9)
			if(istype(I, /obj/item/weapon/stock_parts/cell))
				build_step++
				to_chat(user, "<span class='notice'>You complete the ED-209.</span>")
				var/turf/T = get_turf(src)
				new /obj/machinery/bot/secbot/ed209(T, created_name, lasertag_color)
				qdel(I)
				qdel(src)
				did_something = TRUE

	if(!did_something)
		return ..()

/obj/machinery/bot/secbot/ed209/bullet_act(obj/item/projectile/Proj)
	if(!disabled && istype(Proj, /obj/item/projectile/beam/lasertag))
		var/obj/item/projectile/beam/lasertag/L = Proj
		if(L.lasertag_color != lasertag_color)
			disabled = TRUE
			qdel(Proj)
			addtimer(VARSET_CALLBACK(src, disabled, FALSE), 100)
		return
	return ..()

/obj/machinery/bot/secbot/ed209/bluetag/atom_init() // If desired, you spawn red and bluetag bots easily
	..()
	new /obj/machinery/bot/secbot/ed209(get_turf(src), null, "blue")
	return INITIALIZE_HINT_QDEL

/obj/machinery/bot/secbot/ed209/redtag/atom_init()
	..()
	new /obj/machinery/bot/secbot/ed209(get_turf(src), null, "red")
	return INITIALIZE_HINT_QDEL
