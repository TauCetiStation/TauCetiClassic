/mob/living/carbon/atom_init()
	. = ..()
	carbon_list += src

/mob/living/carbon/Destroy()
	carbon_list -= src
	return ..()

/mob/living/carbon/Life()
	..()

	// Increase germ_level regularly
	if(germ_level < GERM_LEVEL_AMBIENT && prob(80) && !IS_IN_STASIS(src))	//if you're just standing there, you shouldn't get more germs beyond an ambient level
		germ_level++

/mob/living/carbon/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0)
	. = ..()
	if(.)
		handle_phantom_move(NewLoc, Dir)
		if(nutrition && stat != DEAD)
			var/met_factor = get_metabolism_factor()
			nutrition -= met_factor * 0.01
			if(HAS_TRAIT(src, TRAIT_STRESS_EATER))
				var/pain = getHalLoss()
				if(pain > 0)
					nutrition -= met_factor * pain * (m_intent == "run" ? 0.02 : 0.01) // Which is actually a lot if you come to think of it.
			if(m_intent == "run")
				nutrition -= met_factor * 0.01
		if(HAS_TRAIT(src, TRAIT_FAT) && m_intent == "run" && bodytemperature <= 360)
			bodytemperature += 2

		// Moving around increases germ_level faster
		if(germ_level < GERM_LEVEL_MOVE_CAP && prob(8))
			germ_level++

		handle_rig_move(NewLoc, Dir)

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
			audible_message("<span class='rose'>You hear something rumbling inside [src]'s stomach...</span>", hearing_distance = 4)
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
				visible_message("<span class='danger'>[user] attacks [src]'s stomach wall with the [I.name]!</span>")
				playsound(user, 'sound/effects/attackblob.ogg', VOL_EFFECTS_MASTER)

				if(prob(src.getBruteLoss() - 50))
					for(var/atom/movable/A in stomach_contents)
						A.loc = loc
						stomach_contents.Remove(A)
					src.gib()

/mob/living/carbon/attack_animal(mob/living/simple_animal/attacker)
	if(istype(attacker, /mob/living/simple_animal/headcrab))
		var/mob/living/simple_animal/headcrab/crab = attacker
		crab.Infect(src)
		return TRUE
	return ..()

/mob/living/carbon/gib()
	for(var/mob/M in src)
		if(M in src.stomach_contents)
			src.stomach_contents.Remove(M)
		M.loc = src.loc
		visible_message("<span class='danger'>[M] bursts out of [src]!</span>")
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

/mob/living/carbon/attack_unarmed(mob/living/carbon/attacker)
	if(istype(attacker))
		var/spread = TRUE
		if(ishuman(attacker))
			var/mob/living/carbon/human/H = attacker
			if(H.gloves)
				spread = FALSE

		if(spread)
			attacker.spread_disease_to(src, "Contact")

			for(var/datum/disease/D in viruses)
				if(D.spread_by_touch())
					attacker.contract_disease(D, 0, 1, CONTACT_HANDS)

			for(var/datum/disease/D in attacker.viruses)
				if(D.spread_by_touch())
					contract_disease(D, 0, 1, CONTACT_HANDS)
	return ..()

/mob/living/carbon/electrocute_act(shock_damage, obj/source, siemens_coeff = 1.0, def_zone = null, tesla_shock = 0)
	if(status_flags & GODMODE)	return 0	//godmode

	var/turf/T = get_turf(src)
	var/obj/effect/fluid/F = locate() in T
	if(F)
		attack_log += "\[[time_stamp()]\]<font color='red'> [src] was shocked by the [source] and started chain-reaction with water!</font>"
		msg_admin_attack("[key_name(src)] was shocked by the [source] and started chain-reaction with water!", src)
		F.electrocute_act(shock_damage)

	shock_damage *= siemens_coeff
	if(shock_damage<1)
		return 0
	apply_damage(shock_damage, BURN, def_zone, used_weapon="Electrocution")
	if(shock_damage > 10)
		playsound(src, 'sound/effects/electric_shock.ogg', VOL_EFFECTS_MASTER, tesla_shock ? 10 : 50, FALSE) //because Tesla proc causes a lot of sounds
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
		playsound(src, pick(SOUNDIN_SPARKS), VOL_EFFECTS_MASTER)
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
		else if(istype(item_in_hand, /obj/item/weapon/gun/energy/sniperrifle))
			var/obj/item/weapon/gun/energy/sniperrifle/s = item_in_hand
			if(s.zoom)
				s.toggle_zoom()
		else if(istype(item_in_hand, /obj/item/weapon/gun/energy/pyrometer/ce))
			var/obj/item/weapon/gun/energy/pyrometer/ce/C = item_in_hand
			if(C.zoomed)
				C.toggle_zoom()
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

