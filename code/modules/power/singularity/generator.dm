/////SINGULARITY SPAWNER
/obj/machinery/the_singularitygen
	name = "Gravitational Singularity Generator"
	desc = "An Odd Device which produces a Gravitational Singularity when set up."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "TheSingGen"
	anchored = 0
	density = 1
	use_power = NO_POWER_USE
	var/energy = 0
	var/creation_type = /obj/singularity
	var/is_activated = FALSE

/obj/machinery/the_singularitygen/process()
	var/turf/T = get_turf(src)
	if(src.energy >= 200 && !is_activated)
		is_activated = TRUE
		var/atom/movable/overlay/animation = new(T)
		animation.master = src
		animation.pixel_x = -32
		animation.pixel_y = -32
		animation.layer = SINGULARITY_EFFECT_LAYER
		flick('icons/effects/singularity_effect.dmi', animation)
		sleep(60)
		new creation_type(T, 50)
		if(src) qdel(src)
		QDEL_IN(animation, 10)

/obj/machinery/the_singularitygen/attackby(obj/item/W, mob/user)
	if(iswrench(W))
		anchored = !anchored
		playsound(src, 'sound/items/Ratchet.ogg', VOL_EFFECTS_MASTER)
		if(anchored)
			user.visible_message("[user.name] secures [src.name] to the floor.", \
				"You secure the [src.name] to the floor.", \
				"You hear a ratchet")
		else
			user.visible_message("[user.name] unsecures [src.name] from the floor.", \
				"You unsecure the [src.name] from the floor.", \
				"You hear a ratchet")
		return
	return ..()
