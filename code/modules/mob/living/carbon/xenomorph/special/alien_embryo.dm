/*----------------------------------------
This is emryo growth procs
----------------------------------------*/

/mob/living/proc/on_larva_erupt(mob/living/larva)
	visible_message("<span class='userdanger'>[larva] crawls out of [src]!</span>")
	add_overlay(image('icons/mob/alien.dmi', loc = src, icon_state = "bursted_stand"))
	playsound(src, pick(SOUNDIN_XENOMORPH_CHESTBURST), VOL_EFFECTS_MASTER, vary = FALSE, frequency = null, ignore_environment = TRUE)
	death()

/mob/living/carbon/human/on_larva_erupt(mob/living/larva)
	rupture_heart()
	rupture_lung()
	. = ..()
	apply_damage(rand(150, 250), BRUTE, BP_CHEST)

/mob/living/proc/on_larva_kick(stage)
	switch(stage)
		if(2)
			visible_message("<span class='warning'>[src]'s stomach growls loudly.</span>")
			to_chat(src, "<span class='warning'>You feel a strange movement inside you.</span>")
		if(3)
			visible_message("<span class='danger'>[src] clutches their stomach in pain!</span>")
			to_chat(src, "<span class='danger'>Something kicks inside your chest!</span>")
			adjustBruteLoss(rand(10, 15))
			Stun(2)
			emote("scream")
			step_rand(src)
		if(4)
			visible_message("<span class='userdanger'>[src] convulses and collapses!</span>")
			to_chat(src, "<span class='userdanger'>Something is thrashing violently inside you!</span>")
			adjustBruteLoss(rand(20, 30))
			Paralyse(4)
			Weaken(4)
			emote("scream")
			make_jittery(50)
			step_rand(src)

/mob/living/proc/on_larva_bite(bite_count)
	adjustBruteLoss(rand(35, 65))
	playsound(src, 'sound/weapons/bite.ogg', VOL_EFFECTS_MASTER)
	Stun(8)
	Weaken(8)

/mob/living/carbon/human/on_larva_bite(bite_count)
	apply_damage(rand(7, 14), BRUTE, BP_CHEST)
	adjustHalLoss(20)
	playsound(src, 'sound/weapons/bite.ogg', VOL_EFFECTS_MASTER)
	Stun(1)
	Weaken(1)
	emote("scream")

/obj/item/alien_embryo
	name = "alien embryo"
	desc = "All slimy and yuck."
	icon = 'icons/mob/alien.dmi'
	icon_state = "larva0_dead"
	var/mob/living/affected_mob
	var/mob/living/baby
	var/controlled_by_ai = TRUE
	var/growth_counter = 0
	var/stage = 0
	var/next_growth_limit = MAX_EMBRYO_GROWTH
	COOLDOWN_DECLARE(next_kick)
	var/bite_count = 0
	var/datum/weakref/kick_action_ref

/obj/item/alien_embryo/atom_init()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/item/alien_embryo/atom_init_late()
	if(iscarbon(loc))
		affected_mob = loc
		START_PROCESSING(SSobj, src)
		add_infected_hud()
	else
		qdel(src)

/obj/item/alien_embryo/Destroy()
	detach_from_host()
	if(baby)
		baby.clear_alert("alien_embryo")
	var/datum/action/embryo_kick/kick_action = kick_action_ref?.resolve()
	if(kick_action)
		qdel(kick_action)
	kick_action_ref = null
	baby = null
	return ..()

/obj/item/alien_embryo/proc/detach_from_host()
	if(!affected_mob)
		return
	affected_mob.remove_status_flags(XENO_HOST)
	STOP_PROCESSING(SSobj, src)
	remove_infected_hud()
	affected_mob.med_hud_set_status()
	affected_mob = null

