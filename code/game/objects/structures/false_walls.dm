/*
 * False Walls
 */
/obj/structure/falsewall
	name = "wall"
	desc = "A huge chunk of metal used to seperate rooms."
	density = 1
	opacity = 1
	anchored = 1
	icon = 'icons/turf/wall.dmi'
	icon_state = "map"
	var/mineral = "metal"
	var/opening = 0
	smooth = SMOOTH_MORE|SMOOTH_SPECIAL
	canSmoothWith = list(/turf/simulated/wall,
	                     /obj/structure/falsewall,
	                     /obj/structure/falserwall,
	                     /obj/structure/window/fulltile,
	                     /obj/structure/window/reinforced/fulltile,
	                     /obj/structure/window/reinforced/tinted/fulltile,
	                     /obj/machinery/door)

/obj/structure/falsewall/Destroy()
	queue_smooth_neighbors(src)
	return ..()

/obj/structure/falsewall/attack_hand(mob/user)
	if(opening)
		return

	if(density)
		opening = 1
		icon_state = "[mineral]fwall_open"
		smooth = SMOOTH_FALSE
		flick("[mineral]fwall_opening", src)
		sleep(15)
		src.density = 0
		set_opacity(0)
		opening = 0
	else
		opening = 1
		flick("[mineral]fwall_closing", src)
		//icon_state = "[mineral]0"
		smooth = initial(smooth)
		queue_smooth(src)
		density = 1
		sleep(15)
		set_opacity(1)
		opening = 0


/obj/structure/falsewall/attackby(obj/item/weapon/W, mob/user)
	if(opening)
		to_chat(user, "\red You must wait until the door has stopped moving.")
		return

	if(density)
		var/turf/T = get_turf(src)
		if(T.density)
			to_chat(user, "\red The wall is blocked!")
			return
		if(istype(W, /obj/item/weapon/screwdriver))
			user.visible_message("[user] tightens some bolts on the wall.", "You tighten the bolts on the wall.")
			if(!mineral || mineral == "metal")
				T.ChangeTurf(/turf/simulated/wall)
			else
				T.ChangeTurf(text2path("/turf/simulated/wall/mineral/[mineral]"))
			qdel(src)

		if( istype(W, /obj/item/weapon/weldingtool) )
			var/obj/item/weapon/weldingtool/WT = W
			if( WT:welding )
				if(!mineral)
					T.ChangeTurf(/turf/simulated/wall)
				else
					T.ChangeTurf(text2path("/turf/simulated/wall/mineral/[mineral]"))
				if(mineral != "phoron")//Stupid shit keeps me from pushing the attackby() to phoron walls -Sieve
					T = get_turf(src)
					T.attackby(W,user)
				qdel(src)
	else
		to_chat(user, "\blue You can't reach, close it first!")

	if( istype(W, /obj/item/weapon/pickaxe/plasmacutter) )
		var/turf/T = get_turf(src)
		if(!mineral)
			T.ChangeTurf(/turf/simulated/wall)
		else
			T.ChangeTurf(text2path("/turf/simulated/wall/mineral/[mineral]"))
		if(mineral != "phoron")
			T = get_turf(src)
			T.attackby(W,user)
		qdel(src)

	//DRILLING
	else if (istype(W, /obj/item/weapon/pickaxe/drill/diamond_drill))
		var/turf/T = get_turf(src)
		if(!mineral)
			T.ChangeTurf(/turf/simulated/wall)
		else
			T.ChangeTurf(text2path("/turf/simulated/wall/mineral/[mineral]"))
		T = get_turf(src)
		T.attackby(W,user)
		qdel(src)

	else if( istype(W, /obj/item/weapon/melee/energy/blade) )
		var/turf/T = get_turf(src)
		if(!mineral)
			T.ChangeTurf(/turf/simulated/wall)
		else
			T.ChangeTurf(text2path("/turf/simulated/wall/mineral/[mineral]"))
		if(mineral != "phoron")
			T = get_turf(src)
			T.attackby(W,user)
		qdel(src)

/*
 * False R-Walls
 */

