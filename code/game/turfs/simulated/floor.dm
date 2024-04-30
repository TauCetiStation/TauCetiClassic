#define LIGHTFLOOR_ON_BIT 4

#define LIGHTFLOOR_STATE_OK 0
#define LIGHTFLOOR_STATE_FLICKER 1
#define LIGHTFLOOR_STATE_BREAKING 2
#define LIGHTFLOOR_STATE_BROKEN 3
#define LIGHTFLOOR_STATE_BITS 3

//This is so damaged or burnt tiles or platings don't get remembered as the default tile
var/global/list/icons_to_ignore_at_floor_init = list("damaged1","damaged2","damaged3","damaged4",
				"damaged5","panelscorched","floorscorched1","floorscorched2","platingdmg1","platingdmg2",
				"platingdmg3","plating","light_on","light_on_flicker1","light_on_flicker2",
				"light_on_clicker3","light_on_clicker4","light_on_clicker5","light_broken",
				"light_on_broken","light_off","wall_thermite","grass1","grass2","grass3","grass4",
				"asteroid","asteroid_dug",
				"asteroid0","asteroid1","asteroid2","asteroid3","asteroid4",
				"asteroid5","asteroid6","asteroid7","asteroid8","asteroid9","asteroid10","asteroid11","asteroid12",
				"oldburning","light-on-r","light-on-y","light-on-g","light-on-b", "wood", "wood-broken", "carpet",
				"carpetcorner", "carpetside", "carpet", "ironsand1", "ironsand2", "ironsand3", "ironsand4", "ironsand5",
				"ironsand6", "ironsand7", "ironsand8", "ironsand9", "ironsand10", "ironsand11",
				"ironsand12", "ironsand13", "ironsand14", "ironsand15")

/turf/simulated/floor

	//Note to coders, the 'intact' var can no longer be used to determine if the floor is a plating or not.
	//Use the is_plating(), is_plasteel_floor() and is_light_floor() procs instead. --Errorage
	name = "floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "floor"

	var/icon_regular_floor = "floor" //used to remember what icon the tile should have by default
	var/icon_plating = "plating"
	thermal_conductivity = 0.040
	var/mineral = "metal"
	var/floor_type = /obj/item/stack/tile/plasteel
	var/lightfloor_state // for light floors, this is the state of the tile. 0-7, 0x4 is on-bit - use the helper procs below
	footstep = FOOTSTEP_FLOOR
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	can_deconstruct = TRUE

	var/datum/holy_turf/holy

	var/broken = 0
	var/mutable_appearance/damage_overlay
	var/burnt = 0
	var/mutable_appearance/scorch_overlay

/turf/simulated/floor/proc/get_lightfloor_state()
	return lightfloor_state & LIGHTFLOOR_STATE_BITS

/turf/simulated/floor/proc/get_lightfloor_on()
	return lightfloor_state & LIGHTFLOOR_ON_BIT

/turf/simulated/floor/proc/set_lightfloor_state(n)
	lightfloor_state = get_lightfloor_on() | (n & LIGHTFLOOR_STATE_BITS)

/turf/simulated/floor/proc/set_lightfloor_on(n)
	if(n)
		lightfloor_state |= LIGHTFLOOR_ON_BIT
	else
		lightfloor_state &= ~LIGHTFLOOR_ON_BIT

/turf/simulated/floor/proc/toggle_lightfloor_on()
	lightfloor_state ^= LIGHTFLOOR_ON_BIT

/turf/simulated/floor/atom_init()
	. = ..()
	if(icon_state in icons_to_ignore_at_floor_init) //so damaged/burned tiles or plating icons aren't saved as the default
		icon_regular_floor = "floor"
	else
		icon_regular_floor = icon_state

/turf/simulated/floor/ChangeTurf()
	var/old_holy = holy
	. = ..()
	if(istype(src)) // turf is changed, is it still a floor?
		holy = old_holy
	else // nope, it's not a floor
		qdel(old_holy)

