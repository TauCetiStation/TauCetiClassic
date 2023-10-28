/mob/living/simple_animal
	name = "animal"
	desc = "Просто существует."
	icon = 'icons/mob/animal.dmi'
	health = 20
	maxHealth = 20
	immune_to_ssd = TRUE

	var/icon_living = ""
	var/icon_dead = ""
	var/icon_gib = null	// We only try to show a gibbing animation if this exists.
	var/icon_move = null // We only try to show a moving animation if this exists.

	var/list/speak = list()
	var/speak_chance = 0
	var/list/emote_hear = list() // Hearable emotes
	var/list/emote_see = list() // Unlike speak_emote, the list of things in this variable only show by themselves with no spoken text. IE: Ian barks, Ian yaps

	var/turns_per_move = 1
	var/turns_since_move = 0
	universal_speak = 0	// No, just no.
	var/stop_automated_movement = FALSE // Use this to temporarely stop random movement or to if you write special movement code for animals.
	var/wander = TRUE // Does the mob wander around when idle?
	var/stop_automated_movement_when_pulled = TRUE // When set to 1 this stops the animal from moving when someone is pulling it.

	// Interaction
	var/response_help   = "pets the"
	var/response_disarm = "gently pushes aside the"
	var/response_harm   = "kicks the"
	var/harm_intent_damage = 3

	// Temperature effect
	var/minbodytemp = 250
	var/maxbodytemp = 350
	var/heat_damage_per_tick = 3 // amount of damage applied if animal's body temperature is higher than maxbodytemp
	var/cold_damage_per_tick = 2 // same as heat_damage_per_tick, only if the bodytemperature it's lower than minbodytemp

	// Atmos effect - Yes, you can make creatures that require phoron or co2 to survive. N2O is a trace gas and handled separately, hence why it isn't here. It'd be hard to add it. Hard and me don't mix (Yes, yes make all the dick jokes you want with that.) - Errorage
	var/min_oxy = 5
	var/max_oxy = 0 // Leaving something at 0 means it's off - has no maximum
	var/min_tox = 0
	var/max_tox = 1
	var/min_co2 = 0
	var/max_co2 = 5
	var/min_n2 = 0
	var/max_n2 = 0
	var/unsuitable_atoms_damage = 2	// This damage is taken when atmos doesn't fit all the requirements above


	// LETTING SIMPLE ANIMALS ATTACK? WHAT COULD GO WRONG. Defaults to zero so Ian can still be cuddly
	var/melee_damage = 0
	var/melee_damtype = BRUTE
	var/attacktext = "kicks"
	var/list/attack_sound = list()
	var/friendly = "nuzzles" // If the mob does no damage with it's attack
	var/environment_smash = 0 // Set to 1 to allow breaking of crates,lockers,racks,tables; 2 for walls; 3 for Rwalls

	var/animalistic = TRUE // Determines whether the being here is an animal or nah.
	var/has_head = FALSE
	var/has_arm = FALSE
	var/has_leg = FALSE

	can_point = FALSE

	///What kind of footstep this mob should have. Null if it shouldn't have any.
	var/footstep_type

	// See atom_init below.
	moveset_type = null

/mob/living/simple_animal/atom_init()
	if(!moveset_type)
		if(animalistic)
			moveset_type = /datum/combat_moveset/animal
		else if(has_head && has_arm && has_leg)
			moveset_type = /datum/combat_moveset/human
		else
			moveset_type = /datum/combat_moveset/living

	. = ..()
	if(footstep_type)
		AddComponent(/datum/component/footstep, footstep_type)

/mob/living/simple_animal/Login()
	. = ..()
	stop_automated_movement = TRUE

/mob/living/simple_animal/Logout()
	. = ..()
	stop_automated_movement = initial(stop_automated_movement)

/mob/living/simple_animal/Grab(atom/movable/target, force_state, show_warnings = TRUE)
	return

/mob/living/simple_animal/helpReaction(mob/living/attacker, show_message = TRUE)
	if(stat != DEAD)
		visible_message("<span class='notice'>[attacker] [response_help] [src]</span>")
	return ..(attacker, show_message = FALSE)

/mob/living/simple_animal/disarmReaction(mob/living/attacker, show_message = TRUE)
	if(stat != DEAD)
		visible_message("<span class='warning'>[attacker] [response_disarm] [src]</span>")
	return ..(attacker, show_message = FALSE)

/mob/living/simple_animal/hurtReaction(mob/living/attacker, show_message = TRUE)
	if(stat != DEAD)
		visible_message("<span class='warning'>[attacker] [response_harm] [src]</span>")
	return ..(attacker, show_message = FALSE)

