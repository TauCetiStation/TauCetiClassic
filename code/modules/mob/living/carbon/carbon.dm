/mob/living/carbon/atom_init()
	. = ..()
	carbon_list += src

/mob/living/carbon/Destroy()
	carbon_list -= src
	return ..()

/mob/living/carbon/Life()
	..()

	// Increase germ_level regularly
	if(germ_level < GERM_LEVEL_AMBIENT && prob(80))	//if you're just standing there, you shouldn't get more germs beyond an ambient level
		germ_level++

/mob/living/carbon/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0)
	. = ..()
	if(.)
		handle_phantom_move(NewLoc, Dir)
		if(nutrition && stat != DEAD)
			var/met_factor = get_metabolism_factor()
			nutrition -= met_factor * 0.01
			if(has_trait(TRAIT_STRESS_EATER))
				nutrition -= met_factor * getHalLoss() * (m_intent == "run" ? 0.02 : 0.01) // Which is actually a lot if you come to think of it.
			if(m_intent == "run")
				nutrition -= met_factor * 0.01
		if((FAT in mutations) && m_intent == "run" && bodytemperature <= 360)
			bodytemperature += 2

		// Moving around increases germ_level faster
		if(germ_level < GERM_LEVEL_MOVE_CAP && prob(8))
			germ_level++

/mob/living/carbon/relaymove(mob/user, direction)
	if(isessence(user))
		user.setMoveCooldown(1)
		var/mob/living/parasite/essence/essence = user
		if(!(essence.flags_allowed & ESSENCE_PHANTOM))
			to_chat(user, "<span class='userdanger'>Your host forbrade you to own phantom</span>")
			return

		if(!essence.phantom.showed)
			essence.phantom.show_phantom()
			return
		var/tile = get_turf(get_step(essence.phantom, direction))
		if(get_dist(tile, essence.host) < 8)
			essence.phantom.dir = direction
			essence.phantom.loc = tile
		return
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
					var/obj/item/organ/external/BP = H.bodyparts_by_name[BP_CHEST]
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
	..()
	if(istype(M,/mob/living/simple_animal/headcrab))
		var/mob/living/simple_animal/headcrab/crab = M
		crab.Infect(src)
		return TRUE
	return FALSE

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

/mob/living/carbon/attack_hand(mob/M)
	if(!iscarbon(M))
		return

	for(var/datum/disease/D in viruses)
		if(D.spread_by_touch())
			M.contract_disease(D, 0, 1, CONTACT_HANDS)

	for(var/datum/disease/D in M.viruses)
		if(D.spread_by_touch())
			contract_disease(D, 0, 1, CONTACT_HANDS)


/mob/living/carbon/attack_paw(mob/M)
	if(!iscarbon(M))
		return

	for(var/datum/disease/D in viruses)
		if(D.spread_by_touch())
			M.contract_disease(D, 0, 1, CONTACT_HANDS)

	for(var/datum/disease/D in M.viruses)
		if(D.spread_by_touch())
			contract_disease(D, 0, 1, CONTACT_HANDS)

/mob/living/carbon/electrocute_act(shock_damage, obj/source, siemens_coeff = 1.0, def_zone = null, tesla_shock = 0)
	if(status_flags & GODMODE)	return 0	//godmode

	var/turf/T = get_turf(src)
	var/obj/effect/fluid/F = locate() in T
	if(F)
		attack_log += "\[[time_stamp()]\]<font color='red'> [src] was shocked by the [source] and started chain-reaction with water!</font>"
		msg_admin_attack("[key_name(src)] was shocked by the [source] and started chain-reaction with water! [ADMIN_JMP(src)]")
		F.electrocute_act(shock_damage)

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
	if(item_in_hand) //this segment checks if the item in your hand is twohanded.
		if(istype(item_in_hand, /obj/item/weapon/twohanded) || istype(item_in_hand, /obj/item/weapon/gun/projectile/automatic/l6_saw))	//OOP? Generics? Hue hue hue hue ...
			if(item_in_hand:wielded)
				to_chat(usr, "<span class='warning'>Your other hand is too busy holding the [item_in_hand.name]</span>")
				return
	src.hand = !( src.hand )
	if(hud_used.l_hand_hud_object && hud_used.r_hand_hud_object)
		if(hand)	//This being 1 means the left hand is in use
			hud_used.l_hand_hud_object.icon_state = "hand_l_active"
			hud_used.r_hand_hud_object.icon_state = "hand_r_inactive"
		else
			hud_used.l_hand_hud_object.icon_state = "hand_l_inactive"
			hud_used.r_hand_hud_object.icon_state = "hand_r_active"
	/*if (!( src.hand ))
		src.hands.dir = NORTH
	else
		src.hands.dir = SOUTH*/
	return

