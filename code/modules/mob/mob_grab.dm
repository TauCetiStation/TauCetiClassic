#define UPGRADE_KILL_TIMER	100

///Process_Grab()
///Called by client/Move()
///Checks to see if you are grabbing or being grabbed by anything and if moving will affect your grab.
/mob/proc/Process_Grab()
	return

/mob/living/Process_Grab()
	//if we are being grabbed
	if(!src.canmove && src.grabbed_by.len)
		src.resist() //shortcut for resisting grabs

/mob/living/carbon/Process_Grab()
	..()
	//if we are grabbing someone
	for(var/obj/item/weapon/grab/G in list(src.l_hand, src.r_hand))
		G.reset_kill_state() //no wandering across the station/asteroid while choking someone

/obj/item/weapon/grab
	name = "grab"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "reinforce"
	flags = DROPDEL
	var/obj/screen/grab/hud = null
	var/mob/living/affecting = null
	var/mob/living/carbon/human/assailant = null
	var/state = GRAB_PASSIVE

	var/allow_upgrade = 1
	var/last_action = 0
	var/last_hit_zone = 0
	var/force_down //determines if the affecting mob will be pinned to the ground
	var/dancing //determines if assailant and affecting keep looking at each other. Basically a wrestling position

	layer = ABOVE_HUD_LAYER + 1
	abstract = 1
	item_state = "nothing"
	w_class = 5.0


/obj/item/weapon/grab/New(mob/user, mob/victim)
	..()
	loc = user
	assailant = user
	affecting = victim

	if(affecting.anchored || !assailant.Adjacent(victim)) // Shouldn't even be created if these aren't met
		qdel(src)
		return

	affecting.grabbed_by += src

	hud = new /obj/screen/grab(src)
	hud.icon_state = "reinforce"
	icon_state = "grabbed"
	hud.name = "reinforce grab"
	hud.master = src

	//check if assailant is grabbed by victim as well
	if(assailant.grabbed_by)
		for (var/obj/item/weapon/grab/G in assailant.grabbed_by)
			if(G.assailant == affecting && G.affecting == assailant)
				G.dancing = 1
				G.adjust_position()
				dancing = 1
	adjust_position()

//Used by throw code to hand over the mob, instead of throwing the grab. The grab is then deleted by the throw code.
/obj/item/weapon/grab/proc/throw_held()
	if(affecting)
		if(affecting.buckled)
			return null

		if(!affecting.Adjacent(assailant))
			qdel(src)
			return null

		if(state >= GRAB_AGGRESSIVE)
			animate(affecting, pixel_x = 0, pixel_y = 0, 4, 1)
			var/mob/living/affected = affecting
			qdel(src)
			return affected

	return null


//This makes sure that the grab screen object is displayed in the correct hand.
/obj/item/weapon/grab/proc/synch()
	if(QDELETED(src))
		return
	if(affecting)
		if(assailant.r_hand == src)
			hud.screen_loc = ui_rhand
		else
			hud.screen_loc = ui_lhand


/obj/item/weapon/grab/process()
	if(QDELETED(src))
		return PROCESS_KILL

	if(!confirm())
		return PROCESS_KILL // qdel'd in confirm.

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

		if(iscarbon(affecting))
			handle_eye_mouth_covering(affecting, assailant, assailant.zone_sel.selecting)

		if(force_down)
			if(affecting.loc != assailant.loc || size_difference(affecting, assailant) > 0)
				force_down = 0
			else
				affecting.Weaken(2)

	if(state >= GRAB_NECK)
		affecting.Stun(3)
		if(isliving(affecting))
			var/mob/living/L = affecting
			L.adjustOxyLoss(1)

	if(state >= GRAB_KILL)
		if(iscarbon(affecting))
			var/mob/living/carbon/C = affecting
			C.apply_effect(STUTTER, 5) //It will hamper your voice, being choked and all.
			C.Weaken(5)	//Should keep you down unless you get help.
			C.losebreath = max(C.losebreath + 2, 3)

	adjust_position()

/obj/item/weapon/grab/proc/handle_eye_mouth_covering(mob/living/carbon/target, mob/user, target_zone)
	var/announce = (target_zone != last_hit_zone) // only display messages when switching between different target zones
	last_hit_zone = target_zone

	switch(target_zone)
		if(BP_MOUTH)
			if(announce)
				user.visible_message("<span class='warning'>\The [user] covers [target]'s mouth!</span>")
			if(target.silent < 3)
				target.silent = 3
		if(BP_EYES)
			if(announce)
				assailant.visible_message("<span class='warning'>[assailant] covers [affecting]'s eyes!</span>")
			if(affecting.eye_blind < 3)
				affecting.eye_blind = 3

