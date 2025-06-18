/turf/simulated/wall
	name = "wall"
	desc = "Огромный кусок металла для разделения комнат."
	icon = 'icons/turf/walls/has_false_walls/wall.dmi'
	icon_state = "box"
	plane = GAME_PLANE

	var/mineral = "metal"
	var/rotting = 0

	var/damage = 0
	var/damage_cap = 100 //Wall will break down to girders if damage reaches this point

	explosive_resistance = 3

	var/damage_overlay
	var/static/damage_overlays[8]

	var/max_temperature = 2200 //K, walls will take damage if they're next to a fire hotter than this

	var/seconds_to_melt = 10 //It takes 10 seconds for thermite to melt this wall through

	var/list/dent_decals

	opacity = TRUE
	density = TRUE
	blocks_air = AIR_BLOCKED

	thermal_conductivity = WALL_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = 312500 //a little over 5 cm thick , 312500 for 1 m by 2.5 m by 0.25 m plasteel wall

	var/sheet_type = /obj/item/stack/sheet/metal

	canSmoothWith = CAN_SMOOTH_WITH_WALLS
	smooth_adapters = SMOOTH_ADAPTERS_WALLS_FOR_WALLS
	smooth = SMOOTH_TRUE

// todo:
// probably we should make /obj/structure/falsewall 
// and /turf/simulated/wall as meta-types not used in the game, and move 
// real walls and falsewalls to subtypes
/turf/simulated/wall/yellow
	icon = 'icons/turf/walls/has_false_walls/wall_yellow.dmi'

/turf/simulated/wall/red
	icon = 'icons/turf/walls/has_false_walls/wall_red.dmi'

/turf/simulated/wall/purple
	icon = 'icons/turf/walls/has_false_walls/wall_purple.dmi'

/turf/simulated/wall/green
	icon = 'icons/turf/walls/has_false_walls/wall_green.dmi'

/turf/simulated/wall/beige
	icon = 'icons/turf/walls/has_false_walls/wall_beige.dmi'

/turf/simulated/wall/proc/change_color(color)
	var/new_type
	switch(color)
		if("blue")
			new_type = /turf/simulated/wall
		if("yellow")
			new_type = /turf/simulated/wall/yellow
		if("red")
			new_type = /turf/simulated/wall/red
		if("purple")
			new_type = /turf/simulated/wall/purple
		if("green")
			new_type = /turf/simulated/wall/green
		if("beige")
			new_type = /turf/simulated/wall/beige
		else
			stack_trace("Color [color] does not exist")
	if(new_type && new_type != type)
		ChangeTurf(new_type)

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
		to_chat(user, "<span class='info'>Выглядит неповрежденной.</span>")
	else
		var/dam = damage / damage_cap
		if(dam <= 0.3)
			to_chat(user, "<span class='warning'>Выглядит слегка поврежденной.</span>")
		else if(dam <= 0.6)
			to_chat(user, "<span class='warning'>Выглядит довольно поврежденной.</span>")
		else
			to_chat(user, "<span class='danger'>Выглядит сильно поврежденной.</span>")

	if(rotting)
		to_chat(user, "<span class='warning'>На стене растет грибок.</span>")

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

/turf/simulated/wall/take_damage(dam, devastated) // doesnt use atom integrity system
	if(dam)
		damage = max(0, damage + dam)
		update_damage(devastated)

/turf/simulated/wall/proc/update_damage(devastated)
	var/cap = damage_cap
	if(rotting)
		cap = cap / 10

	if(damage >= cap)
		dismantle_wall(devastated)
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
		return (new /obj/structure/girder/cult(src))

	new sheet_type(src, 2)
	return (new /obj/structure/girder(src))

/turf/simulated/wall/proc/devastate_wall()
	if(istype(src, /turf/simulated/wall/cult))
		new /obj/effect/decal/cleanable/blood(src)
		new /obj/effect/decal/remains/human(src)

	new sheet_type(src, 2)
	new /obj/item/stack/sheet/metal(src)

/turf/simulated/wall/ex_act(severity)
	for(var/thing in contents)
		var/atom/movable/movable_thing = thing
		if(QDELETED(movable_thing))
			continue
		switch(severity)
			if(EXPLODE_DEVASTATE)
				SSexplosions.high_mov_atom += movable_thing
			if(EXPLODE_HEAVY)
				SSexplosions.med_mov_atom += movable_thing
			if(EXPLODE_LIGHT)
				SSexplosions.low_mov_atom += movable_thing

	switch(severity)
		if(EXPLODE_DEVASTATE)
			ChangeTurf(basetype)
		if(EXPLODE_HEAVY)
			if(prob(75))
				take_damage(rand(150, 250))
			else
				dismantle_wall(1,1)
		if(EXPLODE_LIGHT)
			take_damage(rand(0, 55))

