#define UPGRADE_TAIL_TIMER	100

//Grab levels
#define GRAB_UPGRADING	5
#define GRAB_EMBRYO		6
#define GRAB_IMPREGNATE	7
#define GRAB_DONE		8

#define BITE_COOLDOWN 20

/mob/living/carbon/xenomorph/facehugger
	name = "alien facehugger"
	desc = "It has some sort of a tube at the end of its tail."
	real_name = "alien facehugger"

	icon_state = "facehugger"
	pass_flags = PASSTABLE | PASSMOB

	maxHealth = 25
	health = 25
	storedPlasma = 50
	max_plasma = 50

	density = FALSE
	small = TRUE

	var/amount_grown = 0
	var/max_grown = 200
	var/time_of_birth

	var/obj/item/weapon/r_store = null
	var/obj/item/weapon/l_store = null

/mob/living/carbon/xenomorph/facehugger/atom_init()
	. = ..()
	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src
	if(name == "alien facehugger")
		name = "alien facehugger ([rand(1, 1000)])"
	real_name = name
	regenerate_icons()
	a_intent = INTENT_GRAB

/mob/living/carbon/xenomorph/facehugger/update_canmove(no_transform = FALSE)
	..()
	density = initial(density)

/mob/living/carbon/xenomorph/facehugger/start_pulling(atom/movable/AM)
	to_chat(src, "<span class='warning'>You are too small to pull anything.</span>")
	return

/mob/living/carbon/xenomorph/facehugger/swap_hand()
	return

/mob/living/carbon/xenomorph/facehugger/movement_delay()
	var/tally = 0
	if (istype(src, /mob/living/carbon/xenomorph/facehugger)) //just in case
		tally = -1
	return (tally + move_delay_add + config.alien_delay)

/mob/living/carbon/xenomorph/facehugger/verb/hide()
	set name = "Hide"
	set desc = "Allows to hide beneath tables or certain items. Toggled on or off."
	set category = "Alien"

	if(stat != CONSCIOUS)
		return

	if (layer != TURF_LAYER + 0.2)
		layer = TURF_LAYER + 0.2
		visible_message("<span class='danger'>[src] scurries to the ground!</span>", "<span class='notice'>You are now hiding.</span>")
	else
		layer = MOB_LAYER
		visible_message("<span class='warning'>[src] slowly peaks up from the ground...</span>", "<span class='notice'>You have stopped hiding.</span>")

/mob/living/carbon/xenomorph/facehugger/u_equip(obj/item/W)
	if (W == r_hand)
		r_hand = null
		update_inv_r_hand(0)

/mob/living/carbon/xenomorph/facehugger/attack_ui(slot_id)
	return

/mob/living/carbon/xenomorph/facehugger/canGrab(atom/movable/target, show_warnings = TRUE)
	if(!ishuman(target) && !ismonkey(target))
		if(show_warnings)
			to_chat(src, "<span class='warning'>[target] is incompatible.</span>")
		return FALSE

	var/mob/living/carbon/C = target
	var/datum/species/S = all_species[C.get_species()]
	if(S && S.flags[NO_BLOOD])
		if(show_warnings)
			to_chat(src, "<span class='warning'>[target] is incompatible.</span>")
		return FALSE

	if(C.stat == DEAD)
		if(show_warnings)
			to_chat(src, "<span class='warning'>[target] looks dead.</span>")
		return FALSE

	// very stupid copypasta since parent checks for size differences to grab.
	if(C == src)
		return FALSE
	if(!isturf(C.loc))
		return FALSE
	if(incapacitated())
		return FALSE
	if(C.anchored)
		return FALSE

	return TRUE

/mob/living/carbon/xenomorph/facehugger/Grab(atom/movable/target, force_state, show_warnings = TRUE)
	// See facehugger/canGrab()
	var/mob/living/carbon/C = target

	var/obj/item/weapon/fh_grab/G = new /obj/item/weapon/fh_grab(src, target)

	put_in_active_hand(G)

	C.grabbed_by += G
	SetNextMove(CLICK_CD_ACTION)
	G.synch()
	C.LAssailant = src

	target.visible_message("<span class='danger'>[src] atempts to leap at [C]'s face!</span>")

/*
 * This is called when facehugger has grabbed(left click) and then
 * used leap from hud action menu(the one that has left and right hand for anyone else).
 */
/mob/living/carbon/xenomorph/facehugger/proc/leap_at_face(mob/living/carbon/C)
	if(ishuman(C) || ismonkey(C)) // CP! THIS IS DELTA SIX! DO WE NEED THIS? CP!
		var/obj/item/clothing/mask/facehugger/FH = new(loc)
		src.loc = FH
		FH.current_hugger = src
		FH.Attach(C)

/mob/living/carbon/xenomorph/facehugger/regenerate_icons()
	cut_overlays()
	update_inv_r_hand(0)
	update_hud()
	update_icons()

