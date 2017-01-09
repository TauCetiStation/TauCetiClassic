#define UPGRADE_TAIL_TIMER	100

//Grab levels
/*
#define GRAB_PASSIVE	1
#define GRAB_AGGRESSIVE	2
#define GRAB_NECK		3
#define GRAB_UPGRADING	4
#define GRAB_KILL		5*/
#define GRAB_EMBRYO		6
#define GRAB_IMPREGNATE	7
#define GRAB_DONE		8

#define BITE_COOLDOWN 20

/*----------------------------------------
This is modified grab mechanic for facehugger
----------------------------------------*/
/mob/living/carbon/human/attack_facehugger(mob/living/carbon/alien/facehugger/FH)
	switch(FH.a_intent)
		if("grab")
			if(istype(src, /mob/living/carbon/human/machine))
				to_chat(FH, "You can't impregnate that!")
				return
			if(src.stat != DEAD)
				if(FH == src)
					return
				var/obj/item/weapon/fh_grab/G = new /obj/item/weapon/fh_grab(FH, src)

				FH.put_in_active_hand(G)

				grabbed_by += G
				G.last_upgrade = world.time - 20
				G.synch()
				LAssailant = FH

				visible_message(text("\red [] atempts to leap at [] face!", FH, src))
			else
				to_chat(FH, "\red looks dead.")

/mob/living/carbon/monkey/attack_facehugger(mob/living/carbon/alien/facehugger/FH)
	switch(FH.a_intent)
		if("grab")
			if(src.stat != DEAD)
				if(FH == src)
					return
				var/obj/item/weapon/fh_grab/G = new /obj/item/weapon/fh_grab(FH, src)

				FH.put_in_active_hand(G)

				grabbed_by += G
				G.last_upgrade = world.time - 20
				G.synch()
				LAssailant = FH

				visible_message(text("\red [] atempts to leap at [] face!", FH, src))
			else
				to_chat(FH, "\red looks dead.")

/mob/living/simple_animal/corgi/attack_facehugger(mob/living/carbon/alien/facehugger/FH)
	switch(FH.a_intent)
		if("grab")
			if(src.stat != DEAD)
				if(FH == src)
					return
				var/obj/item/weapon/fh_grab/G = new /obj/item/weapon/fh_grab(FH, src)

				FH.put_in_active_hand(G)

				grabbed_by += G
				G.last_upgrade = world.time - 20
				G.synch()
				LAssailant = FH

				visible_message(text("\red [] atempts to leap at [] face!", FH, src))
			else
				to_chat(FH, "\red looks dead.")

/*----------------------------------------
This is called when facehugger has grabbed(left click) and then
 used leap from hud action menu(the one that has left and right hand for anyone else).
----------------------------------------*/

/mob/living/carbon/alien/facehugger/proc/leap_at_face(mob/living/L)
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		var/obj/item/clothing/mask/facehugger/FH = new(loc)
		src.loc = FH
		FH.current_hugger = src
		FH.Attach(H)
		H.status_flags |= PASSEMOTES
		return
	else if(ismonkey(L))
		var/mob/living/carbon/monkey/M = L
		var/obj/item/clothing/mask/facehugger/FH = new(loc)
		src.loc = FH
		FH.current_hugger = src
		FH.Attach(M)
		M.status_flags |= PASSEMOTES
		return
	else if(iscorgi(L))
		var/mob/living/simple_animal/corgi/C = L
		var/obj/item/clothing/mask/facehugger/FH = new(loc)
		src.loc = FH
		FH.current_hugger = src
		FH.Attach(C)
		C.status_flags |= PASSEMOTES
		return

/*----------------------------------------
This is chestburster mechanic for damaging
 victim chest to get out from stomach
----------------------------------------*/
/obj/screen/larva_bite
	name = "larva_bite"

/obj/screen/larva_bite/Click()
	var/obj/item/weapon/larva_bite/G = master
	G.s_click(src)
	return 1

/obj/screen/larva_bite/attack_hand()
	return

/obj/screen/larva_bite/attackby()
	return

