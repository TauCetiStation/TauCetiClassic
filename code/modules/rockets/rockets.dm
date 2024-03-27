#define ROCKET_TRIGGER_SPEED 3

/obj/item/rocket
	name = "rocket"
	desc = "Compatible with standard pneumatic systems."
	icon = 'icons/obj/rockets.dmi'
	icon_state = "rocket"

	//max_integrity = 100
	//resistance_flags = CAN_BE_HIT
	//armor = list(MELEE = 100, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 30, FIRE = 50)

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
	var/launch_speed = ROCKET_TRIGGER_SPEED
	var/launch_angle = 0
	var/launch_distance = 200 // max distance when rocket will explode even if not bumped

	var/list/obj/item/clothing/glasses/rocket_observation/tuned_glasses = list()

/obj/item/rocket/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	// check for speed threshhold only if it's not throwed by a mob (fuck user momentum), else do prob for accident
	// todo: make this treshhold more readable and allow atoms be thrower so we can check for disposal here and not some magic number
	if(triggered && ((!throwingdatum.thrower && throwingdatum.speed >= ROCKET_TRIGGER_SPEED) || prob(accident_prob*throwingdatum.speed)))
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

/obj/item/rocket/Moved()
	// another thrownthing thing - currently it ignores maxrange for no-gravity movement
	// so for launch_distance to work correctly in space we need to check it ourselves
	. = ..()
	var/datum/thrownthing/TT = SSthrowing.processing[src]
	if(TT && TT.speed >= ROCKET_TRIGGER_SPEED && TT.dist_travelled > launch_distance)
		trigger(get_turf(loc))

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
		var/list/choices = list("Tune to Glasses", "Change Angle", "Change Distance")
		var/useroption = tgui_input_list(user, "Choise option", "Options", choices)

		if(useroption == "Tune to Glasses")
			var/mob/living/carbon/human/H = user
			if(istype(H) && H.glasses && istype(H.glasses, /obj/item/clothing/glasses/rocket_observation))
				var/obj/item/clothing/glasses/rocket_observation/WO = H.glasses
				WO.sync_to_rocket(src)
				to_chat(usr, "<span class='notice'>You have successfully tuned \the [WO] to \the [src]</span>")
			else
				to_chat(usr, "<span class='warning'>You don't have observation glasses!</span>")
				return

		else if(useroption == "Change Angle")
			var/new_angle = input("Enter new angle between -45 and 45", "Angle Setup", launch_angle) as num|null
			if(!isnum(new_angle))
				return
			if(user.incapacitated() || !Adjacent(user))
				to_chat(usr, "<span class='warning'>You can't do it!</span>")
				return

			launch_angle = clamp(round(new_angle), -45, 45)
			to_chat(usr, "<span class='notice'>You have set launch angle to [launch_angle] degrees.</span>")
			update_name()

		else if(useroption == "Change Distance")
			var/new_distance = input("Enter new maximum distance between 10 and 200", "Distance Setup", launch_distance) as num|null
			if(!isnum(new_distance))
				return
			if(user.incapacitated() || !Adjacent(user))
				to_chat(usr, "<span class='warning'>You can't do it!</span>")
				return

			launch_distance = clamp(round(new_distance), 10, 200)
			to_chat(usr, "<span class='notice'>You have set max distance to [launch_angle].</span>")
			update_name()

		return TRUE
	return ..()

/obj/item/rocket/proc/update_name()
	name = "[initial(name)]"
	if(launch_angle)
		name += " ([launch_angle]deg)"
	if(launch_distance)
		name += " ([launch_distance]dist)"

/* Explosive */

/obj/item/rocket/cheap
	name = "cheap explosive rocket"
	desc = "Compatible with standard pneumatic systems. This one looks suspicious."
	//armor = list(MELEE = 95, BULLET = 25, LASER = 25, ENERGY = 25, BOMB = 15, FIRE = 25)
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
	if(!TT || TT.speed < ROCKET_TRIGGER_SPEED)
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

#undef ROCKET_TRIGGER_SPEED
