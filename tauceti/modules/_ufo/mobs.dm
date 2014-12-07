/mob/living/simple_animal/hostile/chryssalid
	name = "Chryssalid"
	desc = "Alien monster from worst nightmares"
	icon = 'tauceti/modules/_ufo/mobs.dmi'
	icon_state = "chrys"
	icon_living = "chrys"
	icon_dead = "chrys_dead"
	speak_chance = 0
	turns_per_move = 5
	response_help = "pokes the"
	response_disarm = "shoves the"
	response_harm = "hits the"
	speed = -1
	stop_automated_movement_when_pulled = 0
	maxHealth = 300
	health = 300
	harm_intent_damage = 5
	melee_damage_lower = 15
	melee_damage_upper = 20
	attacktext = "claws"
	a_intent = "harm"
	min_oxy = 5
	max_oxy = 0
	min_tox = 0
	max_tox = 1
	min_co2 = 0
	max_co2 = 5
	min_n2 = 0
	max_n2 = 0
	unsuitable_atoms_damage = 15
	faction = "alien"
	status_flags = CANPUSH
	var/stabing = 0
	var/embryons = 10

/mob/living/simple_animal/hostile/chryssalid/verb/impregnate(mob/living/carbon/human/M as mob)
	set name = "Impregnate"
	set desc = "Lays an egg in human body."
	set category = "Alium"
	set src = view(1)
	if(stat)
		return
	if(embryons == 0)
		return
	if(stabing)
		return
	if(!M)
		return
	if(M.stat == DEAD)
		return
	if(!istype(M, /mob/living/carbon/human))
		return
	if(get_dist(src, M) > 1)
		return
	if(locate(/obj/item/alien_embryo) in M.contents)
		src << "[M] already impregnated"
		return

	stabing = 1
	for(var/stage = 1, stage<=3, stage++)
		switch(stage)
			if(1)
				src << "<span class='notice'>This creature is compatible. You must hold still...</span>"
			if(2)
				src << "<span class='notice'>You extend a proboscis.</span>"
				src.visible_message("<span class='warning'>[src] extends a proboscis!</span>")
			if(3)
				src << "<span class='notice'>You stab [M] with the proboscis.</span>"
				src.visible_message("<span class='danger'>[src] stabs [M] with the proboscis!</span>")
				M << "<span class='danger'>You feel a sharp stabbing pain!</span>"
				var/datum/organ/external/affecting = M.get_organ("groin")
				if(affecting.take_damage(10,0,1,0,"large organic needle"))
					M:UpdateDamageIcon()
					continue

		if (!do_mob(usr, M, 50))
			usr << "\red The injection of the embryo has been interrupted!"
			stabing = 0
			return

	src << "<span class='notice'>Impregnation successful!</span>"
	src.visible_message("<span class='danger'>[src] injects [M] with an egg.!</span>")
	M << "<span class='danger'>You have been impregnated by the [src]!</span>"
	src.embryons--

	new /obj/item/alien_embryo/chryssalid(M)
	M.status_flags |= XENO_HOST
	M.reagents.add_reagent("tramadol", 15)
	M.reagents.add_reagent("mindbreaker", 15)
	M.reagents.add_reagent("bicaridine", 15)
	stabing = 0
	return

/obj/item/alien_embryo/chryssalid
	name = "chryssalid embryo"
	desc = "All slimy and yuck."
	icon = 'icons/mob/alien.dmi'
	icon_state = "larva0_dead"
	//mob/living/affected_mob
//	var/stage = 0

/obj/item/alien_embryo/chryssalid/New()
	if(istype(loc, /mob/living))
		affected_mob = loc
		processing_objects.Add(src)
		spawn(0)
			AddInfectionImages(affected_mob)
	else
		del(src)

/obj/item/alien_embryo/chryssalid/Del()
	if(affected_mob)
		affected_mob.status_flags &= ~(XENO_HOST)
		spawn(0)
			RemoveInfectionImages(affected_mob)
	..()