/turf/simulated/floor/Destroy()
	if(floor_type)
		floor_type = null
	QDEL_NULL(holy)
	return ..()

//turf/simulated/floor/CanPass(atom/movable/mover, turf/target, height=0)
//	if ((istype(mover, /obj/machinery/vehicle) && !(src.burnt)))
//		if (!( locate(/obj/machinery/mass_driver, src) ))
//			return 0
//	return ..()

/turf/simulated/floor/ex_act(severity)
	..()
	//set src in oview(1)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			ChangeTurf(basetype)
		if(EXPLODE_HEAVY)
			switch(pick(prob(10);1, prob(10);2, 3))
				if(1)
					ReplaceWithLattice()
					if(prob(33))
						new /obj/item/stack/sheet/metal(src)
				if(2)
					ChangeTurf(basetype)
				if(3)
					if(prob(80))
						break_tile_to_plating()
					else
						break_tile()
					if(prob(33))
						new /obj/item/stack/sheet/metal(src)
		if(EXPLODE_LIGHT)
			if(prob(50))
				break_tile()

/turf/simulated/floor/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(!burnt && prob(5))
		burn_tile()
	else if(prob(1) && !is_plating())
		make_plating()
		burn_tile()
	return

/turf/simulated/floor/adjacent_fire_act(turf/simulated/floor/adj_turf, datum/gas_mixture/adj_air, adj_temp, adj_volume)
	var/dir_to = get_dir(src, adj_turf)

	for(var/obj/structure/window/thin/W in src)
		if(W.dir == dir_to) //Same direction
			W.fire_act(adj_air, adj_temp, adj_volume)

	for(var/obj/structure/window/fulltile/W in src)
		W.fire_act(adj_air, adj_temp, adj_volume)

/turf/simulated/floor/blob_act()
	return

/turf/simulated/floor/singularity_pull(S, current_size)
	if(current_size == STAGE_THREE)
		if(prob(30))
			if(floor_type)
				new floor_type(src)
				make_plating()
	else if(current_size == STAGE_FOUR)
		if(prob(50))
			if(floor_type)
				new floor_type(src)
				make_plating()
	else if(current_size >= STAGE_FIVE)
		if(floor_type)
			if(prob(70))
				new floor_type(src)
				make_plating()
		else if(prob(50))
			ReplaceWithLattice()

// todo: sort this between floor/type/update_icon, wtf
/turf/simulated/floor/update_icon()
	if(is_plasteel_floor())
		icon_state = icon_regular_floor
	else if(is_plating())
		icon_state = icon_plating //Because asteroids are 'platings' too.
	else if(is_light_floor())
		if(get_lightfloor_on())
			switch(get_lightfloor_state())
				if(LIGHTFLOOR_STATE_OK)
					icon_state = "light_on"
					set_light(5)
				if(LIGHTFLOOR_STATE_FLICKER)
					var/num = pick("1","2","3","4")
					icon_state = "light_on_flicker[num]"
					set_light(5)
				if(LIGHTFLOOR_STATE_BREAKING)
					icon_state = "light_on_broken"
					set_light(5)
				if(LIGHTFLOOR_STATE_BROKEN)
					icon_state = "light_off"
					set_light(0)
		else
			set_light(0)
			icon_state = "light_off"
	else if(is_grass_floor())
		if(!(icon_state in list("grass1","grass2","grass3","grass4")))
			icon_state = "grass[pick("1","2","3","4")]"
	else if(is_wood_floor())
		icon_state = "wood"

	if(!broken && damage_overlay)
		remove_damaged_overlay()
	if(!burnt && scorch_overlay)
		remove_scorched_overlay()

	..()

/turf/simulated/floor/attack_paw(mob/user)
	return attack_hand(user)

/turf/simulated/floor/attack_hand(mob/user)
	if (is_light_floor())
		toggle_lightfloor_on()
		update_icon()
	..()

/turf/simulated/floor/proc/gets_drilled()
	return

