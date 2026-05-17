/obj/item/clothing/glasses/rocket_observation
	name = "rocket observation glasses"
	desc = "Allows you to observe rocket launch so you can better adjust accuracy."
	icon_state = "healthhudnight"
	off_state = "healthhudnight"
	item_state = "glasses"
	toggleable = TRUE
	
	var/obj/item/rocket/target

	item_action_types = list(/datum/action/item_action/hands_free/toggle_goggles)

/obj/item/clothing/glasses/rocket_observation/attack_self(mob/living/user)
	toggle_view(user)

/obj/item/clothing/glasses/rocket_observation/dropped(mob/living/user)
	if(user.client?.eye == target)
		toggle_view(user)

	return ..()

/obj/item/clothing/glasses/rocket_observation/proc/toggle_view(mob/living/user, eye_delay = 0)
	if(!istype(user))
		return

	if(user.client?.eye == target)
		if(eye_delay)
			// rocket destroyed, but give some time to watch explosion
			user.reset_view(get_turf(target), force_remote_viewing = TRUE)
			addtimer(CALLBACK(user, TYPE_PROC_REF(/mob/living, reset_view), null, TRUE), eye_delay)
		else
			user.reset_view(null, force_remote_viewing = FALSE)
		active = FALSE
	else
		if(!target)
			to_chat(user, "<span class='notice'>No rocket is tuned to the glasses! Use multitool on the rocket first.</span>")
			return
		user.reset_view(target, force_remote_viewing = TRUE)
		active = TRUE

	playsound(src, activation_sound, VOL_EFFECTS_MASTER, 10, FALSE)
	update_inv_mob()
	update_item_actions()

/obj/item/clothing/glasses/rocket_observation/proc/sync_to_rocket(obj/item/rocket/R)
	if(QDELING(R))
		return

	if(target)
		unsync_from_rocket(target)

	target = R
	R.tuned_glasses += src

/obj/item/clothing/glasses/rocket_observation/proc/unsync_from_rocket(obj/item/rocket/R, eye_delay = 0)
	if(target == R)
		if(slot_equipped && ismob(loc))
			var/mob/living/user = loc
			if(user.client?.eye == target)
				toggle_view(user, eye_delay)

		target = null

	R.tuned_glasses -= src