/mob/living/simple_animal/get_unarmed_attack()
	var/retDam = melee_damage
	var/retDamType = melee_damtype
	var/retFlags = 0
	var/retVerb = attacktext
	var/retSound = null
	if(length(attack_sound) > 0)
		retSound = pick(attack_sound)
	var/retMissSound = 'sound/effects/mob/hits/miss_1.ogg'

	if(HULK in mutations)
		retDam += 4

	return list("damage" = retDam, "type" = retDamType, "flags" = retFlags, "verb" = retVerb, "sound" = retSound,
				"miss_sound" = retMissSound)

/mob/living/simple_animal/updatehealth()
	med_hud_set_health()
	med_hud_set_status()
	return

/mob/living/simple_animal/Life()
	handle_combat() // Even in death we still fight.

	// Health
	if(stat == DEAD)
		return 0

	else if(health < 1)
		health = 0
		death()

	health = min(health, maxHealth)

	if(client)
		handle_regular_hud_updates()

	// Movement
	if(!client && !stop_automated_movement && wander && !anchored)
		if(isturf(src.loc) && !buckled && canmove) // This is so it only moves if it's not inside a closet, gentics machine, etc.
			turns_since_move++
			if(turns_since_move >= turns_per_move)
				if(!(stop_automated_movement_when_pulled && pulledby)) // Some animals don't move when pulled
					var/anydir = pick(cardinal)
					if(Process_Spacemove(anydir))
						Move(get_step(src,anydir), anydir)
						turns_since_move = 0

	// Speaking
	handle_automated_speech()

	// Atmos
	var/atmos_suitable = 1

	var/atom/A = src.loc
	if(isturf(A))
		var/turf/T = A
		var/areatemp = T.temperature
		if( abs(areatemp - bodytemperature) > 40 )
			var/diff = areatemp - bodytemperature
			diff = diff / 5
			//world << "changed from [bodytemperature] by [diff] to [bodytemperature + diff]"
			adjust_bodytemperature(diff)

		if(istype(T,/turf/simulated))
			var/turf/simulated/ST = T
			if(ST.air)
				var/tox = ST.air.gas["phoron"]
				var/oxy = ST.air.gas["oxygen"]
				var/n2  = ST.air.gas["nitrogen"]
				var/co2 = ST.air.gas["carbon_dioxide"]

				if(min_oxy)
					if(oxy < min_oxy)
						atmos_suitable = 0
				if(max_oxy)
					if(oxy > max_oxy)
						atmos_suitable = 0
				if(min_tox)
					if(tox < min_tox)
						atmos_suitable = 0
				if(max_tox)
					if(tox > max_tox)
						atmos_suitable = 0
				if(min_n2)
					if(n2 < min_n2)
						atmos_suitable = 0
				if(max_n2)
					if(n2 > max_n2)
						atmos_suitable = 0
				if(min_co2)
					if(co2 < min_co2)
						atmos_suitable = 0
				if(max_co2)
					if(co2 > max_co2)
						atmos_suitable = 0

	//Atmos effect
	if(bodytemperature < minbodytemp)
		adjustBruteLoss(cold_damage_per_tick)
	else if(bodytemperature > maxbodytemp)
		adjustBruteLoss(heat_damage_per_tick)

	if(!atmos_suitable)
		adjustBruteLoss(unsuitable_atoms_damage)
	return 1

/mob/living/simple_animal/proc/handle_automated_speech()
	if(!speak_chance || !(speak.len || emote_hear.len || emote_see.len))
		return

	if(client && !(ckey == null))
		return

	if(!(rand(0,200) < speak_chance))
		return

	var/mode = pick(
	speak.len;      1,
	emote_hear.len; 2,
	emote_see.len;  3
	)

	switch(mode)
		if(1)
			say(pick(speak))
		if(2)
			me_emote(pick(emote_hear), SHOWMSG_AUDIO)
		if(3)
			me_emote(pick(emote_see), SHOWMSG_VISUAL)

/mob/living/simple_animal/rejuvenate()
	..()
	icon_state = icon_living

/mob/living/simple_animal/revive()
	..()
	density = initial(density)
	mouse_opacity = initial(mouse_opacity)

/mob/living/simple_animal/gib()
	if(icon_gib)
		flick(icon_gib, src)
	if(butcher_results)
		for(var/path in butcher_results)
			for(var/i = 1 to butcher_results[path])
				new path(loc)
	..()

/mob/living/simple_animal/attack_larva(mob/living/carbon/xenomorph/larva/attacker)
	if(attacker.a_intent == INTENT_HARM && stat != DEAD)
		var/attack_obj = attacker.get_unarmed_attack()
		var/atk_damage = attack_obj["damage"]
		attacker.amount_grown = min(attacker.amount_grown + atk_damage, attacker.max_grown)
	return ..()

/mob/living/simple_animal/movement_delay()
	return speed + config.animal_delay

