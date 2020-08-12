/turf/simulated/wall
	name = "wall"
	desc = "A huge chunk of metal used to seperate rooms."
	icon = 'icons/turf/walls/has_false_walls/wall.dmi'
	icon_state = "box"
	plane = GAME_PLANE

	var/mineral = "metal"
	var/rotting = 0

	var/damage = 0
	var/damage_cap = 100 //Wall will break down to girders if damage reaches this point

	var/damage_overlay
	var/static/damage_overlays[8]

	var/max_temperature = 2200 //K, walls will take damage if they're next to a fire hotter than this

	var/seconds_to_melt = 10 //It takes 10 seconds for thermite to melt this wall through

	opacity = 1
	density = 1
	blocks_air = 1

	thermal_conductivity = WALL_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = 312500 //a little over 5 cm thick , 312500 for 1 m by 2.5 m by 0.25 m plasteel wall

	var/sheet_type = /obj/item/stack/sheet/metal

	canSmoothWith = list(
		/turf/simulated/wall,
		/turf/simulated/wall/r_wall,
		/obj/structure/falsewall,
		/obj/structure/falsewall/reinforced,
		/obj/structure/girder,
		/obj/structure/girder/reinforced,
		/obj/machinery/door/airlock,
		/obj/machinery/door/airlock/command,
		/obj/machinery/door/airlock/security,
		/obj/machinery/door/airlock/engineering,
		/obj/machinery/door/airlock/medical,
		/obj/machinery/door/airlock/virology,
		/obj/machinery/door/airlock/maintenance,
		/obj/machinery/door/airlock/freezer,
		/obj/machinery/door/airlock/mining,
		/obj/machinery/door/airlock/atmos,
		/obj/machinery/door/airlock/research,
		/obj/machinery/door/airlock/science,
		/obj/machinery/door/airlock/neutral,
		/obj/machinery/door/airlock/highsecurity,
		/obj/machinery/door/airlock/vault,
		/obj/machinery/door/airlock/external,
		/obj/machinery/door/airlock/glass,
		/obj/machinery/door/airlock/command/glass,
		/obj/machinery/door/airlock/engineering/glass,
		/obj/machinery/door/airlock/security/glass,
		/obj/machinery/door/airlock/medical/glass,
		/obj/machinery/door/airlock/virology/glass,
		/obj/machinery/door/airlock/research/glass,
		/obj/machinery/door/airlock/mining/glass,
		/obj/machinery/door/airlock/atmos/glass,
		/obj/machinery/door/airlock/science/glass,
		/obj/machinery/door/airlock/science/neutral,
		)
	smooth = SMOOTH_TRUE

/turf/simulated/wall/Destroy()
	for(var/obj/effect/E in src)
		if(E.name == "Wallrot")
			qdel(E)
	dismantle_wall()
	return ..()

/turf/simulated/wall/ChangeTurf()
	for(var/obj/effect/E in src)
		if(E.name == "Wallrot")
			qdel(E)
	return ..()

//Appearance

/turf/simulated/wall/examine(mob/user)
	..()

	if(!damage)
		to_chat(user, "<span class='info'>It looks fully intact.</span>")
	else
		var/dam = damage / damage_cap
		if(dam <= 0.3)
			to_chat(user, "<span class='warning'>It looks slightly damaged.</span>")
		else if(dam <= 0.6)
			to_chat(user, "<span class='warning'>It looks moderately damaged.</span>")
		else
			to_chat(user, "<span class='danger'>It looks heavily damaged.</span>")

	if(rotting)
		to_chat(user, "<span class='warning'>There is fungus growing on [src].</span>")

/turf/simulated/wall/update_icon()
	if(!damage_overlays[1]) //list hasn't been populated
		generate_overlays()

	if(!damage)
		cut_overlays()
		return

	var/overlay = round(damage / damage_cap * damage_overlays.len) + 1
	if(overlay > damage_overlays.len)
		overlay = damage_overlays.len

	if(damage_overlay && overlay == damage_overlay) //No need to update.
		return

	cut_overlays()
	add_overlay(damage_overlays[overlay])
	damage_overlay = overlay

	return

/turf/simulated/wall/proc/generate_overlays()
	var/alpha_inc = 256 / damage_overlays.len

	for(var/i = 1; i <= damage_overlays.len; i++)
		var/image/img = image(icon = 'icons/turf/walls.dmi', icon_state = "overlay_damage")
		img.blend_mode = BLEND_MULTIPLY
		img.alpha = (i * alpha_inc) - 1
		damage_overlays[i] = img

//Damage

/turf/simulated/wall/proc/take_damage(dam)
	if(dam)
		damage = max(0, damage + dam)
		update_damage()
	return