/mob/living/carbon/proc/activate_hand(selhand) //0 or "r" or "right" for right hand; 1 or "l" or "left" for left hand.

	if(istext(selhand))
		selhand = lowertext(selhand)

		if(selhand == "right" || selhand == "r")
			selhand = 0
		if(selhand == "left" || selhand == "l")
			selhand = 1

	if(selhand != src.hand)
		swap_hand()

/mob/living/carbon/proc/help_shake_act(mob/living/carbon/M)
	if (src.health >= config.health_threshold_crit)
		if(src == M && istype(src, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = src
			src.visible_message( \
				text("<span class='notice'>[src] examines [].</span>",src.gender==MALE?"himself":"herself"), \
				"<span class='notice'>You check yourself for injuries.</span>" \
				)

			for(var/obj/item/organ/external/BP in H.bodyparts)
				var/status = ""
				var/brutedamage = BP.brute_dam
				var/burndamage = BP.burn_dam
				if(halloss > 0)
					if(prob(30))
						brutedamage += halloss
					if(prob(30))
						burndamage += halloss

				if(brutedamage > 40)
					status = "mangled"
				else if(brutedamage > 20)
					status = "bleeding"
				else if(brutedamage > 0)
					status = "bruised"

				if(brutedamage > 0 && burndamage > 0)
					status += " and "

				if(burndamage > 40)
					status += "peeling away"
				else if(burndamage > 10)
					status += "blistered"
				else if(burndamage > 0)
					status += "numb"

				if(BP.status & ORGAN_DESTROYED)
					status = "MISSING!"
				if(BP.status & ORGAN_MUTATED)
					status = "weirdly shapen."
				if(status == "")
					status = "OK"
				src.show_message(text("\t []My [] is [].", status == "OK" ? "\blue " : "\red ", BP.name,status), 1)

			if(roundstart_quirks.len)
				to_chat(src, "<span class='notice'>You have these traits: [get_trait_string()].</span>")

			if(H.species && (H.species.name == SKELETON) && !H.w_uniform && !H.wear_suit)
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
				if (!M.lying)
					if(!src.sleeping)
						src.resting = 0
					if(src.crawling)
						if(crawl_can_use() && src.pass_flags & PASSCRAWL)
							src.pass_flags ^= PASSCRAWL
							src.crawling = 0
					M.visible_message("<span class='notice'>[M] shakes [src] trying to wake [t_him] up!</span>", \
										"<span class='notice'>You shake [src] trying to wake [t_him] up!</span>")
				else
					if(!src.sleeping)
						M.visible_message("<span class='notice'>[M] cuddles with [src] to make [t_him] feel better!</span>", \
								"<span class='notice'>You cuddle with [src] to make [t_him] feel better!</span>")
					else
						M.visible_message("<span class='notice'>[M] gently touches [src] trying to wake [t_him] up!</span>", \
										"<span class='notice'>You gently touch [src] trying to wake [t_him] up!</span>")
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

	if( stat || weakened || stunned || paralysis || resting || sleeping || (status_flags & FAKEDEATH) || buckled)
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
					var/obj/item/organ/external/BP = H.bodyparts_by_name[BP_HEAD]
					BP.take_damage(5, used_weapon = "Facepalm") // what?.. that guy was insane anyway.
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
		if(H.gloves)
			if(H.gloves.clean_blood())
				H.update_inv_gloves()
			H.gloves.germ_level = 0
		else
			if(H.bloody_hands)
				H.bloody_hands = 0
				H.update_inv_gloves()
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

	var/atom/movable/item = src.get_active_hand()

	if(!item || !item:canremove) return

	if (istype(item, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = item
		item = G.throw_held() //throw the person instead of the grab
		qdel(G)
		if(ismob(item))
			var/turf/start_T = get_turf(loc) //Get the start and target tile for the descriptors
			var/turf/end_T = get_turf(target)
			if(start_T && end_T)
				var/mob/M = item
				var/start_T_descriptor = "<font color='#6b5d00'>tile at [start_T.x], [start_T.y], [start_T.z] in area [get_area(start_T)]</font>"
				var/end_T_descriptor = "<font color='#6b4400'>tile at [end_T.x], [end_T.y], [end_T.z] in area [get_area(end_T)]</font>"

				M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been thrown by [usr.name] ([usr.ckey]) from [start_T_descriptor] with the target [end_T_descriptor]</font>")
				usr.attack_log += text("\[[time_stamp()]\] <font color='red'>Has thrown [M.name] ([M.ckey]) from [start_T_descriptor] with the target [end_T_descriptor]</font>")
				msg_admin_attack("[usr.name] ([usr.ckey]) has thrown [M.name] ([M.ckey]) from [start_T_descriptor] with the target [end_T_descriptor] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[usr.x];Y=[usr.y];Z=[usr.z]'>JMP</a>)")

	if(!item) return //Grab processing has a chance of returning null

	src.remove_from_mob(item)

	//actually throw it!
	if (item)
		src.visible_message("<span class='rose'>[src] has thrown [item].</span>")

		newtonian_move(get_dir(target, src))

		item.throw_at(target, item.throw_range, item.throw_speed, src)

		if(ishuman(src))
			var/mob/living/carbon/human/H = src
			if(H.wear_suit && istype(H.wear_suit, /obj/item/clothing/suit))
				var/obj/item/clothing/suit/V = H.wear_suit
				V.attack_reaction(H, REACTION_THROWITEM)

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

/mob/living/carbon/u_equip(obj/item/W)
	if(!W)	return 0

	else if (W == handcuffed)
		handcuffed = null
		update_inv_handcuffed()
		if(buckled && buckled.buckle_require_restraints)
			buckled.unbuckle_mob()

	else if (W == legcuffed)
		legcuffed = null
		update_inv_legcuffed()
	else
	 ..()

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
	user << browse(entity_ja(dat), text("window=mob[];size=325x500", name))
	onclose(user, "mob[name]")
	return

//generates realistic-ish pulse output based on preset levels
/mob/living/carbon/proc/get_pulse(method)	//method 0 is for hands, 1 is for machines, more accurate
	var/temp = 0								//see setup.dm:694
	switch(src.pulse)
		if(PULSE_NONE)
			return "0"
		if(PULSE_SLOW)
			temp = rand(40, 60)
			return num2text(method ? temp : temp + rand(-10, 10))
		if(PULSE_NORM)
			temp = rand(60, 90)
			return num2text(method ? temp : temp + rand(-10, 10))
		if(PULSE_FAST)
			temp = rand(90, 120)
			return num2text(method ? temp : temp + rand(-10, 10))
		if(PULSE_2FAST)
			temp = rand(120, 160)
			return num2text(method ? temp : temp + rand(-10, 10))
		if(PULSE_THREADY)
			return method ? ">250" : "extremely weak and fast, patient's artery feels like a thread"
//			output for machines^	^^^^^^^output for people^^^^^^^^^

/mob/living/carbon/verb/mob_sleep()
	set name = "Sleep"
	set category = "IC"

	if(sleeping)
		to_chat(src, "<span class='rose'>You are already sleeping</span>")
		return
	if(alert(src, "You sure you want to sleep for a while?","Sleep","Yes","No") == "Yes")
		sleeping = 20 //Short nap

/mob/living/carbon/slip(slipped_on, stun_duration=4, weaken_duration=2)
	if(buckled || sleeping || weakened || paralysis || stunned || resting || crawling)
		return FALSE
	stop_pulling()
	to_chat(src, "<span class='warning'>You slipped on [slipped_on]!</span>")
	playsound(loc, 'sound/misc/slip.ogg', 50, 1, -3)
	if (stun_duration > 0)
		Stun(stun_duration)
	if(weaken_duration > 0)
		Weaken(weaken_duration)
	return TRUE

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

/mob/living/carbon/proc/uncuff()
	if(handcuffed)
		var/obj/item/weapon/W = handcuffed
		handcuffed = null
		if(buckled && buckled.buckle_require_restraints)
			buckled.unbuckle_mob()
		update_inv_handcuffed()
		if(client)
			client.screen -= W
		if(W)
			W.loc = loc
			W.dropped(src)
			if(W)
				W.layer = initial(W.layer)
				W.plane = initial(W.plane)
	if(legcuffed)
		var/obj/item/weapon/W = legcuffed
		legcuffed = null
		update_inv_legcuffed()
		if (client)
			client.screen -= W
		if (W)
			W.loc = loc
			W.dropped(src)
			if(W)
				W.layer = initial(W.layer)
				W.plane = initial(W.plane)

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

/mob/living/carbon/proc/bloody_hands(mob/living/source, amount = 2)
	return

/mob/living/carbon/proc/bloody_body(mob/living/source)
	return

/mob/living/carbon/is_nude(maximum_coverage = 0, pos_slots = list(src.head, src.shoes, src.neck, src.mouth))
	// We for some reason assume that the creature wearing human clothes has human-like anatomy. Mind-boggling, huh?
	var/percentage_covered = 0

	var/head_covered = FALSE
	var/face_covered = FALSE
	var/eyes_covered = FALSE
	var/mouth_covered = FALSE
	var/chest_covered = FALSE
	var/groin_covered = FALSE
	var/legs_covered = 0
	var/arms_covered = 0

	for(var/obj/item/I in pos_slots)
		if(!eyes_covered && ((I.flags & (GLASSESCOVERSEYES|MASKCOVERSEYES|HEADCOVERSEYES)) || I.flags_inv & HIDEEYES)) // All of them refer to the same value, but for reader's sake...
			percentage_covered += EYES_COVERAGE
			eyes_covered = TRUE
		if(!mouth_covered && ((I.flags & (MASKCOVERSMOUTH|HEADCOVERSMOUTH)) || I.flags_inv & HIDEMASK))
			percentage_covered += MOUTH_COVERAGE
			mouth_covered = TRUE
		if(!face_covered && (I.flags_inv & HIDEFACE))
			percentage_covered += FACE_COVERAGE
			face_covered = TRUE
		if(!head_covered && (I.body_parts_covered & HEAD))
			percentage_covered += HEAD_COVERAGE
			head_covered = TRUE
		if(!chest_covered && (I.body_parts_covered & UPPER_TORSO))
			percentage_covered += CHEST_COVERAGE
			chest_covered = TRUE
		if(!groin_covered && (I.body_parts_covered & LOWER_TORSO))
			percentage_covered += GROIN_COVERAGE
			groin_covered = TRUE
		if(legs_covered < 2 && (I.body_parts_covered & LEG_LEFT))
			percentage_covered += LEGS_COVERAGE
			legs_covered++
		if(legs_covered < 2 && (I.body_parts_covered & LEG_RIGHT)) // Because one thing can cover both and we need to check seperately and asdosadas
			percentage_covered += LEGS_COVERAGE
			legs_covered++
		if(arms_covered < 2 && (I.body_parts_covered & ARM_LEFT))
			percentage_covered += ARMS_COVERAGE
			arms_covered++
		if(arms_covered < 2 && (I.body_parts_covered & ARM_RIGHT))
			percentage_covered += ARMS_COVERAGE
			arms_covered++

	return percentage_covered <= maximum_coverage

/mob/living/carbon/naturechild_check()
	return is_nude(maximum_coverage = 20) && !istype(head, /obj/item/clothing/head/bearpelt) && !istype(head, /obj/item/weapon/holder)

/mob/living/carbon/proc/handle_phantom_move(NewLoc, direct)
	if(!mind || !mind.changeling || length(mind.changeling.essences) < 1)
		return
	if(loc == NewLoc)
		for(var/mob/living/parasite/essence/essence in mind.changeling.essences)
			if(essence.phantom.showed)
				essence.phantom.loc = get_turf(get_step(essence.phantom, direct))

/mob/living/carbon/proc/remove_passemotes_flag()
	for(var/thing in src)
		if(istype(thing, /obj/item/weapon/holder))
			return
		if(istype(thing, /mob/living/carbon/monkey/diona))
			return
	status_flags &= ~PASSEMOTES

/mob/living/carbon/proc/can_eat(flags = 255) //I don't know how and why does it work
	return TRUE

/mob/living/carbon/proc/crawl_in_blood(obj/effect/decal/cleanable/blood/floor_blood)
	return

/mob/living/carbon/get_nutrition()
	return nutrition + (reagents.get_reagent("nutriment") + reagents.get_reagent("plantmatter") + reagents.get_reagent("protein") + reagents.get_reagent("dairy")) * 2.5 // We multiply by this "magic" number, because all of these are equal to 2.5 nutrition.

/mob/living/carbon/get_metabolism_factor()
	. = metabolism_factor
