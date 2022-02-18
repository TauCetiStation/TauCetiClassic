/atom/movable/proc/play_rock_paper_scissors_animation(choice)
	var/choice_icon
	var/choice_icon_state
	switch(choice)
		if("rock")
			choice_icon = 'icons/obj/mining.dmi'
			choice_icon_state = pick("slag", "Coal ore")
		if("paper")
			choice_icon = 'icons/obj/bureaucracy.dmi'
			choice_icon_state = pick("paper", "paper_words", "paper_talisman", "cpaper_words")
		if("scissors")
			choice_icon = 'icons/obj/items.dmi'
			choice_icon_state = "scissors"
		else
			return

	var/image/I = image(choice_icon, src, choice_icon_state, EMOTE_LAYER)
	I.alpha = 200
	I.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/offeset = 15
	var/animation_time = 2 SECOND
	flick_overlay(I, clients, animation_time)
	animate(I, pixel_x = X_OFFSET(offeset, dir), pixel_y = Y_OFFSET(offeset, dir), alpha = 0, time = animation_time)
	QDEL_IN(I, animation_time)
