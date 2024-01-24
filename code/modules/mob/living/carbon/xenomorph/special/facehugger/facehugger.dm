#define MIN_ACTIVE_TIME 100 //time between being dropped and going idle
#define MAX_ACTIVE_TIME 200

/obj/item/clothing/mask/facehugger
	name = "alien"
	desc = "Из кончика хвоста выступает отросток, похожий на трубочку."
	icon = 'icons/mob/alien.dmi'
	icon_state = "facehugger"
	item_state = "facehugger"
	density = TRUE
	layer = MOB_LAYER
	flags = MASKCOVERSMOUTH | MASKCOVERSEYES
	body_parts_covered = FACE|EYES

	var/stat = CONSCIOUS //UNCONSCIOUS is the idle state in this case
	var/sterile = 0
	var/strength = 5
	var/current_hugger	//container for playable facehugger
	var/mob/living/carbon/target = null
	var/chase_time = 0

/obj/item/clothing/mask/facehugger/atom_init(mapload, mob/hugger)
	..()
	if(hugger)
		current_hugger = hugger
		hugger.forceMove(src)
	else
		new /datum/proximity_monitor(src, 1)
	facehuggers_list += src
	return INITIALIZE_HINT_LATELOAD

/obj/item/clothing/mask/facehugger/atom_init_late()
	if(facehuggers_control_type == FACEHUGGERS_DYNAMIC_AI)
		START_PROCESSING(SSobj, src)

/obj/item/clothing/mask/facehugger/Destroy()
	target = null
	facehuggers_list -= src
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/clothing/mask/facehugger/CanPass(atom/movable/mover, turf/target, height=0)
	return ismob(mover) || (stat == DEAD)

/obj/item/clothing/mask/facehugger/process()
	if(stat != CONSCIOUS)
		return
	if(isturf(loc))
		if(!target)
			for(var/mob/living/carbon/C in range(7, src))
				var/obj/effect/vision/V = new /obj/effect/vision(get_turf(src))
				V.target = C
				if(V.check())
					qdel(V)
					if(CanHug(C, FALSE))
						chase_time = 28
						target = C
						chase()
						break
					else
						continue
				else
					qdel(V)
					continue
			if(!target && prob(65))
				step(src, pick(cardinal))

/obj/item/clothing/mask/facehugger/proc/chase()
	while(target)
		if(facehuggers_control_type != FACEHUGGERS_DYNAMIC_AI)
			target = null
			return
		if(!isturf(loc))
			target = null
			return
		else if(stat != CONSCIOUS)
			target = null
			return

		for(var/mob/living/carbon/C in range(4, src))
			if(C != target)
				if(CanHug(C, TRUE))
					if(get_dist(src,C) < get_dist(src,target))
						target = C
						break
					else
						continue
				else
					continue

		if(!CanHug(target, FALSE))
			target = null
			return
		else if(get_dist(src,target) < 2)
			Attach(target)
			target = null
			return
		else if(target in view(7,src))
			step_to(src,target)
		else if(chase_time > 0)
			chase_time--
			step_towards(src,target)
		else
			target = null
			return
		sleep(5)

/obj/effect/vision
	invisibility = 101
	var/target = null

/obj/effect/vision/proc/check()
	for(var/i in 1 to 8)
		if(!src || !target)
			return FALSE
		step_to(src, target)
		if(get_dist(src, target) == 0)
			return TRUE
	return FALSE

/obj/item/clothing/mask/facehugger/examine(mob/user)
	..()
	switch(stat)
		if(DEAD, UNCONSCIOUS)
			to_chat(user, "<span class='danger'>[src] is not moving.</span>")
		if(CONSCIOUS)
			to_chat(user, "<span class='danger'>[src] seems to be active.</span>")
	if (sterile)
		to_chat(user, "<span class='danger'>It looks like the proboscis has been removed.</span>")

/obj/item/clothing/mask/facehugger/attackby(obj/item/I, mob/user, params)
	if(I.force)
		Die()

/obj/item/clothing/mask/facehugger/attack_hand(mob/user)
	if((stat == CONSCIOUS && !sterile) && !isxeno(user))
		if(Attach(user))
			return
	else
		if(stat == DEAD && isxenoadult(user))
			if(do_after(user, 20, target = src))
				var/mob/living/carbon/xenomorph/humanoid/X = user
				if(X.health >= X.maxHealth)
					X.adjustToxLoss(50)
					to_chat(X, "<span class='notice'>Вы проглотили лицехвата. Это дало вам немного плазмы.</span>")
				else
					X.adjustBruteLoss(-50)
					X.adjustFireLoss(-50)
					X.adjustOxyLoss(-50)
					X.adjustCloneLoss(-50)
					to_chat(X, "<span class='notice'>Вы проглотили лицехвата. Ваше самочувствие улучшилось.</span>")
				qdel(src)
			return
		..()