/turf/simulated/wall/proc/update_damage()
	var/cap = damage_cap
	if(rotting)
		cap = cap / 10

	if(damage >= cap)
		dismantle_wall()
	else
		update_icon()

	return

/turf/simulated/wall/adjacent_fire_act(turf/simulated/floor/adj_turf, datum/gas_mixture/adj_air, adj_temp, adj_volume)
	if(adj_temp > max_temperature)
		take_damage(rand(10, 20) * (adj_temp / max_temperature))

	return ..()

/turf/simulated/wall/proc/dismantle_wall(devastated=0, explode=0)
	if(devastated)
		devastate_wall()
	else
		playsound(src, 'sound/items/Welder.ogg', VOL_EFFECTS_MASTER)
		var/newgirder = break_wall()
		transfer_fingerprints_to(newgirder)

	for(var/obj/O in src.contents) //Eject contents!
		if(istype(O,/obj/effect/decal/cleanable/crayon))
			qdel(O)
		else if(istype(O,/obj/structure/sign/poster))
			var/obj/structure/sign/poster/P = O
			P.roll_and_drop(src)
		else
			O.loc = src
	ChangeTurf(/turf/simulated/floor/plating)

/turf/simulated/wall/proc/break_wall()
	if(istype(src, /turf/simulated/wall/cult))
		new /obj/effect/decal/cleanable/blood(src)
		return (new /obj/structure/cultgirder(src))

	new sheet_type(src, 2)
	return (new /obj/structure/girder(src))

/turf/simulated/wall/proc/devastate_wall()
	if(istype(src, /turf/simulated/wall/cult))
		new /obj/effect/decal/cleanable/blood(src)
		new /obj/effect/decal/remains/human(src)

	new sheet_type(src, 2)
	new /obj/item/stack/sheet/metal(src)

/turf/simulated/wall/ex_act(severity)
	switch(severity)
		if(1)
			src.ChangeTurf(basetype)
		if(2)
			if(prob(75))
				take_damage(rand(150, 250))
			else
				dismantle_wall(1,1)
		if(3)
			take_damage(rand(0, 55))
	return

/turf/simulated/wall/blob_act()
	take_damage(rand(75, 125))
	return

// Wall-rot effect, a nasty fungus that destroys walls.
/turf/simulated/wall/proc/rot()
	if(!rotting)
		rotting = 1

		var/number_rots = rand(2,3)
		for(var/i=0, i<number_rots, i++)
			new /obj/effect/overlay/wall_rot(src)

/turf/simulated/wall/proc/thermitemelt(mob/user, var/seconds_to_melt)
	if(mineral == "diamond")
		return
	var/obj/effect/overlay/O = new/obj/effect/overlay(src)
	O.name = "Thermite"
	O.desc = "Looks hot."
	O.icon = 'icons/effects/fire.dmi'
	O.icon_state = "2"
	O.anchored = 1
	O.density = 1
	O.layer = 5

	src.ChangeTurf(/turf/simulated/floor/plating)

	var/turf/simulated/floor/F = src
	F.burn_tile()
	F.icon_state = "wall_thermite"
	to_chat(user, "<span class='warning'>The thermite starts melting through the wall.</span>")

	spawn(seconds_to_melt * 10)
		if(O)	qdel(O)
//	F.sd_LumReset()		//TODO: ~Carn
	return


//Interactions

/turf/simulated/wall/attack_paw(mob/user)
	return src.attack_hand(user) //#Z2

/*
/turf/simulated/wall/attack_animal(mob/living/simple_animal/M)
	if(M.wall_smash)
		if (istype(src, /turf/simulated/wall/r_wall) && !rotting)
			to_chat(M, text("<span class='notice'>This wall is far too strong for you to destroy.</span>"))
			return
		else
			if (prob(40) || rotting)
				to_chat(M, text("<span class='notice'>You smash through the wall.</span>"))
				dismantle_wall(1)
				return
			else
				to_chat(M, text("<span class='notice'>You smash against the wall.</span>"))
				return

	to_chat(M, "<span class='notice'>You push the wall but nothing happens!</span>")
	return */

/turf/simulated/wall/attack_animal(mob/living/simple_animal/M)
	..()
	if(M.environment_smash >= 2)
		if(istype(M, /mob/living/simple_animal/hulk))
			var/mob/living/simple_animal/hulk/Hulk = M
			playsound(Hulk, 'sound/weapons/tablehit1.ogg', VOL_EFFECTS_MASTER)
			Hulk.health -= rand(4,10)
		playsound(M, 'sound/effects/hulk_hit_wall.ogg', VOL_EFFECTS_MASTER)
		if(istype(src, /turf/simulated/wall/r_wall))
			if(M.environment_smash == 3)
				take_damage(rand(25, 75))
				to_chat(M, "<span class='info'>You smash against the wall.</span>")
			else
				to_chat(M, "<span class='info'>This wall is far too strong for you to destroy.</span>")
		else
			if (prob(40) || rotting)
				to_chat(M, text("<span class='notice'>You smash through the wall.</span>"))
				dismantle_wall(1)
			else
				take_damage(rand(25, 75))
				to_chat(M, "<span class='info'>You smash against the wall.</span>")
				return
			return

