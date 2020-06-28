/mob/living/Life()
	set invisibility = 0
	set background = BACKGROUND_ENABLED

	if (notransform)
		return
	if(!loc)
		return

	if(stat != DEAD)
		handle_actions()
		add_ingame_age()

	if(pull_debuff && !pulling)	//For cases when pulling was stopped by 'pulling = null'
		pull_debuff = 0
	update_gravity(mob_has_gravity())

	handle_actions()
	handle_combat()

	if(client)
		handle_regular_hud_updates()

/mob/living/proc/handle_actions()
	//Pretty bad, i'd use picked/dropped instead but the parent calls in these are nonexistent
	for(var/datum/action/A in actions)
		if(A.CheckRemoval(src))
			A.Remove(src)
	for(var/obj/item/I in src)
		if(I.action_button_name)
			if(!I.action)
				if(I.action_button_is_hands_free)
					I.action = new/datum/action/item_action/hands_free
				else
					I.action = new/datum/action/item_action
				I.action.name = I.action_button_name
				I.action.target = I
			I.action.Grant(src)
	return

/mob/living/proc/handle_regular_hud_updates()
	if(!client)
		return 0

	handle_vision()
	update_action_buttons()

	return 1

/mob/living/proc/is_vision_obstructed()
	if(istype(loc, /obj/item/weapon/holder))
		if(ishuman(loc.loc))
			var/mob/living/H = loc.loc
			return H.is_vision_obstructed()
		else
			return TRUE
	if(istype(src, /mob/living/carbon/monkey/diona) && ishuman(loc))
		var/mob/living/H = loc
		if(H.get_species() == DIONA)
			return FALSE
	return loc && !isturf(loc) && !is_type_in_list(loc, ignore_vision_inside)

/mob/living/proc/handle_vision()
	update_sight()

	if(stat != DEAD)
		if(blinded)
			throw_alert("blind", /obj/screen/alert/blind)
			overlay_fullscreen("blind", /obj/screen/fullscreen/blind)
		else if(is_vision_obstructed() && !(XRAY in mutations))
			overlay_fullscreen("blind", /obj/screen/fullscreen/blind)
		else
			clear_alert("blind")
			clear_fullscreen("blind", 0)
			if(!ishuman(src))
				if(disabilities & NEARSIGHTED)
					overlay_fullscreen("impaired", /obj/screen/fullscreen/impaired, 1)
				else
					clear_fullscreen("impaired")

				if(eye_blurry)
					overlay_fullscreen("blurry", /obj/screen/fullscreen/blurry)
				else
					clear_fullscreen("blurry")

				if(druggy)
					overlay_fullscreen("high", /obj/screen/fullscreen/high)
				else
					clear_fullscreen("high")

		if(machine)
			if (!(machine.check_eye(src)))
				reset_view(null)
		else
			if(!client.adminobs)
				reset_view(null)

/mob/living/proc/update_sight()
	return

/mob/living/update_action_buttons()
	if(!hud_used) return
	if(!client) return

	if(hud_used.hud_shown != 1)	//Hud toggled to minimal
		return

	client.screen -= hud_used.hide_actions_toggle
	for(var/datum/action/A in actions)
		if(A.button)
			client.screen -= A.button
		if(!A.target)
			actions -= A
			qdel(A)

	if(hud_used.action_buttons_hidden)
		if(!hud_used.hide_actions_toggle)
			hud_used.hide_actions_toggle = new(hud_used)
			hud_used.hide_actions_toggle.UpdateIcon()

		if(!hud_used.hide_actions_toggle.moved)
			hud_used.hide_actions_toggle.screen_loc = hud_used.ButtonNumberToScreenCoords(1)
			//hud_used.SetButtonCoords(hud_used.hide_actions_toggle,1)

		client.screen += hud_used.hide_actions_toggle
		return

	var/button_number = 0
	for(var/datum/action/A in actions)
		button_number++
		if(A.button == null)
			var/obj/screen/movable/action_button/N = new(hud_used)
			N.owner = A
			A.button = N

		var/obj/screen/movable/action_button/B = A.button

		B.UpdateIcon()

		B.name = A.UpdateName()

		client.screen += B

		if(!B.moved)
			B.screen_loc = hud_used.ButtonNumberToScreenCoords(button_number)
			//hud_used.SetButtonCoords(B,button_number)

	if(button_number > 0)
		if(!hud_used.hide_actions_toggle)
			hud_used.hide_actions_toggle = new(hud_used)
			hud_used.hide_actions_toggle.InitialiseIcon(src)
		if(!hud_used.hide_actions_toggle.moved)
			hud_used.hide_actions_toggle.screen_loc = hud_used.ButtonNumberToScreenCoords(button_number+1)
			//hud_used.SetButtonCoords(hud_used.hide_actions_toggle,button_number+1)
		client.screen += hud_used.hide_actions_toggle
