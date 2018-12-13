
/obj/machinery/power/crystal
	var/power_produced = 100000
	var/working = FALSE
	invisibility = 70

/obj/machinery/power/crystal/process()
	if(working)
		add_avail(power_produced)
	return

/obj/machinery/power/crystal/proc/generate_power()
	working = TRUE

/obj/machinery/power/crystal/proc/generate_power_stop()
	working = FALSE

/obj/structure/crystal
	name = "large crystal"
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = ""
	density = 1
	var/obj/machinery/power/crystal/Generator = null
	var/wired = FALSE
	var/icon_custom_crystal = null

/obj/structure/crystal/atom_init()
	. = ..()

	Generator = new /obj/machinery/power/crystal(src)
	if(anchored)
		Generator.loc = loc
		Generator.connect_to_network()

	icon_custom_crystal = pick("ano70", "ano80")
	icon_state = icon_custom_crystal

	desc = pick(\
	"It shines faintly as it catches the light.",\
	"It appears to have a faint inner glow.",\
	"It seems to draw you inward as you look it at.",\
	"Something twinkles faintly as you look at it.",\
	"It's mesmerizing to behold.")

/obj/structure/crystal/Destroy()
	QDEL_NULL(Generator)
	src.visible_message("\red<b>[src] shatters!</b>")
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

/obj/structure/crystal/attackby(obj/item/W, mob/user)
	if(default_unfasten_wrench(user,W))
		user.SetNextMove(CLICK_CD_INTERACT)
		if(anchored)
			Generator.loc = src.loc
			Generator.connect_to_network()
		else
			Generator.disconnect_from_network()
			Generator.loc = null
		update_crystal()
		return

	if(istype(W, /obj/item/weapon/wirecutters)) // If we want to remove the wiring
		if(wired)
			user.visible_message( \
				"<span class='notice'>[user] starts cutting off the wiring of the [src].</span>", \
				"<span class='notice'>You start cutting off the wiring of the [src].</span>" \
			)
			if (!user.is_busy(src) && do_after(user,20,target = src))
				user.visible_message( \
					"<span class='notice'>[user] cuts off the wiring of the [src].</span>", \
					"<span class='notice'>You cut off the wiring of the [src].</span>" \
				)
				wired = FALSE
				update_crystal()
				return
		else
			to_chat(user, "<span class='red'>There is currently no wiring on the [src].</span>")
			return
	if(istype(W, /obj/item/stack/cable_coil))
		if(!wired)
			var/obj/item/stack/cable_coil/CC = W
			if(!CC.use(2))
				to_chat(user, "<span class='red'>There's not enough wire to finish the task.</span>")
				return
			wired = TRUE
			update_crystal()
			to_chat(user, "<span class='notice'>You put the wires all across the [src]</span>")
			return
		else
			to_chat(user, "<span class='red'>The [src] is already wired.</span>")
			return
	..()

/obj/structure/crystal/proc/update_crystal()
	if(wired && anchored)
		icon_state = "[icon_custom_crystal]_powered"
		Generator.generate_power()
	else
		icon_state = icon_custom_crystal
		Generator.generate_power_stop()
	if(wired)
		src.overlays += image('icons/obj/xenoarchaeology.dmi', "crystal_overlay")
	else
		overlays.Cut()
	return

// laser_act
/obj/structure/crystal/bullet_act(obj/item/projectile/P)
	if(istype(P, /obj/item/projectile/energy) || istype(P, /obj/item/projectile/beam))
		visible_message("<span class='danger'>The [P.name] gets reflected by [src]!</span>", \
						"<span class='userdanger'>The [P.name] gets reflected by [src]!</span>")
		// Find a turf near or on the original location to bounce to
		if(P.starting)
			var/new_x = P.starting.x + pick(0, 0, 0, 0, 0, -1, 1, -2, 2)
			var/new_y = P.starting.y + pick(0, 0, 0, 0, 0, -1, 1, -2, 2)
			var/turf/curloc = get_turf(src)
			// redirect the projectile
			P.redirect(new_x, new_y, curloc, src)
		return -1 // complete projectile permutation

