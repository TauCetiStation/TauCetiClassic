/mob/living/simple_animal
	name = "animal"
	icon = 'icons/mob/animal.dmi'
	health = 20
	maxHealth = 20

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
	var/stop_automated_movement = 0 // Use this to temporarely stop random movement or to if you write special movement code for animals.
	var/wander = 1 // Does the mob wander around when idle?
	var/stop_automated_movement_when_pulled = 1 // When set to 1 this stops the animal from moving when someone is pulling it.

	// Interaction
	var/response_help   = "tries to help"
	var/response_disarm = "tries to disarm"
	var/response_harm   = "tries to hurt"
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
	var/melee_damage_lower = 0
	var/melee_damage_upper = 0
	var/attacktext = "attacks"
	var/list/attack_sound = list()
	var/friendly = "nuzzles" // If the mob does no damage with it's attack
	var/environment_smash = 0 // Set to 1 to allow breaking of crates,lockers,racks,tables; 2 for walls; 3 for Rwalls

	var/speed = 0 // LETS SEE IF I CAN SET SPEEDS FOR SIMPLE MOBS WITHOUT DESTROYING EVERYTHING. Higher speed is slower, negative speed is faster

	var/animalistic = TRUE // Determines whether the being here is an animal or nah.

	///What kind of footstep this mob should have. Null if it shouldn't have any.
	var/footstep_type

/mob/living/simple_animal/atom_init()
	. = ..()
	if(footstep_type)
		AddComponent(/datum/component/footstep, footstep_type)

/mob/living/simple_animal/updatehealth()
	return

/mob/living/simple_animal/Life()

	// Health
	if(stat == DEAD)
		if(health > 0)
			icon_state = icon_living
			dead_mob_list -= src
			alive_mob_list += src
			stat = CONSCIOUS
			density = 1
		return 0

	else if(health < 1)
		health = 0
		death()

	health = min(health, maxHealth)

	if(client)
		handle_vision()

	if(stunned)
		AdjustStunned(-1)
	if(weakened)
		AdjustWeakened(-1)
	if(paralysis)
		AdjustParalysis(-1)

	// Movement
	if(!client && !stop_automated_movement && wander && !anchored)
		if(isturf(src.loc) && !resting && !buckled && canmove) // This is so it only moves if it's not inside a closet, gentics machine, etc.
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
			bodytemperature += diff

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
			emote(pick(emote_hear), 2)
		if(3)
			emote(pick(emote_see), 1)

/mob/living/simple_animal/gib()
	if(icon_gib)
		flick(icon_gib, src)
	if(butcher_results)
		for(var/path in butcher_results)
			for(var/i = 0 to butcher_results[path])
				new path(loc)
	..()

/mob/living/simple_animal/emote(act, m_type = SHOWMSG_VISUAL, message = null, auto)
	if(act)
		if(act == "scream")	act = "whimper" //ugly hack to stop animals screaming when crushed :P
		..(act, m_type)

/mob/living/simple_animal/attack_animal(mob/living/simple_animal/M)
	if(src == M)
		return TRUE
	..()
	if(M.melee_damage_upper == 0)
		M.emote("[M.friendly] [src]")
		return TRUE
	else
		if(length(M.attack_sound))
			playsound(src, pick(M.attack_sound), VOL_EFFECTS_MASTER)
		visible_message("<span class='userdanger'><B>[M]</B> [M.attacktext] [src]!</span>")
		M.attack_log += text("\[[time_stamp()]\] <font color='red'>attacked [src.name] ([src.ckey])</font>")
		src.attack_log += text("\[[time_stamp()]\] <font color='orange'>was attacked by [M.name] ([M.ckey])</font>")
		var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
		adjustBruteLoss(damage)
		return TRUE

/mob/living/simple_animal/bullet_act(obj/item/projectile/Proj)
	if(!Proj)
		return
	if(Proj.nodamage)
		Weaken(20)
	adjustBruteLoss(Proj.damage)
	return 0

/mob/living/simple_animal/attack_hand(mob/living/carbon/human/M)
	..()

	switch(M.a_intent)

		if("help")
			if (health > 0)
				visible_message("<span class='notice'>[M] [response_help] [src]</span>")

		if("grab")
			M.Grab(src)

		if("hurt", "disarm")
			M.do_attack_animation(src)
			adjustBruteLoss(harm_intent_damage)
			visible_message("<span class='warning'>[M] [response_harm] [src]</span>")

	return