/obj/item/clothing/mask/facehugger/attack(mob/living/M, mob/user)
	..()
	user.unEquip(src)
	Attach(M)

/obj/item/clothing/mask/facehugger/attack_alien(mob/user) //can be picked up by aliens
	attack_hand(user)
	return

/obj/item/clothing/mask/facehugger/bullet_act(obj/item/projectile/P, def_zone)
	. = ..()
	if(P.damage)
		Die()

/obj/item/clothing/mask/facehugger/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		Die()
	return

/obj/item/clothing/mask/facehugger/equipped(mob/living/carbon/C)
	..()
	Attach(C)

/obj/item/clothing/mask/facehugger/dropped()
	..()
	get_off()

//If the facehugger was removed from the face and the player controls the facehugger
/obj/item/clothing/mask/facehugger/proc/get_off()
	if(current_hugger)
		var/mob/living/carbon/xenomorph/facehugger/FH = current_hugger
		var/atom/movable/mob_container = FH
		mob_container.forceMove(get_turf(src))	//remove mob/facehugger from the /obj/facehugger
		current_hugger = null
		FH.reset_view()
		qdel(FH.get_active_hand())	//delete a grab
		qdel(src)

/obj/item/clothing/mask/facehugger/Crossed(atom/movable/AM)
	..()
	HasProximity(AM)

/obj/item/clothing/mask/facehugger/HasProximity(mob/living/carbon/C)
	if(istype(C) && !current_hugger && istype(loc, /turf)) //not in hands
		return Attach(C)

/obj/item/clothing/mask/facehugger/on_found(mob/finder)
	if(stat == CONSCIOUS)
		return HasProximity(finder)
	return FALSE

/obj/item/clothing/mask/facehugger/throw_at(atom/target, range, speed, mob/thrower, spin, diagonals_first = FALSE, datum/callback/callback)
	if(!..())
		return
	if(stat == CONSCIOUS)
		icon_state = "[initial(icon_state)]_thrown"
		addtimer(CALLBACK(src, PROC_REF(set_active_icon_state)), 15)

/obj/item/clothing/mask/facehugger/proc/set_active_icon_state()
	if(icon_state == "[initial(icon_state)]_thrown")
		icon_state = "[initial(icon_state)]"

/obj/item/clothing/mask/facehugger/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(..())
		return
	if(stat == CONSCIOUS)
		icon_state = "[initial(icon_state)]"
		Attach(hit_atom)

/obj/item/clothing/mask/facehugger/proc/CanHug(mob/living/carbon/C, check = 1)
	if(!iscarbon(C)) //without this check, we will get a runtime because in C there will be a turf when throwing a facehugger
		return FALSE
	if(!C.is_facehuggable() || stat || istype(C.wear_mask, src) || loc == C)
		return FALSE
	if(check)
		if(isturf(src.loc))
			if(!(C in view(1, src)))
				return FALSE
	return TRUE

/obj/item/clothing/mask/facehugger/proc/mouth_is_protected(obj/item/clothing/I)
	if(istype(I, /obj/item/clothing/head))
		if((I.flags & HEADCOVERSMOUTH) || (I.flags_inv & HIDEMASK))
			return TRUE
	if(istype(I, /obj/item/clothing/mask))
		if(I.flags & MASKCOVERSMOUTH)
			return TRUE
	return FALSE

/obj/item/clothing/mask/facehugger/proc/unequip_head(obj/item/clothing/I, mob/living/carbon/C)
	var/obj/item/clothing/head/helmet/space/rig/R = I
	if(istype(R) && !R.canremove)	//if the helmet is attached to the rig, facehugger will not be able to remove it
		R.canremove = TRUE
	if(C.unEquip(I))
		return TRUE
	return FALSE

