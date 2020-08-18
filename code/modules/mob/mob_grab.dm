///Process_Grab()
///Called by client/Move()
///Checks to see if you are grabbing anything and if moving will affect your grab.
/client/proc/Process_Grab()
	for(var/obj/item/weapon/grab/G in mob.GetGrabs())
		if(G.state == GRAB_KILL) //no wandering across the station/asteroid while choking someone
			mob.visible_message("<span class='warning'>[mob] lost \his tight grip on [G.affecting]'s neck!</span>")
			G.set_state(GRAB_NECK)

/obj/item/weapon/grab
	name = "grab"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "reinforce"
	flags = DROPDEL|NOBLUDGEON
	var/obj/screen/grab/hud = null
	var/mob/living/affecting = null
	var/mob/living/assailant = null
	var/state = GRAB_NONE

	var/allow_upgrade = 1
	var/last_hit_zone = 0
	var/force_down //determines if the affecting mob will be pinned to the ground
	var/dancing //determines if assailant and affecting keep looking at each other. Basically a wrestling position

	layer = 21
	abstract = 1
	item_state = "nothing"
	w_class = ITEM_SIZE_HUGE

/mob/proc/canGrab(atom/movable/target, show_warnings = TRUE)
	if(QDELETED(src) || QDELETED(target))
		return FALSE
	if(target == src)
		return FALSE
	if(!isturf(target.loc))
		return FALSE
	if(incapacitated())
		return FALSE
	if(target.anchored)
		return FALSE
	return TRUE

/mob/proc/tryGrab(atom/movable/target, force_state, show_warnings = TRUE)
	if(!canGrab(target, show_warnings))
		return FALSE

	for(var/obj/item/weapon/grab/G in GetGrabs())
		if(G.affecting == target)
			if(show_warnings)
				to_chat(src, "<span class='warning'>You already grabbed [target]</span>")
			return FALSE

	if(!target.Adjacent(src))
		return FALSE
	if(get_active_hand() && get_inactive_hand())
		if(show_warnings)
			to_chat(src, "<span class='warning'>You are holding too much stuff already.</span>")
		return FALSE

	if(SEND_SIGNAL(target, COMSIG_MOVABLE_TRY_GRAB, src, force_state, show_warnings) & COMPONENT_PREVENT_GRAB)
		return FALSE

	Grab(target, force_state, show_warnings)
	return TRUE

/mob/proc/Grab(atom/movable/target, force_state, show_warnings = TRUE)
	return

/obj/item/weapon/grab/atom_init(mapload, mob/victim, initial_state = GRAB_PASSIVE)
	. = ..()
	assailant = loc
	affecting = victim

	hud = new /obj/screen/grab(src)
	hud.master = src

	victim.grabbed_by += src
	victim.LAssailant = assailant

	set_state(initial_state)
	assailant.put_in_hands(src)

	//check if assailant is grabbed by victim as well
	if(assailant.grabbed_by)
		for (var/obj/item/weapon/grab/G in assailant.grabbed_by)
			if(G.assailant == affecting && G.affecting == assailant)
				G.dancing = 1
				G.adjust_position()
				dancing = 1

	synch()
	playsound(victim, 'sound/weapons/thudswoosh.ogg', VOL_EFFECTS_MASTER)

	switch(state)
		if(GRAB_PASSIVE)
			assailant.visible_message("<span class='red'>[assailant] has grabbed [affecting] passively!</span>")
		if(GRAB_AGGRESSIVE)
			visible_message("<span class='warning'><b>\The [assailant]</b> seizes [affecting] aggressively!</span>")
		if(GRAB_NECK)
			visible_message("<span class='warning'><b>\The [assailant]</b> has grabbed [affecting] by the neck!</span>")

	START_PROCESSING(SSobj, src)

//Used by throw code to hand over the mob, instead of throwing the grab. The grab is then deleted by the throw code.
/obj/item/weapon/grab/proc/throw_held()
	if(affecting)
		if(affecting.buckled)
			return null
		if(state >= GRAB_AGGRESSIVE)
			animate(affecting, pixel_x = 0, pixel_y = 0, 4, 1)
			return affecting
	return null


//This makes sure that the grab screen object is displayed in the correct hand.
/obj/item/weapon/grab/proc/synch()
	if(affecting)
		if(assailant.r_hand == src)
			hud.screen_loc = ui_rhand
		else if(assailant.l_hand == src)
			hud.screen_loc = ui_lhand
		else
			qdel(src)

