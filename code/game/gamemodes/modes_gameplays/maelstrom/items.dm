/obj/item/weapon/kitchenknife/ritual/calling_up
	var/mob/living/blood_brother
	COOLDOWN_DECLARE(incall_cd)

/obj/item/weapon/kitchenknife/ritual/calling_up/proc/register_user(mob/living/user)
	blood_brother = user
	RegisterSignal(user, list(COMSIG_PARENT_QDELETING, COMSIG_MOB_DIED), PROC_REF(destroy_container))

/obj/item/weapon/kitchenknife/ritual/calling_up/proc/destroy_container()
	SIGNAL_HANDLER
	new /obj/item/weapon/reagent_containers/food/snacks/ectoplasm(loc)
	qdel(src)

/obj/item/weapon/kitchenknife/ritual/calling_up/Destroy()
	blood_brother = null
	return ..()

/obj/item/weapon/kitchenknife/ritual/calling_up/attack_self(mob/user)
	if(!(SEND_SIGNAL(user, COMSIG_DETECT_MAELSTROM_IMPLANT) & COMPONENT_IMPLANT_DETECTED))
		return
	if(!COOLDOWN_FINISHED(src, incall_cd))
		return
	if(user == blood_brother)
		return
	if(!isnull(blood_brother))
		COOLDOWN_START(src, incall_cd, 4 SECONDS)
		for(var/progress = 0, progress <= 3, progress++)
			switch(progress)
				if(1)
					new /obj/effect/temp_visual/cult/sparks/purple(get_turf(user))
				if(2)
					new /obj/effect/temp_visual/cult/sparks/quantum(blood_brother.loc)
					new /obj/effect/temp_visual/maelstrom/blood/out(user.loc)
				if(3)
					if(!isnull(blood_brother))
						var/turf/T = get_turf(src)
						new /obj/effect/temp_visual/maelstrom/blood/out(user.loc)
						new /obj/effect/temp_visual/maelstrom/blood(get_turf(blood_brother))
						blood_brother.forceMove(T)
			if(!do_after(user, 1 SECOND, needhand = TRUE, target = src, can_move = TRUE, progress = FALSE))
				return

// poisoned blade
/obj/item/weapon/kitchenknife/ritual/calling_up/attack(mob/living/M, mob/living/user, def_zone)
	. = ..()
	if(!.)
		return
	//not backstab
	var/dir_target = get_dir(M, user)
	var/dir_assassin = get_dir(user, M)
	for(var/direction_target in list(dir_target, turn(dir_target, -90), turn(dir_target, 90)))
		if(dir_assassin == direction_target)
			if(!M.reagents)
				return
			M.reagents.add_reagent("chloralhydrate", 1)
			qdel(src)
			return

	M.apply_status_effect(STATUS_EFFECT_FULL_CONFUSION, 10 SECONDS)
	qdel(src)

/obj/item/weapon/grenade/curse
	icon = 'icons/obj/cult.dmi'
	icon_state = "curse_grenade"

/obj/item/weapon/grenade/curse/attack_self(mob/user)
	if(SEND_SIGNAL(user, COMSIG_DETECT_MAELSTROM_IMPLANT) & COMPONENT_IMPLANT_DETECTED)
		return ..()

/obj/item/weapon/grenade/curse/prime()
	playsound(src, 'sound/effects/screech.ogg', VOL_EFFECTS_MASTER, null, FALSE)
	var/list/surroundings = range(world.view, src)
	for(var/mob/living/L in surroundings)
		L.SetConfused(0)
		L.SetShockStage(0)
		L.setHalLoss(0)
		L.SetParalysis(0)
		L.SetStunned(0)
		L.SetWeakened(0)
		if(iscarbon(L))
			var/mob/living/carbon/C = L
			if(C.handcuffed && !initial(C.handcuffed))
				C.drop_from_inventory(C.handcuffed)
			if(C.legcuffed && !initial(C.legcuffed))
				C.drop_from_inventory(C.legcuffed)
		var/throw_living = FALSE
		if(L.buckled)
			L.buckled.user_unbuckle_mob(L)
			throw_living = TRUE
		if(!isfloorturf(L.loc))
			L.forceMove(get_turf(L))
			throw_living = TRUE
		if(throw_living)
			L.throw_at(get_step(L, get_dir(src, L)), 1, 1)
		if(SEND_SIGNAL(L, COMSIG_DETECT_MAELSTROM_IMPLANT) & COMPONENT_IMPLANT_DETECTED)
			L.reagents.add_reagent("stimulants", 3)
			continue
		L.AdjustConfused(10)
		L.make_jittery(150)
	light_off_range(surroundings, get_turf(src))
	qdel(src)
