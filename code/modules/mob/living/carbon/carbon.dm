/mob/living/carbon/New(loc, new_species = null, list/organ_data)

	if(!dna)
		dna = new /datum/dna(null)
		// Species name is handled by set_species()

	if(!species)
		set_species(new_species, null, 1, organ_data)

	var/datum/reagents/R = new/datum/reagents(1000)
	reagents = R
	R.my_atom = src

	hud_list[HEALTH_HUD]      = image('icons/mob/hud.dmi', src, "hudhealth100")
	hud_list[STATUS_HUD]      = image('icons/mob/hud.dmi', src, "hudhealthy")
	hud_list[ID_HUD]          = image('icons/mob/hud.dmi', src, "hudunknown")
	hud_list[WANTED_HUD]      = image('icons/mob/hud.dmi', src, "hudblank")
	hud_list[IMPLOYAL_HUD]    = image('icons/mob/hud.dmi', src, "hudblank")
	hud_list[IMPCHEM_HUD]     = image('icons/mob/hud.dmi', src, "hudblank")
	hud_list[IMPTRACK_HUD]    = image('icons/mob/hud.dmi', src, "hudblank")
	hud_list[SPECIALROLE_HUD] = image('icons/mob/hud.dmi', src, "hudblank")
	hud_list[STATUS_HUD_OOC]  = image('icons/mob/hud.dmi', src, "hudhealthy")

	..()

	verbs += /mob/living/carbon/proc/crawl // TODO deal with !mob! brain.

	//make_blood()
	regenerate_icons()

/mob/living/carbon/Move(NewLoc, direct)
	. = ..()
	if(.)
		if(src.nutrition && src.stat != DEAD)
			src.nutrition -= HUNGER_FACTOR/10
			if(src.m_intent == "run")
				src.nutrition -= HUNGER_FACTOR/10
		if((src.disabilities & FAT) && src.m_intent == "run" && src.bodytemperature <= 360)
			src.bodytemperature += 2

		// Moving around increases germ_level faster
		if(germ_level < GERM_LEVEL_MOVE_CAP && prob(8))
			germ_level++

/mob/living/carbon/relaymove(mob/user, direction)
	if(user in src.stomach_contents)
		if(prob(40))
			for(var/mob/M in hearers(4, src))
				if(M.client)
					M.show_message(text("<span class='rose'>You hear something rumbling inside [src]'s stomach...</span>"), 2)
			var/obj/item/I = user.get_active_hand()
			if(I && I.force)
				var/d = rand(round(I.force / 4), I.force)
				if(istype(src, /mob/living/carbon/human))
					var/mob/living/carbon/human/H = src
					var/bodypart = H.get_bodypart(BP_CHEST)
					if (istype(bodypart, /obj/item/bodypart))
						var/obj/item/bodypart/BP = bodypart
						BP.take_damage(d, 0)
					H.updatehealth()
				else
					src.take_bodypart_damage(d)
				for(var/mob/M in viewers(user, null))
					if(M.client)
						M.show_message(text("<span class='danger'>[user] attacks [src]'s stomach wall with the [I.name]!</span>"), 2)
				playsound(user.loc, 'sound/effects/attackblob.ogg', 50, 1)

				if(prob(src.getBruteLoss() - 50))
					for(var/atom/movable/A in stomach_contents)
						A.loc = loc
						stomach_contents.Remove(A)
					src.gib()

/mob/living/carbon/attack_animal(mob/living/simple_animal/M)
	if(istype(M,/mob/living/simple_animal/headcrab))
		var/mob/living/simple_animal/headcrab/crab = M
		crab.Infect(src)

/mob/living/carbon/gib()
	for(var/mob/M in src)
		if(M in src.stomach_contents)
			src.stomach_contents.Remove(M)
		M.loc = src.loc
		for(var/mob/N in viewers(src, null))
			if(N.client)
				N.show_message(text("<span class='danger'>[M] bursts out of [src]!</span>"), 2)
	. = ..()

/mob/living/carbon/MiddleClickOn(atom/A)
	if(!src.stat && src.mind && src.mind.changeling && src.mind.changeling.chosen_sting && (istype(A, /mob/living/carbon)) && (A != src))
		next_click = world.time + 5
		mind.changeling.chosen_sting.try_to_sting(src, A)
	else
		..()

/mob/living/carbon/AltClickOn(atom/A)
	if(!src.stat && src.mind && src.mind.changeling && src.mind.changeling.chosen_sting && (istype(A, /mob/living/carbon)) && (A != src))
		next_click = world.time + 5
		mind.changeling.chosen_sting.try_to_sting(src, A)
	else
		..()

/mob/living/carbon/attack_hand(mob/living/carbon/C)
	if(!istype(C))
		return

	var/obj/item/bodypart/BP = C.bodyparts_by_name[BP_R_ARM]
	if (C.hand)
		BP = C.bodyparts_by_name[BP_L_ARM]

	if(BP && !BP.is_usable())
		to_chat(C, "<span class='rose'>You can't use your [BP.name].</span>")
		return

	for(var/datum/disease/D in viruses)
		if(D.spread_by_touch())
			C.contract_disease(D, 0, 1, CONTACT_HANDS)

	for(var/datum/disease/D in C.viruses)
		if(D.spread_by_touch())
			contract_disease(D, 0, 1, CONTACT_HANDS)