/obj/item/weapon/grab/proc/set_state(_state, adjust_time = 5, force_loc = FALSE, force_dir = 0)
	var/next_move_cd = CLICK_CD_GRAB
	if(_state == GRAB_PASSIVE)
		next_move_cd *= 0.5
	assailant.SetNextMove(next_move_cd)

	if(_state != state)
		state = _state
		switch(state)
			if(GRAB_PASSIVE)
				hud.name = "reinforce grab ([affecting])"
				hud.icon_state = "reinforce"
				icon_state = "grabbed"
			if(GRAB_AGGRESSIVE)
				hud.icon_state = "reinforce1"
				icon_state = "grabbed1"
			if(GRAB_NECK)
				hud.name = "kill ([affecting])"
				hud.icon_state = "kill"
				icon_state = "grabbed+1"
			if(GRAB_KILL)
				hud.icon_state = "kill1"
		adjust_position(adjust_time, force_loc, force_dir)

/mob/proc/StopGrabs()
	for(var/obj/item/weapon/grab/G in get_hand_slots())
		qdel(G)

/mob/proc/GetGrabs()
	. = list()
	for(var/obj/item/weapon/grab/G in get_hand_slots())
		. += G

/obj/item/weapon/grab/process()
	confirm()

	if(!assailant)
		qdel(src) // Same here, except we're trying to delete ourselves.
		return PROCESS_KILL

	if(!affecting)
		qdel(src)
		return PROCESS_KILL

	if(affecting.buckled)
		qdel(src)
		return PROCESS_KILL

	if(assailant.client)
		assailant.client.screen -= hud
		assailant.client.screen += hud

	if(assailant.pulling == affecting)
		assailant.stop_pulling()

	if(state <= GRAB_AGGRESSIVE)
		allow_upgrade = 1
		//disallow upgrading if we're grabbing more than one person
		if((assailant.l_hand && assailant.l_hand != src && istype(assailant.l_hand, /obj/item/weapon/grab)))
			var/obj/item/weapon/grab/G = assailant.l_hand
			if(G.affecting != affecting)
				allow_upgrade = 0
		if((assailant.r_hand && assailant.r_hand != src && istype(assailant.r_hand, /obj/item/weapon/grab)))
			var/obj/item/weapon/grab/G = assailant.r_hand
			if(G.affecting != affecting)
				allow_upgrade = 0

		//disallow upgrading past aggressive if we're being grabbed aggressively
		for(var/obj/item/weapon/grab/G in affecting.grabbed_by)
			if(G == src) continue
			if(G.state >= GRAB_AGGRESSIVE)
				allow_upgrade = 0

		if(allow_upgrade)
			if(state < GRAB_AGGRESSIVE)
				hud.icon_state = "reinforce"
			else
				hud.icon_state = "reinforce1"
		else
			hud.icon_state = "!reinforce"

	if(state >= GRAB_AGGRESSIVE)
		affecting.drop_l_hand()
		affecting.drop_r_hand()

		var/hit_zone = assailant.zone_sel.selecting
		var/announce = 0
		if(hit_zone != last_hit_zone)
			announce = 1
		last_hit_zone = hit_zone
		if(ishuman(affecting))
			var/mob/living/carbon/human/AH = affecting
			if(!AH.is_in_space_suit(only_helmet = TRUE))
				switch(hit_zone)
					if(O_MOUTH)
						if(announce)
							assailant.visible_message("<span class='warning'>[assailant] covers [AH]'s mouth!</span>")
						if(AH.silent < 3)
							AH.silent = 3
					if(O_EYES)
						if(announce)
							assailant.visible_message("<span class='warning'>[assailant] covers [AH]'s eyes!</span>")
						if(AH.eye_blind < 3)
							AH.eye_blind = 3
		if(force_down)
			if(affecting.loc != assailant.loc)
				force_down = 0
			else
				affecting.Weaken(2)

	if(state >= GRAB_NECK)
		if(ishuman(affecting))
			var/mob/living/carbon/human/H = affecting
			var/obj/item/organ/external/BP = H.bodyparts_by_name[BP_HEAD]
			BP.add_autopsy_data("Strangled", 0, BRUISE) //if 0, then unknow
			if(!BP || BP.is_stump)
				qdel(src)
				return PROCESS_KILL
		affecting.Stun(1)
		if(isliving(affecting))
			var/mob/living/L = affecting
			L.adjustOxyLoss(1)

	if(state >= GRAB_KILL)
		//affecting.apply_effect(STUTTER, 5) //would do this, but affecting isn't declared as mob/living for some stupid reason.
		affecting.stuttering = max(affecting.stuttering, 5) //It will hamper your voice, being choked and all.
		affecting.Weaken(5)	//Should keep you down unless you get help.
		affecting.losebreath = max(affecting.losebreath + 2, 3)

	adjust_position()


