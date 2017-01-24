///////////////////////////////////////
//Contents: Ladders, Hatches, Stairs.//
///////////////////////////////////////

/obj/multiz
	icon = 'icons/obj/structures.dmi'
	density = 0
	opacity = 0
	anchored = 1

	CanPass(obj/mover, turf/source, height, airflow)
		return airflow || !density

/obj/multiz/ladder
	icon_state = "ladderdown"
	name = "ladder"
	desc = "A ladder.  You climb up and down it."

	var/d_state = 1
	var/obj/multiz/target

/obj/multiz/ladder/New()
	. = ..()

/obj/multiz/ladder/proc/connect()
	if(icon_state == "ladderdown") // the upper will connect to the lower
		d_state = 1
		var/turf/controllerlocation = locate(1, 1, z)
		for(var/obj/effect/landmark/zcontroller/controller in controllerlocation)
			if(controller.down)
				var/turf/below = locate(src.x, src.y, controller.down_target)
				for(var/obj/multiz/ladder/L in below)
					if(L.icon_state == "ladderup")
						target = L
						L.target = src
						d_state = 0
						break
	return

/obj/multiz/ladder/Destroy()
	spawn(1)
		if(target && icon_state == "ladderdown")
			qdel(target)
	return ..()

/obj/multiz/ladder/attack_paw(mob/M)
	return attack_hand(M)

/obj/multiz/ladder/attackby(obj/item/C, mob/user)
	(..)
	src.attack_hand(user)
	return

/obj/multiz/ladder/attack_hand(mob/M)
	if(!target || !istype(target.loc, /turf))
		to_chat(M, "The ladder is incomplete and can't be climbed.")
	else
		var/turf/T = target.loc
		var/blocked = 0
		for(var/atom/A in T.contents)
			if(A.density)
				blocked = 1
				break
		if(blocked || istype(T, /turf/simulated/wall))
			to_chat(M, "Something is blocking the ladder.")
		else
			M.visible_message("\blue \The [M] climbs [src.icon_state == "ladderup" ? "up" : "down"] \the [src]!", "You climb [src.icon_state == "ladderup"  ? "up" : "down"] \the [src]!", "You hear some grunting, and clanging of a metal ladder being used.")
			M.Move(target.loc)

/obj/multiz/stairs
	name = "Stairs"
	desc = "Stairs.  You walk up and down them."
	icon_state = "rampbottom"
	var/obj/multiz/stairs/connected
	var/turf/target

/obj/multiz/stairs/New()
	..()
	var/turf/cl= locate(1, 1, src.z)
	for(var/obj/effect/landmark/zcontroller/c in cl)
		if(c.up)
			var/turf/O = locate(src.x, src.y, c.up_target)
			if(istype(O, /turf/space))
				O.ChangeTurf(/turf/simulated/floor/open)

	spawn(1)
		for(var/dir in cardinal)
			var/turf/T = get_step(src.loc,dir)
			for(var/obj/multiz/stairs/S in T)
				if(S && S.icon_state == "rampbottom" && !S.connected)
					S.dir = dir
					src.dir = dir
					S.connected = src
					src.connected = S
					src.icon_state = "ramptop"
					src.density = 1
					var/turf/controllerlocation = locate(1, 1, src.z)
					for(var/obj/effect/landmark/zcontroller/controller in controllerlocation)
						if(controller.up)
							var/turf/above = locate(src.x, src.y, controller.up_target)
							if(istype(above,/turf/space) || istype(above,/turf/simulated/floor/open))
								src.target = above
					break
			if(target)
				break

/obj/multiz/stairs/Bumped(atom/movable/M)
	if(connected && target && istype(src, /obj/multiz/stairs) && locate(/obj/multiz/stairs) in M.loc)
		var/obj/multiz/stairs/Con = locate(/obj/multiz/stairs) in M.loc
		if(Con == src.connected) //make sure the atom enters from the approriate lower stairs tile
			M.Move(target)
	return