/obj/item/weapon/larva_bite
	name = "larva_bite"
	flags = NOBLUDGEON | ABSTRACT
	var/obj/screen/larva_bite/hud = null
	var/mob/affecting = null
	var/mob/chestburster = null
	var/state = null

	var/last_bite = 0

	layer = 21
	abstract = 1
	item_state = "nothing"
	w_class = 5.0


/obj/item/weapon/larva_bite/New(mob/user, mob/victim)
	..()
	loc = user
	chestburster = user
	affecting = victim

	hud = new /obj/screen/larva_bite(src)
	hud.icon = 'icons/mob/screen1_xeno.dmi'
	hud.icon_state = "chest_burst"
	hud.name = "Burst thru chest"
	hud.master = src

/obj/item/weapon/larva_bite/proc/throw_held()
	return null

/obj/item/weapon/larva_bite/proc/synch()
	if(affecting)
		if(chestburster.r_hand == src)
			hud.screen_loc = ui_rhand

/obj/item/weapon/larva_bite/process()
	confirm()

	if(chestburster.client)
		chestburster.client.screen -= hud
		chestburster.client.screen += hud

/obj/item/weapon/larva_bite/proc/s_click(obj/screen/S)
	if(!affecting)
		return
	if(!chestburster)
		return
	if(chestburster.next_move > world.time)
		return
	if(chestburster.lying)
		return
	if(world.time < (last_bite + BITE_COOLDOWN))
		return
	if(istype(chestburster.loc, /turf))
		qdel(src)
		return

	if(ishuman(affecting))
		var/mob/living/carbon/human/H = affecting
		var/datum/organ/external/chest/C = H.get_organ("chest")
		if(C.status & ORGAN_BROKEN)
			chestburster.loc = get_turf(H)
			chestburster.visible_message("<span class='danger'>[chestburster] bursts thru [H]'s chest!</span>")
			chestburster << sound('sound/voice/hiss5.ogg',0,0,0,100)
			if(H.key)
				H.death()
				H.ghostize(can_reenter_corpse = FALSE, bancheck = TRUE)
				C.open = 1
			else
				H.gib()
			qdel(src)
		else
			last_bite = world.time
			playsound(loc, 'sound/weapons/bite.ogg', 50, 1, -1)
			H.apply_damage(rand(7,14), BRUTE, "chest")
			H.shock_stage = 20
			H.Weaken(1)
			H.emote("scream",,, 1)
	else if(ismonkey(affecting))
		var/mob/living/carbon/monkey/M = affecting
		if(M.stat == DEAD)
			chestburster.loc = get_turf(M)
			chestburster.visible_message("<span class='danger'>[chestburster] bursts thru [M]'s butt!</span>")
			chestburster << sound('sound/voice/hiss5.ogg',0,0,0,100)
			qdel(src)
		else
			last_bite = world.time
			M.adjustBruteLoss(rand(35,65))
			playsound(loc, 'sound/weapons/bite.ogg', 50, 1, -1)
			M.Weaken(8)
	else if(iscorgi(affecting))
		var/mob/living/simple_animal/corgi/C = affecting
		if(C.stat == DEAD)
			chestburster.loc = get_turf(C)
			chestburster.visible_message("<span class='danger'>[chestburster] bursts thru [C]'s butt!</span>")
			chestburster << sound('sound/voice/hiss5.ogg',0,0,0,100)
			qdel(src)
		else
			last_bite = world.time
			C.health -= rand(5,10)
			playsound(loc, 'sound/weapons/bite.ogg', 50, 1, -1)

/obj/item/weapon/larva_bite/proc/confirm()
	if(!chestburster || !affecting)
		qdel(src)
		return 0

	if(affecting)
		if(istype(chestburster.loc, /mob/living))
			return 1
		else
			qdel(src)
			return 0

	return 1


/obj/item/weapon/larva_bite/attack(mob/M, mob/user)
	if(!affecting)
		return

	if(M == affecting)
		s_click(hud)
		return

/obj/item/weapon/larva_bite/dropped()
	qdel(src)

/obj/item/weapon/larva_bite/Destroy()
	qdel(hud)
	return ..()

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
	var/stage = 0

/obj/item/alien_embryo/New()
	if(istype(loc, /mob/living))
		affected_mob = loc
		SSobj.processing |= src
		spawn(0)
			AddInfectionImages(affected_mob)
	else
		qdel(src)