/mob/living/carbon/xenomorph/facehugger/update_icons()
	update_hud()		//TODO: remove the need for this to be here
	cut_overlays()
	if(stat == DEAD)
		icon_state = "facehugger_dead"
	else if(lying || resting)
		icon_state = "facehugger_inactive"
	else
		icon_state = "facehugger"

/mob/living/carbon/xenomorph/facehugger/update_hud()
	//TODO
	if (client)
//		if(other)	client.screen |= hud_used.other		//Not used
//		else		client.screen -= hud_used.other		//Not used
		client.screen |= contents

/*----------------------------------------
              LARVA'S  BITE

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
	flags = NOBLUDGEON | ABSTRACT | DROPDEL
	var/obj/screen/larva_bite/hud = null
	var/mob/affecting = null
	var/mob/chestburster = null
	var/state = null

	var/last_bite = 0

	layer = 21
	abstract = 1
	item_state = "nothing"
	w_class = ITEM_SIZE_HUGE


/obj/item/weapon/larva_bite/atom_init(mapload, mob/victim)
	. = ..()
	chestburster = loc
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
		var/obj/item/organ/external/chest/BP = H.bodyparts_by_name[BP_CHEST]
		if((BP.status & ORGAN_BROKEN) || H.stat == DEAD) //I don't know why, but bodyparts can't be broken, when human is dead.
			chestburster.loc = get_turf(H)
			chestburster.visible_message("<span class='danger'>[chestburster] bursts thru [H]'s chest!</span>")
			chestburster.playsound_local(null, 'sound/voice/xenomorph/small_roar.ogg', VOL_EFFECTS_MASTER, vary = FALSE, ignore_environment = TRUE)
			H.death()
			// we're fucked. no chance to revive a person
			H.apply_damage(rand(150, 250), BRUTE, BP_CHEST)
			H.adjustToxLoss(rand(180, 200)) // Bad but effective solution.
			H.organs_by_name[O_HEART].damage = rand(50, 100)
			H.rupture_lung()
			BP.open = 1
			qdel(src)
		else
			last_bite = world.time
			playsound(src, 'sound/weapons/bite.ogg', VOL_EFFECTS_MASTER)
			H.apply_damage(rand(7, 14), BRUTE, BP_CHEST)
			H.shock_stage = 20
			H.Weaken(1)
			H.emote("scream")
	else if(ismonkey(affecting))
		var/mob/living/carbon/monkey/M = affecting
		if(M.stat == DEAD)
			chestburster.loc = get_turf(M)
			chestburster.visible_message("<span class='danger'>[chestburster] bursts thru [M]'s butt!</span>")
			chestburster.playsound_local(null, 'sound/voice/xenomorph/small_roar.ogg', VOL_EFFECTS_MASTER, vary = FALSE, ignore_environment = TRUE)
			qdel(src)
		else
			last_bite = world.time
			M.adjustBruteLoss(rand(35, 65))
			playsound(src, 'sound/weapons/bite.ogg', VOL_EFFECTS_MASTER)
			M.Weaken(8)

/obj/item/weapon/larva_bite/proc/confirm()
	if(!chestburster || !affecting)
		qdel(src)
		return FALSE

	if(affecting)
		if(istype(chestburster.loc, /mob/living))
			return TRUE
		else
			qdel(src)
			return FALSE

	return TRUE


/obj/item/weapon/larva_bite/attack(mob/M, mob/user)
	if(!affecting)
		return

	if(M == affecting)
		s_click(hud)
		return

/obj/item/weapon/larva_bite/Destroy()
	STOP_PROCESSING(SSobj, src)
	hud = null
	affecting = null
	chestburster = null
	return ..()

/*----------------------------------------
             FACEHUGGER'S  GRAB

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
	return TRUE

/obj/screen/fh_grab/attack_hand()
	return

/obj/screen/fh_grab/attackby()
	return

/obj/item/weapon/fh_grab
	name = "grab"
	flags = NOBLUDGEON | ABSTRACT | DROPDEL
	var/obj/screen/fh_grab/hud = null
	var/mob/affecting = null
	var/mob/assailant = null
	var/state = GRAB_PASSIVE

	layer = 21
	abstract = 1
	item_state = "nothing"
	w_class = ITEM_SIZE_HUGE


/obj/item/weapon/fh_grab/atom_init(mapload, mob/victim)
	. = ..()
	assailant = loc
	affecting = victim

	assailant.SetNextMove(CLICK_CD_ACTION)

	hud = new /obj/screen/fh_grab(src)
	hud.icon = 'icons/mob/screen1_xeno.dmi'
	hud.icon_state = "leap"
	hud.name = "Leap at face"
	hud.master = src

	assailant.put_in_active_hand(src)
	affecting.grabbed_by += src

	synch()
	affecting.LAssailant = assailant

/obj/item/weapon/fh_grab/Destroy()
	STOP_PROCESSING(SSobj, src)
	QDEL_NULL(hud)
	affecting = null
	assailant = null
	return ..()

/obj/item/weapon/fh_grab/proc/throw_held()
	return null

/obj/item/weapon/fh_grab/proc/synch()
	if(affecting)
		if(assailant.r_hand == src)
			hud.screen_loc = ui_rhand


/obj/item/weapon/fh_grab/process()
	if(!confirm())
		return

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
		affecting.Paralyse(MAX_IMPREGNATION_TIME / 6)
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
	if(istype(assailant.loc, /turf))
		state = GRAB_PASSIVE

	if(get_dist(assailant, affecting) > 1)
		to_chat(assailant, "Too far.")
		qdel(src)
		return

	var/obj/item/clothing/mask/facehugger/hugger
	if(iscorgi(affecting) || iscarbon(affecting))
		if(isIAN(affecting))
			var/mob/living/carbon/ian/IAN = affecting
			hugger = IAN.head
		else
			hugger = affecting.wear_mask
	if(istype(hugger) && hugger.current_hugger != assailant)
		to_chat(assailant, "There is already facehugger on the face")
		qdel(src)
		return

	for(var/obj/item/alien_embryo/AE in affecting.contents)
		to_chat(assailant, "<span class='warning'>[affecting] already impregnated.</span>")
		qdel(src)
		return

	for(var/mob/living/carbon/xenomorph/larva/baby in affecting.contents)
		to_chat(assailant, "<span class='warning'>[affecting] already impregnated.</span>")
		qdel(src)
		return

	assailant.SetNextMove(CLICK_CD_GRAB)

	switch(state)
		if(GRAB_PASSIVE)
			var/mob/living/carbon/xenomorph/facehugger/FH = assailant
			state = GRAB_AGGRESSIVE
			hud.icon_state = "grab/neck"
			hud.name = "grab around neck"
			FH.leap_at_face(affecting)
		if(GRAB_AGGRESSIVE)
			assailant.visible_message("<span class='warning'>[assailant] has reinforced \his grip on [affecting] neck!</span>")
			state = GRAB_NECK
			hud.icon_state = "grab/neck+"
			hud.name = "reinforce grab"
		if(GRAB_NECK)
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
		if(GRAB_EMBRYO)
			state = GRAB_IMPREGNATE
			hud.icon_state = "grab/impreg"
			hud.name = "ready to impregnate"
			to_chat(assailant, "You are now ready to inject embryo inside your victim")
		if(GRAB_IMPREGNATE)
			state = GRAB_DONE
			hud.icon_state = "grab/do_impreg"
			hud.name = "impregnating"
			assailant.visible_message("<span class='danger'>[assailant] extends its proboscis deep inside [affecting]'s mouth!</span>")
			addtimer(CALLBACK(src, .proc/Impregnate_by_playable_fh, affecting, assailant), rand(MIN_IMPREGNATION_TIME, MAX_IMPREGNATION_TIME))

/obj/item/weapon/fh_grab/proc/Impregnate_by_playable_fh()
	if(!affecting || !assailant)
		return
	if(istype(assailant.loc, /obj/item/clothing/mask/facehugger))
		assailant.visible_message("<span class='danger'>[assailant] falls limp after violating [affecting]'s face!</span>")
		var/obj/item/clothing/mask/facehugger/FH_mask = assailant.loc
		FH_mask.canremove = 1
		FH_mask.Impregnate(affecting, assailant)
		qdel(src)

//This is used to make sure the victim hasn't managed to yackety sax away before using the grab.
/obj/item/weapon/fh_grab/proc/confirm()
	if(!assailant || !affecting)
		qdel(src)
		return FALSE

	if(affecting.stat == DEAD)
		var/obj/item/clothing/mask/facehugger/hugger = affecting.wear_mask
		if(hugger)
			hugger.host_is_dead()
		if(iscarbon(affecting))
			affecting.update_inv_wear_mask(1)
		qdel(src)
		return FALSE

	if(affecting)
		if(iscarbon(assailant.loc.loc))
			return TRUE
		if(!isturf(assailant.loc) || ( !isturf(affecting.loc) || assailant.loc != affecting.loc && get_dist(assailant, affecting) > 1) )
			qdel(src)
			return FALSE

	return TRUE


/obj/item/weapon/fh_grab/attack(mob/M, mob/user)
	if(!affecting)
		return

	if(M == affecting)
		s_click(hud)
		return

#undef UPGRADE_TAIL_TIMER

#undef GRAB_UPGRADING
#undef GRAB_EMBRYO
#undef GRAB_IMPREGNATE
#undef GRAB_DONE

#undef BITE_COOLDOWN
