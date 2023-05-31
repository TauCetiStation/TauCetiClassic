/*
 * False Walls
 */
/obj/structure/falsewall
	name = "wall"
	desc = "Огромный кусок металла для разделения комнат."
	icon = 'icons/turf/walls/has_false_walls/wall.dmi'
	icon_state = "box"
	anchored = TRUE
	density = TRUE
	opacity = TRUE
	can_block_air = TRUE

	canSmoothWith = list(
		/turf/simulated/wall,
		/turf/simulated/wall/r_wall,
		/obj/structure/falsewall,
		/obj/structure/falsewall/reinforced,
		/obj/structure/girder,
		/obj/structure/girder/reinforced
	)
	smooth = SMOOTH_TRUE
	can_be_unanchored = FALSE

	var/walltype = /turf/simulated/wall
	var/opening = FALSE
	var/block_air_zones = TRUE

	max_integrity = 100
	resistance_flags = CAN_BE_HIT

/obj/structure/falsewall/c_airblock(turf/other)
	if(block_air_zones)
		return ..() | ZONE_BLOCKED
	return ..()

/obj/structure/falsewall/CanPass(atom/movable/mover, turf/target, height=0)
	if(istype(mover, /obj/effect/beam))
		return !opacity
	return !density

/obj/structure/falsewall/attack_hand(mob/user)
	if(opening)
		return

	user.SetNextMove(CLICK_CD_MELEE)
	opening = TRUE
	update_icon()
	addtimer(CALLBACK(src, /obj/structure/falsewall/proc/toggle_open), 5)

/obj/structure/falsewall/proc/toggle_open()
	if(!QDELETED(src))
		opening = FALSE
		if(!density)
			var/turf/T = get_turf(src)
			for(var/obj/O in T.contents)
				if(O.density)
					update_icon()
					return
		density = !density
		set_opacity(density)
		update_icon()
		update_nearby_tiles()

/obj/structure/falsewall/update_icon()//Calling icon_update will refresh the smoothwalls if it's closed, otherwise it will make sure the icon is correct if it's open
	if(opening)
		if(density)
			flick("fwall_opening", src)
			icon_state = "fwall_open"
			smooth = SMOOTH_FALSE
		else
			flick("fwall_closing", src)
			icon_state = initial(icon_state)
	else
		if(density)
			icon_state = initial(icon_state)
			smooth = SMOOTH_TRUE
			queue_smooth(src)
		else
			icon_state = "fwall_open"

/obj/structure/falsewall/attackby(obj/item/weapon/W, mob/user)
	if(opening)
		to_chat(user, "<span class='warning'>Вы должны подождать, пока дверь не закончит движение.</span>")
		return
	user.SetNextMove(CLICK_CD_INTERACT)

	if(density)
		var/turf/T = get_turf(src)
		if(T.density)
			to_chat(user, "<span class='warning'>Стена заблокирована!</span>")
			return
		if(isscrewing(W))
			user.visible_message("[user] tightens some screws on the wall.", "Вы затягиваете винты на стене.")
			T.ChangeTurf(walltype)
			qdel(src)

		if( iswelding(W) )
			var/obj/item/weapon/weldingtool/WT = W
			if( WT.isOn() )
				T.ChangeTurf(walltype)
				if(walltype != /turf/simulated/wall/mineral/phoron)//Stupid shit keeps me from pushing the attackby() to phoron walls -Sieve
					T = get_turf(src)
					T.attackby(W, user)
				qdel(src)
	else
		to_chat(user, "<span class='notice'>Вы не можете этого сделать пока стена открыта.</span>")
	if( istype(W, /obj/item/weapon/gun/energy/laser/cutter) )
		var/turf/T = get_turf(src)
		T.ChangeTurf(walltype)
		if(walltype != /turf/simulated/wall/mineral/phoron)
			T = get_turf(src)
			T.attackby(W, user)
		qdel(src)

	//DRILLING
	else if (istype(W, /obj/item/weapon/pickaxe/drill/diamond_drill))
		var/turf/T = get_turf(src)
		T.ChangeTurf(walltype)
		T = get_turf(src)
		T.attackby(W, user)
		qdel(src)

	else if( istype(W, /obj/item/weapon/melee/energy/blade) )
		var/turf/T = get_turf(src)
		T.ChangeTurf(walltype)
		if(walltype != /turf/simulated/wall/mineral/phoron)
			T = get_turf(src)
			T.attackby(W, user)
		qdel(src)