/mob/living/simple_animal/Stat()
	..()

	if(statpanel("Status"))
		stat(null, "Health: [round((health / maxHealth) * 100)]%")

/mob/living/simple_animal/death()
	icon_state = icon_dead
	stat = DEAD
	health = 0
	density = FALSE
	med_hud_set_health()
	med_hud_set_status()
	return ..()

/mob/living/simple_animal/ex_act(severity)
	if(!blinded)
		flash_eyes()
	switch(severity)
		if(EXPLODE_DEVASTATE)
			gib()

		if(EXPLODE_HEAVY)
			adjustBruteLoss(60)

		if(EXPLODE_LIGHT)
			adjustBruteLoss(30)

/mob/living/simple_animal/blob_act()
	adjustBruteLoss(20)

/mob/living/simple_animal/adjustBruteLoss(damage)
	var/perc_block = (10 - harm_intent_damage) / 10 // #define MAX_HARM_INTENT_DAMAGE 10. Turn harm_intent_damage into armor or something. ~Luduk
	damage *= perc_block

	health = clamp(health - damage, 0, maxHealth)
	if(health < 1 && stat != DEAD)
		death()

/mob/living/simple_animal/adjustFireLoss(damage)
	health = clamp(health - damage, 0, maxHealth)
	if(health < 1 && stat != DEAD)
		death()

/mob/living/simple_animal/proc/SA_attackable(target_mob)
	if (isliving(target_mob))
		var/mob/living/L = target_mob
		if(L.stat == CONSCIOUS && L.health >= 0)
			return FALSE
	if (istype(target_mob, /obj/mecha))
		var/obj/mecha/M = target_mob
		if(M.occupant)
			return FALSE
	if (isbot(target_mob))
		var/obj/machinery/bot/B = target_mob
		if(B.get_integrity() > 0)
			return FALSE
	return TRUE

/mob/living/simple_animal/update_fire()
	return
/mob/living/simple_animal/IgniteMob()
	return
/mob/living/simple_animal/ExtinguishMob()
	return

/mob/living/simple_animal/proc/CanAttack(atom/the_target)
	if(see_invisible < the_target.invisibility)
		return FALSE
	if (isliving(the_target))
		var/mob/living/L = the_target
		if(L.stat != CONSCIOUS)
			return FALSE
		if(animalistic && HAS_TRAIT(L, TRAIT_NATURECHILD) && L.naturechild_check())
			return FALSE
	if (istype(the_target, /obj/mecha))
		var/obj/mecha/M = the_target
		if (M.occupant)
			return FALSE
	return TRUE

/mob/living/simple_animal/IgniteMob()
	return FALSE

/mob/living/simple_animal/say(message)
	if(stat != CONSCIOUS)
		return

	message = sanitize(message)

	if(!message)
		return

	if(message[1] == "*")
		return emote(copytext(message, 2))

	var/verb = "says"
	var/ending = copytext(message, -1)
	var/list/parsed = parse_language(message)
	message = parsed[1]
	var/datum/language/speaking = parsed[2]

	if (speaking)
		verb = speaking.get_spoken_verb(ending)

	else
		verb = pick(speak_emote)

	message = capitalize(trim_left(message))

	..(message, speaking, verb, sanitize = 0)

/mob/living/simple_animal/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0)
	. = ..()
	if(icon_move && stat == CONSCIOUS && !ISDIAGONALDIR(Dir))
		flick(icon_move, src)

/mob/living/simple_animal/update_stat()
	if(stat == DEAD)
		return
	if(IsSleeping())
		stat = UNCONSCIOUS
		blinded = TRUE
	else
		stat = CONSCIOUS
		blinded = FALSE
	med_hud_set_status()

/mob/living/simple_animal/get_scrambled_message(message, datum/language/speaking = null)
	if(!speak.len)
		return null
	return pick(speak)

/mob/living/simple_animal/is_usable_head(targetzone = null)
	return has_head

/mob/living/simple_animal/is_usable_arm(targetzone = null)
	return has_arm

/mob/living/simple_animal/is_usable_leg(targetzone = null)
	return has_leg

/mob/living/simple_animal/do_attack_animation(atom/A, end_pixel_y, has_effect = TRUE, visual_effect_icon, visual_effect_color)
	if(has_effect && !visual_effect_icon && melee_damage)
		if(attack_push_vis_effect && !iswallturf(A)) // override the standard visual effect.
			visual_effect_icon = attack_push_vis_effect
		else if(melee_damage < 10)
			visual_effect_icon = ATTACK_EFFECT_PUNCH
		else
			visual_effect_icon = ATTACK_EFFECT_SMASH
	..()

/mob/living/simple_animal/crawl()
	return FALSE

/mob/living/simple_animal/can_pickup(obj/O)
	return FALSE