/obj/item/alien_embryo/Destroy()
	if(affected_mob)
		affected_mob.status_flags &= ~(XENO_HOST)
		SSobj.processing.Remove(src)
		spawn(0)
			RemoveInfectionImages(affected_mob)
	return ..()

/obj/item/alien_embryo/proc/show_message(message, m_type)
	for(var/mob/living/M in contents)
		M.show_message(message,m_type)

/obj/item/alien_embryo/process()
	if(istype(loc,/turf) || !(contents.len))
		if(baby)
			var/atom/movable/mob_container
			mob_container = baby
			mob_container.forceMove(get_turf(affected_mob))
			baby.reset_view()
		qdel(src)

	if(!affected_mob)	return
	if(loc != affected_mob)
		affected_mob.status_flags &= ~(XENO_HOST)
		SSobj.processing.Remove(src)
		spawn(0)
			RemoveInfectionImages(affected_mob)
			affected_mob = null
		return
	if(stage < 5)
		if(affected_mob.stat == DEAD)
			to_chat(baby, "\red Your host died, so and you.")
			baby.death()
			if(baby.key)
				baby.ghostize(can_reenter_corpse = FALSE, bancheck = TRUE)
			qdel(src)
		else if(prob(4))
			stage++
			spawn(0)
				RefreshInfectionImage(affected_mob)
		if(iscarbon(affected_mob))
			affected_mob.reagents.add_reagent("dexalinp", REAGENTS_METABOLISM)

	switch(stage)
		if(2, 3)
			if(prob(1))
				affected_mob.emote("sneeze")
			if(prob(1))
				affected_mob.emote("cough")
			if(prob(1))
				to_chat(affected_mob, "\red Your throat feels sore.")
			if(prob(1))
				to_chat(affected_mob, "\red Mucous runs down the back of your throat.")
		if(4)
			if(prob(1))
				affected_mob.emote("sneeze")
			if(prob(1))
				affected_mob.emote("cough")
			if(prob(2))
				to_chat(affected_mob, "\red Your muscles ache.")
				if(prob(20))
					affected_mob.take_organ_damage(1)
			if(prob(2))
				to_chat(affected_mob, "\red Your stomach hurts.")
				if(prob(20))
					affected_mob.adjustToxLoss(1)
					affected_mob.updatehealth()
		if(5)
			affected_mob.updatehealth()
			AttemptGrow()

/obj/item/alien_embryo/proc/AttemptGrow()
	if(baby)
		var/atom/movable/mob_container
		mob_container = baby
		mob_container.forceMove(affected_mob)
		baby.reset_view()
		baby.sleeping = 0
		var/obj/item/weapon/larva_bite/G = new /obj/item/weapon/larva_bite(baby, src.loc)
		baby.put_in_active_hand(G)
		G.last_bite = world.time - 20
		G.synch()
		qdel(src)

/*----------------------------------------
This is facehugger Attach procs
----------------------------------------*/
/obj/item/clothing/mask/facehugger
	name = "alien"
	desc = "It has some sort of a tube at the end of its tail."
	icon = 'icons/mob/alien.dmi'
	icon_state = "facehugger"
	item_state = "facehugger"
	w_class = 1 //note: can be picked up by aliens unlike most other items of w_class below 4
	flags = MASKCOVERSMOUTH | MASKCOVERSEYES | MASKINTERNALS
	body_parts_covered = FACE|EYES
	throw_range = 5
	var/stat = CONSCIOUS //UNCONSCIOUS is the idle state in this case
	var/sterile = 0
	var/real = 1 //0 for the toy, 1 for real
	var/strength = 5
	var/current_hugger

/obj/item/clothing/mask/facehugger/New()
	SSobj.processing |= src
	..()

/obj/item/clothing/mask/facehugger/Destroy()
	SSobj.processing.Remove(src)
	return ..()

/obj/item/clothing/mask/facehugger/process()
	if(istype(loc,/turf) || !(contents.len))
		if(current_hugger)
			var/mob/living/carbon/alien/facehugger/FH = current_hugger
			var/atom/movable/mob_container
			mob_container = FH
			mob_container.forceMove(get_turf(src))
			FH.reset_view()
		qdel(src)

