// This is the power crystal, that basically generates lots of power when it is:
// 1) Wrenched down to the floor turf where the cable ends
// 2) Has wired = 1 (click on it with the cable to enable and with cutters to disable)
//
// TO DO:
// * More interaction.
// * Change the power supply method making it less complex.
//
/obj/machinery/power/crystal
	name = "large crystal"
	icon = 'icons/obj/xenoarchaeology/artifacts.dmi'
	icon_state = "artifact_11"
	density = TRUE
	anchored = FALSE

	var/power_produced = 50000
	var/working = FALSE

	var/wired = FALSE
	var/icon_custom_crystal = null

/obj/machinery/power/crystal/atom_init()
	. = ..()

	if(anchored)
		connect_to_network()

	icon_custom_crystal = pick("artifact_11", "artifact_12", "artifact_13")
	icon_state = icon_custom_crystal

	desc = pick(
	"It shines faintly as it catches the light.",
	"It appears to have a faint inner glow.",
	"It seems to draw you inward as you look it at.",
	"Something twinkles faintly as you look at it.",
	"It's mesmerizing to behold.")

/obj/machinery/power/crystal/attackby(obj/item/W, mob/user)
	if(default_unfasten_wrench(user,W))
		user.SetNextMove(CLICK_CD_INTERACT)
		if(anchored)
			connect_to_network()
		else
			disconnect_from_network()
		update_crystal()
		return

	if(iswirecutter(W)) // If we want to remove the wiring
		if(wired)
			user.visible_message(
				"<span class='notice'>[user] starts cutting off the wiring of the [src].</span>",
				"<span class='notice'>You start cutting off the wiring of the [src].</span>"
			)
			if(!user.is_busy(src) && W.use_tool(src, user, 20, volume = 50))
				user.visible_message(
					"<span class='notice'>[user] cuts off the wiring of the [src].</span>",
					"<span class='notice'>You cut off the wiring of the [src].</span>"
				)
				wired = FALSE
				update_crystal()
				return
		else
			to_chat(user, "<span class='red'>There is currently no wiring on the [src].</span>")
			return
	if(iscoil(W)) // If we want to put the wiring
		if(!wired)
			var/obj/item/stack/cable_coil/CC = W
			if(!CC.use(2))
				to_chat(user, "<span class='red'>There's not enough wire to finish the task.</span>")
				return
			user.visible_message(
				"<span class='notice'>[user] starts putting the wiring all over the [src].</span>",
				"<span class='notice'>You start putting the wiring all over the [src].</span>"
			)
			if(!user.is_busy(src) && W.use_tool(src, user, 20, volume = 50))
				user.visible_message(
					"<span class='notice'>[user] puts the wiring all over the [src].</span>",
					"<span class='notice'>You put the wiring all over the [src].</span>"
				)
				wired = TRUE
				update_crystal()
			return
		else
			to_chat(user, "<span class='red'>The [src] is already wired.</span>")
			return

/obj/machinery/power/crystal/Destroy()
	src.visible_message("<span class='warning'>[src] shatters!</span>")
	if(prob(75))
		new /obj/item/weapon/shard/phoron(src.loc)
	if(prob(50))
		new /obj/item/weapon/shard/phoron(src.loc)
	if(prob(25))
		new /obj/item/weapon/shard/phoron(src.loc)
	if(prob(75))
		new /obj/item/weapon/shard(src.loc)
	if(prob(50))
		new /obj/item/weapon/shard(src.loc)
	if(prob(25))
		new /obj/item/weapon/shard(src.loc)
	return ..()

/obj/machinery/power/crystal/process()
	if(working)
		add_avail(power_produced)
	return

/obj/machinery/power/crystal/proc/generate_power()
	working = TRUE

/obj/machinery/power/crystal/proc/generate_power_stop()
	working = FALSE

/obj/machinery/power/crystal/proc/update_crystal()
	if(wired && anchored)
		icon_state = "[icon_custom_crystal]_active"
		generate_power()
	else
		icon_state = icon_custom_crystal
		generate_power_stop()
	if(wired)
		src.add_overlay(image('icons/obj/xenoarchaeology/artifacts.dmi', "crystal_overlay"))
	else
		cut_overlays()
	return

// laser_act
/obj/machinery/power/crystal/bullet_act(obj/item/projectile/P)
	if(istype(P, /obj/item/projectile/energy) || istype(P, /obj/item/projectile/beam))
		visible_message("<span class='danger'>The [P.name] gets reflected by [src]!</span>",
						"<span class='userdanger'>The [P.name] gets reflected by [src]!</span>")
		// Find a turf near or on the original location to bounce to
		if(P.starting)
			var/new_x = P.starting.x + pick(0, 0, 0, 0, 0, -1, 1, -2, 2)
			var/new_y = P.starting.y + pick(0, 0, 0, 0, 0, -1, 1, -2, 2)
			var/turf/curloc = get_turf(src)
			// redirect the projectile
			P.redirect(new_x, new_y, curloc, src)
		return -1 // complete projectile permutation