/turf/simulated/wall/attack_hand(mob/user)
	user.SetNextMove(CLICK_CD_MELEE)
	if(HULK in user.mutations) //#Z2 No more chances, just randomized damage and hurt intent
		if(user.a_intent == INTENT_HARM)
			playsound(user, 'sound/effects/grillehit.ogg', VOL_EFFECTS_MASTER)
			to_chat(user, text("<span class='notice'>You punch the wall.</span>"))
			take_damage(rand(15, 50))
			if(prob(25))
				user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
			return //##Z2

	if(rotting)
		to_chat(user, "<span class='notice'>The wall crumbles under your touch.</span>")
		dismantle_wall()
		return

	to_chat(user, "<span class='notice'>You push the wall but nothing happens!</span>")
	playsound(src, 'sound/weapons/Genhit.ogg', VOL_EFFECTS_MASTER, 25)
	src.add_fingerprint(user)
	return

/turf/simulated/wall/attackby(obj/item/weapon/W, mob/user)

	if (!(ishuman(user)|| SSticker) && SSticker.mode.name != "monkey")
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return

	//get the user's location
	if(!isturf(user.loc))
		return	//can't do this stuff whilst inside objects and such
	user.SetNextMove(CLICK_CD_MELEE)

	if(rotting)
		if(iswelder(W))
			var/obj/item/weapon/weldingtool/WT = W
			if(WT.use(0,user))
				to_chat(user, "<span class='notice'>You burn away the fungi with \the [WT].</span>")
				playsound(src, 'sound/items/Welder.ogg', VOL_EFFECTS_MASTER, 10)
				for(var/obj/effect/E in src) if(E.name == "Wallrot")
					qdel(E)
				rotting = 0
				return
		else if(!W.is_sharp() && W.force >= 10 || W.force >= 20)
			to_chat(user, "<span class='notice'>\The [src] crumbles away under the force of your [W.name].</span>")
			src.dismantle_wall(1)
			return

	//THERMITE related stuff. Calls src.thermitemelt() which handles melting simulated walls and the relevant effects
	if(thermite)
		if(iswelder(W))
			var/obj/item/weapon/weldingtool/WT = W
			if(WT.use(0,user))
				thermitemelt(user, seconds_to_melt)
				return

		else if(istype(W, /obj/item/weapon/pickaxe/plasmacutter))
			thermitemelt(user, seconds_to_melt)
			return

		else if(istype(W, /obj/item/weapon/melee/energy/blade))
			var/obj/item/weapon/melee/energy/blade/EB = W

			EB.spark_system.start()
			to_chat(user, "<span class='notice'>You slash \the [src] with \the [EB]; the thermite ignites!</span>")
			playsound(src, pick(SOUNDIN_SPARKS), VOL_EFFECTS_MASTER)
			playsound(src, 'sound/weapons/blade1.ogg', VOL_EFFECTS_MASTER)

			thermitemelt(user, seconds_to_melt)
			return

	var/turf/T = user.loc	//get user's location for delay checks

	//DECONSTRUCTION
	if(iswelder(W))
		if(user.is_busy()) return

		var/response = "Dismantle"
		if(damage)
			response = alert(user, "Would you like to repair or dismantle [src]?", "[src]", "Repair", "Dismantle")

		var/obj/item/weapon/weldingtool/WT = W

		if(WT.use(0,user))
			if(response == "Repair")
				to_chat(user, "<span class='notice'>You start repairing the damage to [src].</span>")
				if(WT.use_tool(src, user, max(5, damage / 5), volume = 100))
					to_chat(user, "<span class='notice'>You finish repairing the damage to [src].</span>")
					take_damage(-damage)

			else if(response == "Dismantle")
				to_chat(user, "<span class='notice'>You begin slicing through the outer plating.</span>")
				if(WT.use_tool(src, user, 100, volume = 100))
					if(!istype(src, /turf/simulated/wall) || !T)
						return

					if(user.loc == T && user.get_active_hand() == WT)
						to_chat(user, "<span class='notice'>You remove the outer plating.</span>")
						dismantle_wall()
			return
		else
			to_chat(user, "<span class='notice'>You need more welding fuel to complete this task.</span>")
			return

	else if(istype(W, /obj/item/weapon/pickaxe/plasmacutter))
		if(user.is_busy(src))
			return
		to_chat(user, "<span class='notice'>You begin slicing through the outer plating.</span>")
		if(W.use_tool(src, user, 60, volume = 100))
			if(mineral == "diamond")//Oh look, it's tougher
				sleep(60)
			if(!istype(src, /turf/simulated/wall) || !user || !W || !T)
				return

			if(user.loc == T && user.get_active_hand() == W)
				to_chat(user, "<span class='notice'>You remove the outer plating.</span>")
				dismantle_wall()
				visible_message("<span class='warning'>The wall was sliced apart by [user]!</span>", blind_message = "<span class='warning'>You hear metal being sliced apart.</span>", viewing_distance = 5)
		return

	//DRILLING
	else if (istype(W, /obj/item/weapon/pickaxe/drill/diamond_drill))
		if(user.is_busy(src))
			return
		to_chat(user, "<span class='notice'>You begin to drill though the wall.</span>")
		if(W.use_tool(src, user, 60, volume = 50))
			if(mineral == "diamond")
				sleep(60)
			if(!istype(src, /turf/simulated/wall) || !user || !W || !T)
				return

			if(user.loc == T && user.get_active_hand() == W)
				to_chat(user, "<span class='notice'>Your drill tears though the last of the reinforced plating.</span>")
				dismantle_wall()
				visible_message("<span class='warning'>The wall was drilled through by [user]!</span>", blind_message = "<span class='warning'>You hear the grinding of metal.</span>", viewing_distance = 5)
		return

	else if(istype(W, /obj/item/weapon/melee/energy/blade))
		if(user.is_busy()) return
		var/obj/item/weapon/melee/energy/blade/EB = W

		EB.spark_system.start()
		to_chat(user, "<span class='notice'>You stab \the [EB] into the wall and begin to slice it apart.</span>")
		playsound(src, pick(SOUNDIN_SPARKS), VOL_EFFECTS_MASTER)
		if(W.use_tool(src, user, 70))
			if(mineral == "diamond")
				sleep(70)
			if(!istype(src, /turf/simulated/wall) || !user || !EB || !T)
				return

			if(user.loc == T && user.get_active_hand() == W)
				EB.spark_system.start()
				playsound(src, pick(SOUNDIN_SPARKS), VOL_EFFECTS_MASTER)
				playsound(src, 'sound/weapons/blade1.ogg', VOL_EFFECTS_MASTER)
				dismantle_wall(1)
				visible_message("<span class='warning'>The wall was sliced apart by [user]!</span>", blind_message = "<span class='warning'>You hear metal being sliced apart and sparks flying.</span>", viewing_distance = 5)
		return
	else if(istype(W,/obj/item/weapon/changeling_hammer) && !rotting)
		var/obj/item/weapon/changeling_hammer/C = W
		visible_message("<span class='danger'>[user] has punched the[src]!</span>")
		user.do_attack_animation(src)
		if(C.use_charge(user))
			playsound(user, pick('sound/effects/explosion1.ogg', 'sound/effects/explosion2.ogg'), VOL_EFFECTS_MASTER)
			take_damage(pick(10, 20, 30))
		return

	else if(istype(W,/obj/item/apc_frame))
		var/obj/item/apc_frame/AH = W
		AH.try_build(src)
		return

	else if(istype(W,/obj/item/newscaster_frame))
		var/obj/item/newscaster_frame/AH = W
		AH.try_build(src)
		return

	else if(istype(W,/obj/item/alarm_frame))
		var/obj/item/alarm_frame/AH = W
		AH.try_build(src)
		return

	else if(istype(W,/obj/item/firealarm_frame))
		var/obj/item/firealarm_frame/AH = W
		AH.try_build(src)
		return

	else if(istype(W,/obj/item/light_fixture_frame))
		var/obj/item/light_fixture_frame/AH = W
		AH.try_build(src)
		return

	else if(istype(W,/obj/item/light_fixture_frame/small))
		var/obj/item/light_fixture_frame/small/AH = W
		AH.try_build(src)
		return

	else if(istype(W,/obj/item/door_control_frame))
		var/obj/item/door_control_frame/AH = W
		AH.try_build(src)
		return

	//Poster stuff
	else if(istype(W,/obj/item/weapon/poster))
		place_poster(W,user)
		return

	else
		return attack_hand(user)

/turf/simulated/wall/singularity_pull(S, current_size)
	if(current_size >= STAGE_FIVE)
		if(prob(50))
			dismantle_wall()
		return
	if(current_size == STAGE_FOUR)
		if(prob(30))
			dismantle_wall()
