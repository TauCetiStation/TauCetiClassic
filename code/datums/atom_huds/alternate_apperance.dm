var/global/list/active_alternate_appearances = list()

/atom/proc/remove_alt_appearance(key)
	if(alternate_appearances)
		for(var/K in alternate_appearances)
			var/datum/atom_hud/alternate_appearance/AA = alternate_appearances[K]
			if(AA.appearance_key == key)
				AA.remove_from_hud(src)
				break

/atom/proc/add_alt_appearance(type, key, ...)
	if(!type || !key)
		return
	if(alternate_appearances && alternate_appearances[key])
		return
	var/list/arguments = args.Copy(2)
	return new type(arglist(arguments))

/atom/proc/update_all_alt_apperance()
	for(var/datum/atom_hud/alternate_appearance/AA as anything in global.active_alternate_appearances)
		AA.update_alt_appearance(src)

/atom/proc/update_alt_apperance_by(type)
	for(var/datum/atom_hud/alternate_appearance/AA as anything in global.active_alternate_appearances)
		if(istype(AA, type))
			AA.update_alt_appearance(src)

/**
  * Allows you to add an alternative sprite to the object in the form "appearance_key" = "image"
  *
*/
/datum/atom_hud/alternate_appearance
	var/appearance_key
	var/transfer_overlays = FALSE
	var/atom/alternate_obj

/datum/atom_hud/alternate_appearance/New(key)
	..()
	global.active_alternate_appearances += src
	appearance_key = key

/datum/atom_hud/alternate_appearance/Destroy()
	global.active_alternate_appearances -= src
	QDEL_NULL(alternate_obj)
	return ..()

/datum/atom_hud/alternate_appearance/proc/update_alt_appearance(mob/M)
	if(mobShouldSee(M))
		add_hud_to(M)
	else
		remove_hud_from(M)

/datum/atom_hud/alternate_appearance/proc/mobShouldSee(mob/M)
	return FALSE

/datum/atom_hud/alternate_appearance/add_to_hud(atom/A, image/I)
	. = ..()
	if(.)
		LAZYINITLIST(A.alternate_appearances)
		A.alternate_appearances[appearance_key] = src

/datum/atom_hud/alternate_appearance/remove_from_hud(atom/A)
	. = ..()
	if(.)
		LAZYREMOVE(A.alternate_appearances, appearance_key)

/datum/atom_hud/alternate_appearance/proc/copy_overlays(atom/other, cut_old)
	return

//an alternate appearance that attaches a single image to a single atom
/datum/atom_hud/alternate_appearance/basic
	var/atom/target
	var/image/theImage
	var/add_ghost_version = FALSE
	var/ghost_appearance

/**
  * If you have one sprite superimposed on the second, then in image/I set `I.override = TRUE`
  * You can choose to send an image or an entire object type. For items that can be picked up, it is better to pass the type.
  * image/I OR alternate_type AND loc you must pass
  * Arguments:
  * * key - name of the associative array in the form "key" = "image"
  * * image/I - not an important argument, image of alternate apperance
  * * alternate_type - not an important argument if you pass another atom here, alternate apperance will intercept examine.
  * * loc - not an important argument if you pass another image here
  * * options - not an important argument, type of transfer overlays
  *
*/
/datum/atom_hud/alternate_appearance/basic/New(key, image/I, alternate_type, loc, options = AA_TARGET_SEE_APPEARANCE)
	..()
	transfer_overlays = options & AA_MATCH_TARGET_OVERLAYS

	if(!alternate_obj && alternate_type)
		alternate_obj = new alternate_type

	hud_icons = list(appearance_key)

	if(I)
		theImage = I
		target = I.loc
	else
		target = loc
		update_image()

	theImage.layer = target.layer
	theImage.plane = target.plane
	theImage.appearance_flags = target.appearance_flags

	if(transfer_overlays)
		theImage.copy_overlays(target)

	add_to_hud(target, theImage)

	if((options & AA_TARGET_SEE_APPEARANCE) && ismob(target))
		add_hud_to(target)

	if(add_ghost_version)
		var/image/ghost_image = image(icon = theImage.icon , icon_state = theImage.icon_state, loc = theImage.loc)
		ghost_image.override = FALSE
		ghost_image.alpha = 128
		ghost_image.pixel_x = theImage.pixel_x
		ghost_image.pixel_y = theImage.pixel_y
		ghost_image.color = theImage.color
		ghost_image.plane = theImage.plane
		ghost_image.transform = theImage.transform
		ghost_appearance = new /datum/atom_hud/alternate_appearance/basic/observers(key + "_observer", ghost_image, NONE)