/obj/item/clothing/mask/facehugger/proc/host_is_dead()
	if(current_hugger)
		var/mob/living/carbon/alien/facehugger/FH = current_hugger
		var/atom/movable/mob_container
		mob_container = FH
		mob_container.forceMove(get_turf(src))
		FH.reset_view()
		qdel(src)

/obj/item/clothing/mask/facehugger/proc/show_message(message, m_type)
	if(current_hugger)
		var/mob/living/carbon/alien/facehugger/FH = current_hugger
		FH.show_message(message,m_type)

/obj/item/clothing/mask/facehugger/examine(mob/user)
	..()
	if(!real)//So that giant red text about probisci doesn't show up.
		return
	switch(stat)
		if(DEAD,UNCONSCIOUS)
			to_chat(user, "<span class='danger'>[src] is not moving.</span>")
		if(CONSCIOUS)
			to_chat(user, "<span class='danger'>[src] seems to be active.</span>")
	if (sterile)
		to_chat(user, "<span class='danger'>It looks like the proboscis has been removed.</span>")

/obj/item/clothing/mask/facehugger/attackby()
	Die()
	return

/obj/item/clothing/mask/facehugger/bullet_act()
	Die()
	return

/obj/item/clothing/mask/facehugger/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		Die()
	return

/obj/item/clothing/mask/facehugger/proc/Attach(M)
	if( (!iscorgi(M) && !iscarbon(M)) || isalien(M))
		return

	var/mob/living/L = M //just so I don't need to use :

	if(loc == L) return
	if(stat == DEAD)	return
	if(!sterile) L.take_organ_damage(strength,0)

	if(ishuman(M))
		var/mob/living/carbon/human/target = L
		target.equip_to_slot(src, slot_wear_mask)
	else if(ismonkey(M))
		var/mob/living/carbon/monkey/target = L
		target.equip_to_slot(src, slot_wear_mask)
		target.contents += src // Monkey sanity check - Snapshot
	else if(iscorgi(M))
		var/mob/living/simple_animal/corgi/C = M
		src.loc = C
		C.facehugger = src
		C.wear_mask = src

	return

/obj/item/clothing/mask/facehugger/proc/Impregnate(mob/living/target, mob/living/FH)
	if(!target || target.wear_mask != src || target.stat == DEAD) //was taken off or something
		return

	if(!FH || FH.stat == DEAD)
		return

	if(!sterile)
		var/obj/item/alien_embryo/new_embryo = new /obj/item/alien_embryo(target)
		var/mob/living/carbon/alien/larva/new_xeno = new /mob/living/carbon/alien/larva(new_embryo)

		new_xeno.loc = new_embryo
		new_xeno.key = FH.key
		new_embryo.baby = new_xeno
		qdel(FH)
		target.remove_from_mob(target.wear_mask)
		if(ismonkey(target))
			for(var/obj/item/clothing/mask/facehugger/FH_mask in target.contents)
				FH_mask.loc = get_turf(target)

		SSobj.processing.Remove(src)

		target.status_flags |= XENO_HOST
		target.visible_message("\red \b [src] falls limp after violating [target]'s face!")

		Die()
		icon_state = "[initial(icon_state)]_impregnated"

		if(iscorgi(target))
			var/mob/living/simple_animal/corgi/C = target
			src.loc = get_turf(C)
			C.facehugger = null
	else
		target.visible_message("\red \b [src] violates [target]'s face!")

/obj/item/clothing/mask/facehugger/proc/Die()
	if(stat == DEAD)
		return

	icon_state = "[initial(icon_state)]_dead"
	stat = DEAD
	src.visible_message("\red \b[src] curls up into a ball!")
	return

/*----------------------------------------
This is tail grab mechanic. Actually, a heavy modified grab.
We also check here, if there is any facehugger on the victim face.
When we successfully clicked someone, it makes this special grab version to appear
 in player's tail control button hud.
The first step is we leap at victim face. With second step, we reinforce grip.
With third step, we start to reinforce grip to its maximum phase and when that phase is passed,
 we cant remove facehugger from victim face anymore, until facehugger injects embryo inside victim.
With fourth step, we just confirm embryo injection and with firth, we actually start injecting embryo.
When we finish, facehugger's player will be transfered inside embryo.
----------------------------------------*/
/obj/screen/fh_grab
	name = "fh_grab"

