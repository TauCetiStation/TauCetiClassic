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
	new type(arglist(arguments))
/**
  * Allows you to add an alternative sprite to the object in the form "appearance_key" = "image"
  *
*/
/datum/atom_hud/alternate_appearance
	var/appearance_key
	var/transfer_overlays = FALSE
	var/static/atom/alternate_obj

/datum/atom_hud/alternate_appearance/New(key)
	..()
	global.active_alternate_appearances += src
	appearance_key = key

/datum/atom_hud/alternate_appearance/Destroy()
	global.active_alternate_appearances -= src
	return ..()

/datum/atom_hud/alternate_appearance/proc/update_alt_appearance(mob/M)
	if(mobShouldSee(M))
		add_hud_to(M)

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
		theImage = image(alternate_obj.icon, target, alternate_obj.icon_state, alternate_obj.layer)
		//This is necessary so that sprites are not layered
		theImage.override = TRUE

	theImage.layer = target.layer

	if(transfer_overlays)
		theImage.copy_overlays(target)

	add_to_hud(target, theImage)

	if((options & AA_TARGET_SEE_APPEARANCE) && ismob(target))
		add_hud_to(target)

	if(add_ghost_version)
		var/image/ghost_image = image(icon = theImage.icon , icon_state = theImage.icon_state, loc = theImage.loc)
		ghost_image.override = FALSE
		ghost_image.alpha = 128
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

/datum/atom_hud/alternate_appearance/basic/observers/mobShouldSee(mob/M)
	return isobserver(M)

// Fake-image can see only the specified person
/datum/atom_hud/alternate_appearance/basic/one_person
	var/mob/seer
	add_ghost_version = TRUE

/datum/atom_hud/alternate_appearance/basic/one_person/New(key, image/I, mob/living/M)
	..(key, I, FALSE)
	seer = M
	add_hud_to(seer)

/datum/atom_hud/alternate_appearance/basic/one_person/mobShouldSee(mob/M)
	if(M == seer || isobserver(M))
		return TRUE
	return FALSE

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