/turf/simulated/wall/blob_act()
	add_dent(WALL_DENT_HIT)
	take_damage(rand(75, 125))

// Wall-rot effect, a nasty fungus that destroys walls.
/turf/simulated/wall/proc/rot()
	if(!rotting)
		rotting = 1

		var/number_rots = rand(2,3)
		for(var/i=0, i<number_rots, i++)
			new /obj/effect/overlay/wall_rot(src)

/turf/simulated/wall/proc/thermitemelt(mob/user, seconds_to_melt)
	if(mineral == "diamond")
		return
	var/obj/effect/overlay/O = new/obj/effect/overlay(src)
	O.name = "Thermite"
	O.desc = "Looks hot."
	O.icon = 'icons/effects/fire.dmi'
	O.icon_state = "2"
	O.anchored = TRUE
	O.density = TRUE
	O.layer = 5

	ChangeTurf(/turf/simulated/floor/plating)

	var/turf/simulated/floor/F = src
	F.burnt = TRUE
	F.add_scorched_overlay("thermite")

	to_chat(user, "<span class='warning'>Термит начинает плавить стену.</span>")

	spawn(seconds_to_melt * 10)
		if(O)	qdel(O)
//	F.sd_LumReset()		//TODO: ~Carn
	return


//Interactions

/turf/simulated/wall/attack_paw(mob/user)
	return attack_hand(user) //#Z2

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

/turf/simulated/wall/attack_hulk(mob/living/simple_animal/hulk/M)
	if(istype(M))
		playsound(M, 'sound/weapons/tablehit1.ogg', VOL_EFFECTS_MASTER)
		M.health -= rand(4, 10)
		attack_animal(M)
		return TRUE

/turf/simulated/wall/attack_animal(mob/living/simple_animal/M)
	..()
	if(M.environment_smash >= 2)
		playsound(M, 'sound/effects/hulk_hit_wall.ogg', VOL_EFFECTS_MASTER)
		if(istype(src, /turf/simulated/wall/r_wall))
			if(M.environment_smash >= 3)
				add_dent(WALL_DENT_HIT)
				take_damage(rand(25, 75))
				to_chat(M, "<span class='info'>Вы крушите стену.</span>")
			else
				to_chat(M, "<span class='info'>Стена слишком прочная, чтобы вы могли ее уничтожить.</span>")
		else
			if (prob(40) || rotting)
				to_chat(M, "<span class='notice'>Вы пробиваете стену насквозь.</span>")
				dismantle_wall(TRUE)
			else
				add_dent(WALL_DENT_HIT)
				take_damage(rand(25, 75), TRUE)
				to_chat(M, "<span class='info'>Вы крушите стену.</span>")

/turf/simulated/wall/attack_hand(mob/user)
	user.SetNextMove(CLICK_CD_MELEE)
	if(HULK in user.mutations && user.a_intent == INTENT_HARM) //#Z2 No more chances, just randomized damage and hurt intent
		playsound(user, 'sound/effects/grillehit.ogg', VOL_EFFECTS_MASTER)
		to_chat(user, text("<span class='notice'>Вы бьете стену.</span>"))
		take_damage(rand(15, 50))
		if(prob(25))
			user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
		return //##Z2

	if(rotting)
		to_chat(user, "<span class='notice'>Стена крошится от вашего касания.</span>")
		dismantle_wall()
		return

	to_chat(user, "<span class='notice'>Вы толкаете стену, но ничего не происходит!</span>")
	playsound(src, 'sound/weapons/Genhit.ogg', VOL_EFFECTS_MASTER, 25)
	add_fingerprint(user)
	return

