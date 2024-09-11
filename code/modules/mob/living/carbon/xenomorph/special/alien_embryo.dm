/*----------------------------------------
This is emryo growth procs
----------------------------------------*/

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
	if(affected_mob)
		affected_mob.remove_status_flags(XENO_HOST)
		STOP_PROCESSING(SSobj, src)
		remove_infected_hud()
		affected_mob.med_hud_set_status()
	if(baby)
		baby.clear_alert("alien_embryo")
	affected_mob = null
	baby = null
	return ..()

/obj/item/alien_embryo/process()
	if(!affected_mob) // The mob we were gestating in is straight up gone, we shouldn't be here
		STOP_PROCESSING(SSobj, src)
		qdel(src)
		return FALSE

	if(!controlled_by_ai)
		if(istype(loc, /turf) || !(contents.len))
			if(baby)
				var/atom/movable/mob_container
				mob_container = baby
				mob_container.forceMove(get_turf(affected_mob))
				baby.reset_view()
			qdel(src)
			return FALSE

	if(loc != affected_mob)
		affected_mob.remove_status_flags(XENO_HOST)
		STOP_PROCESSING(SSobj, src)
		remove_infected_hud()
		affected_mob.med_hud_set_status()
		affected_mob = null
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
		var/list/candidates = pollGhostCandidates("Would you like to be \a larva", ROLE_ALIEN, IGNORE_LARVA)

		var/client/larva_candidate
		if(candidates.len)
			var/mob/candidate = pick(candidates)
			larva_candidate = candidate.key
		else if(affected_mob.client)
			if((ROLE_ALIEN in affected_mob.client.prefs.be_role) && !jobban_isbanned(affected_mob.client, ROLE_ALIEN))
				larva_candidate = affected_mob.key

		if(!larva_candidate)
			stage = 4 // mission failed we'll get em next time
			growth_counter -= MAX_EMBRYO_GROWTH
			next_growth_limit -= MAX_EMBRYO_GROWTH
			START_PROCESSING(SSobj, src)
			return

		affected_mob.death()
		if(ishuman(affected_mob)) // we're fucked. no chance to revive a person
			var/mob/living/carbon/human/H = affected_mob
			H.apply_damage(rand(150, 250), BRUTE, BP_CHEST)
			H.adjustToxLoss(rand(180, 200)) // Bad but effective solution.
			H.organs_by_name[O_HEART].damage = rand(50, 100)
			H.rupture_lung()
		var/mob/living/carbon/xenomorph/larva/new_xeno = new /mob/living/carbon/xenomorph/larva(get_turf(affected_mob))
		new_xeno.key = larva_candidate
		new_xeno.update_icons()
		playsound(new_xeno, pick(SOUNDIN_XENOMORPH_CHESTBURST), VOL_EFFECTS_MASTER, vary = FALSE, frequency = null, ignore_environment = TRUE) // To get the player's attention

		affected_mob.visible_message("<span class='userdanger'>[new_xeno] crawls out of [affected_mob]!</span>")
		affected_mob.add_overlay(image('icons/mob/alien.dmi', loc = affected_mob, icon_state = "bursted_stand"))
		qdel(src)
	else
		if(baby)
			STOP_PROCESSING(SSobj, src)
			var/atom/movable/mob_container
			mob_container = baby
			mob_container.forceMove(affected_mob)
			baby.reset_view()
			baby.SetSleeping(0)
			var/obj/item/weapon/larva_bite/G = new /obj/item/weapon/larva_bite(baby, src.loc)
			baby.put_in_active_hand(G)
			G.last_bite = world.time - 20
			G.synch()
			qdel(src)

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
