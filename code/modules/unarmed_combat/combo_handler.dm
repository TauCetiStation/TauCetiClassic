#define ANIM_MAX_HIT_TURN_ANGLE 40
#define COMBOPOINTS_LOSE_PER_TICK 0.7
#define MIN_COMBOPOINTS_LOSE_PER_TICK 0.3

/*
 * This class handles all combo-attack logic,
 * accumulating points, choosing the next combo,
 * creating an user interface.
 */
/datum/combo_handler
	var/last_hit_registered = 0
	var/delete_after_no_hits = 10 SECONDS

	// Amount of "combo points" accumulated.
	var/fullness = 0
	// An icon of current available combo.
	var/image/combo_icon
	var/list/combo_elements_icons = list()

	// Displays fullness.
	var/datum/progressbar/progbar

	var/list/combo_elements = list()

	var/mob/living/attacker
	var/mob/living/victim
	var/datum/combat_combo/next_combo

	// Switching hands doubles fullness gained.
	var/last_hand_hit = 0

	// After reaching this cap, the first combo element is deleted, and all others are shifted "left".
	var/max_combo_elements = 4

/datum/combo_handler/New(mob/living/victim, mob/living/attacker, combo_element, combo_value, max_combo_elements = 4)
	last_hit_registered = world.time + delete_after_no_hits

	src.attacker = attacker
	src.victim = victim
	progbar = new(attacker, 100, victim, my_icon_state="combat_prog_bar", insert_under=TRUE)

	src.max_combo_elements = max_combo_elements // Take note, that there are only sprites for 4 atm.

/datum/combo_handler/Destroy()
	if(attacker.client)
		if(combo_icon)
			attacker.client.images -= combo_icon
		for(var/c_el_i in combo_elements_icons)
			attacker.client.images -= c_el_i
	QDEL_NULL(combo_icon)
	QDEL_LIST(combo_elements_icons)
	attacker.combo_animation = FALSE
	attacker.attack_animation = FALSE
	attacker.combos_performed -= src
	victim.combos_saved -= src
	attacker = null
	victim = null
	QDEL_NULL(progbar)
	next_combo = null
	return ..()

/datum/combo_handler/proc/set_combo_icon(image/new_icon)
	if(!attacker)
		return

	if(combo_icon && attacker.client)
		attacker.client.images -= combo_icon

	if(new_icon)
		combo_icon = new_icon
		combo_icon.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
		combo_icon.loc = victim
		if(attacker.client)
			attacker.client.images += combo_icon
			var/matrix/M = matrix()
			M.Scale(0.1)
			combo_icon.transform = M
			var/matrix/N = matrix()
			animate(combo_icon, transform=N, time=2)

		INVOKE_ASYNC(src, .proc/shake_combo_icon)

/datum/combo_handler/proc/shake_combo_icon()
	sleep(2) // This is here for set_combo_icon to properly animate the icon.

	if(!attacker || !attacker.client)
		return

	var/matrix/M = matrix()
	for(var/i in 1 to 3)
		if(!combo_icon)
			return
		M.Turn(pick(-30, 30))
		animate(combo_icon, transform=M, time=2)
		sleep(2)
		if(!combo_icon)
			return
		M = matrix()
		animate(combo_icon, transform=M, time=1)
		sleep(1)

// Animates a push/hurt hit.
/datum/combo_handler/proc/animate_attack(combo_element, combo_value, mob/living/V, mob/living/A)
	if(A.attack_animation || A.combo_animation || A.notransform)
		return
	A.attack_animation = TRUE

	combo_value = min(ANIM_MAX_HIT_TURN_ANGLE, combo_value)

	var/matrix/M = matrix(A.default_transform)
	if(iscarbon(A))
		if(A.hand)
			M.Turn(-combo_value)
		else
			M.Turn(combo_value)
	else
		M.Turn(pick(-combo_value, combo_value))

	animate(A, transform=M, time=2)
	sleep(2)
	if(QDELETED(A))
		return
	if(QDELETED(src))
		A.transform = A.default_transform
		A.attack_animation = FALSE
		return
	animate(A, transform=A.default_transform, time=1)
	sleep(1)
	if(QDELETED(A))
		return
	A.transform = A.default_transform
	A.attack_animation = FALSE

