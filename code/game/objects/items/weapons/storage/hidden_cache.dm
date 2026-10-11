/obj/item/weapon/storage/hidden_cache
	storage_slots = 1
	max_w_class = SIZE_SMALL

	var/particles/interaction_particle
	var/interaction_time = 1 SECONDS

/obj/item/weapon/storage/hidden_cache/try_open(mob/user)
	if(!user)
		return FALSE

	if(!user.in_interaction_vicinity(src))
		return FALSE

	if(user.is_busy())
		return FALSE

	user.visible_message("<span class='danger'>[user] возится с [CASE(loc, ABLATIVE_CASE)]...</span>")

	if(length(use_sound))
		playsound(src, pick(use_sound), VOL_EFFECTS_MASTER, null, FALSE, null, -5)

	var/obj/effect/abstract/particle_holder/Holder
	if(interaction_particle)
		Holder = new /obj/effect/abstract/particle_holder(src, interaction_particle, PARTICLE_FADEOUT)

	if(!do_after(user, interaction_time, target = loc))
		QDEL_NULL(Holder)
		return

	QDEL_NULL(Holder)

	open(user)
	return TRUE

/obj/item/weapon/storage/hidden_cache/toilet
	interaction_particle = /particles/tool/digging/watersplash
	use_sound = 'sound/effects/water_turf_entered_obj.ogg'
	interaction_time = 0.5 SECOND

/obj/item/weapon/storage/hidden_cache/toilet/try_open(mob/user)
	var/obj/structure/toilet/toilet = loc
	if(!toilet.cistern_open)
		return FALSE

	return ..()

/obj/item/weapon/storage/hidden_cache/flowerpot
	interaction_particle = /particles/tool/digging/flowerpot
	use_sound = 'sound/effects/shovel_digging.ogg'
	interaction_time = 3 SECONDS

	max_w_class = SIZE_TINY

/obj/item/weapon/storage/hidden_cache/vending
	use_sound = 'sound/items/surgery_tray_use.ogg'

/obj/item/weapon/storage/hidden_cache/mirror
	use_sound = 'sound/items/Crowbar.ogg'

	max_w_class = SIZE_MINUSCULE