/mob/living/carbon/helpReaction(mob/living/carbon/human/attacker, show_message = TRUE)
	help_shake_act(attacker)
	return TRUE

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
				var/BPname = BP.name
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

				if(BP.is_stump)
					status = "MISSING!"
					BPname = parse_zone(BP.body_zone)
				if(BP.status & ORGAN_MUTATED)
					status = "weirdly shapen."
				if(status == "")
					status = "OK"
				to_chat(src, "\t <span class='[status == "OK" ? "notice " : "warning"]'>My [BPname] is [status].</span>")

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
				AdjustSleeping(-10 SECONDS)
				if (!M.lying)
					if(!IsSleeping())
						src.resting = 0
					if(src.crawling)
						if(crawl_can_use() && src.pass_flags & PASSCRAWL)
							src.pass_flags ^= PASSCRAWL
							src.crawling = 0
					M.visible_message("<span class='notice'>[M] shakes [src] trying to wake [t_him] up!</span>", \
										"<span class='notice'>You shake [src] trying to wake [t_him] up!</span>")
				else
					if(!IsSleeping())
						M.visible_message("<span class='notice'>[M] cuddles with [src] to make [t_him] feel better!</span>", \
								"<span class='notice'>You cuddle with [src] to make [t_him] feel better!</span>")
					else
						M.visible_message("<span class='notice'>[M] gently touches [src] trying to wake [t_him] up!</span>", \
										"<span class='notice'>You gently touch [src] trying to wake [t_him] up!</span>")
			else switch(M.get_targetzone())
				if(BP_R_ARM || BP_L_ARM)
					M.visible_message( "<span class='notice'>[M] shakes [src]'s hand.</span>", \
									"<span class='notice'>You shake [src]'s hand.</span>", )
				if(BP_HEAD)
					M.visible_message("<span class='notice'>[M] pats [src] on the head.</span>", \
									"<span class='notice'>You pat [src] on the head.</span>", )
				if(O_EYES)
					M.visible_message("<span class='notice'>[M] looks into [src]'s eyes.</span>", \
									"<span class='notice'>You look into [src]'s eyes.</span>", )
				if(BP_GROIN)
					M.visible_message("<span class='notice'>[M] does something to [src] to make [t_him] feel better!</span>", \
									"<span class='notice'>You do something to [src] to make [t_him] feel better!</span>", )
				else
					M.visible_message("<span class='notice'>[M] hugs [src] to make [t_him] feel better!</span>", \
									"<span class='notice'>You hug [src] to make [t_him] feel better!</span>")

			AdjustParalysis(-3)
			AdjustStunned(-3)
			AdjustWeakened(-3)

			playsound(src, 'sound/weapons/thudswoosh.ogg', VOL_EFFECTS_MASTER)

/mob/living/carbon/proc/crawl_can_use()
	var/turf/T = get_turf(src)
	if( (locate(/obj/structure/table) in T) || (locate(/obj/structure/stool/bed) in T) || (locate(/obj/structure/plasticflaps) in T))
		return FALSE
	return TRUE