/obj/item/weapon/grab/attack_self()
	return s_click(hud)


//Updating pixelshift, position and direction
//Gets called on process, when the grab gets upgraded or the assailant moves
/obj/item/weapon/grab/proc/adjust_position(adjust_time = 5, force_loc = FALSE, force_dir = 0)
	if(!affecting)
		return
	if(affecting.buckled)
		animate(affecting, pixel_x = 0, pixel_y = 0, time = adjust_time, 1, LINEAR_EASING)
		return
	if(affecting.lying && state != GRAB_KILL)
//		animate(affecting, pixel_x = 0, pixel_y = 0, 5, 1, LINEAR_EASING)
		if(force_down)
			affecting.set_dir(SOUTH) //face up
		return
	var/shift = 0
	var/adir = get_dir(assailant, affecting)
	affecting.layer = 4
	switch(state)
		if(GRAB_PASSIVE)
			shift = 8
			if(dancing) //look at partner
				shift = 10
				assailant.set_dir(get_dir(assailant, affecting))
		if(GRAB_AGGRESSIVE)
			shift = 12
		if(GRAB_NECK)
			shift = -10
			if(!force_dir)
				force_dir = assailant.dir
			affecting.set_dir(assailant.dir)
			force_loc = TRUE
		if(GRAB_KILL)
			shift = 0
			if(!force_dir)
				force_dir = NORTH
			affecting.set_dir(SOUTH) //face up
			force_loc = TRUE

	if(force_dir)
		adir = force_dir

	if(force_loc)
		affecting.forceMove(assailant.loc)

	switch(adir)
		if(NORTH)
			if(adjust_time == 0)
				affecting.pixel_x = 0
				affecting.pixel_y = -shift
			animate(affecting, pixel_x = 0, pixel_y =-shift, time = adjust_time, TRUE, LINEAR_EASING)
			affecting.layer = 3.9
		if(SOUTH)
			if(adjust_time == 0)
				affecting.pixel_x = 0
				affecting.pixel_y = shift
			animate(affecting, pixel_x = 0, pixel_y = shift, time = adjust_time, TRUE, LINEAR_EASING)
		if(WEST)
			if(adjust_time == 0)
				affecting.pixel_x = shift
				affecting.pixel_y = 0
			animate(affecting, pixel_x = shift, pixel_y = 0, time = adjust_time, TRUE, LINEAR_EASING)
		if(EAST)
			if(adjust_time == 0)
				affecting.pixel_x = -shift
				affecting.pixel_y = 0
			animate(affecting, pixel_x =-shift, pixel_y = 0, time = adjust_time, TRUE, LINEAR_EASING)

/obj/item/weapon/grab/proc/s_click(obj/screen/S)
	if(!affecting)
		return
	if(!assailant)
		return
	if(assailant.next_move > world.time)
		return
	if(assailant.incapacitated())
		qdel(src)
		return

	if(state < GRAB_AGGRESSIVE)
		if(!allow_upgrade)
			return
		if(!affecting.lying)
			assailant.visible_message("<span class='warning'>[assailant] has grabbed [affecting] aggressively (now hands)!</span>")
		else
			assailant.visible_message("<span class='warning'>[assailant] pins [affecting] down to the ground (now hands)!</span>")
			force_down = 1
			affecting.Weaken(3)
			step_to(assailant, affecting)
			assailant.set_dir(EAST) //face the victim
			affecting.set_dir(SOUTH) //face up
		set_state(GRAB_AGGRESSIVE)

	else if(state < GRAB_NECK)
		if(isslime(affecting))
			to_chat(assailant, "<span class='notice'>You squeeze [affecting], but nothing interesting happens.</span>")
			return
		if(ishuman(affecting))
			var/mob/living/carbon/human/H = affecting
			var/obj/item/organ/external/BP = H.bodyparts_by_name[BP_HEAD]
			if(!BP || BP.is_stump)
				to_chat(assailant, "<span class='warning'>You can't take a headless man by the neck!</span>")
				return
		assailant.visible_message("<span class='warning'>[assailant] has reinforced \his grip on [affecting] (now neck)!</span>")
		assailant.set_dir(get_dir(assailant, affecting))

		affecting.log_combat(assailant, "neck-grabbed")

		affecting.Stun(10) //10 ticks of ensured grab
		set_state(GRAB_NECK)

	else if(state < GRAB_KILL)
		if(ishuman(affecting))
			var/mob/living/carbon/human/AH = affecting
			if(AH.is_in_space_suit())
				to_chat(assailant, "<span class='notice'>You can't strangle him, because space helmet covers [affecting]'s neck.</span>")
				return

		assailant.visible_message("<span class='danger'>[assailant] has tightened \his grip on [affecting]'s neck!</span>")

		affecting.log_combat(assailant, "strangled")

		affecting.losebreath += 1
		affecting.set_dir(WEST)

		set_state(GRAB_KILL)

