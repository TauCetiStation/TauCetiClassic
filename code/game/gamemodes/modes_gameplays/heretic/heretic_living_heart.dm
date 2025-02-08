/**
 * # Living Heart Component
 *
 * Applied to a heart to turn it into a heretic's 'living heart'.
 * The living heart is what they use to track people they need to sacrifice.
 *
 * This component handles the action associated with it -
 * if the organ is removed, the action should be deleted
 */
/datum/component/living_heart
	/// The action we create and give to our heart.
	var/datum/action/cooldown/track_target/action

/datum/component/living_heart/Initialize()
	if(!isorgan(parent))
		return COMPONENT_INCOMPATIBLE

	var/obj/item/organ/organ_parent = parent
	action = new(src)
	action.Grant(organ_parent.owner)

/datum/component/living_heart/Destroy(force)
	QDEL_NULL(action)
	return ..()

/datum/component/living_heart/RegisterWithParent()
	ADD_TRAIT(parent, TRAIT_LIVING_HEART, REF(src))
	RegisterSignal(parent, COMSIG_ORGAN_REMOVED, PROC_REF(on_organ_removed))
	RegisterSignal(parent, COMSIG_ORGAN_BEING_REPLACED, PROC_REF(on_organ_replaced))

/datum/component/living_heart/UnregisterFromParent()
	REMOVE_TRAIT(parent, TRAIT_LIVING_HEART, REF(src))
	UnregisterSignal(parent, list(COMSIG_ORGAN_REMOVED, COMSIG_ORGAN_BEING_REPLACED))

/datum/component/living_heart/PostTransfer(datum/new_parent)
	if(!isorgan(new_parent))
		return COMPONENT_INCOMPATIBLE

/**
 * Signal proc for [COMSIG_ORGAN_REMOVED].
 *
 * If the organ is removed, the component will remove itself.
 */
/datum/component/living_heart/proc/on_organ_removed(obj/item/organ/source, mob/living/carbon/old_owner)
	SIGNAL_HANDLER

	to_chat(old_owner, span_userdanger("As your living [source.name] leaves your body, you feel less connected to the Mansus!"))
	qdel(src)

/**
 * Signal proc for [COMSIG_ORGAN_BEING_REPLACED].
 *
 * If the organ is replaced, before it's done transfer the component over
 */
/datum/component/living_heart/proc/on_organ_replaced(obj/item/organ/source, obj/item/organ/replacement)
	SIGNAL_HANDLER

	if(IS_ROBOTIC_ORGAN(replacement))
		qdel(src)
		return

	replacement.TakeComponent(src)

/**
 * The action associated with the living heart.
 * Allows a heretic to track sacrifice targets.
 */
/datum/action/cooldown/track_target
	name = "Living Heartbeat"
	desc = "LMB: Chose one of your sacrifice targets to track. RMB: Repeats last target you chose to track."
	check_flags = AB_CHECK_CONSCIOUS
	background_icon_state = "bg_heretic"
	icon = 'icons/heretic/weapon/eldritch.dmi'
	button_icon_state = "living_heart"
	charge_max = 4 SECONDS

	/// Tracks whether we were right clicked or left clicked in our last trigger
	var/right_clicked = FALSE
	/// The real name of the last mob we tracked
	var/last_tracked_name
	/// Whether the target radial is currently opened.
	var/radial_open = FALSE
	/// Navigator to our target that we have.
	var/datum/status_effect/agent_pinpointer/scan/heretic/heretic_pinpointer

/datum/action/cooldown/track_target/Grant(mob/granted)
	if(!isheretic(granted))
		return

	return ..()

/datum/action/cooldown/track_target/IsAvailable(feedback = FALSE)
	. = ..()
	if(!.)
		return

	if(!isheretic(owner))
		return FALSE
	if(radial_open)
		return FALSE

	return TRUE

/datum/action/cooldown/track_target/Trigger(trigger_flags, atom/target)
	right_clicked = !!(trigger_flags & TRIGGER_SECONDARY_ACTION)
	return ..()