/mob/living/carbon/var/crawl_getup = FALSE
/mob/living/carbon/proc/crawl()
	set name = "Crawl"
	set category = "IC"

	if(incapacitated() || (status_flags & FAKEDEATH) || buckled)
		return
	if(crawl_getup)
		return

	if(crawling)
		crawl_getup = TRUE
		if(do_after(src, 10, target = src))
			crawl_getup = FALSE
			if(!crawl_can_use())
				playsound(src, 'sound/weapons/tablehit1.ogg', VOL_EFFECTS_MASTER)
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
	throw_mode_off()
	if(usr.incapacitated() || !target)
		return
	if(target.type == /obj/screen)
		return

	var/atom/movable/item = get_active_hand()
	if(!item)
		return

	if(istype(item, /obj/item))
		var/obj/item/W = item
		if(!W.canremove || W.flags & NODROP)
			return

	if (istype(item, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = item
		item = G.throw_held() //throw the person instead of the grab
		qdel(G)
		if(isliving(item))
			var/turf/start_T = get_turf(loc) //Get the start and target tile for the descriptors
			var/turf/end_T = get_turf(target)
			if(start_T && end_T)
				var/mob/living/M = item
				var/start_T_descriptor = "<font color='#6b5d00'>tile at [start_T.x], [start_T.y], [start_T.z] in area [get_area(start_T)]</font>"
				var/end_T_descriptor = "<font color='#6b4400'>tile at [end_T.x], [end_T.y], [end_T.z] in area [get_area(end_T)]</font>"

				M.log_combat(usr, "thrown from [start_T_descriptor] with the target [end_T_descriptor]")

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

/mob/living/carbon/show_inv(mob/user)
	user.set_machine(src)
	var/list/dat = list()

	dat += "<table>"
	dat += "<tr><td><B>Left Hand:</B></td><td><A href='?src=\ref[src];item=[SLOT_L_HAND]'>[(l_hand && !(l_hand.flags & ABSTRACT)) ? l_hand : "<font color=grey>Empty</font>"]</a></td></tr>"
	dat += "<tr><td><B>Right Hand:</B></td><td><A href='?src=\ref[src];item=[SLOT_R_HAND]'>[(r_hand && !(r_hand.flags & ABSTRACT)) ? r_hand : "<font color=grey>Empty</font>"]</a></td></tr>"
	dat += "<tr><td>&nbsp;</td></tr>"

	dat += "<tr><td><B>Back:</B></td><td><A href='?src=\ref[src];item=[SLOT_BACK]'>[(back && !(back.flags & ABSTRACT)) ? back : "<font color=grey>Empty</font>"]</A>"
	if(istype(wear_mask, /obj/item/clothing/mask) && istype(back, /obj/item/weapon/tank))
		dat += "&nbsp;<A href='?src=\ref[src];internal=[SLOT_BACK]'>[internal ? "Disable Internals" : "Set Internals"]</A>"
	dat += "</td></tr>"

	dat += "<tr><td><B>Mask:</B></td><td><A href='?src=\ref[src];item=[SLOT_WEAR_MASK]'>[(wear_mask && !(wear_mask.flags & ABSTRACT)) ? wear_mask : "<font color=grey>Empty</font>"]</A></td></tr>"

	if(handcuffed)
		dat += "<tr><td><B>Handcuffed:</B></td><td><A href='?src=\ref[src];item=[SLOT_HANDCUFFED]'>Remove</A></td></tr>"
	if(legcuffed)
		dat += "<tr><td><B>Legcuffed:</B></td><td><A href='?src=\ref[src];item=[SLOT_LEGCUFFED]'>Remove</A></td></tr>"

	dat += {"</table>
	<A href='?src=\ref[user];mach_close=mob\ref[src]'>Close</A>
	"}

	var/datum/browser/popup = new(user, "mob\ref[src]", "[src]", 440, 500)
	popup.set_content(dat.Join())
	popup.open()

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

	if(IsSleeping())
		to_chat(src, "<span class='rose'>You are already sleeping</span>")
		return
	if(alert(src, "You sure you want to sleep for a while?","Sleep","Yes","No") == "Yes")
		SetSleeping(40 SECONDS) //Short nap

//Brain slug proc for voluntary removal of control.
/mob/living/carbon/proc/release_control()

	set category = "Borer"
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
	set category = "Borer"
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
	set category = "Borer"
	set name = "Reproduce"
	set desc = "Spawn several young."

	var/mob/living/simple_animal/borer/B = has_brain_worms()

	if(!B)
		return

	if(B.chemicals >= 100)
		to_chat(src, "<span class='danger'>Your host twitches and quivers as you rapdly excrete several larvae from your sluglike body.</span>")
		B.chemicals -= 100
		B.has_reproduced = 1

		vomit()
		new/mob/living/simple_animal/borer(get_turf(src), TRUE)
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
/mob/living/carbon/get_pixel_y_offset(lying_current = FALSE)
	if(lying)
		if(buckled && istype(buckled, /obj/structure/stool/bed/roller))
			return 1
		else if(locate(/obj/structure/stool/bed/roller, src.loc))
			return -5
		else if(locate(/obj/machinery/optable, src.loc) || locate(/obj/structure/stool/bed, src.loc) || locate(/obj/structure/altar_of_gods, src.loc))	//we need special pixel shift for beds & optable to make mob lying centered
			return -4
		else
			return -6
	else
		return initial(pixel_y)

/mob/living/carbon/get_pixel_x_offset(lying_current = FALSE)
	if(lying)
		if(locate(/obj/machinery/optable, src.loc) || locate(/obj/structure/stool/bed, src.loc) || locate(/obj/structure/altar_of_gods, src.loc))	//we need special pixel shift for beds & optable to make mob lying centered
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


/mob/living/carbon/proc/perform_av(mob/living/carbon/human/user) // don't forget to INVOKE_ASYNC this proc if sleep is a problem.
	if(!ishuman(src) && !isIAN(src))
		return
	if(user.is_busy(src))
		return

	visible_message("<span class='danger'>[user] is trying perform AV on [src]!</span>")

	if(health <= (config.health_threshold_dead + 5))
		var/suff = min(getOxyLoss(), 2) //Pre-merge level, less healing, more prevention of dieing.
		adjustOxyLoss(-suff)

	if(do_mob(user, src, HUMAN_STRIP_DELAY))
		 // yes, we check this after the action, allowing player to try this even if it looks wrong (for fun).
		if(user.species && user.species.flags[NO_BREATHE])
			to_chat(user, "<span class='notice bold'>Your species can not perform AV!</span>")
			return
		if((user.head && (user.head.flags & HEADCOVERSMOUTH)) || (user.wear_mask && (user.wear_mask.flags & MASKCOVERSMOUTH)))
			to_chat(user, "<span class='notice bold'>Remove your mask!</span>")
			return

		if(ishuman(src))
			var/mob/living/carbon/human/H = src
			if(H.species && H.species.flags[NO_BREATHE])
				to_chat(user, "<span class='notice bold'>You can not perform AV on these species!</span>")
				return
			if(wear_mask && wear_mask.flags & MASKCOVERSMOUTH)
				to_chat(user, "<span class='notice bold'>Remove [src] [wear_mask]!</span>")
				return

		if(head && head.flags & HEADCOVERSMOUTH)
			to_chat(user, "<span class='notice bold'>Remove [src] [head]!</span>")
			return

		if (health > config.health_threshold_dead && health < config.health_threshold_crit)
			var/suff = min(getOxyLoss(), 5) //Pre-merge level, less healing, more prevention of dieing.
			adjustOxyLoss(-suff)
			visible_message("<span class='warning'>[user] performs AV on [src]!</span>")
			to_chat(src, "<span class='notice'>You feel a breath of fresh air enter your lungs. It feels good.</span>")
			to_chat(user, "<span class='warning'>Repeat at least every 7 seconds.</span>")
		updatehealth()

/mob/living/carbon/Topic(href, href_list)
	..()

	if (href_list["item"] && usr.CanUseTopicInventory(src))
		var/slot = text2num(href_list["item"])
		var/obj/item/item_to_add = usr.get_active_hand()

		if(item_to_add && (item_to_add.flags & (ABSTRACT | DROPDEL)))
			item_to_add = null

		if(item_to_add && get_slot_ref(slot))
			if(item_to_add.w_class > ITEM_SIZE_SMALL)
				to_chat(usr, "<span class='red'>[src] is already wearing something. You need empty hand to take that off (or holding small item).</span>")
				return
			item_to_add = null

		stripPanelUnEquip(usr, slot, item_to_add)

		if(usr.machine == src && in_range(src, usr))
			show_inv(usr)
		else
			usr << browse(null, "window=mob\ref[src]")

	if (href_list["internal"] && usr.CanUseTopicInventory(src))
		var/slot = text2num(href_list["internal"])
		var/obj/item/weapon/tank/ITEM = get_equipped_item(slot)
		if(ITEM && istype(ITEM) && wear_mask && (wear_mask.flags & MASKINTERNALS))
			visible_message("<span class='danger'>[usr] tries to [internal ? "close" : "open"] the valve on [src]'s [ITEM.name].</span>")

			if(do_mob(usr, src, HUMAN_STRIP_DELAY))
				var/mob/living/carbon/C = src
				var/gas_log_string = ""
				var/internalsound
				if (internal)
					internal.add_fingerprint(usr)
					internal = null
					if (internals)
						internals.icon_state = "internal0"
					internalsound = 'sound/misc/internaloff.ogg'
					if(ishuman(C)) // Because only human can wear a spacesuit
						var/mob/living/carbon/human/H = C
						if(istype(H.head, /obj/item/clothing/head/helmet/space) && istype(H.wear_suit, /obj/item/clothing/suit/space))
							internalsound = 'sound/misc/riginternaloff.ogg'
					playsound(src, internalsound, VOL_EFFECTS_MASTER, null, FALSE, -5)
				else if(ITEM && istype(ITEM, /obj/item/weapon/tank) && wear_mask && (wear_mask.flags & MASKINTERNALS))
					internal = ITEM
					internal.add_fingerprint(usr)
					if (internals)
						internals.icon_state = "internal1"
					internalsound = 'sound/misc/internalon.ogg'
					if(ishuman(C)) // Because only human can wear a spacesuit
						var/mob/living/carbon/human/H = C
						if(istype(H.head, /obj/item/clothing/head/helmet/space) && istype(H.wear_suit, /obj/item/clothing/suit/space))
							internalsound = 'sound/misc/riginternalon.ogg'
					playsound(src, internalsound, VOL_EFFECTS_MASTER, null, FALSE, -5)

					if(ITEM.air_contents && length(ITEM.air_contents.gas))
						gas_log_string = " (gases:"
						for(var/G in ITEM.air_contents.gas)
							gas_log_string += " - [G]=[ITEM.air_contents.gas[G]]"
						gas_log_string += ")"
					else
						gas_log_string = " (gases: empty)"

				visible_message("<span class='danger'>[usr] [internal ? "opens" : "closes"] the valve on [src]'s [ITEM.name].</span>")
				attack_log += text("\[[time_stamp()]\] <font color='orange'>Had their internals [internal ? "open" : "close"] by [usr.name] ([usr.ckey])[gas_log_string]</font>")
				usr.attack_log += text("\[[time_stamp()]\] <font color='red'>[internal ? "opens" : "closes"] the valve on [src]'s [ITEM.name][gas_log_string]</font>")

/mob/living/carbon/vomit(punched = FALSE, masked = FALSE)
	var/mask_ = masked
	if(head && (head.flags & HEADCOVERSMOUTH))
		mask_ = TRUE

	. = ..(punched, mask_)
	if(. && !mask_)
		if(reagents.total_volume > 0)
			var/toxins_puked = 0
			var/datum/reagents/R = new(10)

			while(TRUE)
				var/datum/reagent/R_V = pick(reagents.reagent_list)
				if(istype(R_V, /datum/reagent/water))
					toxins_puked += 0.5
				else if(R_V.id == "carbon")
					toxins_puked += 2
				else if(R_V.id == "anti_toxin")
					toxins_puked += 3
				else if(R_V.id == "thermopsis")
					toxins_puked += 5
				reagents.trans_id_to(R, R_V.id, 1)
				if(R.total_volume >= 10)
					break
				if(reagents.total_volume <= 0)
					break
			R.reaction(loc)
			adjustToxLoss(-toxins_puked)

/mob/living/carbon/update_stat()
	if(stat == DEAD)
		return
	if(IsSleeping())
		stat = UNCONSCIOUS
		blinded = TRUE

/mob/living/carbon/get_unarmed_attack()
	var/retDam = 2
	var/retDamType = BRUTE
	var/retFlags = 0
	var/retVerb = "attacks"
	var/retSound = null
	var/retMissSound = 'sound/weapons/punchmiss.ogg'

	var/specie = get_species()
	var/datum/species/S = all_species[specie]
	if(S)
		var/datum/unarmed_attack/attack = S.unarmed

		retDam = 2 + attack.damage
		retDamType = attack.damType
		retFlags = attack.damage_flags()
		retVerb = pick(attack.attack_verb)

		if(length(attack.attack_sound))
			retSound = pick(attack.attack_sound)

		retMissSound = 'sound/weapons/punchmiss.ogg'

	if(HULK in mutations)
		retDam += 4

	return list("damage" = retDam, "type" = retDamType, "flags" = retFlags, "verb" = retVerb, "sound" = retSound,
				"miss_sound" = retMissSound)

/mob/living/carbon/set_m_intent(intent)
	if(intent == MOVE_INTENT_RUN)
		if(legcuffed)
			to_chat(src, "<span class='notice'>You are legcuffed! You cannot run until you get [legcuffed] removed!</span>")
			return FALSE

	return ..()