//This is used to make sure the victim hasn't managed to yackety sax away before using the grab.
/obj/item/weapon/grab/proc/confirm()
	if(!assailant || !affecting)
		qdel(src)
		return 0

	if(affecting)
		if(!isturf(assailant.loc) || ( !isturf(affecting.loc) || assailant.loc != affecting.loc && get_dist(assailant, affecting) > 1) )
			qdel(src)
			return 0

	return 1


/obj/item/weapon/grab/attack(mob/M, mob/living/user)
	if(QDELETED(src))
		return

	if(!affecting)
		return

	if(!M.Adjacent(user))
		qdel(src)
		return

	assailant.SetNextMove(CLICK_CD_ACTION)

	if(M == affecting)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			var/hit_zone = assailant.zone_sel.selecting
			flick(hud.icon_state, hud)
			switch(assailant.a_intent)
				if(INTENT_HELP)
					if(force_down)
						to_chat(assailant, "<span class='warning'>You are no longer pinning [affecting] to the ground.</span>")
						force_down = 0
						return
					if(state >= GRAB_AGGRESSIVE)
						if(!H.apply_pressure(assailant, hit_zone))
							if(hit_zone == BP_CHEST)
								var/obj/item/organ/external/BP = H.bodyparts_by_name[ran_zone(hit_zone)]
								var/armor_block = H.run_armor_check(BP, "melee")

								var/chance_to_force_vomit = 30
								if(H.stat >= UNCONSCIOUS)
									chance_to_force_vomit += 20
								if(prob(armor_block))
									chance_to_force_vomit = 0
								user.visible_message("<span class='notice'>[user] squeezes [H], trying to make them puke.</span>")
								if(prob(chance_to_force_vomit))
									H.vomit(punched=TRUE)
					else if(hit_zone == O_MOUTH && ishuman(user))
						var/mob/living/carbon/human/H_H = user
						H_H.force_vomit(H)
					else
						inspect_organ(affecting, assailant, hit_zone)
				if(INTENT_GRAB)
					if(state < GRAB_AGGRESSIVE)
						to_chat(assailant, "<span class='warning'>You require a better grab to do this.</span>")
						return
					var/obj/item/organ/external/BP = H.bodyparts_by_name[check_zone(hit_zone)]
					if(!BP)
						return
					assailant.visible_message("<span class='danger'>[assailant] [pick("bent", "twisted")] [H]'s [BP.name] into a jointlock!</span>")
					var/armor = H.run_armor_check(H, "melee")
					if(armor < 2)
						to_chat(H, "<span class='danger'>You feel extreme pain!</span>")
						H.adjustHalLoss(clamp(0, 40 - H.halloss, 40)) //up to 40 halloss
					return
				if(INTENT_HARM)
					if(hit_zone == O_EYES)
						if(state < GRAB_NECK)
							to_chat(assailant, "<span class='warning'>You require a better grab to do this.</span>")
							return
						if((H.head && H.head.flags & HEADCOVERSEYES) || (H.wear_mask && H.wear_mask.flags & MASKCOVERSEYES) || (H.glasses && H.glasses.flags & GLASSESCOVERSEYES))
							to_chat(assailant, "<span class='danger'>You're going to need to remove the eye covering first.</span>")
							return
						if(!affecting.has_organ(O_EYES))
							to_chat(assailant, "<span class='danger'>You cannot locate any eyes on [affecting]!</span>")
							return
						assailant.visible_message("<span class='danger'>[assailant] pressed \his fingers into [affecting]'s eyes!</span>")
						to_chat(affecting, "<span class='danger'>You experience immense pain as you feel digits being pressed into your eyes!</span>")

						affecting.log_combat(assailant, "finger-pressed into the eyes")

						var/obj/item/organ/internal/eyes/IO = affecting:organs_by_name[O_EYES]
						IO.damage += rand(3,4)
						if (IO.damage >= IO.min_broken_damage)
							if(affecting.stat != DEAD)
								to_chat(affecting, "<span class='warning'>You go blind!</span>")
					else if(state >= GRAB_AGGRESSIVE && hit_zone == BP_CHEST)
						var/chance_to_force_vomit = 30

						if(ishuman(user))
							var/mob/living/carbon/human/H_user = user
							var/datum/unarmed_attack/attack = H_user.species.unarmed

							var/damage = rand(1, 5)
							damage += attack.damage

							var/obj/item/organ/external/BP = H.bodyparts_by_name[ran_zone(hit_zone)]
							var/armor_block = H.run_armor_check(BP, "melee")

							if(attack.damage_flags() & (DAM_SHARP|DAM_EDGE))
								chance_to_force_vomit = 0
							else
								chance_to_force_vomit += attack.damage
							if(prob(armor_block))
								chance_to_force_vomit = 0
							H.apply_damage(damage, BRUTE, BP, armor_block, attack.damage_flags())

						else
							H.adjustBruteLoss(3)

						user.visible_message("<span class='warning'>[user] punches [H] in the gut, trying to make them puke.</span>")
						if(prob(chance_to_force_vomit))
							H.vomit(punched=TRUE)
