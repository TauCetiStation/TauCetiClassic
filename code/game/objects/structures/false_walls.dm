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
		/turf/simulated/wall, \
		/turf/simulated/wall/yellow, \
		/turf/simulated/wall/red, \
		/turf/simulated/wall/purple, \
		/turf/simulated/wall/green, \
		/turf/simulated/wall/beige, \
		/turf/simulated/wall/r_wall, \
		/turf/simulated/wall/r_wall/yellow, \
		/turf/simulated/wall/r_wall/red, \
		/turf/simulated/wall/r_wall/purple, \
		/turf/simulated/wall/r_wall/green, \
		/turf/simulated/wall/r_wall/beige, \
		/obj/structure/falsewall, \
		/obj/structure/falsewall/yellow, \
		/obj/structure/falsewall/red, \
		/obj/structure/falsewall/purple, \
		/obj/structure/falsewall/green, \
		/obj/structure/falsewall/beige, \
		/obj/structure/falsewall/reinforced, \
		/obj/structure/falsewall/reinforced/yellow, \
		/obj/structure/falsewall/reinforced/red, \
		/obj/structure/falsewall/reinforced/purple, \
		/obj/structure/falsewall/reinforced/green, \
		/obj/structure/falsewall/reinforced/beige, \
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

	var/can_be_painted = TRUE

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
	addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/structure/falsewall, toggle_open)), 5)

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
		else if(isscrewing(W))
			user.visible_message("[user] tightens some screws on the wall.", "Вы затягиваете винты на стене.")
			T.ChangeTurf(walltype)
			qdel(src)
			return

		else if(iswelding(W))
			var/obj/item/weapon/weldingtool/WT = W
			if( WT.isOn() )
				T.ChangeTurf(walltype)
				if(walltype != /turf/simulated/wall/mineral/phoron)//Stupid shit keeps me from pushing the attackby() to phoron walls -Sieve
					T = get_turf(src)
					T.attackby(W, user)
				qdel(src)
				return

		// only base and reinforced types can be painted
		else if(istype(W, /obj/item/weapon/airlock_painter) && can_be_painted)

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

	else if(istype(W, /obj/item/weapon/gun/energy/laser/cutter))
		var/turf/T = get_turf(src)
		T.ChangeTurf(walltype)
		if(walltype != /turf/simulated/wall/mineral/phoron)
			T = get_turf(src)
			T.attackby(W, user)
		qdel(src)
		return

	//DRILLING
	else if(istype(W, /obj/item/weapon/pickaxe/drill/diamond_drill))
		var/turf/T = get_turf(src)
		T.ChangeTurf(walltype)
		T = get_turf(src)
		T.attackby(W, user)
		qdel(src)
		return

	else if( istype(W, /obj/item/weapon/melee/energy/blade) )
		var/turf/T = get_turf(src)
		T.ChangeTurf(walltype)
		if(walltype != /turf/simulated/wall/mineral/phoron)
			T = get_turf(src)
			T.attackby(W, user)
		qdel(src)
		return

/obj/structure/falsewall/deconstruct(disassembled = TRUE)
	if(flags & NODECONSTRUCT)
		return ..()
	var/turf/T = loc
	T.ChangeTurf(walltype)
	var/turf/simulated/wall/wall = loc
	wall.dismantle_wall(!disassembled)
	..()

/obj/structure/falsewall/proc/change_color(color)
	var/new_type
	switch(color)
		if("blue")
			new_type = /obj/structure/falsewall
		if("yellow")
			new_type = /obj/structure/falsewall/yellow
		if("red")
			new_type = /obj/structure/falsewall/red
		if("purple")
			new_type = /obj/structure/falsewall/purple
		if("green")
			new_type = /obj/structure/falsewall/green
		if("beige")
			new_type = /obj/structure/falsewall/beige
		else
			stack_trace("Color [color] does not exist")
	if(new_type && new_type != type)
		new new_type(loc)
		qdel(src)

// todo:
// probably we should make /obj/structure/falsewall 
// and /turf/simulated/wall as meta-types not used in the game, and move 
// real walls and falsewalls to subtypes
/obj/structure/falsewall/yellow
	icon = 'icons/turf/walls/has_false_walls/wall_yellow.dmi'
	walltype = /turf/simulated/wall/yellow

/obj/structure/falsewall/red
	icon = 'icons/turf/walls/has_false_walls/wall_red.dmi'
	walltype = /turf/simulated/wall/red

/obj/structure/falsewall/purple
	icon = 'icons/turf/walls/has_false_walls/wall_purple.dmi'
	walltype = /turf/simulated/wall/purple