/datum/atom_hud/alternate_appearance/basic/Destroy()
	. = ..()
	if(ghost_appearance)
		QDEL_NULL(ghost_appearance)

/datum/atom_hud/alternate_appearance/basic/add_to_hud(atom/A)
	LAZYINITLIST(A.hud_list)
	A.hud_list[appearance_key] = theImage
	. = ..()

/datum/atom_hud/alternate_appearance/basic/remove_from_hud(atom/A)
	. = ..()
	A.hud_list -= appearance_key
	if(. && !QDELETED(src))
		qdel(src)

/datum/atom_hud/alternate_appearance/basic/copy_overlays(atom/other, cut_old)
		theImage.copy_overlays(other, cut_old)

/datum/atom_hud/alternate_appearance/basic/proc/update_image()
	if(!alternate_obj)
		return

	qdel(theImage)
	theImage = image(alternate_obj.icon, target, alternate_obj.icon_state, alternate_obj.layer)
	//This is necessary so that sprites are not layered
	theImage.override = TRUE
	theImage.pixel_x = alternate_obj.pixel_x
	theImage.pixel_y = alternate_obj.pixel_y

/datum/atom_hud/alternate_appearance/basic/proc/set_image_layering(_plane, _layer)
	if(!isnull(_plane))
		theImage.plane = _plane
	if(!isnull(_layer))
		theImage.layer = _layer

// Fake-image can see everyone
/datum/atom_hud/alternate_appearance/basic/everyone
	add_ghost_version = TRUE

/datum/atom_hud/alternate_appearance/basic/everyone/New()
	..()
	for(var/mob in global.mob_list)
		if(mobShouldSee(mob))
			add_hud_to(mob)

/datum/atom_hud/alternate_appearance/basic/everyone/mobShouldSee(mob/M)
	return !isobserver(M)

// Fake-image can see only silicon
/datum/atom_hud/alternate_appearance/basic/silicons

/datum/atom_hud/alternate_appearance/basic/silicons/New()
	..()
	for(var/mob in global.silicon_list)
		if(mobShouldSee(mob))
			add_hud_to(mob)

/datum/atom_hud/alternate_appearance/basic/silicons/mobShouldSee(mob/M)
	if(issilicon(M))
		return TRUE
	return FALSE

// Fake-image can see only observers
/datum/atom_hud/alternate_appearance/basic/observers
	add_ghost_version = FALSE //just in case, to prevent infinite loops

/datum/atom_hud/alternate_appearance/basic/observers/New()
	..()
	for(var/mob in global.dead_mob_list)
		if(mobShouldSee(mob))
			add_hud_to(mob)

/datum/atom_hud/alternate_appearance/basic/observers/Destroy()
	var/datum/atom_hud/alternate_appearance/AA = target.alternate_appearances[appearance_key]
	if(AA)
		target.alternate_appearances[appearance_key] = null
		target.alternate_appearances -= appearance_key
	return ..()

/datum/atom_hud/alternate_appearance/basic/observers/mobShouldSee(mob/M)
	return isobserver(M)

// Fake-image can see only the specified person
/datum/atom_hud/alternate_appearance/basic/one_person
	var/mob/seer
	add_ghost_version = TRUE

/datum/atom_hud/alternate_appearance/basic/one_person/New(key, image/I, mob/living/M, alternate_type, loc)
	..(key, I, alternate_type, loc)
	seer = M
	add_hud_to(seer)

/datum/atom_hud/alternate_appearance/basic/one_person/mobShouldSee(mob/M)
	if(M == seer)
		return TRUE
	return FALSE

/datum/atom_hud/alternate_appearance/basic/group
	var/list/seers
	add_ghost_version = TRUE

/datum/atom_hud/alternate_appearance/basic/group/New(key, image/I, mob_or_mobs)
	..(key, I, FALSE)
	var/list/mobs = islist(mob_or_mobs) ? mob_or_mobs : list(mob_or_mobs)
	seers = mobs
	for(var/mob/M in seers)
		add_hud_to(M)

/datum/atom_hud/alternate_appearance/basic/group/mobShouldSee(mob/M)
	if(M in seers)
		return TRUE
	return FALSE

// Fake-image can see only the specified faction
/datum/atom_hud/alternate_appearance/basic/faction
	var/datum/faction2check
	add_ghost_version = TRUE

/datum/atom_hud/alternate_appearance/basic/faction/New(key, image/I, faction)
	..(key, I, FALSE)
	if(SSticker)
		faction2check = faction
		var/datum/faction/F = find_faction_by_type(faction2check)
		if(!F)
			return // in case if someone spawned faction-related stuff with hud, but we don't have faction in current round
		for(var/datum/role/role in F.members)
			if(role.antag.current)
				add_hud_to(role.antag.current)