/datum/action/cooldown/track_target/Activate(atom/target)
	var/datum/role/heretic/heretic_datum = GET_HERETIC(owner)
	var/datum/heretic_knowledge/sac_knowledge = heretic_datum.get_knowledge(/datum/heretic_knowledge/hunt_and_sacrifice)
	if(!LAZYLEN(heretic_datum.sac_targets))
		owner.balloon_alert(owner, "no targets, visit a rune!")
		StartCooldown(1 SECONDS)
		return TRUE

	var/list/targets_to_choose = list()
	var/list/mob/living/carbon/human/human_targets = list()
	for(var/mob/living/carbon/human/sac_target as anything in heretic_datum.sac_targets)
		human_targets[sac_target.real_name] = sac_target
		targets_to_choose[sac_target.real_name] = heretic_datum.sac_targets[sac_target]

	// If we don't have a last tracked name, open a radial to set one.
	// If we DO have a last tracked name, we skip the radial if they right click the action.
	if(isnull(last_tracked_name) || !right_clicked)
		radial_open = TRUE
		last_tracked_name = show_radial_menu(
			owner,
			owner,
			targets_to_choose,
			custom_check = CALLBACK(src, PROC_REF(check_menu)),
			radius = 40,
			require_near = TRUE,
			tooltips = TRUE,
		)
		radial_open = FALSE

	// If our last tracked name is still null, skip the trigger
	if(isnull(last_tracked_name))
		return FALSE

	var/mob/living/carbon/human/tracked_mob = human_targets[last_tracked_name]
	if(QDELETED(tracked_mob))
		last_tracked_name = null
		return FALSE

	playsound(owner, 'sound/effects/singlebeat.ogg', 50, TRUE, SILENCED_SOUND_EXTRARANGE)
	owner.balloon_alert(owner, get_balloon_message(tracked_mob))


	// Let them know how to sacrifice people if they're able to be sac'd
	if(tracked_mob.stat == DEAD)
		to_chat(owner, span_hierophant("[tracked_mob] is dead. Bring them to a transmutation rune \
			and invoke \"[sac_knowledge.name]\" to sacrifice them!"))

	StartCooldown()
	return TRUE

/datum/action/cooldown/track_target/proc/make_navigate_arrow(turf/tracked_turf, arrow_color)
	var/datum/hud/user_hud = owner.hud_used
	if(!user_hud)
		return
	var/atom/movable/screen/heretic_arrow/arrow = new /atom/movable/screen/heretic_arrow(null, user_hud)
	animate(arrow, transform = matrix(dir2angle(get_dir(owner, tracked_turf)), MATRIX_ROTATE), 0.2 SECONDS)
	arrow.screen_loc = around_player
	arrow.color = arrow_color
	user_hud.infodisplay += arrow
	user_hud.show_hud(user_hud.hud_version)
	addtimer(CALLBACK(src, PROC_REF(end_effect), user_hud, arrow), 1.6 SECONDS)

/datum/action/cooldown/track_target/proc/end_effect(datum/hud/user_hud, atom/movable/screen/heretic_arrow/arrow)
	arrow.icon_state = "heretic_arrow_disappear"
	addtimer(CALLBACK(src, PROC_REF(null_arrow), user_hud, arrow), 0.4 SECONDS)

/datum/action/cooldown/track_target/proc/null_arrow(datum/hud/user_hud, atom/movable/screen/heretic_arrow/arrow)
	user_hud.infodisplay -= arrow
	user_hud.show_hud(user_hud.hud_version)

/// Callback for the radial to ensure it's closed when not allowed.
/datum/action/cooldown/track_target/proc/check_menu()
	if(QDELETED(src))
		return FALSE
	if(!isheretic(owner))
		return FALSE
	return TRUE

/// Gets the balloon message for who we're tracking.
/datum/action/cooldown/track_target/proc/get_balloon_message(mob/living/carbon/human/tracked_mob)
	var/balloon_message = "error text!"
	var/turf/their_turf = get_turf(tracked_mob)
	var/turf/our_turf = get_turf(owner)
	var/their_z = their_turf?.z
	var/our_z = our_turf?.z

	// One of us is in somewhere we shouldn't be
	if(!our_z || !their_z)
		// "Hell if I know"
		balloon_message = "on another plane!"

	// They're not on the same z-level as us
	else if(our_z != their_z)
		// They're on the station
		if(is_station_level(their_z))
			// We're on a multi-z station
			if(is_station_level(our_z))
				if(our_z > their_z)
					balloon_message = "below you!"
				else
					balloon_message = "above you!"
			// We're off station, they're not
			else
				balloon_message = "on station!"

		// Mining
		else if(is_mining_level(their_z))
			balloon_message = "on lavaland!"

		// In the gateway
		else if(is_away_level(their_z) || is_secret_level(their_z))
			balloon_message = "beyond the gateway!"

		// They're somewhere we probably can't get too - sacrifice z-level, centcom, etc
		else
			balloon_message = "on another plane!"

	// They're on the same z-level as us!
	else
		var/dist = get_dist(our_turf, their_turf)
		var/dir = get_dir(our_turf, their_turf)

		var/arrow_color

		switch(dist)
			if(0 to 15)
				balloon_message = "very near, [dir2text(dir)]!"
				arrow_color = COLOR_GREEN
			if(16 to 31)
				balloon_message = "near, [dir2text(dir)]!"
				arrow_color = COLOR_YELLOW
			if(32 to 127)
				balloon_message = "far, [dir2text(dir)]!"
				arrow_color = COLOR_ORANGE
			else
				balloon_message = "very far!"
				arrow_color = COLOR_RED

		make_navigate_arrow(their_turf, arrow_color)

	if(tracked_mob.stat == DEAD)
		balloon_message = "they're dead, " + balloon_message

	return balloon_message

/atom/movable/screen/heretic_arrow
	icon = 'icons/effects/96x96.dmi'
	name = "heretic arrow"
	icon_state = "heretic_arrow_appear"
	pixel_x = -32
	pixel_y = -32
