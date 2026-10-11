/obj/item/weapon/storage/hidden_cache
	storage_slots = 1
	max_w_class = SIZE_SMALL

	var/particles/interaction_particle
	var/interaction_time = 3 SECONDS

/obj/item/weapon/storage/hidden_cache/try_open(mob/user)
	if(!user)
		return FALSE

	if(!user.in_interaction_vicinity(src))
		return FALSE

	user.visible_message("<span class='danger'>[user] возится с [CASE(loc, ABLATIVE_CASE)]...</span>")

	var/obj/effect/abstract/particle_holder/Holder
	if(interaction_particle)
		Holder = new /obj/effect/abstract/particle_holder(get_turf(src), interaction_particle, PARTICLE_FADEOUT|PARTICLE_FLICK)

	if(!do_after(user, interaction_time, target = loc))
		if(Holder)
			qdel(Holder)
		return

	open(user)
	return TRUE

/obj/item/weapon/storage/hidden_cache/toilet
	//interaction_particle =
	//use_sound
	interaction_time = 1 SECOND

/obj/item/weapon/storage/hidden_cache/toilet/try_open(mob/user)
	var/obj/structure/toilet/toilet = loc
	if(!toilet.cistern_open)
		return FALSE

	return ..()

/obj/item/weapon/storage/hidden_cache/flowerpot
	//interaction_particle =
	//use_sound
	interaction_time = 5 SECONDS

/obj/item/weapon/storage/hidden_cache/vending
	//use_sound =