/obj/item/alien_embryo/chryssalid/process()
	if(!affected_mob)	return
	if(loc != affected_mob)
		affected_mob.status_flags &= ~(XENO_HOST)
		processing_objects.Remove(src)
		spawn(0)
			RemoveInfectionImages(affected_mob)
			affected_mob = null
		return

	if(stage < 5 && prob(3))
		stage++
		spawn(0)
			RefreshInfectionImage(affected_mob)

	switch(stage)
		if(2, 3)
			if(prob(1))
				affected_mob.emote("groan")
			if(prob(1))
				affected_mob.emote("drools")
			if(prob(1))
				affected_mob << "\red “ы чувствуешь, что теряешь контроль над собой."
				affected_mob.reagents.add_reagent("mindbreaker", 15)
			if(prob(1))
				affected_mob << "\red Mucous runs down the back of your throat."
			if(prob(1))
				affected_mob.reagents.add_reagent("synaptizine", 5)

		if(4)
			if(prob(1))
				affected_mob.emote("groan")
			if(prob(1))
				affected_mob.emote("drools")
			if(prob(2))
				affected_mob << "\red “воя голова раскалывается от боли."
				if(prob(20))
					affected_mob.adjustBrainLoss(20)
					affected_mob.updatehealth()
			if(prob(2))
				affected_mob << "\red Your stomach hurts."
				if(prob(20))
					affected_mob.adjustToxLoss(1)
					affected_mob.reagents.add_reagent("synaptizine", 5)
					affected_mob.updatehealth()
		if(5)
			affected_mob << "\red You feel something tearing its way out of you..."
			affected_mob.adjustToxLoss(10)
			affected_mob.updatehealth()
			if(prob(50))
				AttemptGrow()

/obj/item/alien_embryo/chryssalid/AttemptGrow(var/gib_on_success = 1)
	var/list/candidates = get_alien_candidates()
	var/picked = null

	// To stop clientless larva, we will check that our host has a client
	// if we find no ghosts to become the alien. If the host has a client
	// he will become the alien but if he doesn't then we will set the stage
	// to 2, so we don't do a process heavy check everytime.

	if(candidates.len)
		picked = pick(candidates)
	else if(affected_mob.client)
		picked = affected_mob.key
	else
		stage = 4 // Let's try again later.
		return

/*	if(affected_mob.lying)
		affected_mob.overlays += image('icons/mob/alien.dmi', loc = affected_mob, icon_state = "burst_lie")
	else
		affected_mob.overlays += image('icons/mob/alien.dmi', loc = affected_mob, icon_state = "burst_stand") */
	spawn(6)
		var/mob/living/simple_animal/hostile/chryssalid/new_xeno = new(affected_mob.loc)
		new_xeno.key = picked
		new_xeno << sound('sound/voice/hiss5.ogg',0,0,0,100)	//To get the player's attention
		if(gib_on_success)
			affected_mob.gib()
		del(src)

/*----------------------------------------
Proc: RefreshInfectionImage()
Des: Removes all infection images from aliens and places an infection image on all infected mobs for aliens.
----------------------------------------*/
/obj/item/alien_embryo/chryssalid/RefreshInfectionImage()
	for(var/mob/living/simple_animal/hostile/chryssalid/alien in world)
		if(alien.client)
			for(var/image/I in alien.client.images)
				if(dd_hasprefix_case(I.icon_state, "infected"))
					del(I)
			for(var/mob/living/L in mob_list)
				if(iscorgi(L) || iscarbon(L))
					if(L.status_flags & XENO_HOST)
						var/I = image('icons/mob/alien.dmi', loc = L, icon_state = "infected[stage]")
						alien.client.images += I

/*----------------------------------------
Proc: AddInfectionImages(C)
Des: Checks if the passed mob (C) is infected with the alien egg, then gives each alien client an infected image at C.
----------------------------------------*/
/obj/item/alien_embryo/chryssalid/AddInfectionImages(var/mob/living/C)
	if(C)
		for(var/mob/living/simple_animal/hostile/chryssalid/alien in world)
			if(alien.client)
				if(C.status_flags & XENO_HOST)
					var/I = image('icons/mob/alien.dmi', loc = C, icon_state = "infected[stage]")
					alien.client.images += I

/*----------------------------------------
Proc: RemoveInfectionImage(C)
Des: Removes the alien infection image from all aliens in the world located in passed mob (C).
----------------------------------------*/

/obj/item/alien_embryo/chryssalid/RemoveInfectionImages(var/mob/living/C)
	if(C)
		for(var/mob/living/simple_animal/hostile/chryssalid/alien in world)
			if(alien.client)
				for(var/image/I in alien.client.images)
					if(I.loc == C)
						if(dd_hasprefix_case(I.icon_state, "infected"))
							del(I)