/obj/screen/fh_grab/Click()
	var/obj/item/weapon/fh_grab/G = master
	G.s_click(src)
	return 1

/obj/screen/fh_grab/attack_hand()
	return

/obj/screen/fh_grab/attackby()
	return

/obj/item/weapon/fh_grab
	name = "grab"
	flags = NOBLUDGEON | ABSTRACT
	var/obj/screen/fh_grab/hud = null
	var/mob/affecting = null
	var/mob/assailant = null
	var/state = GRAB_PASSIVE

	var/last_upgrade = 0

	layer = 21
	abstract = 1
	item_state = "nothing"
	w_class = 5.0


/obj/item/weapon/fh_grab/New(mob/user, mob/victim)
	..()
	loc = user
	assailant = user
	affecting = victim

	hud = new /obj/screen/fh_grab(src)
	hud.icon = 'icons/mob/screen1_xeno.dmi'
	hud.icon_state = "leap"
	hud.name = "Leap at face"
	hud.master = src


/obj/item/weapon/fh_grab/proc/throw_held()
	return null

/obj/item/weapon/fh_grab/proc/synch()
	if(affecting)
		if(assailant.r_hand == src)
			hud.screen_loc = ui_rhand


/obj/item/weapon/fh_grab/process()
	confirm()

	if(assailant.client)
		assailant.client.screen -= hud
		assailant.client.screen += hud

	if(state <= GRAB_AGGRESSIVE)
		if(state == GRAB_AGGRESSIVE)
			var/h = affecting.hand
			affecting.hand = 0
			affecting.drop_item()
			affecting.hand = 1
			affecting.drop_item()
			affecting.hand = h

	if(state >= GRAB_AGGRESSIVE)
		affecting.Paralyse(MAX_IMPREGNATION_TIME/6)
		if(iscarbon(affecting))
			affecting.reagents.add_reagent("dexalinp", REAGENTS_METABOLISM)