/obj/structure/falsewall/green
	icon = 'icons/turf/walls/has_false_walls/wall_green.dmi'
	walltype = /turf/simulated/wall/green

/obj/structure/falsewall/beige
	icon = 'icons/turf/walls/has_false_walls/wall_beige.dmi'
	walltype = /turf/simulated/wall/beige

/*
 * False R-Walls
 */

/obj/structure/falsewall/reinforced
	name = "reinforced wall"
	desc = "Огромный кусок укреплённого металла для разделения комнат."
	icon = 'icons/turf/walls/has_false_walls/reinforced.dmi'
	walltype = /turf/simulated/wall/r_wall

/obj/structure/falsewall/reinforced/change_color(color)
	var/new_type
	switch(color)
		if("blue")
			new_type = /obj/structure/falsewall/reinforced
		if("yellow")
			new_type = /obj/structure/falsewall/reinforced/yellow
		if("red")
			new_type = /obj/structure/falsewall/reinforced/red
		if("purple")
			new_type = /obj/structure/falsewall/reinforced/purple
		if("green")
			new_type = /obj/structure/falsewall/reinforced/green
		if("beige")
			new_type = /obj/structure/falsewall/reinforced/beige
		else
			stack_trace("Color [color] does not exist")
	if(new_type && new_type != type)
		new new_type(loc)
		qdel(src)

/obj/structure/falsewall/reinforced/yellow
	icon = 'icons/turf/walls/has_false_walls/reinforced_yellow.dmi'
	walltype = /turf/simulated/wall/r_wall/yellow

/obj/structure/falsewall/reinforced/red
	icon = 'icons/turf/walls/has_false_walls/reinforced_red.dmi'
	walltype = /turf/simulated/wall/r_wall/red

/obj/structure/falsewall/reinforced/purple
	icon = 'icons/turf/walls/has_false_walls/reinforced_purple.dmi'
	walltype = /turf/simulated/wall/r_wall/purple

/obj/structure/falsewall/reinforced/green
	icon = 'icons/turf/walls/has_false_walls/reinforced_green.dmi'
	walltype = /turf/simulated/wall/r_wall/green

/obj/structure/falsewall/reinforced/beige
	icon = 'icons/turf/walls/has_false_walls/reinforced_beige.dmi'
	walltype = /turf/simulated/wall/r_wall/beige

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

	can_be_painted = FALSE

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
	can_be_painted = FALSE

/obj/structure/falsewall/silver
	name = "silver wall"
	desc = "Стена с серебрянной обшивкой. Блестит."
	icon = 'icons/turf/walls/has_false_walls/silver_wall.dmi'
	walltype = /turf/simulated/wall/mineral/silver
	canSmoothWith = list(/obj/structure/falsewall/silver, /turf/simulated/wall/mineral/silver)
	can_be_painted = FALSE

/obj/structure/falsewall/diamond
	name = "diamond wall"
	desc = "Стена с алмазной обшивкой. Ты чудовище."
	icon = 'icons/turf/walls/has_false_walls/diamond_wall.dmi'
	walltype = /turf/simulated/wall/mineral/diamond
	canSmoothWith = list(/obj/structure/falsewall/diamond, /turf/simulated/wall/mineral/diamond)
	can_be_painted = FALSE

/obj/structure/falsewall/bananium
	name = "bananium wall"
	desc = "Стена с бананиумовой обшивкой. Хонк!"
	icon = 'icons/turf/walls/has_false_walls/bananium_wall.dmi'
	walltype = /turf/simulated/wall/mineral/bananium
	canSmoothWith = list(/obj/structure/falsewall/bananium, /turf/simulated/wall/mineral/bananium)
	can_be_painted = FALSE

/obj/structure/falsewall/sandstone
	name = "sandstone wall"
	desc = "Стена с песчаной обшивкой."
	icon = 'icons/turf/walls/has_false_walls/sandstone_wall.dmi'
	walltype = /turf/simulated/wall/mineral/sandstone
	canSmoothWith = list(/obj/structure/falsewall/sandstone, /turf/simulated/wall/mineral/sandstone)
	can_be_painted = FALSE

/obj/structure/falsewall/phoron
	name = "phoron wall"
	desc = "Стена с обшивкой из форона. Определённо плохая идея."
	icon = 'icons/turf/walls/has_false_walls/phoron_wall.dmi'
	walltype = /turf/simulated/wall/mineral/phoron
	canSmoothWith = list(/obj/structure/falsewall/phoron, /turf/simulated/wall/mineral/phoron)
	can_be_painted = FALSE
