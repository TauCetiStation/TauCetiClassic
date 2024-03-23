/mob/living/Life()
	set invisibility = 0
	set background = BACKGROUND_ENABLED

	if (notransform)
		return
	if(!loc)
		return

	if(stat != DEAD)
		add_ingame_age()

	update_gravity(mob_has_gravity())

	handle_combat()

	handle_nutrition()

	if(client)
		handle_regular_hud_updates()
		var/turf/T = get_turf(src)
		if(T && last_z != T.z)
			update_z(T.z)

/mob/living/proc/update_health_hud()
	if(!healths)
		return

	if(stat == DEAD)
		healths.icon_state = "health7"
		return

	var/severity
	switch(100 * health / maxHealth)
		if(100 to INFINITY)
			severity = 0
		if(80 to 100)
			severity = 1
		if(60 to 80)
			severity = 2
		if(40 to 60)
			severity = 3
		if(20 to 40)
			severity = 4
		if(0 to 20)
			severity = 5
		else
			severity = 6

	healths.icon_state = "health[severity]"

/mob/living/proc/handle_regular_hud_updates()
	if(!client)
		return

	handle_vision()
	update_health_hud()

	pullin?.update_icon(src)

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

/mob/living/proc/handle_vision(vision_for_dead = FALSE)
	update_sight()

	if(vision_for_dead || stat != DEAD)
		if(blinded)
			throw_alert("blind", /atom/movable/screen/alert/blind)
			overlay_fullscreen("blind", /atom/movable/screen/fullscreen/blind)
		else if(is_vision_obstructed() && !(XRAY in mutations))
			overlay_fullscreen("blind", /atom/movable/screen/fullscreen/blind)
		else
			clear_alert("blind")
			clear_fullscreen("blind", 0)
		if(machine)
			if (!(machine.check_eye(src)))
				reset_view(null)
		else
			if(!client?.adminobs && !force_remote_viewing)
				reset_view(null)


/mob/update_action_buttons()
	if(!hud_used) return
	if(!client) return

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
			var/atom/movable/screen/movable/action_button/N = new(hud_used)
			N.owner = A
			A.button = N

		var/atom/movable/screen/movable/action_button/B = A.button

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

/mob/living/proc/handle_nutrition()
	return