/obj/item/weapon/fh_grab/proc/s_click(obj/screen/S)
	if(!affecting)
		return
	if(affecting.stat == DEAD)
		var/obj/item/clothing/mask/facehugger/hugger = affecting.wear_mask
		if(hugger)
			hugger.host_is_dead()
		qdel(src)
		return
	if(state == GRAB_UPGRADING)
		return
	if(assailant.next_move > world.time)
		return
	if(assailant.lying)
		return
	if(world.time < (last_upgrade + UPGRADE_COOLDOWN))
		return
	if(istype(assailant.loc, /turf))
		state = GRAB_PASSIVE

	if(get_dist(assailant, affecting) > 1)
		to_chat(assailant, "Too far.")
		qdel(src)
		return

	if(iscarbon(affecting))
		var/obj/item/clothing/mask/facehugger/hugger = affecting.wear_mask
		if(hugger)
			if(hugger.current_hugger != assailant)
				to_chat(assailant, "There is already facehugger on the face")
				qdel(src)
				return
	else if(iscorgi(affecting))
		var/mob/living/simple_animal/corgi/C = affecting

		var/obj/item/clothing/mask/facehugger/hugger = C.wear_mask
		if(hugger)
			if(hugger.current_hugger != assailant)
				to_chat(assailant, "There is already facehugger on the face")
				qdel(src)
				return

	for(var/obj/item/alien_embryo/AE in affecting.contents)
		to_chat(assailant, "\red [affecting] already impregnated.")
		qdel(src)
		return

	for(var/mob/living/carbon/alien/larva/baby in affecting.contents)
		to_chat(assailant, "\red [affecting] already impregnated.")
		qdel(src)
		return

	last_upgrade = world.time
	if(state == GRAB_PASSIVE)
		assailant.visible_message("<span class='warning'>[assailant] leaps at [affecting] face!</span>")
		var/mob/living/carbon/alien/facehugger/FH = assailant
		if(affecting.wear_mask)
			if(!istype(affecting.wear_mask, /obj/item/clothing/mask/facehugger))
				var/obj/item/clothing/mask/victim_mask = affecting.wear_mask
				affecting.remove_from_mob(victim_mask)
				qdel(victim_mask)
		FH.leap_at_face(affecting)
		state = GRAB_AGGRESSIVE
		hud.icon_state = "grab/neck"
		hud.name = "grab around neck"
	else if(state == GRAB_AGGRESSIVE)
		assailant.visible_message("<span class='warning'>[assailant] has reinforced \his grip on [affecting] neck!</span>")
		state = GRAB_NECK
		hud.icon_state = "grab/neck+"
		hud.name = "reinforce grab"
	else if(state == GRAB_NECK)
		assailant.visible_message("<span class='danger'>[assailant] starts to tighten \his tail on [affecting]'s neck!</span>")
		hud.icon_state = "grab/neck++"
		state = GRAB_UPGRADING
		if(do_after(assailant, UPGRADE_TAIL_TIMER, target = affecting))
			if(state == GRAB_EMBRYO)
				return
			if(!affecting)
				qdel(src)
				return
			if(!assailant.canmove || assailant.lying)
				qdel(src)
				return
			state = GRAB_EMBRYO
			hud.icon_state = "grab/neck+++"
			hud.name = "prepare to impregnate"
			if(istype(assailant.loc, /obj/item/clothing/mask/facehugger))
				var/obj/item/clothing/mask/facehugger/FH_mask = assailant.loc
				FH_mask.canremove = 0
			assailant.visible_message("<span class='danger'>[assailant] has tightened \his tail on [affecting]'s neck!</span>")
			assailant.next_move = world.time + 10
			//affecting.losebreath += 1
		else
			assailant.visible_message("<span class='warning'>[assailant] was unable to tighten \his grip on [affecting]'s neck!</span>")
			hud.icon_state = "grab/neck"
			state = GRAB_AGGRESSIVE
	else if(state == GRAB_EMBRYO)
		state = GRAB_IMPREGNATE
		hud.icon_state = "grab/impreg"
		hud.name = "ready to impregnate"
		to_chat(assailant, "You are now ready to inject embryo inside your victim")
	else if(state == GRAB_IMPREGNATE)
		state = GRAB_DONE
		hud.icon_state = "grab/do_impreg"
		hud.name = "impregnating"
		assailant.visible_message("<span class='danger'>[assailant] extends its proboscis deep inside [affecting]'s mouth!</span>")
		spawn(rand(MIN_IMPREGNATION_TIME,MAX_IMPREGNATION_TIME))
			if(istype(assailant.loc, /obj/item/clothing/mask/facehugger))
				assailant.visible_message("\red \b [assailant] falls limp after violating [affecting]'s face!")
				var/obj/item/clothing/mask/facehugger/FH_mask = assailant.loc
				FH_mask.canremove = 1
				FH_mask.Impregnate(affecting, assailant)

//This is used to make sure the victim hasn't managed to yackety sax away before using the grab.
/obj/item/weapon/fh_grab/proc/confirm()
	if(!assailant || !affecting)
		qdel(src)
		return 0

	if(affecting.stat == DEAD)
		var/obj/item/clothing/mask/facehugger/hugger = affecting.wear_mask
		if(hugger)
			hugger.host_is_dead()
		if(iscarbon(affecting))
			affecting.update_inv_wear_mask(1)
		qdel(src)
		return 0

	if(affecting)
		if(iscarbon(assailant.loc.loc))
			return 1
		if(iscorgi(assailant.loc.loc))
			return 1
		if(!isturf(assailant.loc) || ( !isturf(affecting.loc) || assailant.loc != affecting.loc && get_dist(assailant, affecting) > 1) )
			qdel(src)
			return 0

	return 1


/obj/item/weapon/fh_grab/attack(mob/M, mob/user)
	if(!affecting)
		return

	if(M == affecting)
		s_click(hud)
		return

/obj/item/weapon/fh_grab/dropped()
	qdel(src)

/obj/item/weapon/fh_grab/Destroy()
	qdel(hud)
	return ..()