/obj/structure/falsewall/deconstruct(disassembled = TRUE)
	if(flags & NODECONSTRUCT)
		return ..()
	var/turf/T = loc
	T.ChangeTurf(walltype)
	var/turf/simulated/wall/wall = loc
	wall.dismantle_wall(!disassembled)
	..()

/*
 * False R-Walls
 */

/obj/structure/falsewall/reinforced
	name = "reinforced wall"
	desc = "Огромный кусок укреплённого металла для разделения комнат."
	icon = 'icons/turf/walls/has_false_walls/reinforced_wall.dmi'
	walltype = /turf/simulated/wall/r_wall

/*
 * Uranium Falsewalls
 */

/obj/structure/falsewall/uranium
	name = "uranium wall"
	desc = "Стена с урановой обшивкой. Наверное, это плохая идея."
	icon = 'icons/turf/walls/has_false_walls/uranium_wall.dmi'
	walltype = /turf/simulated/wall/mineral/uranium
	canSmoothWith = list(/obj/structure/falsewall/uranium, /turf/simulated/wall/mineral/uranium)

	var/active = null
	var/last_event = 0

/obj/structure/falsewall/uranium/attackby(obj/item/weapon/W, mob/user)
	radiate()
	..()

/obj/structure/falsewall/uranium/attack_hand(mob/user)
	radiate()
	..()

/obj/structure/falsewall/uranium/proc/radiate()
	if(!active)
		if(world.time > last_event + 15)
			active = 1
			irradiate_in_dist(get_turf(src), 12, 3)
			for(var/turf/simulated/wall/mineral/uranium/T in range(3, src))
				T.radiate()
			last_event = world.time
			active = null

/*
 * Other misc falsewall types
 */

/obj/structure/falsewall/gold
	name = "gold wall"
	desc = "Стена с золотой обшивкой. Оу-ееее!"
	icon = 'icons/turf/walls/has_false_walls/gold_wall.dmi'
	walltype = /turf/simulated/wall/mineral/gold
	canSmoothWith = list(/obj/structure/falsewall/gold, /turf/simulated/wall/mineral/gold)

/obj/structure/falsewall/silver
	name = "silver wall"
	desc = "Стена с серебрянной обшивкой. Блестит."
	icon = 'icons/turf/walls/has_false_walls/silver_wall.dmi'
	walltype = /turf/simulated/wall/mineral/silver
	canSmoothWith = list(/obj/structure/falsewall/silver, /turf/simulated/wall/mineral/silver)

/obj/structure/falsewall/diamond
	name = "diamond wall"
	desc = "Стена с алмазной обшивкой. Ты чудовище."
	icon = 'icons/turf/walls/has_false_walls/diamond_wall.dmi'
	walltype = /turf/simulated/wall/mineral/diamond
	canSmoothWith = list(/obj/structure/falsewall/diamond, /turf/simulated/wall/mineral/diamond)

/obj/structure/falsewall/bananium
	name = "bananium wall"
	desc = "Стена с бананиумовой обшивкой. Хонк!"
	icon = 'icons/turf/walls/has_false_walls/bananium_wall.dmi'
	walltype = /turf/simulated/wall/mineral/bananium
	canSmoothWith = list(/obj/structure/falsewall/bananium, /turf/simulated/wall/mineral/bananium)

/obj/structure/falsewall/sandstone
	name = "sandstone wall"
	desc = "Стена с песчаной обшивкой."
	icon = 'icons/turf/walls/has_false_walls/sandstone_wall.dmi'
	walltype = /turf/simulated/wall/mineral/sandstone
	canSmoothWith = list(/obj/structure/falsewall/sandstone, /turf/simulated/wall/mineral/sandstone)

/obj/structure/falsewall/phoron
	name = "phoron wall"
	desc = "Стена с обшивкой из форона. Определённо плохая идея."
	icon = 'icons/turf/walls/has_false_walls/phoron_wall.dmi'
	walltype = /turf/simulated/wall/mineral/phoron
	canSmoothWith = list(/obj/structure/falsewall/phoron, /turf/simulated/wall/mineral/phoron)
