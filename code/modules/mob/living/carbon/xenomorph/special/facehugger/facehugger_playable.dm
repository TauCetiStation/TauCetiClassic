//Grab levels
#define GRAB_LEAP		1
#define GRAB_UPGRADING	2
#define GRAB_EMBRYO		3
#define GRAB_IMPREGNATE	4

#define BITE_COOLDOWN 20

/mob/living/carbon/xenomorph/facehugger
	name = "alien facehugger"
	desc = "Из кончика хвоста выступает отросток, похожий на трубочку."
	real_name = "alien facehugger"

	icon_state = "facehugger"
	pass_flags = PASSTABLE | PASSMOB

	maxHealth = 25
	health = 25
	storedPlasma = 50
	max_plasma = 50

	speed = -1

	density = FALSE
	w_class = SIZE_SMALL

	var/amount_grown = 0
	var/max_grown = 200
	var/time_of_birth
	alien_spells = list(/obj/effect/proc_holder/spell/no_target/hide)

	var/obj/item/weapon/r_store = null
	var/obj/item/weapon/l_store = null

/mob/living/carbon/xenomorph/facehugger/atom_init()
	. = ..()
	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src
	name = "alien facehugger ([rand(1, 1000)])"
	real_name = name
	regenerate_icons()
	set_a_intent(INTENT_GRAB)
	alien_list[ALIEN_FACEHUGGER] += src

/mob/living/carbon/xenomorph/facehugger/Destroy()
	alien_list[ALIEN_FACEHUGGER] -= src
	return ..()

/mob/living/carbon/xenomorph/facehugger/start_pulling(atom/movable/AM)
	to_chat(src, "<span class='warning'>You are too small to pull anything.</span>")
	return

/mob/living/carbon/xenomorph/facehugger/swap_hand()
	return

/mob/living/carbon/xenomorph/facehugger/u_equip(obj/item/W)
	if (W == r_hand)
		r_hand = null
		W.update_inv_mob()

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

	G.synch()
	C.LAssailant = src

	target.visible_message("<span class='danger'>[src] atempts to leap at [C]'s face!</span>")

/*
 * This is called when facehugger has grabbed(left click) and then
 * used leap from hud action menu(the one that has left and right hand for anyone else).
 */
/mob/living/carbon/xenomorph/facehugger/proc/leap_at_face(mob/living/carbon/C)
	if(ishuman(C) || ismonkey(C)) // CP! THIS IS DELTA SIX! DO WE NEED THIS? CP!
		var/obj/item/clothing/mask/facehugger/FH = new(loc, src)
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
	else if(stat == UNCONSCIOUS || lying || crawling)
		icon_state = "facehugger_inactive"
	else
		icon_state = "facehugger"

/mob/living/carbon/xenomorph/facehugger/update_hud()
	if(client)
		client.screen |= contents

/mob/living/carbon/xenomorph/facehugger/can_pickup(obj/O)
	return FALSE

/mob/living/carbon/xenomorph/facehugger/is_usable_head(targetzone = null)
	return TRUE

/mob/living/carbon/xenomorph/facehugger/is_usable_arm(targetzone = null)
	return FALSE

/mob/living/carbon/xenomorph/facehugger/is_usable_leg(targetzone = null)
	return FALSE

/*----------------------------------------
              LARVA'S  BITE

This is chestburster mechanic for damaging
 victim chest to get out from stomach
----------------------------------------*/
/atom/movable/screen/larva_bite
	name = "larva_bite"

/atom/movable/screen/larva_bite/Click()
	var/obj/item/weapon/larva_bite/G = master
	if(G)
		G.s_click(src)
		return TRUE

/atom/movable/screen/larva_bite/attack_hand()
	return

/atom/movable/screen/larva_bite/attackby()
	return