/mob/living/simple_animal/attack_alien(mob/living/carbon/xenomorph/humanoid/M)

	switch(M.a_intent)

		if ("help")
			visible_message("<span class='notice'>[M] caresses [src] with its scythe like arm.</span>")
		if ("grab")
			M.Grab(src)

		if("hurt", "disarm")
			var/damage = rand(15, 30)
			visible_message("<span class='warning'><B>[M] has slashed at [src]!</B></span>")
			adjustBruteLoss(damage)

	return

/mob/living/simple_animal/attack_larva(mob/living/carbon/xenomorph/larva/L)

	switch(L.a_intent)
		if("help")
			visible_message("<span class='notice'>[L] rubs it's head against [src]</span>")


		else

			var/damage = rand(5, 10)
			visible_message("<span class='warning'><B>[L] bites [src]!</B></span>")

			if(stat != DEAD)
				adjustBruteLoss(damage)
				L.amount_grown = min(L.amount_grown + damage, L.max_grown)


/mob/living/simple_animal/attack_slime(mob/living/carbon/slime/M)
	if (!ticker)
		to_chat(M, "You cannot attack people before the game has started.")
		return

	if(M.Victim)
		return // can't attack while eating!

	visible_message("<span class='danger'>The [M.name] glomps [src]!</span>")

	var/damage = rand(1, 3)

	if(istype(src, /mob/living/carbon/slime/adult))
		damage = rand(20, 40)
	else
		damage = rand(5, 35)

	adjustBruteLoss(damage)


	return


/mob/living/simple_animal/attackby(obj/item/O, mob/user) // Marker -Agouri
	if(istype(O, /obj/item/stack/medical))
		if(stat != DEAD)
			var/obj/item/stack/medical/MED = O
			if(health < maxHealth && MED.use(1))
				adjustBruteLoss(-MED.heal_brute)
				src.visible_message("<span class='notice'>[user] applies the [MED] on [src]</span>")
		else
			to_chat(user, "<span class='notice'> this [src] is dead, medical items won't bring it back to life.</span>")
	user.SetNextMove(CLICK_CD_MELEE)
	..()


/mob/living/simple_animal/movement_delay()
	var/tally = 0 // Incase I need to add stuff other than "speed" later

	tally = speed

	return tally+config.animal_delay

/mob/living/simple_animal/Stat()
	..()

	if(statpanel("Status"))
		stat(null, "Health: [round((health / maxHealth) * 100)]%")

/mob/living/simple_animal/death()
	icon_state = icon_dead
	stat = DEAD
	health = 0
	density = 0
	return ..()

/mob/living/simple_animal/ex_act(severity)
	if(!blinded)
		flash_eyes()
	switch (severity)
		if (1.0)
			adjustBruteLoss(500)
			gib()
			return

		if (2.0)
			adjustBruteLoss(60)


		if(3.0)
			adjustBruteLoss(30)

/mob/living/simple_animal/adjustBruteLoss(damage)
	health = CLAMP(health - damage, 0, maxHealth)
	if(health < 1 && stat != DEAD)
		death()

/mob/living/simple_animal/adjustFireLoss(damage)
	health = CLAMP(health - damage, 0, maxHealth)
	if(health < 1 && stat != DEAD)
		death()

/mob/living/simple_animal/proc/SA_attackable(target_mob)
	if (isliving(target_mob))
		var/mob/living/L = target_mob
		if(!L.stat && L.health >= 0)
			return (0)
	if (istype(target_mob,/obj/mecha))
		var/obj/mecha/M = target_mob
		if (M.occupant)
			return (0)
	if (istype(target_mob,/obj/machinery/bot))
		var/obj/machinery/bot/B = target_mob
		if(B.health > 0)
			return (0)
	return (1)

// Call when target overlay should be added/removed
/mob/living/simple_animal/update_targeted()
	if(!targeted_by && target_locked)
		qdel(target_locked)
	cut_overlays()
	if (targeted_by && target_locked)
		add_overlay(target_locked)

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

/mob/living/simple_animal/say(var/message)
	if(stat)
		return

	message = sanitize(message)

	if(copytext(message,1,2) == "*")
		return emote(copytext(message,2))

	if(stat)
		return

	var/verb = "says"

	if(speak_emote.len)
		verb = pick(speak_emote)

	message = capitalize(trim_left(message))

	..(message, null, verb, sanitize = 0)

/mob/living/simple_animal/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0)
	. = ..()
	if(icon_move && !stat)
		flick(icon_move, src)

/mob/living/simple_animal/update_stat()
	if(stat == DEAD)
		return
	if(IsSleeping())
		stat = UNCONSCIOUS
		blinded = TRUE