/obj/item/alien_embryo/process()
	if(!affected_mob) // The mob we were gestating in is straight up gone, we shouldn't be here
		STOP_PROCESSING(SSobj, src)
		qdel(src)
		return FALSE

	if(!controlled_by_ai)
		if(istype(loc, /turf) || !(contents.len))
			if(baby)
				baby.forceMove(get_turf(affected_mob))
				baby.reset_view()
			qdel(src)
			return FALSE

	if(loc != affected_mob)
		detach_from_host()
		return FALSE

	if(stage < MAX_EMBRYO_STAGE)
		if(affected_mob.stat == DEAD)
			if(stage < 4)
				if(!controlled_by_ai)
					to_chat(baby, "<span class='userdanger'> Your host died, so and you.</span>")
					baby.death()
					if(baby.key)
						baby.ghostize(can_reenter_corpse = FALSE, bancheck = TRUE)
				qdel(src)
				return
		if(growth_counter >= next_growth_limit)
			stage++
			next_growth_limit += MAX_EMBRYO_GROWTH
			add_infected_hud()
//increase the growth rate if the host is buckled to the alien nest
	var/growth_rate = 1
	if(affected_mob.buckled && istype(affected_mob.buckled, /obj/structure/stool/bed/nest))
		growth_rate = 3

	if(baby && baby.client)
		if(growth_rate == 1)
			baby.throw_alert("alien_embryo", /atom/movable/screen/alert/alien_embryo)
		else
			baby.clear_alert("alien_embryo")

	var/diff = FULL_EMBRYO_GROWTH - growth_counter
	if(diff < growth_rate)
		growth_counter += diff	//so as not to go beyond the growth counter
	else
		growth_counter += growth_rate

	switch(stage)
		if(2)
			if(prob(2))
				to_chat(affected_mob, "<span class='warning'>[pick("Your chest hurts a little bit", "Your stomach hurts")].</span>")
		if(3)
			if(prob(2))
				to_chat(affected_mob, "<span class='warning'>[pick("Your throat feels sore", "Mucous runs down the back of your throat")].</span>")
			else if(prob(1))
				to_chat(affected_mob, "<span class='warning'>Your muscles ache.</span>")
			else if(prob(2))
				affected_mob.emote(pick("sneeze", "cough"))
		if(4)
			if(prob(1))
				if(affected_mob.stat == CONSCIOUS)
					affected_mob.visible_message("<span class='danger'>\The [affected_mob] starts shaking uncontrollably!</span>", \
                                                 "<span class='danger'>You start shaking uncontrollably!</span>")
					affected_mob.Paralyse(10)
					affected_mob.make_jittery(110)
			if(prob(2))
				to_chat(affected_mob, "<span class='warning'>[pick("Your chest hurts badly", "It becomes difficult to breathe", "Your heart starts beating rapidly, and each beat is painful")].</span>")
			if(prob(33))
				affected_mob.adjustToxLoss(2)
		if(5)
			to_chat(affected_mob, "<span class='danger'>You feel something tearing its way out of your stomach...</span>")
			affected_mob.updatehealth()
			if(controlled_by_ai)
				if(prob(70))
					if(ishuman(affected_mob))
						var/mob/living/carbon/human/H = affected_mob
						H.apply_damage(rand(20, 30), BRUTE, BP_CHEST)
						H.emote("scream")
					else
						affected_mob.adjustBruteLoss(15)
			AttemptGrow()

/obj/item/alien_embryo/proc/AttemptGrow()
	if(controlled_by_ai)
		if(!affected_mob)
			return
		STOP_PROCESSING(SSobj, src)
		// To stop clientless larva, we will check that our host has a client
		// if we find no ghosts to become the alien. If the host has a client
		// he will become the alien but if he doesn't then we will set the stage
		// to 4, so we don't do a process heavy check everytime.
		var/list/candidates = pollGhostCandidates("Would you like to be a larva", ROLE_ALIEN, IGNORE_LARVA)

		var/client/larva_candidate
		if(candidates.len)
			var/mob/candidate = pick(candidates)
			larva_candidate = candidate.key
		else if(affected_mob.client)
			if((ROLE_ALIEN in affected_mob.client.prefs.be_role) && !jobban_isbanned(affected_mob.client, ROLE_ALIEN))
				larva_candidate = affected_mob.key

		if(!larva_candidate)
			rewind_failed_burst()
			return

		var/mob/living/carbon/xenomorph/larva/new_xeno = new /mob/living/carbon/xenomorph/larva(get_turf(affected_mob))
		new_xeno.key = larva_candidate
		new_xeno.update_icons()
		affected_mob.on_larva_erupt(new_xeno)
		qdel(src)
	else
		if(baby)
			STOP_PROCESSING(SSobj, src)
			baby.forceMove(affected_mob)
			baby.reset_view()

