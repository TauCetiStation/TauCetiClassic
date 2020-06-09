/obj/machinery/transformer
	name = "Automatic Robotic Factory 5000"
	desc = "A large metalic machine with an entrance and an exit. A sign on the side reads, 'human go in, robot come out', human must be lying down and alive."
	icon = 'icons/obj/recycling.dmi'
	icon_state = "separator-AO1"
	layer = MOB_LAYER+1 // Overhead
	anchored = 1
	density = 1
	var/transform_dead = 0
	var/transform_standing = 0

/obj/machinery/transformer/atom_init()
	// On us
	. = ..()
	new /obj/machinery/conveyor(loc, WEST, 1)

/obj/machinery/transformer/Bumped(atom/movable/AM)
	if(ishuman(AM))
		// Only humans can enter from the west side, while lying down.
		var/move_dir = get_dir(loc, AM.loc)
		var/mob/living/carbon/human/H = AM
		if((transform_standing || H.lying) && move_dir == EAST)// || move_dir == WEST)
			AM.loc = src.loc
			transform(AM)

/obj/machinery/transformer/proc/transform(mob/living/carbon/human/H)
	if(stat & (BROKEN|NOPOWER))
		return
	if(!transform_dead && H.stat == DEAD)
		playsound(src, 'sound/machines/buzz-sigh.ogg', VOL_EFFECTS_MASTER, null, FALSE)
		return
	playsound(src, 'sound/items/Welder.ogg', VOL_EFFECTS_MASTER)
	use_power(5000) // Use a lot of power.
	var/mob/living/silicon/robot = H.Robotize()
	robot.lying = 1
	spawn(50) // So he can't jump out the gate right away.
		playsound(src, 'sound/machines/ping.ogg', VOL_EFFECTS_MASTER, null, FALSE)
		if(robot)
			robot.lying = 0

/obj/machinery/transformer/conveyor/atom_init()
	. = ..()
	var/turf/T = loc
	if(T)
		// Spawn Conveyour Belts

		//East
		var/turf/east = locate(T.x + 1, T.y, T.z)
		if(istype(east, /turf/simulated/floor))
			new /obj/machinery/conveyor(east, WEST, 1)

		// West
		var/turf/west = locate(T.x - 1, T.y, T.z)
		if(istype(west, /turf/simulated/floor))
			new /obj/machinery/conveyor(west, WEST, 1)