/turf/simulated/wall/attackby(obj/item/weapon/W, mob/user)
	//get the user's location
	if(!isturf(user.loc))
		return	//can't do this stuff whilst inside objects and such
	user.SetNextMove(CLICK_CD_MELEE)

	if(rotting)
		if(iswelding(W))
			var/obj/item/weapon/weldingtool/WT = W
			if(WT.use(0,user))
				to_chat(user, "<span class='notice'>Вы сжигаете грибок сваркой.</span>")
				playsound(src, 'sound/items/Welder.ogg', VOL_EFFECTS_MASTER, 10)
				for(var/obj/effect/E in src) if(E.name == "Wallrot")
					qdel(E)
				rotting = 0
				return
		else if(!W.is_sharp() && W.force >= 10 || W.force >= 20)
			to_chat(user, "<span class='notice'>Стена рассыпается от удара [W.name].</span>")
			dismantle_wall(1)
			return

	//THERMITE related stuff. Calls thermitemelt() which handles melting simulated walls and the relevant effects
	if(thermite)
		if(iswelding(W))
			var/obj/item/weapon/weldingtool/WT = W
			if(WT.use(0,user))
				thermitemelt(user, seconds_to_melt)
				return

		else if(istype(W, /obj/item/weapon/melee/energy/blade))
			var/obj/item/weapon/melee/energy/blade/EB = W

			EB.spark_system.start()
			to_chat(user, "<span class='notice'>Вы бьете стену энергетическим мечом; термит вспыхивает!</span>")
			playsound(src, pick(SOUNDIN_SPARKS), VOL_EFFECTS_MASTER)
			playsound(src, 'sound/weapons/blade1.ogg', VOL_EFFECTS_MASTER)

			thermitemelt(user, seconds_to_melt)
			return

	var/turf/T = user.loc	//get user's location for delay checks

	//DECONSTRUCTION
	if(iswelding(W))
		var/obj/item/weapon/weldingtool/WT = W
		if(!WT.use(0, user))
			to_chat(user, "<span class='notice'>Нужно больше топлива.</span>")
			return
		if(user.a_intent == INTENT_HELP)
			if(!damage)
				return
			to_chat(user, "<span class='warning'>Вы ремонтируете стену.</span>")
			if(WT.use_tool(src, user, max(5, damage / 5), volume = 100, required_skills_override = list(/datum/skill/engineering = SKILL_LEVEL_TRAINED)))
				to_chat(user, "<span class='notice'>Вы отремонтировали стену.</span>")
				take_damage(-damage)

		else
			to_chat(user, "<span class='notice'>Вы разрезаете обшивку.</span>")
			if(WT.use_tool(src, user, SKILL_TASK_DIFFICULT, 3, 100, required_skills_override = list(/datum/skill/engineering = SKILL_LEVEL_TRAINED)))
				if(!iswallturf(src))
					return
				to_chat(user, "<span class='notice'>Вы сняли обшивку.</span>")
				dismantle_wall()

	if(istype(W, /obj/item/weapon/airlock_painter))
		var/obj/item/weapon/airlock_painter/A = W
		if(!A.can_use(user, 1))
			return
		var/new_color = tgui_input_list(user, "Выберите цвет", "Цвет", WALLS_COLORS)
		if(!new_color)
			return
		if(!A.use_tool(src, user, 10, 1))
			return
		change_color(new_color)
		return

	//DRILLING
	else if (istype(W, /obj/item/weapon/pickaxe/drill/diamond_drill))
		if(user.is_busy(src))
			return
		to_chat(user, "<span class='notice'>Вы бурите сквозь стену.</span>")
		if(W.use_tool(src, user, SKILL_TASK_TOUGH, volume = 50))
			if(mineral == "diamond")
				sleep(60)
			if(!iswallturf(src) || !user || !W || !T)
				return

			if(user.loc == T && user.get_active_hand() == W)
				to_chat(user, "<span class='notice'>Вы пробурили последний лист обшивки.</span>")
				dismantle_wall()
				visible_message("<span class='warning'>[user] пробурил стену!</span>", blind_message = "<span class='warning'>Вы слышите скрежет металла.</span>", viewing_distance = 5)
		return

	else if(istype(W, /obj/item/weapon/melee/energy/blade))
		if(user.is_busy()) return
		var/obj/item/weapon/melee/energy/blade/EB = W

		EB.spark_system.start()
		to_chat(user, "<span class='notice'>Вы вонзаете энергетический меч в стену, начиная разрезать преграду.</span>")
		playsound(src, pick(SOUNDIN_SPARKS), VOL_EFFECTS_MASTER)
		if(W.use_tool(src, user, 70))
			if(mineral == "diamond")
				sleep(70)
			if(!iswallturf(src) || !user || !EB || !T)
				return

			if(user.loc == T && user.get_active_hand() == W)
				EB.spark_system.start()
				playsound(src, pick(SOUNDIN_SPARKS), VOL_EFFECTS_MASTER)
				playsound(src, 'sound/weapons/blade1.ogg', VOL_EFFECTS_MASTER)
				dismantle_wall(1)
				visible_message("<span class='warning'>[user] прорезает стену!</span>", blind_message = "<span class='warning'>Вы слышите треск искр и скрежет металла.</span>", viewing_distance = 5)
		return
	//fulldestruct to walls when
	else if(istype(W,/obj/item/weapon/melee/changeling_hammer) && !rotting)
		var/obj/item/weapon/melee/changeling_hammer/hammer = W
		//slowdown, user. No need destruct all walls without debuff
		if(iscarbon(user))
			var/mob/living/carbon/C = user
			C.shock_stage += 5
		user.visible_message("<span class='danger'><B>[user]</B> бьет стену!</span>")
		user.do_attack_animation(src)
		playsound(user, pick(hammer.hitsound), VOL_EFFECTS_MASTER)
		take_damage(hammer.get_object_damage())
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

	// why is all of this here help me
	else if(istype(W, /obj/item/noticeboard_frame))
		var/obj/item/noticeboard_frame/NF = W
		NF.try_build(user, src)

	else if(istype(W,/obj/item/painting_frame))
		var/obj/item/painting_frame/AH = W
		AH.try_build(src)
		return

	//Poster stuff
	else if(istype(W,/obj/item/weapon/poster))
		place_poster(W,user)
		return

	else if((istype(W, /obj/item/weapon/paper) || istype(W, /obj/item/weapon/paper_bundle) || istype(W, /obj/item/weapon/photo)) && (get_dir(user,src) in global.cardinal))
		user.drop_from_inventory(W)
		W.pixel_x = X_OFFSET(24, get_dir(user, src))
		W.pixel_y = Y_OFFSET(24, get_dir(user, src))
		RegisterSignal(W, COMSIG_MOVABLE_MOVED, CALLBACK(src, PROC_REF(tied_object_reset_pixel_offset), W))
		RegisterSignal(W, COMSIG_PARENT_QDELETING, CALLBACK(src, PROC_REF(tied_object_reset_pixel_offset), W))
		return
	else if((istype(W, /obj/item/wallclock) || istype(W, /obj/item/portrait)) && (get_dir(user,src) in global.cardinal))
		user.drop_from_inventory(W)
		W.pixel_x = X_OFFSET(32, get_dir(user, src))
		W.pixel_y = Y_OFFSET(32, get_dir(user, src))
		W.anchored = TRUE
		RegisterSignal(W, COMSIG_MOVABLE_MOVED, CALLBACK(src, PROC_REF(tied_object_reset_pixel_offset), W, TRUE))
		RegisterSignal(W, COMSIG_PARENT_QDELETING, CALLBACK(src, PROC_REF(tied_object_reset_pixel_offset), W, TRUE))
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