//only aliens will see this HUD
/obj/item/alien_embryo/proc/add_infected_hud()
	var/datum/atom_hud/hud = global.huds[DATA_HUD_EMBRYO]
	hud.add_to_hud(affected_mob)
	var/image/holder = affected_mob.hud_list[ALIEN_EMBRYO_HUD]
	holder.icon_state = "infected[stage]"

/obj/item/alien_embryo/proc/remove_infected_hud()
	var/datum/atom_hud/hud = global.huds[DATA_HUD_EMBRYO]
	hud.remove_hud_from(affected_mob)
	var/image/holder = affected_mob.hud_list[ALIEN_EMBRYO_HUD]
	holder.icon_state = null

// Rolls embryo back from stage 5 to stage 4 when no larva candidate is available.
/obj/item/alien_embryo/proc/rewind_failed_burst()
	stage = 4 // mission failed we'll get em next time
	growth_counter -= MAX_EMBRYO_GROWTH
	next_growth_limit -= MAX_EMBRYO_GROWTH
	START_PROCESSING(SSobj, src)

/obj/item/alien_embryo/proc/kick()
	if(!affected_mob)
		return
	if(!baby)
		return
	if(!baby.client)
		return
	if(stage < 2)
		to_chat(baby, "<span class='warning'>You are too small to do anything yet.</span>")
		return
	if(!COOLDOWN_FINISHED(src, next_kick))
		to_chat(baby, "<span class='warning'>You need to rest before kicking again.</span>")
		return
	if(stage < 5)
		COOLDOWN_START(src, next_kick, 1.5 SECONDS)
		affected_mob.on_larva_kick(stage)
		to_chat(baby, "<span class='notice'>You kick your host from the inside.</span>")
		return
	COOLDOWN_START(src, next_kick, 0.6 SECONDS)
	bite_count++
	affected_mob.on_larva_bite(bite_count)
	affected_mob.updatehealth()
	to_chat(baby, "<span class='warning'>You tear at your host's insides!</span>")
	var/chest_broken = FALSE
	if(ishuman(affected_mob))
		var/mob/living/carbon/human/H = affected_mob
		var/obj/item/organ/external/chest = H.bodyparts_by_name[BP_CHEST]
		if(chest && (chest.status & ORGAN_BROKEN))
			chest_broken = TRUE
	if(chest_broken || affected_mob.stat == DEAD || affected_mob.health <= 0 || bite_count >= 6)
		baby.forceMove(get_turf(affected_mob))
		baby.reset_view()
		if(bite_count >= 5)
			affected_mob.visible_message("<span class='userdanger'>[affected_mob]'s body bulges grotesquely before exploding!</span>")
			playsound(affected_mob, 'sound/effects/splat.ogg', VOL_EFFECTS_MASTER)
			affected_mob.gib()
		else
			affected_mob.on_larva_erupt(baby)
		if(!QDELETED(src))
			qdel(src)

/datum/action/embryo_kick
	name = "Kick Host"
	action_type = AB_ITEM
	button_icon = 'icons/hud/screen1_xeno.dmi'
	button_icon_state = "chest_burst"
	check_flags = 0

/datum/action/embryo_kick/Activate()
	if(QDELETED(target))
		return
	var/obj/item/alien_embryo/embryo = target
	embryo.kick()