/datum/combo_handler/proc/update_combo_elements()
	if(attacker && attacker.client)
		for(var/combo_element_icon in combo_elements_icons)
			attacker.client.images -= combo_element_icon
		combo_elements_icons.Cut()

		var/i = 1
		for(var/c_el in combo_elements)
			var/CC_icon_state = "combo_element_combo"
			switch(c_el)
				if(INTENT_HELP)
					CC_icon_state = "combo_element_help"
				if(INTENT_PUSH)
					CC_icon_state = "combo_element_disarm"
				if(INTENT_GRAB)
					CC_icon_state = "combo_element_grab"
				if(INTENT_HARM)
					CC_icon_state = "combo_element_hurt"
			var/image/C_EL_I = image(icon='icons/mob/unarmed_combat_combos.dmi', icon_state="[CC_icon_state]_[i]")
			C_EL_I.loc = victim
			C_EL_I.layer = ABOVE_HUD_LAYER
			C_EL_I.plane = ABOVE_HUD_PLANE
			C_EL_I.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
			C_EL_I.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
			C_EL_I.pixel_x = 8
			C_EL_I.pixel_y = -2
			combo_elements_icons += C_EL_I
			attacker.client.images += C_EL_I
			i++

/datum/combo_handler/proc/get_next_combo()
	var/target_zone = attacker.get_targetzone()

	var/combo_hash = "[target_zone]|"
	for(var/CE in combo_elements)
		combo_hash += "[CE]#"

	var/datum/combat_combo/CC = global.combat_combos[combo_hash]
	if(CC && CC.can_execute(src))
		next_combo = global.combat_combos[combo_hash]
		set_combo_icon(next_combo.get_combo_icon())
		next_combo.on_ready(victim, attacker)

		return TRUE
	return FALSE

// An async wrapper for everything animation-related.
/datum/combo_handler/proc/do_animation(datum/combat_combo/CC)
	if(CC.heavy_animation)
		CC.before_animation(victim, attacker)

	CC.animate_combo(victim, attacker)

	if(CC.heavy_animation)
		CC.after_animation(victim, attacker)

// Returns TRUE if a we want to cancel the AltClick/whatever was there. But actually, basically always
// returns TRUE.
/datum/combo_handler/proc/activate_combo()
	if(!attacker)
		return FALSE

	var/datum/combat_combo/CC = next_combo
	if(!CC)
		return FALSE

	if(CC.can_execute(src, show_warning = TRUE))
		next_combo = null
		CC.pre_execute(victim, attacker)

		INVOKE_ASYNC(src, .proc/do_animation, CC)

		CC.execute(victim, attacker)
		fullness -= CC.fullness_lose_on_execute
		set_combo_icon(null)
		combo_elements.Cut()
		register_attack(CC.name, 0)
	else
		set_combo_icon(null)
		next_combo = null
		get_next_combo()
	return TRUE

// Is used to remove the first combo element, so users can perform combos with elements lower than max.
/datum/combo_handler/proc/drop_combo_element()
	if(combo_elements.len >= 1)
		combo_elements.Cut(1, 2)
		update_combo_elements()
		set_combo_icon(null)
		next_combo = null
		get_next_combo()

/datum/combo_handler/proc/register_attack(combo_element, combo_value)
	if(!attacker)
		return

	last_hit_registered = world.time
	if(combo_elements.len == max_combo_elements)
		combo_elements.Cut(1, 2)

	if(attacker.hand != last_hand_hit)
		combo_value *= 2
		last_hand_hit = attacker.hand

	if(attacker.incapacitated())
		combo_value *= 0.5
	if(victim.incapacitated())
		combo_value *= 0.5

	if(attacker.crawling) // Suffer, crawling scum.
		combo_value *= 0.5
	if(victim.crawling) // SUFFER CRAWLING SCUM.
		combo_value *= 2.0

	combo_elements += combo_element

	fullness = min(100, fullness + combo_value)

	if(next_combo)
		set_combo_icon(null)
		next_combo = null
	else
		get_next_combo()

	update_combo_elements()

	if(combo_element == INTENT_PUSH || combo_element == INTENT_HARM)
		INVOKE_ASYNC(src, .proc/animate_attack, combo_element, combo_value, victim, attacker)

	return FALSE

/datum/combo_handler/proc/update()
	if(!attacker)
		return

	if(combo_icon && (SSmobs.times_fired % 3) == 0)
		INVOKE_ASYNC(src, .proc/shake_combo_icon)

	progbar.update(fullness)

	var/fullness_to_remove = COMBOPOINTS_LOSE_PER_TICK
	fullness_to_remove = max(MIN_COMBOPOINTS_LOSE_PER_TICK, fullness_to_remove - length(attacker.combos_performed) * 0.1)
	fullness -= fullness_to_remove

	if(next_combo)
		// Lose combo since we lost the thing.
		if(next_combo.fullness_lose_on_execute > fullness)
			set_combo_icon(null)
			next_combo = null
			// Perhaps a less powerful combo is there?
			get_next_combo()

	else if(get_next_combo())
		update_combo_elements()

	if(fullness < 0 || last_hit_registered + delete_after_no_hits < world.time)
		qdel(src)

#undef ANIM_MAX_HIT_TURN_ANGLE
#undef COMBOPOINTS_LOSE_PER_TICK
#undef MIN_COMBOPOINTS_LOSE_PER_TICK