/obj/item/weapon/grab/attack_self()
	return s_click(hud)


/obj/item/weapon/grab/proc/reset_position()
	if(!affecting.buckled)
		animate(affecting, pixel_x = 0, pixel_y = 0, 4, 1, LINEAR_EASING)
	affecting.layer = initial(affecting.layer)

//Updating pixelshift, position and direction
//Gets called on process, when the grab gets upgraded or the assailant moves
/obj/item/weapon/grab/proc/adjust_position()
	if(!affecting || affecting.buckled)
		return
	if(!assailant)
		return
	if(affecting.lying && state != GRAB_KILL)
		animate(affecting, pixel_x = 0, pixel_y = 0, 5, 1, LINEAR_EASING)
		if(force_down)
			affecting.set_dir(SOUTH) // face up
		return
	var/shift = 0
	var/adir = get_dir(assailant, affecting)
	affecting.layer = initial(affecting.layer)
	switch(state)
		if(GRAB_PASSIVE)
			shift = 8
			if(dancing) //look at partner
				shift = 10
				assailant.set_dir(get_dir(assailant, affecting))
		if(GRAB_AGGRESSIVE)
			shift = 12
		if(GRAB_NECK, GRAB_UPGRADING)
			shift = -10
			adir = assailant.dir
			affecting.set_dir(assailant.dir)
			affecting.loc = assailant.loc
		if(GRAB_KILL)
			shift = 0
			adir = 1
			affecting.set_dir(SOUTH) //face up
			affecting.loc = assailant.loc

	switch(adir)
		if(NORTH)
			animate(affecting, pixel_x = 0, pixel_y =-shift, 5, 1, LINEAR_EASING)
			affecting.layer = assailant.layer - 0.01
		if(SOUTH)
			animate(affecting, pixel_x = 0, pixel_y = shift, 5, 1, LINEAR_EASING)
		if(WEST)
			animate(affecting, pixel_x = shift, pixel_y = 0, 5, 1, LINEAR_EASING)
		if(EAST)
			animate(affecting, pixel_x =-shift, pixel_y = 0, 5, 1, LINEAR_EASING)

