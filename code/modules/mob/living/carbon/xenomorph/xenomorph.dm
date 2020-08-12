/mob/living/carbon/xenomorph
	name = "alien"
	voice_name = "alien"
	icon = 'icons/mob/xenomorph.dmi'
	gender = NEUTER
	dna = null
	faction = "alien"

	alien_talk_understand = 1
	speak_emote = list("hisses")
	var/nightvision = 1
	var/storedPlasma = 250
	var/max_plasma = 500
	var/last_sound_emote = 0 // prevents sounds spam

	var/obj/item/weapon/card/id/wear_id = null // Fix for station bounced radios -- Skie
	var/move_delay_add = 0 // movement delay to add

	status_flags = CANPARALYSE|CANPUSH
	var/heal_rate = 1
	var/plasma_rate = 5

	var/heat_protection = 0.5
	var/leaping = 0
	ventcrawler = 2

/mob/living/carbon/xenomorph/atom_init()
	. = ..()
	alien_list += src

/mob/living/carbon/xenomorph/Destroy()
	alien_list -= src
	return ..()

/mob/living/carbon/xenomorph/adjustToxLoss(amount)
	storedPlasma = min(max(storedPlasma + amount,0),max_plasma) //upper limit of max_plasma, lower limit of 0
	updatePlasmaDisplay()
	return

/mob/living/carbon/xenomorph/adjustFireLoss(amount) // Weak to Fire
	if(amount > 0)
		..(amount * 2)
	else
		..(amount)
	return

/mob/living/carbon/xenomorph/proc/getPlasma()
	return storedPlasma

/mob/living/carbon/xenomorph/eyecheck()
	return 2

/mob/living/carbon/xenomorph/getToxLoss()
	return 0

/mob/living/carbon/xenomorph/updatehealth()
	if(status_flags & GODMODE)
		health = maxHealth
		stat = CONSCIOUS
	else
		//oxyloss is only used for suicide
		//toxloss isn't used for aliens, its actually used as alien powers!!
		health = maxHealth - getOxyLoss() - getFireLoss() - getBruteLoss() - getCloneLoss()

/mob/living/carbon/xenomorph/handle_environment(datum/gas_mixture/environment)

	//If there are alien weeds on the ground then heal if needed or give some plasma
	if(locate(/obj/structure/alien/weeds) in loc)
		if(health >= maxHealth)
			adjustToxLoss(plasma_rate)
		else
			if(storedPlasma >= max_plasma)
				adjustBruteLoss(-heal_rate*2)
				adjustFireLoss(-heal_rate*2)
				adjustOxyLoss(-heal_rate*2)
				adjustCloneLoss(-heal_rate*2)
			else
				adjustBruteLoss(-heal_rate)
				adjustFireLoss(-heal_rate)
				adjustOxyLoss(-heal_rate)
				adjustCloneLoss(-heal_rate)
				adjustToxLoss(plasma_rate/2)

	if(!environment)
		return

	var/loc_temp = get_temperature(environment)

	//world << "Loc temp: [loc_temp] - Body temp: [bodytemperature] - Fireloss: [getFireLoss()] - Fire protection: [heat_protection] - Location: [loc] - src: [src]"

	// Aliens are now weak to fire.

	//After then, it reacts to the surrounding atmosphere based on your thermal protection
	if(!on_fire) // If you're on fire, ignore local air temperature
		if(loc_temp > bodytemperature)
			//Place is hotter than we are
			var/thermal_protection = heat_protection //This returns a 0 - 1 value, which corresponds to the percentage of protection based on what you're wearing and what you're exposed to.
			if(thermal_protection < 1)
				bodytemperature += (1-thermal_protection) * ((loc_temp - bodytemperature) / BODYTEMP_HEAT_DIVISOR)
		else
			bodytemperature += 1 * ((loc_temp - bodytemperature) / BODYTEMP_HEAT_DIVISOR)

	// +/- 50 degrees from 310.15K is the 'safe' zone, where no damage is dealt.
	if(bodytemperature > 700)
		//Body temperature is too hot.
		throw_alert("alien_fire", /obj/screen/alert/alien_fire)
		switch(bodytemperature)
			if(700 to 850)
				apply_damage(HEAT_DAMAGE_LEVEL_1, BURN)
			if(850 to 1000)
				apply_damage(HEAT_DAMAGE_LEVEL_2, BURN)
			if(1000 to INFINITY)
				if(on_fire)
					apply_damage(HEAT_DAMAGE_LEVEL_3, BURN)
				else
					apply_damage(HEAT_DAMAGE_LEVEL_2, BURN)
	else
		clear_alert("alien_fire")

/mob/living/carbon/xenomorph/proc/handle_mutations_and_radiation()

	// Aliens love radiation nom nom nom
	if (radiation)
		if (radiation > 100)
			radiation = 100

		if (radiation < 0)
			radiation = 0

		switch(radiation)
			if(1 to 49)
				radiation--
				if(prob(25))
					adjustToxLoss(1)

			if(50 to 74)
				radiation -= 2
				adjustToxLoss(1)
				if(prob(5))
					radiation -= 5

			if(75 to 100)
				radiation -= 3
				adjustToxLoss(3)