/obj/structure/falserwall
	name = "reinforced wall"
	desc = "A huge chunk of reinforced metal used to seperate rooms."
	icon = 'icons/turf/wall_reinforced.dmi'
	icon_state = "map"
	density = 1
	opacity = 1
	anchored = 1
	var/mineral = "metal"
	var/opening = 0
	smooth = SMOOTH_MORE|SMOOTH_SPECIAL
	canSmoothWith = list(/turf/simulated/wall,
	                     /obj/structure/falsewall,
	                     /obj/structure/falserwall,
	                     /obj/structure/window/fulltile,
	                     /obj/structure/window/reinforced/fulltile,
	                     /obj/structure/window/reinforced/tinted/fulltile,
	                     /obj/machinery/door)


/obj/structure/falserwall/Destroy()
	queue_smooth_neighbors(src)
	return ..()

/obj/structure/falserwall/attack_hand(mob/user)
	if(opening)
		return

	if(density)
		opening = 1
		// Open wall
		icon_state = "frwall_open"
		smooth = SMOOTH_FALSE
		flick("frwall_opening", src)
		sleep(15)
		density = 0
		set_opacity(0)
		opening = 0
	else
		opening = 1
		//icon_state = "r_wall"
		smooth = initial(smooth)
		flick("frwall_closing", src)
		density = 1
		sleep(15)
		set_opacity(1)
		opening = 0

/obj/structure/falserwall/attackby(obj/item/weapon/W, mob/user)
	if(opening)
		to_chat(user, "\red You must wait until the door has stopped moving.")
		return

	if(istype(W, /obj/item/weapon/screwdriver))
		var/turf/T = get_turf(src)
		user.visible_message("[user] tightens some bolts on the r wall.", "You tighten the bolts on the wall.")
		T.ChangeTurf(/turf/simulated/wall/r_wall)
		qdel(src)

	if(istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W
		if( WT.remove_fuel(0,user) )
			var/turf/T = get_turf(src)
			T.ChangeTurf(/turf/simulated/wall/r_wall)
			T = get_turf(src)
			T.attackby(W,user)
			qdel(src)

	else if(istype(W, /obj/item/weapon/pickaxe/plasmacutter))
		var/turf/T = get_turf(src)
		T.ChangeTurf(/turf/simulated/wall/r_wall)
		T = get_turf(src)
		T.attackby(W,user)
		qdel(src)

	//DRILLING
	else if (istype(W, /obj/item/weapon/pickaxe/drill/diamond_drill))
		var/turf/T = get_turf(src)
		T.ChangeTurf(/turf/simulated/wall/r_wall)
		T = get_turf(src)
		T.attackby(W,user)
		qdel(src)

	else if( istype(W, /obj/item/weapon/melee/energy/blade) )
		var/turf/T = get_turf(src)
		T.ChangeTurf(/turf/simulated/wall/r_wall)
		T = get_turf(src)
		T.attackby(W,user)
		qdel(src)


/*
 * Uranium Falsewalls
 */
/*
/obj/structure/falsewall/uranium
	name = "uranium wall"
	desc = "A wall with uranium plating. This is probably a bad idea."
	icon_state = ""
	mineral = "uranium"
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
		if(world.time > last_event+15)
			active = 1
			for(var/mob/living/L in range(3,src))
				L.apply_effect(12,IRRADIATE,0)
			for(var/turf/simulated/wall/mineral/uranium/T in range(3,src))
				T.radiate()
			last_event = world.time
			active = null
			return
	return
*/
/*
 * Other misc falsewall types
 */
/*
/obj/structure/falsewall/gold
	name = "gold wall"
	desc = "A wall with gold plating. Swag!"
	icon_state = ""
	mineral = "gold"

/obj/structure/falsewall/silver
	name = "silver wall"
	desc = "A wall with silver plating. Shiny."
	icon_state = ""
	mineral = "silver"

/obj/structure/falsewall/diamond
	name = "diamond wall"
	desc = "A wall with diamond plating. You monster."
	icon_state = ""
	mineral = "diamond"

/obj/structure/falsewall/phoron
	name = "phoron wall"
	desc = "A wall with phoron plating. This is definately a bad idea."
	icon_state = ""
	mineral = "phoron"

//-----------wtf?-----------start
/obj/structure/falsewall/clown
	name = "bananium wall"
	desc = "A wall with bananium plating. Honk!"
	icon_state = ""
	mineral = "clown"

/obj/structure/falsewall/sandstone
	name = "sandstone wall"
	desc = "A wall with sandstone plating."
	icon_state = ""
	mineral = "sandstone"
//------------wtf?------------end
*/