/mob/living/carbon/attack_paw(mob/M)
	if(!istype(M, /mob/living/carbon)) return

	for(var/datum/disease/D in viruses)

		if(D.spread_by_touch())
			M.contract_disease(D, 0, 1, CONTACT_HANDS)

	for(var/datum/disease/D in M.viruses)

		if(D.spread_by_touch())
			contract_disease(D, 0, 1, CONTACT_HANDS)

	return

/mob/living/carbon/electrocute_act(shock_damage, obj/source, siemens_coeff = 1.0, def_zone = null, tesla_shock = 0)
	if(status_flags & GODMODE)	return 0	//godmode

	var/turf/T = get_turf(src)
	var/obj/effect/decal/cleanable/water/W = locate(/obj/effect/decal/cleanable/water, T)
	if(W)
		attack_log += "\[[time_stamp()]\]<font color='red'> [src] was shocked by the [source] and started chain-reaction with water!</font>"
		msg_admin_attack("[key_name(src)] was shocked by the [source] and started chain-reaction with water! (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)")
		W.electrocute_act(shock_damage)

	shock_damage *= siemens_coeff
	if(shock_damage<1)
		return 0
	apply_damage(shock_damage, BURN, def_zone, used_weapon="Electrocution")
	playsound(loc, "sparks", 50, 1, -1)
	if(shock_damage > 10)
		visible_message(
			"<span class='rose'>[src] was shocked by the [source]!</span>", \
			"<span class='danger'>You feel a powerful shock course through your body!</span>", \
			"<span class='rose'>You hear a heavy electrical crack.</span>" \
		)
		make_jittery(1000)
		stuttering += 2
		if(!tesla_shock || (tesla_shock && siemens_coeff > 0.5))
			Stun(2)
		spawn(20)
			jitteriness = max(jitteriness - 990, 10) //Still jittery, but vastly less
			if(!tesla_shock || (tesla_shock && siemens_coeff > 0.5))
				Stun(8)
				Weaken(8)
	else
		visible_message(
			"<span class='rose'>[src] was mildly shocked by the [source].</span>", \
			"<span class='rose'>You feel a mild shock course through your body.</span>", \
			"<span class='rose'>You hear a light zapping.</span>" \
		)
	return shock_damage


/mob/living/carbon/proc/swap_hand()
	var/obj/item/item_in_hand = src.get_active_hand()
	if(item_in_hand) //this segment checks if the item in your hand is twohanded. TODO check if this needs to be updated.
		if(istype(item_in_hand, /obj/item/weapon/twohanded) || istype(item_in_hand, /obj/item/weapon/gun/projectile/automatic/l6_saw))	//OOP? Generics? Hue hue hue hue ...
			if(item_in_hand:wielded)
				to_chat(usr, "<span class='warning'>Your other hand is too busy holding the [item_in_hand.name]</span>")
				return

	if(!active_hand && inactive_hands.len)
		active_hand = inactive_hands[1]
		inactive_hands -= active_hand
		active_hand.update_swapped_hand_hud()
	else if(active_hand && inactive_hands.len)
		var/obj/item/bodypart/BP = active_hand // save active hand ref for later
		active_hand = null
		inactive_hands += BP // add current active hand to the end of the list and then ...
		BP.update_swapped_hand_hud()

		active_hand = inactive_hands[1] // ... pick inactive hand from first position in the list (useful if mob has more than two hands).
		inactive_hands -= active_hand
		active_hand.update_swapped_hand_hud()

/mob/living/carbon/proc/activate_hand(obj/item/bodypart/selhand) // helps player to select exact hand when clicking hand box on the hud.
	if(active_hand != selhand)
		if(active_hand)
			var/obj/item/bodypart/BP = active_hand
			active_hand = null
			inactive_hands += BP
			BP.update_swapped_hand_hud()

		active_hand = selhand
		inactive_hands -= active_hand
		active_hand.update_swapped_hand_hud()

/obj/item/bodypart/proc/update_swapped_hand_hud()
	var/obj/screen/S = inv_slots_data[inv_slots_data[1]]
	if(S)
		if(owner.active_hand == src)
			S.icon_state = inv_box_data[inv_box_data[1]]["icon_state"] + "_active"
		else
			S.icon_state = inv_box_data[inv_box_data[1]]["icon_state"] + "_inactive"