/turf/simulated/floor/proc/break_tile_to_plating()
	if(!is_plating())
		make_plating()
	break_tile()

/turf/simulated/floor/is_plasteel_floor()
	if(ispath(floor_type, /obj/item/stack/tile/plasteel))
		return 1
	else
		return 0

/turf/simulated/floor/is_light_floor()
	if(ispath(floor_type, /obj/item/stack/tile/light))
		return 1
	else
		return 0

/turf/simulated/floor/is_grass_floor()
	if(ispath(floor_type, /obj/item/stack/tile/grass))
		return 1
	else
		return 0

/turf/simulated/floor/is_wood_floor()
	if(ispath(floor_type, /obj/item/stack/tile/wood))
		return 1
	else
		return 0

/turf/simulated/floor/is_carpet_floor()
	if(ispath(floor_type, /obj/item/stack/tile/carpet))
		return 1
	else
		return 0

/turf/simulated/floor/is_catwalk()
	return 0

/turf/simulated/floor/is_plating()
	if(!floor_type && !is_catwalk())
		return 1
	return 0

/turf/simulated/floor/proc/break_tile()
	if(broken)
		return

	var/damage_state

	// some turfs change icon_state, some turfs use overlay
	if(is_plasteel_floor())
		damage_state = "damaged_[pick(1,2,3,4)]"
		broken = TRUE
	else if(is_light_floor())
		icon_state = "light_broken"
		broken = TRUE
	else if(is_plating())
		damage_state = "damaged_[pick(1,2,3,4)]"
		broken = TRUE
	else if(is_wood_floor())
		damage_state = "wood_damaged_[pick(1,2,3,4,5,6,7)]"
		broken = TRUE
	else if(is_carpet_floor())
		damage_state = "carpet_damaged"
	else if(istype(src, /turf/simulated/floor/glass))
		damage_state = "glass_damaged_[pick("1","2","3")]"
		broken = TRUE
	else if(is_grass_floor())
		src.icon_state = "ironsand[pick("1","2","3")]"
		broken = TRUE

	if(damage_state)
		add_damaged_overlay(damage_state)

/turf/simulated/floor/proc/add_damaged_overlay(state)
	if(damage_overlay)
		return

	damage_overlay = mutable_appearance('icons/turf/floors/damaged_overlays.dmi', state)
	add_overlay(damage_overlay)

/turf/simulated/floor/proc/remove_damaged_overlay()
	if(!damage_overlay)
		return

	cut_overlay(damage_overlay)
	damage_overlay = null

/turf/simulated/floor/proc/burn_tile() //
	if(burnt || broken) // broken overlay has priority, should not overlap
		return

	var/scorch_state

	if(is_plasteel_floor())
		scorch_state = "scorched_[pick(1,2)]"
		burnt = TRUE
	else if(is_plating())
		scorch_state = "scorched_[pick(1,2)]"
		burnt = TRUE
	else if(is_wood_floor())
		scorch_state = "wood_damaged_[pick(1,2,3,4,5,6,7)]"
		burnt = TRUE
	else if(is_carpet_floor())
		scorch_state = "carpet_damaged"
		burnt = TRUE
	else if(is_grass_floor())
		src.icon_state = "ironsand[pick("1","2","3")]"
		burnt = TRUE

	if(scorch_state)
		add_scorched_overlay(scorch_state)

/turf/simulated/floor/proc/add_scorched_overlay(state)
	if(scorch_overlay)
		return

	scorch_overlay = mutable_appearance('icons/turf/floors/damaged_overlays.dmi', state)
	add_overlay(scorch_overlay)

/turf/simulated/floor/proc/remove_scorched_overlay()
	if(!scorch_overlay)
		return

	cut_overlay(scorch_overlay)
	scorch_overlay = null