/obj/item/weapon/grab/proc/s_click(obj/screen/S)
	if(QDELETED(src))
		return
	if(!affecting)
		return
	if(!assailant)
		return
	if(state == GRAB_UPGRADING)
		return
	if(!assailant.canClick())
		return
	if(world.time < (last_action + UPGRADE_COOLDOWN))
		return
	if(!assailant.canmove || assailant.lying)
		qdel(src)
		return

	last_action = world.time

	if(assailant.a_intent == I_HELP)
		switch(state)
			if(GRAB_PASSIVE) //Lets go
				assailant.visible_message("<span class='notice'>[assailant] lets go of [affecting].</span>")
				qdel(src)

			if(GRAB_AGGRESSIVE) //downgrade to GRAB_PASSIVE
				if(force_down)
					to_chat(assailant, "<span class='warning'>You are no longer pinning [affecting] to the ground.</span>")
					force_down = 0

				assailant.visible_message("<span class='notice'>[assailant] has relaxed \his grip on [affecting]'s hands.</span>")
				state = GRAB_PASSIVE
				icon_state = "grabbed"
				assailant.set_dir(get_dir(assailant, affecting))

				hud.icon_state = "reinforce"
				hud.name = "reinforce grab"

			if(GRAB_NECK) //downgrade to GRAB_AGGRESSIVE
				assailant.visible_message("<span class='notice'>[assailant] has relaxed \his grip on [affecting]'s neck, grabbing their hands!</span>")
				hud.icon_state = "reinforce1"
				icon_state = "grabbed1"
				hud.name = "reinforce grab"
				state = GRAB_AGGRESSIVE

			if(GRAB_KILL) //downgrade to GRAB_NECK
				assailant.visible_message("<span class='notice'>[assailant] has relaxed \his grip on [affecting]'s throat.</span>")
				hud.icon_state = "kill"
				hud.name = "kill"
				state = GRAB_NECK
	else
		switch(state)
			if(GRAB_PASSIVE) //upgrade to GRAB_AGGRESSIVE
				if(!allow_upgrade)
					return
				if(!affecting.lying || size_difference(affecting, assailant) > 0)
					assailant.visible_message("<span class='warning'>[assailant] has grabbed [affecting] aggressively (now hands)!</span>")
				else
					assailant.visible_message("<span class='warning'>[assailant] pins [affecting] down to the ground (now hands)!</span>")
					apply_pinning(affecting, assailant)

				state = GRAB_AGGRESSIVE
				icon_state = "grabbed1"
				hud.icon_state = "reinforce1"

			if(GRAB_AGGRESSIVE) //upgrade to GRAB_NECK
				if(isslime(affecting))
					to_chat(assailant, "<span class='notice'>You squeeze [affecting], but nothing interesting happens.</span>")
					return

				assailant.visible_message("<span class='warning'>[assailant] has reinforced \his grip on [affecting] (now neck)!</span>")
				state = GRAB_NECK
				icon_state = "grabbed+1"
				assailant.set_dir(get_dir(assailant, affecting))
				affecting.attack_log += "\[[time_stamp()]\] <font color='orange'>Has had their neck grabbed by [assailant.name] ([assailant.ckey])</font>"
				assailant.attack_log += "\[[time_stamp()]\] <font color='red'>Grabbed the neck of [affecting.name] ([affecting.ckey])</font>"
				msg_admin_attack("[key_name(assailant)] grabbed the neck of [key_name(affecting)] ([ADMIN_JMP(assailant)])")

				hud.icon_state = "kill"
				hud.name = "kill"
				affecting.Stun(10) //10 ticks of ensured grab

			if(GRAB_NECK) //upgrade to GRAB_KILL
				assailant.visible_message("<span class='danger'>[assailant] starts to tighten \his grip on [affecting]'s neck!</span>")
				hud.icon_state = "kill1"

				state = GRAB_KILL
				assailant.visible_message("<span class='danger'>[assailant] has tightened \his grip on [affecting]'s neck!</span>")
				affecting.attack_log += "\[[time_stamp()]\] <font color='orange'>Has been strangled (kill intent) by [assailant.name] ([assailant.ckey])</font>"
				assailant.attack_log += "\[[time_stamp()]\] <font color='red'>Strangled (kill intent) [affecting.name] ([affecting.ckey])</font>"
				msg_admin_attack("[key_name(assailant)] strangled (kill intent) [key_name(affecting)] ([ADMIN_JMP(assailant)])")

				affecting.setClickCooldown(10)
				affecting.set_dir(WEST)
				if(iscarbon(affecting))
					var/mob/living/carbon/C = affecting
					C.losebreath += 1

	adjust_position()

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
	if(world.time < (last_action + 20))
		return
	if(!M.Adjacent(user))
		qdel(src)
		return

	last_action = world.time
	reset_kill_state() //using special grab moves will interrupt choking them

	if(M == affecting)
		if(ishuman(M))
			var/mob/living/carbon/human/H = affecting
			var/hit_zone = assailant.zone_sel.selecting
			flick(hud.icon_state, hud)
			switch(assailant.a_intent)
				if(I_HELP)
					if(force_down)
						to_chat(assailant, "<span class='warning'>You are no longer pinning [affecting] to the ground.</span>")
						force_down = 0
						return
					if(state >= GRAB_AGGRESSIVE)
						H.apply_pressure(assailant, hit_zone)
					else
						inspect_bodypart(affecting, assailant, hit_zone)

				if(I_GRAB)
					jointlock(affecting, assailant, hit_zone)

				if(I_HURT)
					if(hit_zone == BP_EYES)
						attack_eye(affecting, assailant)
					else if(hit_zone == BP_HEAD)
						headbut(affecting, assailant)
					else
						dislocate(affecting, assailant, hit_zone)

				if(I_DISARM)
					pin_down(affecting, assailant)

	if(M == assailant && state >= GRAB_AGGRESSIVE)
		if(assailant.devour(affecting))
			qdel(src)

/obj/item/weapon/grab/proc/reset_kill_state()
	if(!assailant)
		qdel(src)
		return
	if(state == GRAB_KILL)
		assailant.visible_message("<span class='warning'>[assailant] lost \his tight grip on [affecting]'s neck!</span>")
		hud.icon_state = "kill"
		state = GRAB_NECK

