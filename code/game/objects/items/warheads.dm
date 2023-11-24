/obj/item/clothing/glasses/warhead_monitor
	name = "warhead observation glasses"
	desc = "Allows you to watch warheads and adjust accuracy."
	icon_state = "healthhudnight"
	off_state = "healthhudnight"
	item_state = "glasses"
	toggleable = TRUE
	
	var/obj/item/warhead/target

	item_action_types = list(/datum/action/item_action/hands_free/toggle_goggles)

/obj/item/clothing/glasses/warhead_monitor/attack_self(mob/living/user)
	if(!target)
		to_chat(usr, "<span class='notice'>No warheads tuned to the glasses! Use multitool on warhead first.</span>")
		return

	if(user.client.eye == target) // reset_view
		user.client.eye = user
		user.client.perspective = MOB_PERSPECTIVE
		user.force_remote_viewing = FALSE
	else
		user.client.eye = target
		user.client.perspective = EYE_PERSPECTIVE
		user.force_remote_viewing = TRUE

/datum/action/item_action/hands_free/toggle_pda_light/Activate()
	var/obj/item/device/pda/P = target
	P.toggle_light()

/obj/item/warhead
	name = "warhead"
	desc = "Compatible with standard pneumatic systems."
	icon = 'icons/obj/warheads.dmi'
	icon_state = "warhead"

	throwforce = 20

	density = TRUE
	w_class = SIZE_LARGE

	var/accident_prob = 5

	var/triggered = TRUE // for VV

	// human throw parameters - can't throw it far
	throw_speed = 2
	throw_range = 1

	// disposal outlet aka launch platform throw parameters
	var/launch_speed = 3
	var/launch_angle = 0

/obj/item/warhead/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(triggered && (throwingdatum.speed >= 3 || prob(accident_prob*throwingdatum.speed)))
		trigger(hit_atom)
		QDEL_NULL(src)
	else
		return ..()

/obj/item/warhead/proc/trigger(atom/target)
	explosion(target, 2, 4, 6)

/obj/item/warhead/Destroy()
	trigger(get_turf(loc))

	return ..()

/obj/item/warhead/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			qdel(src)
		if(EXPLODE_HEAVY)
			if(prob(40+accident_prob*2))
				qdel(src)
		if(EXPLODE_LIGHT)
			if(prob(accident_prob*2))
				qdel(src)

/obj/item/warhead/attackby(obj/item/C, mob/user)
	if(ispulsing(C))
		var/useroption = tgui_alert(user, "Choise option", "Options:", list("Tune to Observation Glasses", "Change angle", "Cancel"))

		if(useroption == "Tune to Observation Glasses")
			var/mob/living/carbon/human/H = user
			if(istype(H) && H.glasses && istype(H.glasses, /obj/item/clothing/glasses/warhead_monitor))
				var/obj/item/clothing/glasses/warhead_monitor/WM = H.glasses
				WM.target = src
				to_chat(usr, "<span class='notice'>You have successfully tuned \the [WM] to \the [src]</span>")
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

			launch_angle = floor(clamp(new_angle, -45, 45))
			to_chat(usr, "<span class='notice'>You have set launch angle to [launch_angle] degrees.</span>")
			update_name()

		return TRUE
	return ..()

/obj/item/warhead/proc/update_name()
	name = "[initial(name)]"
	if(launch_angle)
		name += " ([launch_angle]deg)"

/* Explosive */

/obj/item/warhead/explosive
	name = "explosive warhead"
	icon_state = "warhead_red"

/obj/item/warhead/cheap
	name = "cheap explosive warhead"
	desc = "Compatible with standard pneumatic systems. This one looks suspicious."
	accident_prob = 15

/* EMP */

/obj/item/warhead/emp
	name = "EMP warhead"
	icon_state = "warhead_blue"

/obj/item/warhead/emp/trigger(atom/target)
	empulse(target, 5, 10)

/* Armor-piercing */

/obj/item/warhead/piercing
	name = "armor-piercing warhead"
	icon_state = "warhead_green"

	triggered = FALSE

	var/pierced = 0
	var/pierced_cap = 4

/obj/item/warhead/piercing/Bump(atom/target)
	if(!throwing || pierced >= pierced_cap)
		return ..()
	var/datum/thrownthing/TT = SSthrowing.processing[src]
	if(!TT || TT.speed < 3)
		return ..()
	// walls don't use resistance_flags yet, walls don't use armor yet, can't do this part nicely
	if(istype(target, /turf/simulated/wall))
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
		pierced += 0.5
		return FALSE
	else if(!(target.resistance_flags & INDESTRUCTIBLE) && prob((pierced_cap - pierced) / pierced_cap * 100 + 50))
		qdel(target)
		pierced += 0.25
		return FALSE

	return ..()

/* Fire */
// todo, fire not work in space