//This proc will set floor_type to null and the update_icon() proc will then change the icon_state of the turf
//This proc auto corrects the grass tiles' siding (but we don't have them).
/turf/simulated/floor/proc/make_plating()
	if(istype(src,/turf/simulated/floor/engine))
		return
	if(is_catwalk())
		return

	if(is_grass_floor())
		for(var/direction in cardinal)
			if(istype(get_step(src,direction),/turf/simulated/floor))
				var/turf/simulated/floor/FF = get_step(src,direction)
				FF.update_icon() //so siding get updated properly

	if(!floor_type)
		return
	name = "plating"
	icon_plating = "plating"
	set_light(0)
	floor_type = null
	underfloor_accessibility = UNDERFLOOR_INTERACTABLE
	broken = 0
	burnt = 0

	clean_turf_decals()
	update_icon()
	levelupdate()

//This proc will make the turf a plasteel floor tile. The expected argument is the tile to make the turf with
//If none is given it will make a new object. dropping or unequipping must be handled before or after calling
//this proc.
/turf/simulated/floor/proc/make_plasteel_floor(obj/item/stack/tile/plasteel/T = null)
	broken = 0
	burnt = 0
	underfloor_accessibility = UNDERFLOOR_HIDDEN
	set_light(0)
	if(T)
		if(istype(T,/obj/item/stack/tile/plasteel))
			floor_type = T.type
			if (icon_regular_floor)
				icon_state = icon_regular_floor
			else
				icon_state = "floor"
				icon_regular_floor = icon_state
			update_icon()
			levelupdate()
			return
	//if you gave a valid parameter, it won't get thisf ar.
	floor_type = /obj/item/stack/tile/plasteel
	icon_state = "floor"
	icon_regular_floor = icon_state

	update_icon()
	levelupdate()

//This proc will make the turf a light floor tile. The expected argument is the tile to make the turf with
//If none is given it will make a new object. dropping or unequipping must be handled before or after calling
//this proc.
/turf/simulated/floor/proc/make_light_floor(obj/item/stack/tile/light/T = null)
	broken = 0
	burnt = 0
	underfloor_accessibility = UNDERFLOOR_HIDDEN
	if(T)
		if(istype(T,/obj/item/stack/tile/light))
			floor_type = T.type
			update_icon()
			levelupdate()
			return
	//if you gave a valid parameter, it won't get thisf ar.
	floor_type = /obj/item/stack/tile/light

	update_icon()
	levelupdate()

//This proc will make a turf into a grass patch. Fun eh? Insert the grass tile to be used as the argument
//If no argument is given a new one will be made.
/turf/simulated/floor/proc/make_grass_floor(obj/item/stack/tile/grass/T = null)
	broken = 0
	burnt = 0
	underfloor_accessibility = UNDERFLOOR_HIDDEN
	if(T)
		if(istype(T,/obj/item/stack/tile/grass))
			floor_type = T.type
			update_icon()
			levelupdate()
			return
	//if you gave a valid parameter, it won't get thisf ar.
	floor_type = /obj/item/stack/tile/grass

	update_icon()
	levelupdate()

//This proc will place a turf into tile. Hate this
/turf/simulated/floor/proc/place_floor(obj/item/C)
	var/obj/item/stack/tile/T = C
	if(!T.use(1))
		return
	playsound(src, 'sound/weapons/Genhit.ogg', VOL_EFFECTS_MASTER)
	if(T.use_change_turf)
		ChangeTurf(T.turf_type)
		return
	floor_type = T.type
	icon = initial(T.turf_type.icon)
	name = initial(T.turf_type.name)
	underfloor_accessibility = UNDERFLOOR_HIDDEN
	if(istype(T,/obj/item/stack/tile/light))
		var/obj/item/stack/tile/light/L = T
		set_lightfloor_state(L.state)
		set_lightfloor_on(L.on)
	if(istype(T,/obj/item/stack/tile/grass))
		for(var/direction in cardinal)
			if(istype(get_step(src,direction),/turf/simulated/floor))
				var/turf/simulated/floor/FF = get_step(src,direction)
				FF.update_icon() //so siding gets updated properly
	update_icon()
	levelupdate()