/obj/item/weapon/grab/proc/handle_resist()
	var/grab_name = "grip"
	var/break_strength = 1
	var/list/break_chance_table = list(100)
	switch(state)
		if(GRAB_PASSIVE)
			//Being knocked down makes it harder to break a grab, so it is easier to cuff someone who is down without forcing them into unconsciousness.
			//use same chance_table as aggressive but give +2 for not-weakened so that resomi grabs don't become auto-success for weakened either, that's lame
			if(!affecting.incapacitated(INCAPACITATION_KNOCKDOWN))
				break_strength += 2
			break_chance_table = list(15, 60, 100)

		if(GRAB_AGGRESSIVE)
			//Being knocked down makes it harder to break a grab, so it is easier to cuff someone who is down without forcing them into unconsciousness.
			if(!affecting.incapacitated(INCAPACITATION_KNOCKDOWN))
				break_strength++
			break_chance_table = list(15, 60, 100)

		if(GRAB_NECK)
			grab_name = "headlock"
			//If the you move when grabbing someone then it's easier for them to break free. Same if the affected mob is immune to stun.
			if(world.time - assailant.l_move_time < 30 || !affecting.stunned)
				break_strength++
			break_chance_table = list(3, 18, 45, 100)

		if(GRAB_KILL)
			grab_name = "stranglehold"
			break_chance_table = list(5, 20, 40, 80, 100)


	//It's easier to break out of a grab by a smaller mob
	break_strength += max(size_difference(affecting, assailant), 0)

	var/break_chance = break_chance_table[Clamp(break_strength, 1, break_chance_table.len)]
	if(prob(break_chance))
		if(state == GRAB_KILL && !prob((break_chance+100)/2))
			if(grab_name)
				affecting.visible_message("<span class='warning'>[affecting] has broken free of [assailant]'s [grab_name]!</span>")
			reset_kill_state()
			return
		else
			if(grab_name)
				affecting.visible_message("<span class='warning'>[affecting] has broken free of [assailant]'s [grab_name]!</span>")
			qdel(src)

//returns the number of size categories between affecting and assailant, rounded. Positive means A is larger than B
/obj/item/weapon/grab/proc/size_difference(mob/A, mob/B)
	return mob_size_difference(A.mob_size, B.mob_size)

/obj/item/weapon/grab/Destroy()
	if(affecting)
		reset_position()
		if(affecting)
			affecting.grabbed_by -= src
			affecting = null
	if(assailant)
		if(assailant.client)
			assailant.client.screen -= hud
		assailant = null
	qdel(hud)
	hud = null
	return ..()

/obj/item/weapon/grab/proc/inspect_bodypart(mob/living/carbon/human/H, mob/user, target_zone)

	var/obj/item/bodypart/BP = H.get_bodypart(target_zone)

	if(!BP || BP.is_stump())
		to_chat(user, "<span class='notice'>[H] is missing that bodypart.</span>")
		return

	user.visible_message("<span class='notice'>[user] starts inspecting [affecting]'s [BP.name] carefully.</span>")
	if(!do_mob(user,H, 30))
		to_chat(user, "<span class='notice'>You must stand still to inspect [BP] for wounds.</span>")
	else if(BP.wounds.len)
		to_chat(user, "<span class='warning'>You find [BP.get_wounds_desc()]</span>")
	else
		to_chat(user, "<span class='notice'>You find no visible wounds.</span>")

	to_chat(user, "<span class='notice'>Checking bones now...</span>")
	if(!do_mob(user, H, 60))
		to_chat(user, "<span class='notice'>You must stand still to feel [BP] for fractures.</span>")
	else if(BP.status & ORGAN_BROKEN)
		to_chat(user, "<span class='warning'>The [BP.encased ? BP.encased : "bone in the [BP.name]"] moves slightly when you poke it!</span>")
		H.custom_pain("Your [BP.name] hurts where it's poked.", 40, BP = BP)
	else
		to_chat(user, "<span class='notice'>The [BP.encased ? BP.encased : "bones in the [BP.name]"] seem to be fine.</span>")

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

/obj/item/weapon/grab/proc/jointlock(mob/living/carbon/human/target, mob/attacker, target_zone)
	if(state < GRAB_AGGRESSIVE)
		to_chat(attacker, "<span class='warning'>You require a better grab to do this.</span>")
		return

	var/obj/item/bodypart/BP = target.get_bodypart(check_zone(target_zone))
	if(!BP || BP.dislocated == -1)
		return

	attacker.visible_message("<span class='danger'>[attacker] [pick("bent", "twisted")] [target]'s [BP.name] into a jointlock!</span>")

	if(!BP.can_feel_pain())
		return

	var/armor = target.run_armor_check(target, "melee")
	if(armor < 100)
		to_chat(target, "<span class='danger'>You feel extreme pain!</span>")

		var/max_halloss = round(target.species.total_health * 0.8) //up to 80% of passing out
		affecting.adjustHalLoss(Clamp(0, max_halloss - affecting.getHalLoss(), 30))

