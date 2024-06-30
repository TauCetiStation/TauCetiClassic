/obj/machinery/accelerator
	name = "Accelerator"
	desc = "Pushes objects and people in the desired direction. Useful for zero gravitation."

	icon = 'icons/obj/machines/accelerator.dmi'
	icon_state = "placeholder"

	layer = TURF_CAP_LAYER+0.1
	plane = FLOOR_PLANE

	idle_power_usage = 25

	anchored = TRUE

	var/image/lights

/obj/machinery/accelerator/atom_init()
	..()

	icon_state = "platform"

	update_icon()

/obj/machinery/accelerator/is_operational()
	return anchored && ..()

/obj/machinery/telescience_jammer/attackby(obj/item/I, mob/user)
	user.SetNextMove(CLICK_CD_INTERACT)
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>It's too complicated for you.</span>")
		return

	if(default_unfasten_wrench(user, I))
		return

	return ..()

/obj/machinery/accelerator/Crossed(atom/movable/AM)
	var/datum/thrownthing/TT = SSthrowing.processing[AM]
	if(TT)
		world.log << "[x].[y] - [TT.speed]"

	if(is_operational() && istype(AM))
		use_power(idle_power_usage*100)
		AM.throw_at(get_step(src, dir), 16, emagged ? 10 : 1, spin = prob(50))

/obj/machinery/accelerator/power_change()
	..()
	update_icon()

/obj/machinery/accelerator/update_icon()
	cut_overlays()
	if(anchored && !(stat & (NOPOWER | BROKEN | MAINT)))
		if(!lights)
			lights = image(icon, "lights", layer = ABOVE_LIGHTING_LAYER)
			lights.plane = LIGHTING_LAMPS_PLANE

		if(emagged)
			lights.color = "#eb345f"
		else
			lights.color = "#34d8eb"

		add_overlay(lights)
		set_light(1)
	else
		set_light(0)

/obj/machinery/accelerator/verb/rotate()
	set category = "Object"
	set name = "Rotate Pipe"
	set src in view(1)

	if(anchored)
		to_chat(usr, "<span class='notice'>You need to unwrench it firts!</span>")
		return

	if (usr.incapacitated())
		return

	set_dir(turn(dir, 45))