/datum/atom_hud/alternate_appearance/basic/faction/mobShouldSee(mob/M)
	if(!SSticker) //We can't check it anyway without it
		return FALSE
	var/datum/faction/F = find_faction_by_type(faction2check)
	if(!F)
		return FALSE
	if(M in F.members)
		return TRUE
	return FALSE

/datum/atom_hud/alternate_appearance/basic/exclude_ckeys
	// Dictionary of form list(ckey = TRUE) for all who shouldn't see this appearance.
	var/list/ckeys

	add_ghost_version = FALSE

/datum/atom_hud/alternate_appearance/basic/exclude_ckeys/New(key, image/I, ckeys)
	..(key, I, FALSE)
	src.ckeys = ckeys
	for(var/mob in global.player_list)
		if(mobShouldSee(mob))
			add_hud_to(mob)

/datum/atom_hud/alternate_appearance/basic/exclude_ckeys/mobShouldSee(mob/M)
	return !ckeys || !ckeys[M.ckey]

// Fake-image can see only mime
/datum/atom_hud/alternate_appearance/basic/mime

/datum/atom_hud/alternate_appearance/basic/mime/New()
	..()
	for(var/mob in global.player_list)
		if(mobShouldSee(mob))
			add_hud_to(mob)

/datum/atom_hud/alternate_appearance/basic/mime/mobShouldSee(mob/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.mind && H.mind.assigned_role == "Mime")
			return TRUE
	return FALSE

// Fake-image can see only holy_roled
/datum/atom_hud/alternate_appearance/basic/holy_role
	add_ghost_version = TRUE

/datum/atom_hud/alternate_appearance/basic/holy_role/New()
	..()
	for(var/mob/living/carbon/human/H in global.player_list)
		if(mobShouldSee(H))
			add_hud_to(H)

/datum/atom_hud/alternate_appearance/basic/holy_role/mobShouldSee(mob/living/carbon/human/H)
	if(H.mind && H.mind.holy_role)
		return TRUE
	return FALSE

// Fake-image can see members of one religion
/datum/atom_hud/alternate_appearance/basic/my_religion
	add_ghost_version = TRUE
	var/datum/religion/religion

/datum/atom_hud/alternate_appearance/basic/my_religion/New(key, image/I, loc, datum/religion/R, alternate_type)
	..(key, I, alternate_type, loc)
	religion = R
	for(var/mob/M in global.player_list)
		if(mobShouldSee(M))
			add_hud_to(M)

/datum/atom_hud/alternate_appearance/basic/my_religion/Destroy()
	religion = null
	return ..()

/datum/atom_hud/alternate_appearance/basic/my_religion/mobShouldSee(mob/M)
	if(religion.is_member(M))
		return TRUE
	return FALSE

/datum/atom_hud/alternate_appearance/basic/trait
	var/list/traits

/datum/atom_hud/alternate_appearance/basic/trait/New(key, image/I, list/_traits)
	..(key, I, FALSE)
	traits = _traits
	for(var/mob/M as anything in global.player_list)
		if(mobShouldSee(M))
			add_hud_to(M)

/datum/atom_hud/alternate_appearance/basic/trait/mobShouldSee(mob/living/carbon/human/H)
	for(var/trait in traits)
		if(!HAS_TRAIT(H, trait))
			return FALSE
	return TRUE

/datum/atom_hud/alternate_appearance/basic/see_ghosts

/datum/atom_hud/alternate_appearance/basic/see_ghosts/New()
	..()
	RegisterSignal(target, COMSIG_MOVABLE_ORBIT_BEGIN, PROC_REF(remove_hud))
	RegisterSignal(target, COMSIG_MOVABLE_ORBIT_STOP, PROC_REF(add_hud))
	for(var/mob/M as anything in global.player_list)
		if(mobShouldSee(M))
			add_hud_to(M)

/datum/atom_hud/alternate_appearance/basic/see_ghosts/mobShouldSee(mob/M)
	if(HAS_TRAIT(M, TRAIT_SEE_GHOSTS))
		return TRUE
	return FALSE

/datum/atom_hud/alternate_appearance/basic/see_ghosts/proc/add_hud(atom/movable/ghost, atom/target)
	for(var/mob/M as anything in global.player_list)
		if(mobShouldSee(M))
			add_hud_to(M)

/datum/atom_hud/alternate_appearance/basic/see_ghosts/proc/remove_hud(atom/movable/ghost, atom/target)
	for(var/v in hudusers)
		remove_hud_from(v)