/obj/item/weapon/grab/proc/attack_eye(mob/living/carbon/human/target, mob/living/carbon/human/attacker)
	if(!istype(attacker))
		return

	var/datum/unarmed_attack/attack = attacker.get_unarmed_attack(target, BP_EYES)

	if(!attack)
		return
	if(state < GRAB_NECK)
		to_chat(attacker, "<span class='warning'>You require a better grab to do this.</span>")
		return
	if(target.get_equipped_covered(BP_HEAD) & EYES)
		to_chat(attacker, "<span class='danger'>You're going to need to remove the eye covering first.</span>")
		return
	if(!target.has_eyes())
		to_chat(attacker, "<span class='danger'>You cannot locate any eyes on [target]!</span>")
		return

	assailant.attack_log += text("\[[time_stamp()]\] <font color='red'>Pressed fingers into the eyes of [affecting.name] ([affecting.ckey])</font>")
	affecting.attack_log += text("\[[time_stamp()]\] <font color='orange'>Had fingers pressed into their eyes by [assailant.name] ([assailant.ckey])</font>")
	msg_admin_attack("[key_name(assailant)] has pressed his fingers into [key_name(affecting)]'s eyes. ([ADMIN_JMP(assailant)])")

	attack.handle_eye_attack(attacker, target)

/obj/item/weapon/grab/proc/headbut(mob/living/carbon/human/target, mob/living/carbon/human/attacker)
	if(!istype(attacker))
		return
	if(target.lying)
		return

	var/damage = 20
	var/obj/item/clothing/hat = attacker.get_equipped_item(slot_head)
	var/damage_flags = 0
	if(istype(hat))
		damage += hat.force * 3
		damage_flags = hat.damage_flags()

	if(damage_flags & DAM_SHARP)
		attacker.visible_message("<span class='danger'>[attacker] gores [target][istype(hat)? " with \the [hat]" : ""]!</span>")
	else
		attacker.visible_message("<span class='danger'>[attacker] thrusts \his head into [target]'s skull!</span>")

	var/armor = target.run_armor_check(BP_HEAD, "melee")
	target.apply_damage(damage, BRUTE, BP_HEAD, armor, damage_flags)
	attacker.apply_damage(10, BRUTE, BP_HEAD, attacker.run_armor_check(BP_HEAD, "melee"))

	if(armor < 50 && target.headcheck(BP_HEAD) && prob(damage))
		target.apply_effect(20, PARALYZE)
		target.visible_message("<span class='danger'>[target] [target.species.get_knockout_message(target)]</span>")

	playsound(attacker.loc, "swing_hit", 25, 1, -1)

	assailant.attack_log += text("\[[time_stamp()]\] <font color='red'>Headbutted [affecting.name] ([affecting.ckey])</font>")
	affecting.attack_log += text("\[[time_stamp()]\] <font color='orange'>Headbutted by [assailant.name] ([assailant.ckey])</font>")
	msg_admin_attack("[key_name(assailant)] has headbutted [key_name(affecting)] ([ADMIN_JMP(assailant)])")

	qdel(src)

/obj/item/weapon/grab/proc/dislocate(mob/living/carbon/human/target, mob/living/attacker, target_zone)
	if(state < GRAB_NECK)
		to_chat(attacker, "<span class='warning'>You require a better grab to do this.</span>")
		return
	if(target.grab_joint(attacker, target_zone))
		playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
		return

/obj/item/weapon/grab/proc/pin_down(mob/target, mob/attacker)
	if(state < GRAB_AGGRESSIVE)
		to_chat(attacker, "<span class='warning'>You require a better grab to do this.</span>")
		return
	if(force_down)
		to_chat(attacker, "<span class='warning'>You are already pinning [target] to the ground.</span>")
		return
	if(size_difference(affecting, assailant) > 0)
		to_chat(attacker, "<span class='warning'>You are too small to do that!</span>")
		return

	attacker.visible_message("<span class='danger'>[attacker] starts forcing [target] to the ground!</span>")
	if(do_after(attacker, 20, progress=0) && target)
		last_action = world.time
		attacker.visible_message("<span class='danger'>[attacker] forces [target] to the ground!</span>")
		apply_pinning(target, attacker)

/obj/item/weapon/grab/proc/apply_pinning(mob/target, mob/attacker)
	force_down = 1
	target.Weaken(3)
	target.lying = 1
	step_to(attacker, target)
	attacker.set_dir(EAST) //face the victim
	target.set_dir(SOUTH) //face up
