/proc/random_blood_type()
	return pick(4;"O-", 36;"O+", 3;"A-", 28;"A+", 1;"B-", 20;"B+", 1;"AB-", 5;"AB+")

/proc/random_hair_style(gender, species = HUMAN, ipc_head)
	var/h_style = "Bald"

	var/list/valid_hairstyles = get_valid_styles_from_cache(hairs_cache, species, gender, ipc_head)

	if(valid_hairstyles.len)
		h_style = pick(valid_hairstyles)

	return h_style

/proc/random_gradient_style()
	return pick(hair_gradients)

/proc/random_facial_hair_style(gender, species = HUMAN)
	var/f_style = "Shaved"

	var/list/valid_facialhairstyles = get_valid_styles_from_cache(facial_hairs_cache, species, gender)

	if(valid_facialhairstyles.len)
		f_style = pick(valid_facialhairstyles)

		return f_style

/proc/random_unique_name(gender, attempts_to_find_unique_name = 10)
	for(var/i in 1 to attempts_to_find_unique_name)
		if(gender == FEMALE)
			. = capitalize(pick(global.first_names_female)) + " " + capitalize(pick(global.last_names))
		else
			. = capitalize(pick(global.first_names_male)) + " " + capitalize(pick(global.last_names))

		if(!findname(.))
			break

/proc/random_name(gender, species = HUMAN)
	if(gender==FEMALE)	return capitalize(pick(first_names_female)) + " " + capitalize(pick(last_names))
	else				return capitalize(pick(first_names_male)) + " " + capitalize(pick(last_names))

/proc/random_skin_tone()
	switch(pick(60;"caucasian", 15;"afroamerican", 10;"african", 10;"latino", 5;"albino"))
		if("caucasian")		. = -10
		if("afroamerican")	. = -115
		if("african")		. = -165
		if("latino")		. = -55
		if("albino")		. = 34
		else				. = rand(-185,34)
	return min(max( .+rand(-25, 25), -185),34)

/proc/skintone2racedescription(tone)
	switch (tone)
		if(30 to INFINITY)		return "albino"
		if(20 to 30)			return "pale"
		if(5 to 15)				return "light skinned"
		if(-10 to 5)			return "white"
		if(-25 to -10)			return "tan"
		if(-45 to -25)			return "darker skinned"
		if(-65 to -45)			return "brown"
		if(-INFINITY to -65)	return "black"
		else					return "unknown"

/proc/age2agedescription(age)
	switch(age)
		if(0 to 1)			return "infant"
		if(1 to 3)			return "toddler"
		if(3 to 13)			return "child"
		if(13 to 19)		return "teenager"
		if(19 to 30)		return "young adult"
		if(30 to 45)		return "adult"
		if(45 to 60)		return "middle-aged"
		if(60 to 70)		return "aging"
		if(70 to INFINITY)	return "elderly"
		else				return "unknown"

/proc/RoundHealth(health)
	switch(health)
		if(100 to INFINITY)
			return "health100"
		if(93 to 100)
			return "health93"
		if(86 to 93)
			return "health86"
		if(78 to 86)
			return "health78"
		if(71 to 78)
			return "health71"
		if(64 to 71)
			return "health64"
		if(56 to 64)
			return "health56"
		if(49 to 56)
			return "health49"
		if(42 to 49)
			return "health42"
		if(35 to 42)
			return "health35"
		if(28 to 35)
			return "health28"
		if(21 to 28)
			return "health21"
		if(14 to 21)
			return "health14"
		if(7 to 14)
			return "health7"
		if(1 to 7)
			return "health1"
		if(-50 to 1)
			return "health0"
		if(-85 to -50)
			return "health-50"
		if(-99 to -85)
			return "health-85"
		else
			return "health-100"

//helper for inverting armor blocked values into a multiplier
#define blocked_mult(blocked) max(1 - (blocked / 100), 0)

