#define MIN_ACTIVE_TIME 100 //time between being dropped and going idle
#define MAX_ACTIVE_TIME 200

/obj/item/clothing/mask/facehugger
	name = "alien"
	desc = "It has some sort of a tube at the end of its tail."
	icon = 'icons/mob/alien.dmi'
	icon_state = "facehugger"
	item_state = "facehugger"
	density = 1
	layer = ABOVE_WINDOW_LAYER
	flags = MASKCOVERSMOUTH | MASKCOVERSEYES
	body_parts_covered = FACE|EYES
	throw_range = 1

	var/stat = CONSCIOUS //UNCONSCIOUS is the idle state in this case
	var/sterile = 0
	var/strength = 5
	var/current_hugger
	var/mob/living/carbon/target = null
	var/chase_time = 0

/obj/item/clothing/mask/facehugger/atom_init()
	..()
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
	if(stat)
		return
	if(isturf(loc))
		if(!target)
			for(var/mob/living/carbon/C in range(7, src))
				var/obj/effect/vision/V = new /obj/effect/vision(get_turf(src))
				V.target = C
				if(V.check())
					qdel(V)
					if(CanHug(C, 0))
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
		else if(stat)
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
		if(stat == DEAD && isxeno(user))
			if(do_after(user, 20, target = src))
				to_chat(user, "You ate a facehugger.")
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

/obj/item/clothing/mask/facehugger/bullet_act(obj/item/projectile/P)
	if(P.damage)
		Die()
	return

/obj/item/clothing/mask/facehugger/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		Die()
	return

/obj/item/clothing/mask/facehugger/equipped(mob/living/carbon/C)
	Attach(C)

/obj/item/clothing/mask/facehugger/Crossed(atom/movable/AM)
	..()
	return HasProximity(AM)

/obj/item/clothing/mask/facehugger/HasProximity(mob/living/carbon/C)
	if(!current_hugger)
		return Attach(C)

/obj/item/clothing/mask/facehugger/on_found(mob/finder)
	if(stat == CONSCIOUS)
		return HasProximity(finder)
	return FALSE
/*
/obj/item/clothing/mask/facehugger/proc/show_messageold(message, m_type)
	if(current_hugger)
		var/mob/living/carbon/xenomorph/facehugger/FH = current_hugger
		FH.show_message(message,m_type)*/

/obj/item/clothing/mask/facehugger/throw_at(atom/target, range, speed, mob/thrower, spin, diagonals_first = FALSE, datum/callback/callback)
	if(!..())
		return
	if(stat == CONSCIOUS)
		icon_state = "[initial(icon_state)]_thrown"
		addtimer(CALLBACK(src, .proc/set_active_icon_state), 15)

/obj/item/clothing/mask/facehugger/proc/set_active_icon_state()
	if(icon_state == "[initial(icon_state)]_thrown")
		icon_state = "[initial(icon_state)]"

/obj/item/clothing/mask/facehugger/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	..()
	if(stat == CONSCIOUS)
		icon_state = "[initial(icon_state)]"
		Attach(hit_atom)

/obj/item/clothing/mask/facehugger/proc/CanHug(mob/living/carbon/C, check = 1)
	if(!C.is_facehuggable() || stat || istype(C.wear_mask, src) || loc == C)
		return FALSE
	if(check)
		if(isturf(src.loc))
			if(!(C in view(1, src)))
				return FALSE
	return TRUE

/mob/living/carbon/human/proc/mouth_is_protected()
	if(istype(head, /obj/item/clothing/head))
		if(head.flags & HEADCOVERSMOUTH)
			return head
	else if(istype(wear_mask, /obj/item/clothing/mask))
		if(wear_mask.flags & MASKCOVERSMOUTH)
			return wear_mask
	return FALSE