//Proc for make turf into plating 
/turf/simulated/floor/proc/remove_floor(obj/item/C, mob/user)
	if(broken || burnt)
		to_chat(user, "<span class='warning'>Вы сняли поврежденное покрытие.</span>")
	else
		if(is_wood_floor())
			to_chat(user, "<span class='warning'>Вы с трудом отодрали доски, сломав их.</span>")
		else
			var/obj/item/I = new floor_type(src)
			if(is_light_floor())
				var/obj/item/stack/tile/light/L = I
				L.on = get_lightfloor_on()
				L.state = get_lightfloor_state()
			to_chat(user, "<span class='warning'>Вы демонтировали плитку.</span>")
	make_plating()

//This proc will make a turf into a wood floor. Fun eh? Insert the wood tile to be used as the argument
//If no argument is given a new one will be made.
/turf/simulated/floor/proc/make_wood_floor(obj/item/stack/tile/wood/T = null)
	broken = 0
	burnt = 0
	underfloor_accessibility = UNDERFLOOR_HIDDEN
	if(T)
		if(istype(T,/obj/item/stack/tile/wood))
			floor_type = T.type
			update_icon()
			levelupdate()
			return
	//if you gave a valid parameter, it won't get thisf ar.
	floor_type = /obj/item/stack/tile/wood

	update_icon()
	levelupdate()