/proc/do_mob(mob/user , mob/target, time = 30, check_target_zone = FALSE, uninterruptible = FALSE, progress = TRUE, datum/callback/extra_checks = null)
	if(!user || !target)
		return FALSE

	var/busy_hand = user.hand
	user.become_busy(_hand = busy_hand)

	target.in_use_action = TRUE

	if(check_target_zone)
		check_target_zone = user.zone_sel.selecting

	var/user_loc = user.loc

	var/target_loc = target.loc

	var/holding = user.get_active_hand()
	var/datum/progressbar/progbar
	if (progress)
		if(user.client && (user.client.prefs.toggles & SHOW_PROGBAR))
			progbar = new(user, time, target)
		else
			progress = FALSE

	var/endtime = world.time+time
	var/starttime = world.time
	. = TRUE
	while (world.time < endtime)
		stoplag(1)
		if (progress)
			progbar.update(world.time - starttime)
		if(QDELETED(user) || QDELETED(target))
			. = FALSE
			break
		if(uninterruptible)
			continue
		if(user.loc != user_loc || target.loc != target_loc || user.incapacitated() || user.lying || (extra_checks && !extra_checks.Invoke()))
			. = FALSE
			break

		if(HAS_TRAIT(user, TRAIT_MULTITASKING))
			if(user.hand != busy_hand)
				if(user.get_inactive_hand() != holding)
					. = FALSE
					break
			else
				if(user.get_active_hand() != holding)
					. = FALSE
					break
		else
			if(user.hand != busy_hand)
				. = FALSE
				break
			if(user.get_active_hand() != holding)
				. = FALSE
				break

		if(check_target_zone && user.zone_sel.selecting != check_target_zone)
			. = FALSE
			break
	if(progress)
		qdel(progbar)
	if(user)
		user.become_not_busy(_hand = busy_hand)
	if(target)
		target.in_use_action = FALSE

/proc/do_after(mob/user, delay, needhand = TRUE, atom/target = null, can_move = FALSE, progress = TRUE, datum/callback/extra_checks = null)
	if(!user || target && QDELING(target))
		return FALSE

	var/busy_hand = user.hand
	user.become_busy(_hand = busy_hand)

	var/target_null = TRUE
	var/atom/Tloc = null
	if(target)
		target_null = FALSE
		if(target != user)
			target.in_use_action = TRUE
			Tloc = target.loc

	var/atom/Uloc = null
	if(!can_move)
		Uloc = user.loc

	var/obj/item/holding = user.get_active_hand()

	var/holdingnull = TRUE //User's hand started out empty, check for an empty hand
	if(holding)
		holdingnull = FALSE //Users hand started holding something, check to see if it's still holding that

	var/datum/progressbar/progbar
	if (progress)
		if(user.client && (user.client.prefs.toggles & SHOW_PROGBAR))
			progbar = new(user, delay, target)
		else
			progress = FALSE

	var/endtime = world.time + delay
	var/starttime = world.time
	. = TRUE
	while (world.time < endtime)
		stoplag(1)
		if (progress)
			progbar.update(world.time - starttime)

		if(QDELETED(user) || !target_null && QDELETED(target))
			. = FALSE
			break

		if(user.stat || user.weakened || user.stunned)
			. = FALSE
			break

		if(Uloc && (user.loc != Uloc) || Tloc && (Tloc != target.loc))
			. = FALSE
			break
		if(extra_checks && !extra_checks.Invoke())
			. = FALSE
			break

		if(needhand)
			//This might seem like an odd check, but you can still need a hand even when it's empty
			//i.e the hand is used to pull some item/tool out of the construction
			if(!holdingnull && QDELETED(holding))
				. = FALSE
				break

			if(HAS_TRAIT(user, TRAIT_MULTITASKING))
				if(user.hand != busy_hand)
					if(user.get_inactive_hand() != holding)
						. = FALSE
						break
				else
					if(user.get_active_hand() != holding)
						. = FALSE
						break
			else
				if(user.hand != busy_hand)
					. = FALSE
					break
				if(user.get_active_hand() != holding)
					. = FALSE
					break

	if(progress)
		qdel(progbar)
	if(user)
		user.become_not_busy(_hand = busy_hand)
	if(target && target != user)
		target.in_use_action = FALSE