/obj/item/weapon/larva_bite
	name = "larva_bite"
	flags = NOBLUDGEON | ABSTRACT | DROPDEL | NODROP
	var/atom/movable/screen/larva_bite/hud = null
	var/mob/affecting = null
	var/mob/chestburster = null
	var/state = null

	var/last_bite = 0

	layer = 21
	item_state = "nothing"
	w_class = SIZE_BIG


/obj/item/weapon/larva_bite/atom_init(mapload, mob/victim)
	. = ..()
	chestburster = loc
	affecting = victim

	hud = new /atom/movable/screen/larva_bite(src)
	hud.icon = 'icons/hud/screen1_xeno.dmi'
	hud.icon_state = "chest_burst"
	hud.name = "Burst thru chest"
	hud.master = src

/obj/item/weapon/larva_bite/proc/throw_held()
	return null

/obj/item/weapon/larva_bite/attack_self(mob/user)
	s_click()

/obj/item/weapon/larva_bite/proc/synch()
	if(affecting)
		if(chestburster.r_hand == src)
			hud.screen_loc = ui_rhand

/obj/item/weapon/larva_bite/process()
	confirm()

	if(chestburster.client)
		chestburster.client.screen -= hud
		chestburster.client.screen += hud

/obj/item/weapon/larva_bite/proc/s_click(atom/movable/screen/S)
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
			affecting.visible_message("<span class='userdanger'>[chestburster] crawls out of [affecting]!</span>")
			affecting.add_overlay(image('icons/mob/alien.dmi', loc = affecting, icon_state = "bursted_stand"))
			playsound(chestburster, pick(SOUNDIN_XENOMORPH_CHESTBURST), VOL_EFFECTS_MASTER, vary = FALSE, frequency = null, ignore_environment = TRUE)
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
			H.SetShockStage(20)
			H.Stun(1)
			H.Weaken(1)
			H.emote("scream")
	else if(ismonkey(affecting))
		var/mob/living/carbon/monkey/M = affecting
		if(M.stat == DEAD)
			chestburster.loc = get_turf(M)
			chestburster.visible_message("<span class='danger'>[chestburster] bursts thru [M]'s butt!</span>")
			affecting.add_overlay(image('icons/mob/alien.dmi', loc = affecting, icon_state = "bursted_stand"))
			playsound(chestburster, pick(SOUNDIN_XENOMORPH_CHESTBURST), VOL_EFFECTS_MASTER, vary = FALSE, frequency = null, ignore_environment = TRUE)
			qdel(src)
		else
			last_bite = world.time
			M.adjustBruteLoss(rand(35, 65))
			playsound(src, 'sound/weapons/bite.ogg', VOL_EFFECTS_MASTER)
			M.Stun(8)
			M.Weaken(8)

/obj/item/weapon/larva_bite/proc/confirm()
	if(!chestburster || !affecting)
		qdel(src)
		return FALSE

	if(affecting)
		if(isliving(chestburster.loc))
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
/atom/movable/screen/fh_grab
	name = "fh_grab"

/atom/movable/screen/fh_grab/Click()
	var/obj/item/weapon/fh_grab/G = master
	if(G)
		G.s_click(src)
		return TRUE

/atom/movable/screen/fh_grab/attack_hand()
	return

/atom/movable/screen/fh_grab/attackby()
	return

/obj/item/weapon/fh_grab
	name = "grab"
	flags = NOBLUDGEON | ABSTRACT | DROPDEL | NODROP
	var/atom/movable/screen/fh_grab/hud = null
	var/mob/affecting = null	//target
	var/mob/assailant = null	//facehagger
	var/state = GRAB_LEAP
	var/on_cooldown = FALSE

	layer = 21
	item_state = "nothing"
	w_class = SIZE_BIG


