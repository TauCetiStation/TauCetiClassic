/mob/living/carbon/human/is_busy(atom/target, show_warning = TRUE)
	if(busy_with_action)
		if(HAS_TRAIT(src, TRAIT_MULTITASKING))
			if(busy_left_hand && busy_right_hand)
				if(show_warning)
					to_chat(src, "<span class='warning'>You are busy. Please finish or cancel your current action.</span>")
				return TRUE

			if(hand)
				if(busy_left_hand)
					if(show_warning)
						to_chat(src, "<span class='warning'>Your left hand is busy. Please finish or cancel your current action, or try the other hand.</span>")
					return TRUE
			else
				if(busy_right_hand)
					if(show_warning)
						to_chat(src, "<span class='warning'>Your right hand is busy. Please finish or cancel your current action, or try the other hand.</span>")
					return TRUE
		else
			if(show_warning)
				to_chat(src, "<span class='warning'>You are busy. Please finish or cancel your current action.</span>")
			return TRUE
	if(target && target.in_use_action)
		if(show_warning)
			to_chat(src, "<span class='warning'>Please wait while someone else will finish interacting with [target].</span>")
		return TRUE
	return FALSE

/mob/living/carbon/human/become_busy(_hand = 0) // 0 is right hand, don't question it we don't have defines for this yet.
	if(_hand)
		busy_left_hand = TRUE
	else
		busy_right_hand = TRUE
	busy_with_action = TRUE

/mob/living/carbon/human/become_not_busy(_hand = 0) // See remark above.
	if(_hand)
		busy_left_hand = FALSE
	else
		busy_right_hand = FALSE
	if(!busy_left_hand && !busy_right_hand)
		busy_with_action = FALSE

/mob/living/carbon/human/proc/compare_heights(mob/living/carbon/human/A)
	var/first_height = 0
	var/second_height = 0
	var/difference = 0

	switch(A.height)
		if(HUMANHEIGHT_SHORTEST)
			first_height = 1
		if(HUMANHEIGHT_SHORT)
			first_height = 2
		if(HUMANHEIGHT_MEDIUM)
			first_height = 3
		if(HUMANHEIGHT_TALL)
			first_height = 4
		if(HUMANHEIGHT_TALLEST)
			first_height = 5
	if(!(SMALLSIZE in A.mutations))
		first_height += 5

	switch(height)
		if(HUMANHEIGHT_SHORTEST)
			second_height = 1
		if(HUMANHEIGHT_SHORT)
			second_height = 2
		if(HUMANHEIGHT_MEDIUM)
			second_height = 3
		if(HUMANHEIGHT_TALL)
			second_height = 4
		if(HUMANHEIGHT_TALLEST)
			second_height = 5
	if(!(SMALLSIZE in mutations))
		second_height += 5

	difference = first_height - second_height

	return difference

/mob/living/carbon/human/proc/check_hit_direction(mob/living/carbon/human/Attacker)
	var/message = ""
	var/difference = compare_heights(Attacker)
	switch(difference)
		if(-9)
			message = "The hit has been dealt from a very below"
		if(-8)
			message = "The hit has been dealt from a very below"
		if(-7)
			message = "The hit has been dealt from a very below"
		if(-6)
			message = "The hit has been dealt from a very below"
		if(-5)
			message = "The hit has been dealt from a below"
		if(-4)
			message = "The hit has been dealt from a below"
		if(-3)
			message = "The hit has been dealt from a below"
		if(-2)
			message = "The hit has been dealt from a below"
		if(-1)
			message = "The hit has been dealt from a same height"
		if(0)
			message = "The hit has been dealt from a same height"
		if(1)
			message = "The hit has been dealt from a same height"
		if(2)
			message = "The hit has been dealt from an above"
		if(3)
			message = "The hit has been dealt from an above"
		if(4)
			message = "The hit has been dealt from an above"
		if(5)
			message = "The hit has been dealt from an above"
		if(6)
			message = "The hit has been dealt from a very above"
		if(7)
			message = "The hit has been dealt from a very above"
		if(8)
			message = "The hit has been dealt from a very above"
		if(9)
			message = "The hit has been dealt from a very above"
	return message
