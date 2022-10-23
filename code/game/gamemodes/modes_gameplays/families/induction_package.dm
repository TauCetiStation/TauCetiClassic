/obj/item/gang_induction_package
	name = "family signup package"
	icon = 'icons/obj/gang/signup_points.dmi'
	icon_state = "signup_book"
	/// The typepath of the gang antagonist datum that the person who uses the package should have added to them -- remember that the distinction between e.g. Ballas and Grove Street is on the antag datum level, not the team datum level.
	var/gang_to_use
	/// The team datum that the person who uses this package should be added to.
	var/datum/faction/gang/team_to_use

/obj/item/gang_induction_package/atom_init(mapload, ...)
	. = ..()
	// prevent spawn of kits
	QDEL_IN(src, 20 SECONDS)

/obj/item/gang_induction_package/Destroy()
	new /obj/effect/temp_visual/pulse(get_turf(src))
	return ..()

/obj/item/gang_induction_package/attack_self(mob/living/user)
	..()
	if(user.ismindprotect())
		to_chat(user, "You attended a seminar on not signing up for a gang and are not interested.")
		return
	if(isanycop(user))
		to_chat(user, "As a NanoTrasen officer, you can't join this family. However, you pretend to accept it to keep your cover up.")
		for(var/threads in team_to_use.free_clothes)
			new threads(get_turf(src))
		qdel(src)
		return
	var/datum/role/gangster/is_gangster = isgangsterlead(user)
	if(is_gangster)
		if(is_gangster.faction == team_to_use)
			to_chat(user, "You started your family. You don't need to join it.")
			return
		to_chat(user, "You started your family. You can't turn your back on it now.")
		return
	attempt_join_gang(user)

/// Adds the user to the family that this package corresponds to, dispenses the free_clothes of that family, and adds them to the handler if it exists.
/obj/item/gang_induction_package/proc/add_to_gang(mob/living/user)
	add_faction_member(team_to_use, user, TRUE, TRUE)
	for(var/threads in team_to_use.free_clothes)
		new threads(get_turf(user))
	team_to_use.adjust_points(3)

/// Checks if the user is trying to use the package of the family they are in, and if not, adds them to the family, with some differing processing depending on whether the user is already a family member.
/obj/item/gang_induction_package/proc/attempt_join_gang(mob/living/user)
	if(user?.mind)
		var/datum/role/gangster/is_gangster = user.mind.GetRole(GANGSTER)
		if(is_gangster)
			if(is_gangster.faction == team_to_use || !istype(is_gangster.faction, /datum/faction/gang))
				return
			var/datum/faction/gang/gang = is_gangster.faction
			gang.adjust_points(-3)
			is_gangster.Drop()
		add_to_gang(user)
		qdel(src)