/mob/living/carbon/proc/help_shake_act(mob/living/carbon/M) // TODO check Bay12 version of this proc.
	if (src.health >= config.health_threshold_crit)
		if(src == M && istype(src, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = src
			src.visible_message( \
				text("<span class='notice'>[src] examines [].</span>",src.gender==MALE?"himself":"herself"), \
				"<span class='notice'>You check yourself for injuries.</span>" \
				)

			for(var/obj/item/bodypart/BP in H.bodyparts)
				var/status = ""
				var/brutedamage = BP.brute_dam
				var/burndamage = BP.burn_dam
				var/bodypart_name = BP.name
				if(halloss > 0)
					if(prob(30))
						brutedamage += halloss
					if(prob(30))
						burndamage += halloss

				if(brutedamage > 0)
					status = "bruised"
				if(brutedamage > 20)
					status = "bleeding"
				if(brutedamage > 40)
					status = "mangled"
				if(brutedamage > 0 && burndamage > 0)
					status += " and "
				if(burndamage > 40)
					status += "peeling away"

				else if(burndamage > 10)
					status += "blistered"
				else if(burndamage > 0)
					status += "numb"
				if(BP.is_stump())
					bodypart_name = parse_zone(BP.body_zone)
					status = "MISSING!"
				else if(BP.status & ORGAN_MUTATED)
					status = "weirdly shapen."
				else if(BP.dislocated == 2)
					status = "dislocated"
				else if(BP.status & ORGAN_BROKEN)
					status = "hurts when touched"
				else if(BP.status & ORGAN_DEAD)
					status = "is bruised and necrotic"
				else if(!BP.is_usable() || BP.is_dislocated())
					status = "dangling uselessly"
				if(status == "")
					status = "OK"
				src.show_message(text("\t []My [] is [].",status=="OK"?"\blue ":"\red ",bodypart_name,status),1)
			if(H.species && (H.species.name == S_SKELETON) && !H.w_uniform && !H.wear_suit)
				H.play_xylophone()
		else
			var/t_him = "it"
			if (src.gender == MALE)
				t_him = "him"
			else if (src.gender == FEMALE)
				t_him = "her"
			if (istype(src,/mob/living/carbon/human) && src:w_uniform)
				var/mob/living/carbon/human/H = src
				H.w_uniform.add_fingerprint(M)

			if(lying)
				src.sleeping = max(0,src.sleeping-5)
				if(!src.sleeping)
					src.resting = 0
				if(src.crawling)
					if(crawl_can_use() && src.pass_flags & PASSCRAWL)
						src.pass_flags ^= PASSCRAWL
						src.crawling = 0
				M.visible_message("<span class='notice'>[M] shakes [src] trying to wake [t_him] up!</span>", \
									"<span class='notice'>You shake [src] trying to wake [t_him] up!</span>")
			else
				M.visible_message("<span class='notice'>[M] hugs [src] to make [t_him] feel better!</span>", \
								"<span class='notice'>You hug [src] to make [t_him] feel better!</span>")

			AdjustParalysis(-3)
			AdjustStunned(-3)
			AdjustWeakened(-3)

			playsound(src.loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)

/mob/living/carbon/proc/crawl_can_use()
	var/turf/T = get_turf(src)
	if( (locate(/obj/structure/table) in T) || (locate(/obj/structure/stool/bed) in T) || (locate(/obj/structure/plasticflaps) in T))
		return FALSE
	return TRUE

/mob/living/carbon/var/crawl_getup = FALSE
/mob/living/carbon/proc/crawl()
	set name = "Crawl"
	set category = "IC"

	if( stat || weakened || paralysis || resting || sleeping || (status_flags & FAKEDEATH) || buckled)
		return
	if(crawl_getup)
		return

	if(crawling)
		crawl_getup = TRUE
		if(do_after(src, 10, target = src))
			crawl_getup = FALSE
			if(!crawl_can_use())
				playsound(loc, 'sound/weapons/tablehit1.ogg', 50, 1)
				if(ishuman(src))
					var/mob/living/carbon/human/H = src
					var/obj/item/bodypart/BP = H.get_bodypart(BP_HEAD)
					BP.take_damage(5, 0, 0, "Facepalm") // what?.. that guy was insane anyway.
				else
					take_overall_damage(5, used_weapon = "Table")
				Stun(1)
				to_chat(src, "<span class='danger'>Ouch!</span>")
				return
			layer = 4.0
		else
			crawl_getup = FALSE
			return
	else
		if(!crawl_can_use())
			to_chat(src, "<span class='notice'>You can't crawl here!</span>")
			return
		layer = 3.9

	pass_flags ^= PASSCRAWL
	crawling = !crawling

	to_chat(src, "<span class='notice'>You are now [crawling ? "crawling" : "getting up"].</span>")
	update_canmove()

/mob/living/carbon/proc/eyecheck()
	return 0

/mob/living/carbon/flash_eyes(intensity = 1, override_blindness_check = 0, affect_silicon = 0, visual = 0, type = /obj/screen/fullscreen/flash)
	if(eyecheck() < intensity || override_blindness_check)
		return ..()

// ++++ROCKDTBEN++++ MOB PROCS -- Ask me before touching.
// Stop! ... Hammertime! ~Carn

/mob/living/carbon/proc/getDNA()
	return dna

/mob/living/carbon/proc/setDNA(datum/dna/newDNA)
	dna = newDNA

// ++++ROCKDTBEN++++ MOB PROCS //END

/mob/living/carbon/clean_blood()
	. = ..()
	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		var/obj/item/I = get_equipped_item(slot_gloves)
		if(I)
			I.clean_blood()
			I.germ_level = 0
		else
			if(H.bloody_hands)
				H.bloody_hands = 0
				//H.update_inv_gloves() TODO deal with blood on limbs.
			H.germ_level = 0
	update_icons()	//apply the now updated overlays to the mob


//Throwing stuff

/mob/living/carbon/proc/toggle_throw_mode()
	if (src.in_throw_mode)
		throw_mode_off()
	else
		throw_mode_on()

/mob/living/carbon/proc/throw_mode_off()
	src.in_throw_mode = 0
	if(src.throw_icon) //in case we don't have the HUD and we use the hotkey
		src.throw_icon.icon_state = "act_throw_off"

/mob/living/carbon/proc/throw_mode_on()
	src.in_throw_mode = 1
	if(src.throw_icon)
		src.throw_icon.icon_state = "act_throw_on"

/mob/proc/throw_item(atom/target)
	return

/mob/living/carbon/throw_item(atom/target)
	src.throw_mode_off()
	if(usr.stat || !target)
		return
	if(target.type == /obj/screen) return

	var/atom/movable/thrown_thing
	var/obj/item/I = src.get_active_hand()

	if(!I || !I.canremove) return

	if (istype(I, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = I
		thrown_thing = G.throw_held() //throw the person instead of the grab
		qdel(G)
		if(ismob(thrown_thing))
			var/turf/start_T = get_turf(loc) //Get the start and target tile for the descriptors
			var/turf/end_T = get_turf(target)
			if(start_T && end_T)
				var/mob/M = thrown_thing
				var/start_T_descriptor = "<font color='#6b5d00'>tile at [start_T.x], [start_T.y], [start_T.z] in area [get_area(start_T)]</font>"
				var/end_T_descriptor = "<font color='#6b4400'>tile at [end_T.x], [end_T.y], [end_T.z] in area [get_area(end_T)]</font>"

				M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been thrown by [usr.name] ([usr.ckey]) from [start_T_descriptor] with the target [end_T_descriptor]</font>")
				usr.attack_log += text("\[[time_stamp()]\] <font color='red'>Has thrown [M.name] ([M.ckey]) from [start_T_descriptor] with the target [end_T_descriptor]</font>")
				msg_admin_attack("[usr.name] ([usr.ckey]) has thrown [M.name] ([M.ckey]) from [start_T_descriptor] with the target [end_T_descriptor] [ADMIN_JMP(usr)]")

	if(!thrown_thing && I && !(I.flags & ABSTRACT))
		thrown_thing = I
		dropItemToGround(I)

	//actually throw it!
	if (thrown_thing) // Grab processing has a chance of returning null
		src.visible_message("<span class='rose'>[src] has thrown [thrown_thing].</span>")
		newtonian_move(get_dir(target, src))
		thrown_thing.throw_at(target, thrown_thing.throw_range, thrown_thing.throw_speed, src)

/mob/living/carbon/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	..()
	bodytemperature = max(bodytemperature, BODYTEMP_HEAT_DAMAGE_LIMIT+10)

/mob/living/carbon/can_use_hands()
	if(handcuffed)
		return 0
	if(buckled && ! istype(buckled, /obj/structure/stool/bed/chair)) // buckling does not restrict hands
		return 0
	return 1

/mob/living/carbon/restrained()
	if (handcuffed)
		return 1
	return

/mob/living/carbon/show_inv(mob/living/carbon/user)
	user.set_machine(src)
	var/dat = {"
	<B><HR><FONT size=3>[name]</FONT></B>
	<BR><HR>
	<BR><B>Head(Mask):</B> <A href='?src=\ref[src];item=mask'>[(wear_mask && !(wear_mask.flags&ABSTRACT))	? wear_mask	: "Nothing"]</A>
	<BR><B>Left Hand:</B> <A href='?src=\ref[src];item=l_hand'>[(l_hand && !(l_hand.flags&ABSTRACT))		? l_hand	: "Nothing"]</A>
	<BR><B>Right Hand:</B> <A href='?src=\ref[src];item=r_hand'>[(r_hand && !(r_hand.flags&ABSTRACT))		? r_hand	: "Nothing"]</A>
	<BR><B>Back:</B> <A href='?src=\ref[src];item=back'>[(back ? back : "Nothing")]</A> [((istype(wear_mask, /obj/item/clothing/mask) && istype(back, /obj/item/weapon/tank) && !( internal )) ? text(" <A href='?src=\ref[];item=internal'>Set Internal</A>", src) : "")]
	<BR>[(handcuffed ? text("<A href='?src=\ref[src];item=handcuff'>Handcuffed</A>") : text("<A href='?src=\ref[src];item=handcuff'>Not Handcuffed</A>"))]
	<BR>[(internal ? text("<A href='?src=\ref[src];item=internal'>Remove Internal</A>") : "")]
	<BR><A href='?src=\ref[src];item=pockets'>Empty Pockets</A>
	<BR><A href='?src=\ref[user];refresh=1'>Refresh</A>
	<BR><A href='?src=\ref[user];mach_close=mob[name]'>Close</A>
	<BR>"}
	user << browse(dat, text("window=mob[];size=325x500", name))
	onclose(user, "mob[name]")
	return

//generates realistic-ish pulse output based on preset levels
/mob/living/carbon/proc/get_pulse(method)	//method 0 is for hands, 1 is for machines, more accurate
	var/temp = 0
	switch(pulse())
		if(PULSE_NONE)
			return "0"
		if(PULSE_SLOW)
			temp = rand(40, 60)
		if(PULSE_NORM)
			temp = rand(60, 90)
		if(PULSE_FAST)
			temp = rand(90, 120)
		if(PULSE_2FAST)
			temp = rand(120, 160)
		if(PULSE_THREADY)
			return method ? ">250" : "extremely weak and fast, patient's artery feels like a thread"
	return "[method ? temp : temp + rand(-10, 10)]"
//			output for machines^	^^^^^^^output for people^^^^^^^^^

/mob/living/carbon/proc/pulse()
	var/obj/item/organ/heart/heart = organs_by_name[BP_HEART]
	if(!heart)
		return PULSE_NONE
	else
		return heart.pulse

/mob/living/carbon/verb/mob_sleep()
	set name = "Sleep"
	set category = "IC"

	if(usr.sleeping)
		to_chat(usr, "<span class='rose'>You are already sleeping")
		return
	if(alert(src,"You sure you want to sleep for a while?","Sleep","Yes","No") == "Yes")
		usr.sleeping = 20 //Short nap

//Brain slug proc for voluntary removal of control.
/mob/living/carbon/proc/release_control()

	set category = "Alien"
	set name = "Release Control"
	set desc = "Release control of your host's body."

	var/mob/living/simple_animal/borer/B = has_brain_worms()

	if(!B)
		return

	if(B.controlling)
		to_chat(src, "<span class='danger'>You withdraw your probosci, releasing control of [B.host_brain].</span>")
		to_chat(B.host_brain, "<span class='danger'>Your vision swims as the alien parasite releases control of your body.</span>")
		B.ckey = ckey
		B.controlling = 0
	if(B.host_brain.ckey)
		ckey = B.host_brain.ckey
		B.host_brain.ckey = null
		B.host_brain.name = "host brain"
		B.host_brain.real_name = "host brain"

	verbs -= /mob/living/carbon/proc/release_control
	verbs -= /mob/living/carbon/proc/punish_host
	verbs -= /mob/living/carbon/proc/spawn_larvae

//Brain slug proc for tormenting the host.
/mob/living/carbon/proc/punish_host()
	set category = "Alien"
	set name = "Torment host"
	set desc = "Punish your host with agony."

	var/mob/living/simple_animal/borer/B = has_brain_worms()

	if(!B)
		return

	if(B.host_brain.ckey)
		to_chat(src, "<span class='danger'>You send a punishing spike of psychic agony lancing into your host's brain.</span>")
		if (!can_feel_pain())
			to_chat(B.host_brain, "<span class='warning'>You feel a strange sensation as a foreign influence prods your mind.</span>")
			to_chat(src, "<span class='danger'>It doesn't seem to be as effective as you hoped.</span>")
		else
			to_chat(B.host_brain, "<span class='danger'><FONT size=3>Horrific, burning agony lances through you, ripping a soundless scream from your trapped mind!</FONT></span>")

//Check for brain worms in head.
/mob/proc/has_brain_worms()

	for(var/I in contents)
		if(istype(I,/mob/living/simple_animal/borer))
			return I

	return 0

/mob/living/carbon/proc/spawn_larvae()
	set category = "Alien"
	set name = "Reproduce"
	set desc = "Spawn several young."

	var/mob/living/simple_animal/borer/B = has_brain_worms()

	if(!B)
		return

	if(B.chemicals >= 100)
		to_chat(src, "<span class='danger'>Your host twitches and quivers as you rapdly excrete several larvae from your sluglike body.</span>")
		visible_message("<span class='danger'>[src] heaves violently, expelling a rush of vomit and a wriggling, sluglike creature!</span>")
		B.chemicals -= 100

		new /obj/effect/decal/cleanable/vomit(get_turf(src))
		playsound(loc, 'sound/effects/splat.ogg', 50, 1)
		new /mob/living/simple_animal/borer(get_turf(src))

	else
		to_chat(src, "<span class='info'>You do not have enough chemicals stored to reproduce.</span>")
		return

/**
 *  Return FALSE if victim can't be devoured, DEVOUR_FAST if they can be devoured quickly, DEVOUR_SLOW for slow devour
 */
/mob/living/carbon/proc/can_devour(mob/living/victim)
	if( (ishuman(src) && (FAT in disabilities & FAT) && ismonkey(victim)) || ( isalien(src) && iscarbon(victim) ) )
		return TRUE
	return FALSE

/**
 *  Attempt to devour victim
 *
 *  Returns TRUE on success, FALSE on failure
 */
/mob/living/carbon/proc/devour(mob/living/victim) // TODO update this
	if(!can_devour(victim))
		return FALSE
	src.visible_message("<span class='danger'>[src] is attempting to devour [victim]!</span>")
	if(istype(src, /mob/living/carbon/alien/humanoid/hunter))
		if(!do_mob(src, victim) || !do_after(src, 30, target = victim))
			return FALSE
	else
		if(!do_mob(src, victim) || !do_after(src, 100, target = victim))
			return FALSE
	src.visible_message("<span class='danger'>[src] devours [victim]!</span>")
	if(isalien(src))
		if(victim.stat == DEAD)
			victim.gib()
			if(src.health >= src.maxHealth - src.getCloneLoss())
				src.adjustToxLoss(100)
				to_chat(src, "<span class='notice'>You gain some plasma.</span>")
			else
				src.adjustBruteLoss(-100)
				src.adjustFireLoss(-100)
				src.adjustOxyLoss(-100)
				src.adjustCloneLoss(-100)
				to_chat(src, "<span class='notice'>You feel better.</span>")
		else
			victim.forceMove(src)
			src.stomach_contents.Add(victim)
	else
		victim.forceMove(src)
		src.stomach_contents.Add(victim)

	return TRUE

/mob/living/proc/uncuff()
	return

/mob/living/carbon/uncuff() // maybe separated or arg?
	if(handcuffed)
		dropItemToGround(handcuffed)
	if(legcuffed)
		dropItemToGround(legcuffed)

//-TG- port for smooth lying/standing animations
/mob/living/carbon/get_standard_pixel_y_offset(lying_current = 0)
	if(lying)
		if(buckled && istype(buckled, /obj/structure/stool/bed/roller))
			return 1
		else if(locate(/obj/structure/stool/bed/roller, src.loc))
			return -5
		else if(locate(/obj/machinery/optable, src.loc)||locate(/obj/structure/stool/bed, src.loc))	//we need special pixel shift for beds & optable to make mob lying centered
			return -4
		else
			return -6
	else
		return initial(pixel_y)

/mob/living/carbon/get_standard_pixel_x_offset(lying_current = 0)
	if(lying)
		if(locate(/obj/machinery/optable, src.loc)||locate(/obj/structure/stool/bed, src.loc))	//we need special pixel shift for beds & optable to make mob lying centered
			switch(src.lying_current)
				if(90)	return 2
				if(270)	return -2
	else
		return initial(pixel_x)

/mob/living/carbon/getTrail()
	return "trails_1"

/mob/living/carbon/proc/bloody_hands(mob/living/source, amount = 2)
	return

/mob/living/carbon/proc/bloody_body(mob/living/source)
	return

// ************************************
// MOVED STUFF
// ************************************
// called when something steps onto a human
// this could be made more general, but for now just handle mulebot
/mob/living/carbon/Crossed(var/atom/movable/AM)
	var/obj/machinery/bot/mulebot/MB = AM
	if(istype(MB))
		MB.RunOver(src)

/mob/living/carbon/proc/check_dna()
	dna.check_integrity(src)
	return

/mob/living/carbon/proc/vomit()

	if(species.flags[IS_SYNTHETIC])
		return //Machines don't throw up.

	if(!lastpuke)
		lastpuke = 1
		to_chat(src, "<span class='warning'>You feel nauseous...</span>")
		spawn(150)	//15 seconds until second warning
			to_chat(src, "<span class='warning'>You feel like you are about to throw up!</span>")
			spawn(100)	//and you have 10 more for mad dash to the bucket
				Stun(5)

				src.visible_message("<span class='warning'>[src] throws up!","<spawn class='warning'>You throw up!</span>")
				playsound(loc, 'sound/effects/splat.ogg', 50, 1)

				var/turf/location = loc
				if (istype(location, /turf/simulated))
					location.add_vomit_floor(src, 1)

				nutrition -= 40
				adjustToxLoss(-3)
				spawn(350)	//wait 35 seconds before next volley
					lastpuke = 0

/mob/living/carbon/proc/get_visible_gender()
	if(wear_suit && wear_suit.flags_inv & HIDEJUMPSUIT && ((head && head.flags_inv & HIDEMASK) || wear_mask))
		return NEUTER
	return gender

/mob/living/carbon/proc/increase_germ_level(n)
	if(gloves)
		gloves.germ_level += n
	else
		germ_level += n

/mob/living/carbon/proc/is_lung_ruptured() // TODO update this code and lungs.
	var/obj/item/organ/lungs/IO = organs_by_name[BP_LUNGS]
	return IO && IO.is_bruised()

/mob/living/carbon/proc/rupture_lung()
	var/obj/item/organ/lungs/IO = organs_by_name[BP_LUNGS]

	if(IO && !IO.is_bruised())
		custom_pain("You feel a stabbing pain in your chest!", 50, BP = get_bodypart(IO.parent_bodypart))
		IO.damage = IO.min_bruised_damage

/mob/living/carbon/get_visible_implants(class = 0)
	var/list/visible_implants = list()
	for(var/obj/item/bodypart/BP in src.bodyparts)
		for(var/obj/item/weapon/O in BP.implants)
			if(!istype(O,/obj/item/weapon/implant) && (O.w_class > class) && !istype(O,/obj/item/weapon/shard/shrapnel))
				visible_implants += O

	return(visible_implants)

/mob/living/carbon/embedded_needs_process()
	for(var/obj/item/bodypart/BP in src.bodyparts)
		for(var/obj/item/O in BP.implants)
			if(!istype(O, /obj/item/weapon/implant)) //implant type items do not cause embedding effects, see handle_embedded_objects()
				return TRUE
	return FALSE

/mob/living/carbon/human/proc/handle_embedded_and_stomach_objects()
	for(var/obj/item/bodypart/BP in src.bodyparts)
		if(BP.status & ORGAN_SPLINTED)
			continue
		for(var/obj/item/O in BP.implants)
			if(!istype(O,/obj/item/weapon/implant) && prob(5)) //Moving with things stuck in you could be bad.
				jossle_internal_object(BP, O)
	var/obj/item/bodypart/groin = src.get_bodypart(BP_GROIN)
	if(groin && stomach_contents && stomach_contents.len)
		for(var/obj/item/O in stomach_contents)
			if(O.edge || O.sharp)
				if(prob(1))
					stomach_contents.Remove(O)
					if(can_feel_pain())
						to_chat(src, "<span class='danger'>You feel something rip out of your stomach!</span>")
						groin.embed(O)
				else if(prob(5))
					jossle_internal_object(groin, O)

/mob/living/carbon/human/proc/jossle_internal_object(obj/item/bodypart/BP, obj/item/O)
	// All kinds of embedded objects cause bleeding.
	if(!can_feel_pain())
		to_chat(src, "<span class='warning'>You feel [O] moving inside your [BP.name].</span>")
	else
		var/msg = pick( \
			"<span class='warning'>A spike of pain jolts your [BP.name] as you bump [O] inside.</span>", \
			"<span class='warning'>Your movement jostles [O] in your [BP.name] painfully.</span>", \
			"<span class='warning'>Your movement jostles [O] in your [BP.name] painfully.</span>")
		custom_pain(msg,40,affecting = BP)

	BP.take_damage(rand(1,3), 0, 0)
	if(!(BP.status & ORGAN_ROBOT)) // && (should_have_organ(BP_HEART))) //There is no blood in protheses.
		BP.status |= ORGAN_BLEEDING
		src.adjustToxLoss(rand(1,3))

/*
This function restores the subjects blood to max.
*/
/mob/living/carbon/proc/restore_blood()
	if(!species.flags[NO_BLOOD])
		var/blood_volume = vessel.get_reagent_amount("blood")
		vessel.add_reagent("blood", species.blood_volume - blood_volume)

/mob/living/carbon/proc/get_bodypart(zone)
	if(!zone)	zone = BP_CHEST
	if (zone in list( BP_EYES, BP_MOUTH ))
		zone = BP_HEAD
	return bodyparts_by_name[zone]

// Get rank from ID, ID inside PDA, PDA, ID in wallet, etc.
/mob/living/carbon/proc/get_authentification_rank(if_no_id = "No id", if_no_job = "No job")
	var/obj/item/device/pda/pda = wear_id
	if (istype(pda))
		if (pda.id)
			return pda.id.rank
		else
			return pda.ownrank
	else
		var/obj/item/weapon/card/id/id = get_idcard()
		if(id)
			return id.rank ? id.rank : if_no_job
		else
			return if_no_id

//gets assignment from ID or ID inside PDA or PDA itself
//Useful when player do something with computers
/mob/living/carbon/proc/get_assignment(if_no_id = "No id", if_no_job = "No job")
	var/obj/item/device/pda/pda = wear_id
	var/obj/item/weapon/card/id/id = wear_id
	if (istype(pda))
		if (pda.id && istype(pda.id, /obj/item/weapon/card/id))
			. = pda.id.assignment
		else
			. = pda.ownjob
	else if (istype(id))
		. = id.assignment
	else
		return if_no_id
	if (!.)
		. = if_no_job
	return

//gets name from ID or ID inside PDA or PDA itself
//Useful when player do something with computers
/mob/living/carbon/proc/get_authentification_name(if_no_id = "Unknown")
	var/obj/item/device/pda/pda = wear_id
	var/obj/item/weapon/card/id/id = wear_id
	if (istype(pda))
		if (pda.id)
			. = pda.id.registered_name
		else
			. = pda.owner
	else if (istype(id))
		. = id.registered_name
	else
		return if_no_id
	return

//repurposed proc. Now it combines get_id_name() and get_face_name() to determine a mob's name variable. Made into a seperate proc as it'll be useful elsewhere
/mob/living/carbon/proc/get_visible_name()
	if( wear_mask && (wear_mask.flags_inv&HIDEFACE) )	//Wearing a mask which hides our face, use id-name if possible
		return get_id_name("Unknown")
	if( head && (head.flags_inv&HIDEFACE) )
		return get_id_name("Unknown")		//Likewise for hats
	if(name_override)
		return name_override
	var/face_name = get_face_name()
	var/id_name = get_id_name("")
	if(id_name && (id_name != face_name))
		return "[face_name] (as [id_name])"
	return face_name

//Returns "Unknown" if facially disfigured and real_name if not. Useful for setting name when polyacided or when updating a human's name variable
/mob/living/carbon/proc/get_face_name()
	var/obj/item/bodypart/head/BP = get_bodypart(BP_HEAD)
	if( !BP || BP.is_stump() || BP.disfigured || !real_name || (disabilities & HUSK) )	//disfigured. use id-name if possible
		return "Unknown"
	return real_name

//gets name from ID or PDA itself, ID inside PDA doesn't matter
//Useful when player is being seen by other mobs
/mob/living/carbon/proc/get_id_name(if_no_id = "Unknown")
	. = if_no_id
	if(istype(wear_id,/obj/item/device/pda))
		var/obj/item/device/pda/P = wear_id
		return P.owner
	if(wear_id)
		var/obj/item/weapon/card/id/I = wear_id.GetID()
		if(I)
			return I.registered_name
	return

//gets ID card object from special clothes slot or null.
/mob/living/carbon/proc/get_idcard()
	if(wear_id)
		return wear_id.GetID()

/mob/living/carbon/get_species()
	if(dna && dna.mutantrace == "golem")
		return "Animated Construct"

	return species.name

/mob/living/carbon/proc/set_species(new_species, force_organs, default_colour, list/organ_data)
	if(!new_species)
		return 0

	if(dna)
		dna.species = new_species

	//if(!dna)
	//	if(!new_species)
	//		new_species = S_HUMAN
	//else
	//	if(!new_species)
	//		new_species = dna.species
	//	else
	//		dna.species = new_species

	if(species && (species.name && species.name == new_species))
		return

	if(species && species.language)
		remove_language(species.language)

	species = all_species[new_species]

	if(force_organs || !bodyparts || !bodyparts.len)
		species.create_organs(src, organ_data)
	else if(!force_organs) // when changing one specie into another (without recreating organs), we need to regenerate inventory and hud data.
		for(var/obj/item/bodypart/BP in bodyparts)
			BP.generate_hud_data(species)
		var/hud_style
		var/inv_shown
		if(hud_used)
			hud_style = hud_used.hud_version
			inv_shown = hud_used.inventory_shown
			qdel(hud_used)
		hud_used = new /datum/hud(src, hud_style, inv_shown)// rebuild hud (can be optimized)

	if(species.language)
		add_language(species.language)

	if(species.base_color && default_colour)
		//Apply colour.
		r_skin = hex2num(copytext(species.base_color,2,4))
		g_skin = hex2num(copytext(species.base_color,4,6))
		b_skin = hex2num(copytext(species.base_color,6,8))
	else
		r_skin = 0
		g_skin = 0
		b_skin = 0

	species.handle_post_spawn(src)

	update_icons()

	if(species)
		return 1
	else
		return 0

/mob/living/carbon/IsAdvancedToolUser()
	var/obj/item/organ/brain/BRAIN = organs_by_name[BP_BRAIN]
	if(BRAIN)
		return BRAIN.is_advanced_tool_user
	return FALSE

/mob/living/carbon/on_varedit(modified_var)
	switch(modified_var) // TODO: better implementation..
		if("s_tone")
			if(!species || !species.flags[HAS_SKIN_TONE])
				return
			s_tone = 35 - Clamp(s_tone, 0, 220)
			update_bodyparts()
		if("r_skin")
			if(!species || !species.flags[HAS_SKIN_COLOR])
				return
			r_skin = Clamp(r_skin, 0, 255)
			update_bodyparts()
			update_tail_showing()
		if("g_skin")
			if(!species || !species.flags[HAS_SKIN_COLOR])
				return
			g_skin = Clamp(g_skin, 0, 255)
			update_bodyparts()
			update_tail_showing()
		if("b_skin")
			if(!species || !species.flags[HAS_SKIN_COLOR])
				return
			b_skin = Clamp(b_skin, 0, 255)
			update_bodyparts()
			update_tail_showing()

/mob/living/carbon/proc/AddAbility(obj/effect/proc_holder/alien/A)
	abilities.Add(A)
	A.on_gain(src)
	if(A.has_action)
		A.action.Grant(src)
	sortInsert(abilities, /proc/cmp_abilities_cost, 0)

/mob/living/carbon/proc/RemoveAbility(obj/effect/proc_holder/alien/A)
	abilities.Remove(A)
	A.on_lose(src)
	if(A.action)
		A.action.Remove(src)