/obj/item/clothing/mask/facehugger/proc/Attach(mob/living/carbon/C)
	if(!CanHug(C, FALSE))
		return

	C.visible_message("<span class='danger'>[src] leaps at [C]'s face!</span>", "<span class='userdanger'>[src] leaps at [C]'s face!</span>")

	var/target_head = C.head
	var/target_mask = C.wear_mask
	var/fail_rip_off = FALSE
	if(target_head && mouth_is_protected(target_head))
		if(prob(50) && unequip_head(target_head, C))
			C.visible_message("<span class='danger'>[src] rips off [C]'s [target_head]!</span>", "<span class='userdanger'>[src] rips off your [target_head]!</span>")
			if(!current_hugger && target_mask) //ai can rip off only one layer
				fail_rip_off = TRUE
		else
			C.visible_message("<span class='danger'>[src] fail to rips off [C]'s [target_head]!</span>", "<span class='userdanger'>[src] fail to rips off your [target_head]!</span>")
			fail_rip_off = TRUE
	if(target_mask && mouth_is_protected(target_mask) && !fail_rip_off)
		if(prob(50) && C.unEquip(target_mask))
			C.visible_message("<span class='danger'>[src] rips off [C]'s [target_mask]!</span>", "<span class='userdanger'>[src] rips off your [target_mask]!</span>")
			target_mask = null
		else
			C.visible_message("<span class='danger'>[src] fail to rips off [C]'s [target_mask]!</span>", "<span class='userdanger'>[src] fail to rips off your [target_mask]!</span>")
			fail_rip_off = TRUE
	if(fail_rip_off)
		if(current_hugger) // the playable facehugger can't rip the helmet or mask and dies
			var/mob/living/carbon/xenomorph/facehugger/FH = current_hugger
			to_chat(FH, "<span class='danger'>You died while trying to impregnate [C]</span>!")
			FH.ghostize(can_reenter_corpse = FALSE)
			Die()
			qdel(current_hugger)
			return FALSE
		else // facehugger with ai
			Die()
			return FALSE

	STOP_PROCESSING(SSobj, src)
	if(target_mask)
		C.drop_from_inventory(target_mask)
	if(!C.equip_to_slot_if_possible(src, SLOT_WEAR_MASK, disable_warning = TRUE))
		CRASH("can't equip [src] on [C]. [C]'s have [C.head] in head and [C.wear_mask] in mask")

	if(!sterile)
		C.Paralyse(MAX_IMPREGNATION_TIME / 8) //something like 30 seconds

	GoIdle() //so it doesn't jump the people that tear it off
	if(!current_hugger)
		addtimer(CALLBACK(src, PROC_REF(Impregnate), C), rand(MIN_IMPREGNATION_TIME, MAX_IMPREGNATION_TIME))

	return TRUE

/obj/item/clothing/mask/facehugger/proc/Impregnate(mob/living/carbon/target, mob/living/carbon/xenomorph/facehugger/FH)
	if(!target || target.stat == DEAD) //was taken off or something
		return

	if(iscarbon(target))
		var/mob/living/carbon/C = target
		if(C.wear_mask != src)
			return

	if(!sterile)
		target.visible_message("<span class='danger'>[src] falls limp after violating [target]'s face!</span>")
		Die()
		icon_state = "[initial(icon_state)]_impregnated"
		var/obj/item/alien_embryo/new_embryo = new /obj/item/alien_embryo(target)
		if(current_hugger)
			var/mob/living/carbon/xenomorph/larva/new_xeno = new /mob/living/carbon/xenomorph/larva(new_embryo)
			new_xeno.loc = new_embryo
			new_embryo.baby = new_xeno
			new_embryo.controlled_by_ai = FALSE
			new_xeno.key = FH.key
			qdel(current_hugger)
		target.unEquip(src)
		target.add_status_flags(XENO_HOST)
		target.med_hud_set_status()

	else
		target.visible_message("<span class='danger'>[src] violates [target]'s face!</span>", "<span class='userdanger'>[src] violates your face!</span>")

/obj/item/clothing/mask/facehugger/proc/GoActive()
	if(stat == DEAD || stat == CONSCIOUS)
		return

	stat = CONSCIOUS
	icon_state = "[initial(icon_state)]"

/obj/item/clothing/mask/facehugger/proc/GoIdle()
	if(stat == DEAD || stat == UNCONSCIOUS)
		return

	stat = UNCONSCIOUS
	icon_state = "[initial(icon_state)]_inactive"

	addtimer(CALLBACK(src, PROC_REF(GoActive)), rand(MIN_ACTIVE_TIME, MAX_ACTIVE_TIME))

/obj/item/clothing/mask/facehugger/proc/Die()
	if(stat == DEAD)
		return

	icon_state = "[initial(icon_state)]_dead"
	stat = DEAD
	STOP_PROCESSING(SSobj, src)

	playsound(src, 'sound/voice/xenomorph/facehugger_dies.ogg', VOL_EFFECTS_MASTER)
	visible_message("<span class='warning'>[src] curls up into a ball and exudes a strange substance!</span>")
	for(var/mob/living/carbon/human/H in view(1, src))
		if(!mouth_is_protected())
			H.invoke_vomit_async()

/obj/item/clothing/mask/facehugger/verb/hide_fh()
	set name = "Спрятать"
	set src in oview(1)
	set category = null

	if(usr.stat != CONSCIOUS)
		return

	if(!isxenoadult(usr))
		to_chat(usr, "<span class='notice'>[src] не реагирует.</span>")
		return

	if (layer != TURF_LAYER+0.2)
		layer = TURF_LAYER+0.2
		visible_message("<span class='danger'>[src] исчезает.</span>")
	else
		layer = MOB_LAYER
		visible_message("<span class='danger'>[src] появляется.</span>")

#undef MIN_ACTIVE_TIME
#undef MAX_ACTIVE_TIME