/mob/living/carbon/xenomorph/Stat()
	..()

	if(statpanel("Status"))
		if(isxenoqueen(src))
			var/hugger = 0
			var/larva = 0
			var/drone = 0
			var/sentinel = 0
			var/hunter = 0

			for(var/mob/living/carbon/xenomorph/A in alien_list)
				if(A.stat == DEAD)
					continue
				if(!A.key && A.has_brain())
					continue

				if(isfacehugger(A))
					hugger++
				else if(isxenolarva(A))
					larva++
				else if(isxenodrone(A))
					drone++
				else if(isxenosentinel(A))
					sentinel++
				else if(isxenohunter(A))
					hunter++

			stat(null, "Hive Status:")
			stat(null, "Huggers: [hugger]")
			stat(null, "Larvas: [larva]")
			stat(null, "Drones: [drone]")
			stat(null, "Sentinels: [sentinel]")
			stat(null, "Hunters: [hunter]")
		else
			var/no_queen = 1
			var/mob/living/carbon/xenomorph/queen
			for(var/mob/living/carbon/xenomorph/humanoid/queen/Q in queen_list)
				if(Q.stat == DEAD || !Q.key && Q.has_brain())
					continue
				no_queen = 0
				queen = Q

			if(no_queen)
				stat(null, "Queen: No.")
			else
				stat(null, "Queen Status:")
				stat(null, "Conscious: [queen.stat ? "No":"Yes"]")
				stat(null, "Health: [queen.health]/[queen.maxHealth]")
				stat(null, "Location: [queen.loc.loc.name]")

/mob/living/carbon/xenomorph/Stun(amount, updating = 1, ignore_canstun = 0, lock = null)
	if(status_flags & CANSTUN || ignore_canstun)
		..()
	else
		// add some movement delay
		move_delay_add = min(move_delay_add + round(amount / 2), 10) // a maximum delay of 10

/mob/living/carbon/xenomorph/getDNA()
	return null

/mob/living/carbon/xenomorph/setDNA()
	return

/*----------------------------------------
Hit Procs
-----------------------------------------*/
/mob/living/carbon/xenomorph/ex_act(severity)
	if(!blinded)
		flash_eyes()

	var/shielded = 0

	var/b_loss = null
	var/f_loss = null
	switch (severity)
		if (1.0)
			b_loss += 500
			gib()
			return

		if (2.0)
			if (!shielded)
				b_loss += 60

			f_loss += 60

			ear_damage += 30
			ear_deaf += 120

		if(3.0)
			b_loss += 30
			if (prob(50) && !shielded)
				Paralyse(1)
			ear_damage += 15
			ear_deaf += 60

	adjustBruteLoss(b_loss)
	adjustFireLoss(f_loss)

	updatehealth()

/mob/living/carbon/xenomorph/blob_act()
	if (stat == DEAD)
		return
	var/shielded = 0
	var/damage = null
	if (stat != DEAD)
		damage = rand(30,40)

	if(shielded)
		damage /= 4


	to_chat(src, "<span class='warning'>The blob attacks!</span>")

	adjustFireLoss(damage)

	updatehealth()
	return

/mob/living/carbon/xenomorph/emp_act(severity)
	return

/mob/living/carbon/xenomorph/attack_ui(slot_id)
	return

/mob/living/carbon/xenomorph/restrained()
	return 0

/mob/living/carbon/xenomorph/show_inv(mob/user)
	return

/mob/living/carbon/xenomorph/getTrail()
	return "xltrails"

/*----------------------------------------
Proc: AddInfectionImages()
Des: Gives the client of the alien an image on each infected mob.
----------------------------------------*/
/mob/living/carbon/xenomorph/proc/AddInfectionImages()
	if (client)
		for (var/mob/living/C in living_list)
			if(C.status_flags & XENO_HOST)
				var/obj/item/alien_embryo/A = locate() in C
				var/I = image('icons/mob/alien.dmi', loc = C, icon_state = "infected[A.stage]")
				client.images += I
	return


/*----------------------------------------
Proc: RemoveInfectionImages()
Des: Removes all infected images from the alien.
----------------------------------------*/
/mob/living/carbon/xenomorph/proc/RemoveInfectionImages()
	if (client)
		for(var/image/I in client.images)
			if(dd_hasprefix(I.icon_state, "infected"))
				qdel(I)
	return

/mob/living/carbon/xenomorph/swap_hand()
	var/obj/item/item_in_hand = src.get_active_hand()
	if(item_in_hand) //this segment checks if the item in your hand is twohanded.
		if(istype(item_in_hand,/obj/item/weapon/twohanded))
			if(item_in_hand:wielded == 1)
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

/mob/living/carbon/xenomorph/get_pixel_y_offset(lying = 0)
	return initial(pixel_y)