/obj/item/clothing/mask/facehugger/proc/Attach(mob/living/carbon/C)
	if(!CanHug(C, FALSE))
		return

	C.visible_message("<span class='danger'>[src] leaps at [C]'s face!</span>", "<span class='userdanger'>[src] leaps at [C]'s face!</span>")

	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		var/headgear = H.mouth_is_protected()
		if(headgear)
			if(current_hugger) // playable facehugger
				if(prob(50)) // the playable facehugger successfully rips off the helmet and infects the victim
					H.visible_message("<span class='danger'>[src] smashes against [H]'s [headgear], and rips it off in the process!</span>", "<span class='userdanger'>[src] smashes against yours [headgear], and rips it off in the process!</span>")
					H.unEquip(headgear)
				else // the playable facehugger can't rip the helmet and dies
					H.visible_message("<span class='danger'>[src] smashes against [H]'s [headgear], and fails to rip it off!</span>", "<span class='userdanger'>[src] smashes against yours's [headgear], and fails to rip it off!</span>")
					var/mob/living/carbon/xenomorph/facehugger/FH = current_hugger
					to_chat(FH, "<span class='danger'>You died while trying to remove [H]'s [headgear]</span>!")
					FH.ghostize(can_reenter_corpse = FALSE)
					Die()
					qdel(current_hugger)
					return FALSE
			else // facehugger with ai
				if(prob(40))
					H.visible_message("<span class='danger'>[src] smashes against [H]'s [headgear], and rips it off in the process!</span>", "<span class='userdanger'>[src] smashes against yours [headgear], and rips it off in the process!</span>")
					H.unEquip(headgear)
				else
					H.visible_message("<span class='danger'>[src] smashes against [H]'s [headgear], and fails to rip it off!</span>", "<span class='userdanger'>[src] smashes against yours's [headgear], and fails to rip it off!</span>")
				if(prob(33))
					H.visible_message("<span class='danger'>[H]'s [headgear] melts from the acid!</span>", "<span class='userdanger'>Your [headgear] melts from the acid!</span>")
					qdel(headgear)
				if(prob(66))
					Die()
				else
					H.visible_message("<span class='danger'>[src] bounces off of the [headgear]!</span>", "<span class='userdanger'>[src] bounces off of the [headgear]!</span>")
					GoIdle()
				return FALSE
	else
		if(C.wear_mask)
			if(prob(20))
				return FALSE
			var/obj/item/clothing/mask/WM = target.wear_mask
			if(WM.flags & NODROP)
				return FALSE
			target.unEquip(WM)
			target.visible_message("<span class='danger'>[src] tears [WM] off of [C]'s face!</span>", "<span class='userdanger'>[src] tears [WM] off of [C]'s face!</span>")
	STOP_PROCESSING(SSobj, src)
	C.equip_to_slot_if_possible(src, SLOT_WEAR_MASK, disable_warning = TRUE)

	if(!sterile)
		C.Paralyse(MAX_IMPREGNATION_TIME / 8) //something like 30 seconds

	GoIdle() //so it doesn't jump the people that tear it off
	//if(!sterile)
	//	src.flags |= NODROP
	if(!current_hugger)
		addtimer(CALLBACK(src, .proc/Impregnate, C), rand(MIN_IMPREGNATION_TIME, MAX_IMPREGNATION_TIME))

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
		target.unEquip(src)
		Die()
		icon_state = "[initial(icon_state)]_impregnated"
		var/obj/item/alien_embryo/new_embryo = new /obj/item/alien_embryo(target)
		if(current_hugger)
			var/mob/living/carbon/xenomorph/larva/new_xeno = new /mob/living/carbon/xenomorph/larva(new_embryo)
			new_xeno.loc = new_embryo
			new_embryo.baby = new_xeno
			new_embryo.controlled_by_ai = FALSE
			new_xeno.key = FH.key
		target.status_flags |= XENO_HOST

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

	addtimer(CALLBACK(src, .proc/GoActive), rand(MIN_ACTIVE_TIME, MAX_ACTIVE_TIME))

/obj/item/clothing/mask/facehugger/proc/Die()
	if(stat == DEAD)
		return

	icon_state = "[initial(icon_state)]_dead"
	stat = DEAD
	STOP_PROCESSING(SSobj, src)

	visible_message("<span class='warning'>[src] curls up into a ball!</span>")

	return

#undef MIN_ACTIVE_TIME
#undef MAX_ACTIVE_TIME