//					else if(hit_zone != BP_HEAD)
//						if(state < GRAB_NECK)
//							assailant << "<span class='warning'>You require a better grab to do this.</span>"
//							return
//						if(affecting:grab_joint(assailant))
//							playsound(src, 'sound/weapons/thudswoosh.ogg', VOL_EFFECTS_MASTER)
//							return
					else
						if(affecting.lying)
							return
						assailant.visible_message("<span class='danger'>[assailant] thrusts \his head into [affecting]'s skull!</span>")
						var/damage = 20
						if(iscarbon(assailant))
							var/mob/living/carbon/assailant_C = assailant
							var/obj/item/clothing/hat = assailant_C.head
							if(istype(hat))
								damage += hat.force * 10
						var/armor = affecting.run_armor_check(BP_HEAD, "melee")
						var/armor_assailant = assailant.run_armor_check(BP_HEAD, "melee")
						affecting.apply_damage(damage*rand(90, 110)/100, BRUTE, BP_HEAD, blocked = armor)
						assailant.apply_damage(10*rand(90, 110)/100, BRUTE, BP_HEAD, blocked = armor_assailant)
						if(!armor && prob(damage))
							affecting.apply_effect(20, PARALYZE)
							affecting.visible_message("<span class='danger'>[affecting] has been knocked unconscious!</span>")
						playsound(assailant, pick(SOUNDIN_GENHIT), VOL_EFFECTS_MASTER)

						affecting.log_combat(assailant, "headbutted")

						assailant.drop_from_inventory(src)
						src.loc = null
						qdel(src)
						return
				if(INTENT_PUSH)
					if(state < GRAB_AGGRESSIVE)
						to_chat(assailant, "<span class='warning'>You require a better grab to do this.</span>")
						return
					to_chat(assailant, "<span class='warning'>You start forcing [affecting] to the ground.</span>")
					if(!force_down)
						sleep(20)
						assailant.visible_message("<span class='danger'>[assailant] is forcing [affecting] to the ground!</span>")
						force_down = 1
						affecting.Weaken(3)
						affecting.lying = 1
						step_to(assailant, affecting)
						assailant.set_dir(EAST) //face the victim
						affecting.set_dir(SOUTH) //face up
						affecting.layer = 3.9
						return
					else
						to_chat(assailant, "<span class='warning'>You are already pinning [affecting] to the ground.</span>")
						return

	if(M == assailant && state >= GRAB_AGGRESSIVE)
		if( (ishuman(user) && HAS_TRAIT(user, TRAIT_FAT) && ismonkey(affecting) ) || ( isxeno(user) && iscarbon(affecting) ) )
			var/mob/living/carbon/attacker = user
			user.visible_message("<span class='danger'>[user] is attempting to devour [affecting]!</span>")
			if(istype(user, /mob/living/carbon/xenomorph/humanoid/hunter))
				if(!do_mob(user, affecting)||!do_after(user, 30, target = affecting)) return
			else
				if(!do_mob(user, affecting)||!do_after(user, 100, target = affecting)) return
			user.visible_message("<span class='danger'>[user] devours [affecting]!</span>")
			if(isxeno(user))
				if(affecting.stat == DEAD)
					affecting.gib()
					if(attacker.health >= attacker.maxHealth - attacker.getCloneLoss())
						attacker.adjustToxLoss(100)
						to_chat(attacker, "<span class='notice'>You gain some plasma.</span>")
					else
						attacker.adjustBruteLoss(-100)
						attacker.adjustFireLoss(-100)
						attacker.adjustOxyLoss(-100)
						attacker.adjustCloneLoss(-100)
						to_chat(attacker, "<span class='notice'>You feel better.</span>")
				else
					affecting.loc = user
					attacker.stomach_contents.Add(affecting)
			else
				affecting.loc = user
				attacker.stomach_contents.Add(affecting)
			qdel(src)

