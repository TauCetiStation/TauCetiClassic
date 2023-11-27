/* Observation Glasses */

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

	if(user.client?.eye == target) // reset_view
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

/* Crates */

/obj/structure/storage_box/rocket
	name = "Rockets Crate"
	desc = "A heavy box storing rockets."
	var/spawn_type = /obj/item/rocket
	var/number = 9

/obj/structure/storage_box/rocket/atom_init(mapload)
	for(var/i in 1 to number)
		new spawn_type(src)

	return ..()

/obj/structure/storage_box/rocket/cheap
	name = "Cheap Explosive Rockets Crate"
	desc = "A heavy box storing rockets."
	spawn_type = /obj/item/rocket/cheap

/obj/structure/storage_box/rocket/explosive
	name = "Explosive Rockets Crate"
	desc = "A heavy box storing rockets."
	spawn_type = /obj/item/rocket/explosive

/obj/structure/storage_box/rocket/emp
	name = "EMP Rockets Crate"
	desc = "A heavy box storing rockets."
	spawn_type = /obj/item/rocket/emp

/obj/structure/storage_box/rocket/piercing
	name = "Armor-piercing Rockets Crate"
	desc = "A heavy box storing rockets."
	spawn_type = /obj/item/rocket/piercing

// todo: we need merge mechanics for simultaneous explosions on the same turf
// here i do it manyally because this box can contain only rockets
/obj/structure/storage_box/rocket/ex_act(severity)
	switch(severity)
		if(EXPLODE_HEAVY)
			if(prob(50))
				return
		if(EXPLODE_LIGHT)
			if(prob(95))
				return

	var/new_explosion_severity

	for(var/obj/item/rocket/R as anything in contents)
		new_explosion_severity += 0.5
		R.exploded = TRUE
		qdel(R)

	var/turf/T = get_turf(src)

	qdel(src) // mark as destroying first so explosions don't go into recursion

	if(new_explosion_severity)
		new_explosion_severity = clamp(new_explosion_severity, 1, 3)
		explosion(T, new_explosion_severity, new_explosion_severity*2, new_explosion_severity*3)

/* rockets */

/obj/item/rocket
	name = "rocket"
	desc = "Compatible with standard pneumatic systems."
	icon = 'icons/obj/rockets.dmi'
	icon_state = "rocket"

	throwforce = 20

	density = TRUE
	w_class = SIZE_LARGE

	var/accident_prob = 5

	var/triggered = TRUE // currently only for VV and debug purposes
	var/exploded = FALSE

	// human throw parameters - can't throw it far
	throw_speed = 1
	throw_range = 1

	// disposal outlet aka launch platform throw parameters
	var/launch_speed = 3
	var/launch_angle = 0

	var/list/obj/item/clothing/glasses/rocket_observation/tuned_glasses = list()

/obj/item/rocket/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	// check for speed threshhold only if it's not throwed by a mob (fuck user momentum), else do prob for accident
	// todo: make this treshhold more readable and allow atoms be thrower so we can check for disposal here
	if(triggered && ((!throwingdatum.thrower && throwingdatum.speed >= 3) || prob(accident_prob*throwingdatum.speed)))
		trigger(hit_atom)
		QDEL_NULL(src)
	else
		return ..()

/obj/item/rocket/proc/trigger(atom/target)
	if(!exploded)
		exploded = TRUE
		explosion(target, 1, 2, 4)

/obj/item/rocket/Destroy()
	trigger(get_turf(loc))

	for(var/obj/item/clothing/glasses/rocket_observation/glasses as anything in tuned_glasses)
		glasses.unsync_from_rocket(src, eye_delay = 1 SECOND)

	tuned_glasses = null

	return ..()

/obj/item/rocket/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			qdel(src)
		if(EXPLODE_HEAVY)
			if(prob(40+accident_prob*2))
				qdel(src)
		if(EXPLODE_LIGHT)
			if(prob(accident_prob*2))
				qdel(src)

/obj/item/rocket/attackby(obj/item/C, mob/user)
	if(ispulsing(C))
		var/useroption = tgui_alert(user, "Choise option", "Options:", list("Tune to Glasses", "Change angle")) // todo: radial?

		if(useroption == "Tune to Glasses")
			var/mob/living/carbon/human/H = user
			if(istype(H) && H.glasses && istype(H.glasses, /obj/item/clothing/glasses/rocket_observation))
				var/obj/item/clothing/glasses/rocket_observation/WO = H.glasses
				WO.sync_to_rocket(src)
				to_chat(usr, "<span class='notice'>You have successfully tuned \the [WO] to \the [src]</span>")
			else
				to_chat(usr, "<span class='warning'>You don't have observation glasses!</span>")
				return

		else if(useroption == "Change angle")
			var/new_angle = input("Enter new angle between -45 and 45", "Angle Setup", launch_angle) as num|null
			if(!isnum(new_angle))
				return
			if(user.incapacitated() || !Adjacent(user))
				to_chat(usr, "<span class='warning'>You can't do it!</span>")
				return

			launch_angle = clamp(round(new_angle), -45, 45)
			to_chat(usr, "<span class='notice'>You have set launch angle to [launch_angle] degrees.</span>")
			update_name()

		return TRUE
	return ..()

/obj/item/rocket/proc/update_name()
	name = "[initial(name)]"
	if(launch_angle)
		name += " ([launch_angle]deg)"

/* Explosive */

/obj/item/rocket/cheap
	name = "cheap explosive rocket"
	desc = "Compatible with standard pneumatic systems. This one looks suspicious."
	accident_prob = 15

/obj/item/rocket/explosive
	name = "explosive rocket"
	icon_state = "rocket_red"

/obj/item/rocket/explosive/trigger(atom/target)
	if(!exploded)
		exploded = TRUE
		explosion(target, 2, 4, 6)

/* EMP */

/obj/item/rocket/emp
	name = "EMP rocket"
	icon_state = "rocket_blue"

/obj/item/rocket/emp/trigger(atom/target)
	if(!exploded)
		exploded = TRUE
		empulse(target, 5, 10)

/* Armor-piercing */

/obj/item/rocket/piercing
	name = "armor-piercing rocket"
	icon_state = "rocket_green"

	var/pierced = 0
	var/pierced_cap = 4

/obj/item/rocket/piercing/trigger(atom/target)
	if(!exploded)
		exploded = TRUE
		explosion(target, 2, 4, 6)

/obj/item/rocket/piercing/Bump(atom/target)
	if(!throwing || pierced >= pierced_cap)
		return ..()
	var/datum/thrownthing/TT = SSthrowing.processing[src]
	if(!TT || TT.speed < 3)
		return ..()
	// walls don't use resistance_flags yet, walls don't use armor yet, can't do this part nicely
	if(iswallturf(target))
		var/turf/simulated/wall/W = target
		var/chance = (pierced_cap - pierced) / pierced_cap * 100 + (W.damage / W.damage_cap) * 100
		if(istype(W, /obj/structure/window/thin/reinforced))
			chance = chance * 0.5
		if(prob(chance))
			W.ChangeTurf(W.basetype)
			pierced++
			return FALSE
	else if(ismob(target) && prob((pierced_cap - pierced) / pierced_cap * 100 + 50))
		var/mob/M = target
		M.gib()
		pierced += 0.75
		return FALSE
	else if(!(target.resistance_flags & INDESTRUCTIBLE) && prob((pierced_cap - pierced) / pierced_cap * 100 + 50))
		qdel(target)
		pierced += 0.5
		return FALSE

	return ..()

/* Fire */
// todo, fire not work in space, also need to add fire_act