/turf/simulated/floor/attackby(obj/item/C, mob/user)
	if(!C || !user)
		return 0
	. = ..()
	if(.)
		return
	user.SetNextMove(CLICK_CD_INTERACT)
	if(istype(C, /obj/item/weapon/sledgehammer))
		var/obj/item/weapon/sledgehammer/S = C
		if(HAS_TRAIT(S, TRAIT_DOUBLE_WIELDED))
			playsound(user, 'sound/items/sledgehammer_hit.ogg', VOL_EFFECTS_MASTER)
			shake_camera(user, 1, 1)
			break_tile()

	if(istype(C,/obj/item/weapon/light/bulb)) //only for light tiles
		if(is_light_floor())
			if(get_lightfloor_state())
				user.remove_from_mob(C)
				qdel(C)
				set_lightfloor_state(0) //fixing it by bashing it with a light bulb, fun eh?
				update_icon()
				to_chat(user, "<span class='notice'>Вы заменили лампочку.</span>")
			else
				to_chat(user, "<span class='notice'>Похоже, лампочка в порядке, менять её не нужно.</span>")

	if(isprying(C) && !is_plating() && !is_catwalk())
		remove_floor(C, user)
		// Can't play sounds from areas. - N3X
		playsound(src, 'sound/items/Crowbar.ogg', VOL_EFFECTS_MASTER)
		return

	if(isscrewing(C))
		if(is_wood_floor())
			if(broken || burnt)
				return
			else
				if(is_wood_floor())
					to_chat(user, "<span class='warning'>Вы открутили доски.</span>")
					new floor_type(src)

			make_plating()
			playsound(src, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER)
		else if(is_catwalk())
			if(broken)
				return
			ReplaceWithLattice()
			playsound(src, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER)
			// todo: move catwalk to standart smooth system
			for(var/direction in cardinal)
				var/turf/T = get_step(src,direction)
				if(T.is_catwalk())
					var/turf/simulated/floor/plating/airless/catwalk/CW=T
					CW.update_icon(0)
		else if(istype(src, /turf/simulated/floor/grid_floor))
			var/turf/simulated/floor/grid_floor/GF = src
			GF.toggle_cower()
			to_chat(user, "<span class='warning'>Вы открутили решетку.</span>")
			playsound(src, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER)
		return

	if(istype(C, /obj/item/stack/rods))
		var/obj/item/stack/rods/R = C
		if (is_plating())
			if (R.get_amount() >= 2)
				if(user.is_busy(src))
					return
				to_chat(user, "<span class='notice'>Вы начинаете укреплять обшивку.</span>")
				if(R.use_tool(src, user, 30, amount = 2, volume = 50) && is_plating())
					ChangeTurf(/turf/simulated/floor/engine)
					playsound(src, 'sound/items/Deconstruct.ogg', VOL_EFFECTS_MASTER)
					return
			else
				to_chat(user, "<span class='warning'>Нужно больше стержней.</span>")
		else if (is_catwalk())
			to_chat(user, "<span class='warning'>Объект уже на 100% состоит из стержней, больше не нужно.</span>")
		else
			to_chat(user, "<span class='warning'>Сначала нужно удалить покрытие.</span>")
		return

	if(istype(C, /obj/item/stack/tile))
		if (is_catwalk())
			to_chat(user, "<span class='warning'>Помост не приспособлен для установки на нем покрытия.</span>")
		if (!is_plating())
			var/obj/item/CB = user.get_inactive_hand()
			if (!isprying(CB))
				return
			remove_floor(CB, user)
			place_floor(C)
		if(is_plating())
			if(!broken && !burnt)
				place_floor(C)
			else
				to_chat(user, "<span class='notice'>Эта секция слишком повреждена, чтобы выдержать покрытие. Используйте сварочный аппарат для ремонта.</span>")

	if(iscoil(C))
		if(is_plating() || is_catwalk())
			var/obj/item/stack/cable_coil/coil = C
			for(var/obj/structure/cable/LC in src)
				if((LC.d1==0)||(LC.d2==0))
					LC.attackby(C,user)
					return
			coil.turf_place(src, user)
		else
			to_chat(user, "<span class='warning'>Сначала нужно удалить покрытие.</span>")

	if(istype(C, /obj/item/weapon/shovel))
		if(is_grass_floor())
			new /obj/item/weapon/ore/glass(src)
			new /obj/item/weapon/ore/glass(src) //Make some sand if you shovel grass
			to_chat(user, "<span class='notice'>Вы вскапываете траву.</span>")
			make_plating()
		else
			to_chat(user, "<span class='warning'>Это нельзя вскопать.</span>")

	if(iswelding(C))
		var/obj/item/weapon/weldingtool/W = C
		if(!is_plating())
			return
		if(!can_deconstruct)
			return
		if(!W.use(0, user))
			to_chat(user, "<span class='notice'>Нужно больше топлива для сварки.</span>")
			return
		if(user.a_intent == INTENT_HELP)
			if(!broken && !burnt)
				return
			to_chat(user, "<span class='warning'>Вы отремонтировали обшивку.</span>")
			playsound(src, 'sound/items/Welder.ogg', VOL_EFFECTS_MASTER)
			burnt = 0
			broken = 0
			update_icon()
		else
			user.visible_message(
				"<span class='warning'><B>[user]</B> начинает разбирать обшивку! По ту сторону открытый космос!</span>",
				"<span class='warning'>Вы начинаете разрезать обшивку! За ней открытый космос!</span>",
				"<span class='warning'>Вы слышите звуки будто разрезают обшивку! По ту сторону должен быть открытый космос!</span>",
				viewing_distance = 5)
			if(W.use_tool(src, user, 100, 3, 100))
				user.visible_message(
					"<span class='warning'><B>[user]</B> завершает разборку обшивки!</span>",
					"<span class='warning'>Вы разобрали обшивку!</span>",
					"<span class='warning'>Звуки прекратились. Похоже, обшивка была разрезана на части!</span>",
					viewing_distance = 5)
				new /obj/item/stack/tile/plasteel(src)
				ReplaceWithLattice()
#undef LIGHTFLOOR_ON_BIT

#undef LIGHTFLOOR_STATE_OK
#undef LIGHTFLOOR_STATE_FLICKER
#undef LIGHTFLOOR_STATE_BREAKING
#undef LIGHTFLOOR_STATE_BROKEN
#undef LIGHTFLOOR_STATE_BITS