/obj/item/weapon/fh_grab/atom_init(mapload, mob/victim)
	. = ..()
	assailant = loc
	affecting = victim

	hud = new /atom/movable/screen/fh_grab(src)
	hud.icon = 'icons/hud/screen1_xeno.dmi'
	hud.icon_state = "leap"
	hud.name = "Leap at face"
	hud.master = src
	start_cooldown(hud, 4, CALLBACK(src, PROC_REF(reset_cooldown)))
	on_cooldown = TRUE

	assailant.put_in_active_hand(src)
	synch()
	affecting.LAssailant = assailant
	assailant.update_hud()

/obj/item/weapon/fh_grab/Destroy()
	STOP_PROCESSING(SSobj, src)
	QDEL_NULL(hud)
	affecting = null
	assailant = null
	return ..()

/obj/item/weapon/fh_grab/proc/throw_held()
	return null

/obj/item/weapon/fh_grab/proc/reset_cooldown()
	on_cooldown = FALSE

/obj/item/weapon/fh_grab/attack_self(mob/user)
	s_click()

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

	if(state == GRAB_UPGRADING)
		var/h = affecting.hand
		affecting.hand = 0
		affecting.drop_item()
		affecting.hand = 1
		affecting.drop_item()
		affecting.hand = h
		if(!on_cooldown)
			state = GRAB_EMBRYO

	if(state > GRAB_EMBRYO)
		affecting.Paralyse(MAX_IMPREGNATION_TIME / 6)
		if(iscarbon(affecting))
			affecting.reagents.add_reagent("dexalinp", REAGENTS_METABOLISM)

/obj/item/weapon/fh_grab/proc/s_click(atom/movable/screen/S)
	if(!affecting)
		return
	if(affecting.stat == DEAD)
		var/obj/item/clothing/mask/facehugger/hugger = affecting.wear_mask
		if(istype(hugger, /obj/item/clothing/mask/facehugger))
			hugger.get_off()
		qdel(src)
		return
	if(on_cooldown || state == GRAB_IMPREGNATE)
		return
	if(assailant.lying)
		return
	if(istype(assailant.loc, /turf))
		state = GRAB_LEAP

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

	switch(state)
		if(GRAB_LEAP)
			var/mob/living/carbon/xenomorph/facehugger/FH = assailant
			start_cooldown(hud, 6, CALLBACK(src, PROC_REF(reset_cooldown)))
			on_cooldown = TRUE
			state = GRAB_UPGRADING
			hud.icon_state = "grab/impreg"
			hud.name = "impregnate"
			FH.leap_at_face(affecting)
		if(GRAB_EMBRYO)
			assailant.visible_message("<span class='danger'>extends its proboscis deep inside [affecting]'s mouth!</span>")
			hud.icon_state = "impreg"
			hud.name = "impregnating"
			state = GRAB_IMPREGNATE
			addtimer(CALLBACK(src, PROC_REF(Impregnate_by_playable_fh), affecting, assailant), MIN_IMPREGNATION_TIME)

/obj/item/weapon/fh_grab/proc/Impregnate_by_playable_fh()
	if(!affecting || !assailant)
		return
	if(istype(assailant.loc, /obj/item/clothing/mask/facehugger))
		assailant.visible_message("<span class='danger'>[assailant] falls limp after violating [affecting]'s face!</span>")
		var/obj/item/clothing/mask/facehugger/FH_mask = assailant.loc
		FH_mask.canremove = TRUE
		FH_mask.Impregnate(affecting, assailant)
		qdel(src)

//This is used to make sure the victim hasn't managed to yackety sax away before using the grab.
/obj/item/weapon/fh_grab/proc/confirm()
	if(!assailant || !affecting)
		qdel(src)
		return FALSE

	if(affecting.stat == DEAD)
		var/obj/item/clothing/mask/facehugger/hugger = affecting.wear_mask
		if(istype(hugger, /obj/item/clothing/mask/facehugger))
			hugger.get_off()
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

#undef GRAB_LEAP
#undef GRAB_UPGRADING
#undef GRAB_EMBRYO
#undef GRAB_IMPREGNATE

#undef BITE_COOLDOWN