/obj/item/weapon/grab/Destroy()
	if(affecting)
		animate(affecting, pixel_x = 0, pixel_y = 0, 4, 1, LINEAR_EASING)
		affecting.layer = 4
		if(affecting)
			affecting.grabbed_by -= src
			affecting = null
	if(assailant)
		if(assailant.client)
			assailant.client.screen -= hud
		assailant = null
	QDEL_NULL(hud)
	return ..()

/obj/item/weapon/grab/proc/inspect_organ(mob/living/carbon/human/H, mob/user, target_zone)

	var/obj/item/organ/external/BP = H.get_bodypart(target_zone)
	var/foundwound = FALSE
	var/foundgerm = FALSE
	var/foundorganwound = FALSE
	var/foundorgangerm = FALSE

	if(!BP || (BP.is_stump))
		to_chat(user, "<span class='notice'>[H] is missing that bodypart.</span>")
		return

	user.visible_message("<span class='notice'>[user] starts inspecting [affecting]'s [BP.name] carefully.</span>")
	if(!do_mob(user,H, 30))
		to_chat(user, "<span class='notice'>You must stand still to inspect [BP] for wounds.</span>")
	else
		if(length(BP.wounds))
			to_chat(user, "<span class='warning'>You find [BP.get_wounds_desc()]</span>")
			foundwound = TRUE
		if(length(BP.implants))
			to_chat(user, "<span class='notice'>You feel something solid under [BP.name]'s skin.</span>")
		if(BP.germ_level >= INFECTION_LEVEL_ONE)
			foundgerm = TRUE
		for(var/obj/item/organ/internal/IO in BP.bodypart_organs)
			if(IO.is_bruised())
				foundorganwound = TRUE
			if(IO.germ_level >= INFECTION_LEVEL_ONE)
				foundorgangerm = TRUE
		if(foundorgangerm && !foundgerm)
			to_chat(user, "<span class='warning'>Lymph nodes in the [BP.name] are slightly enlarged.</span>")
			foundwound = TRUE
		if(foundorganwound)
			to_chat(user, "<span class='warning'>You find ecchymosis and inflation in the [BP.name].</span>")
			foundwound = TRUE
		if(foundgerm)
			to_chat(user, "<span class='warning'>Lymph nodes in the [BP.name] are greatly enlarged.</span>")
			foundwound = TRUE
		if(!foundwound)
			to_chat(user, "<span class='notice'>You find no visible wounds.</span>")

	to_chat(user, "<span class='notice'>Checking bones now...</span>")
	if(!do_mob(user, H, 60))
		to_chat(user, "<span class='notice'>You must stand still to feel [BP] for fractures.</span>")
	else if(BP.status & ORGAN_BROKEN)
		to_chat(user, "<span class='warning'>The bone in the [BP.name] moves slightly when you poke it!</span>")
		H.custom_pain("Your [BP.name] hurts where it's poked.")
	else
		to_chat(user, "<span class='notice'>The bones in the [BP.name] seem to be fine.</span>")

	to_chat(user, "<span class='notice'>Checking skin now...</span>")
	if(!do_mob(user, H, 30))
		to_chat(user, "<span class='notice'>You must stand still to check [H]'s skin for abnormalities.</span>")
	else
		var/bad = 0
		if(H.getToxLoss() >= 40)
			to_chat(user, "<span class='warning'>[H] has an unhealthy skin discoloration.</span>")
			bad = 1
		if(H.getOxyLoss() >= 20)
			to_chat(user, "<span class='warning'>[H]'s skin is unusaly pale.</span>")
			bad = 1
		if(BP.status & ORGAN_DEAD)
			to_chat(user, "<span class='warning'>[BP] is decaying!</span>")
			bad = 1
		if(!bad)
			to_chat(user, "<span class='notice'>[H]'s skin is normal.</span>")