/turf/simulated/wall/bullet_act(obj/item/projectile/Proj, def_zone)
	. = ..()
	if(!Proj.nodamage && (Proj.damage_type == BRUTE || Proj.damage_type == BURN) && prob(75) && iswallturf(src))
		add_dent(WALL_DENT_SHOT, Proj.p_x, Proj.p_y)

/turf/simulated/wall/proc/add_dent(denttype, x, y)
	if(length(dent_decals) >= MAX_DENT_DECALS)
		return

	var/mutable_appearance/decal = mutable_appearance('icons/effects/effects.dmi', "", BULLET_HOLE_LAYER, plane)
	if(isnull(x) || isnull(y))
		x = rand(-12, 12)
		y = rand(-12, 12)
	else
		x = clamp(x - 16, -16, 16) // because sprites are centered
		y = clamp(y - 16, -16, 16)

	switch(denttype)
		if(WALL_DENT_SHOT)
			decal.icon_state = "bullet_hole[rand(1,2)]"
			decal.pixel_x = clamp(x, -15, 15) // because sprite size
			decal.pixel_y = clamp(y, -15, 15)
		if(WALL_DENT_HIT)
			decal.icon_state = "impact[rand(1, 3)]"
			decal.pixel_x = clamp(x, -12, 12) // because sprite size
			decal.pixel_y = clamp(y, -12, 12)

	LAZYADD(dent_decals, decal)
	add_overlay(decal)

/turf/simulated/wall/proc/tied_object_reset_pixel_offset(obj/O, unanchor = FALSE)
	O.pixel_y = rand(-8, 8)
	O.pixel_x = rand(-9, 9)
	UnregisterSignal(O, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(O, COMSIG_PARENT_QDELETING)

	if(unanchor)
		O.anchored = FALSE
